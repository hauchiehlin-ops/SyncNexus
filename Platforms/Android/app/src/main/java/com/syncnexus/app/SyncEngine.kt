package com.syncnexus.app

import android.content.Context
import android.net.Uri
import android.webkit.MimeTypeMap
import androidx.documentfile.provider.DocumentFile
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.security.MessageDigest

data class ScannedDocFile(
    val relativePath: String,
    val name: String,
    val size: Long,
    val lastModified: Long,
    val sha256: String,
    val docFile: DocumentFile
) {
    val info get() = FileInfo(sha256, size, lastModified)
}

data class SyncLogItem(
    val timestamp: String,
    val operation: String,
    val filePath: String,
    val isSuccess: Boolean,
    val detail: String = ""
)

data class SyncExecutionReport(
    val trackedFiles: Int,
    val syncedTransfers: Int,
    val conflicts: Int,
    val logs: List<SyncLogItem>,
    val pendingConfirmation: PendingConfirmation? = null
)

data class SyncGroup(
    val id: String,
    val name: String,
    val icon: String = "folder",
    val createdAt: Long = System.currentTimeMillis()
)

/**
 * Android core two-way sync engine over SAF folders.
 * Decisions come from [SyncPlanner] (three-way, against the last agreed state); this class does the file work:
 * scanning with SHA-256, atomic-ish copies, archiving what is replaced, conflict copies, verification.
 * Files are only ever added or updated here; nothing is deleted by a sync.
 */
class SyncEngine(
    private val context: Context,
    private val safAdapter: SAFStorageAdapter
) {
    private val stores = HashMap<String, GroupStateStore>()
    private val opLock = Any()          // one mutating operation at a time (sync, resolve, restore, verify)

    @Synchronized fun state(groupId: String): GroupStateStore = stores.getOrPut(groupId) { GroupStateStore(context, groupId) }

    /** Forgets everything remembered about a deleted group. */
    @Synchronized fun forget(groupId: String) { stores.remove(groupId)?.deleteAll() ?: GroupStateStore(context, groupId).deleteAll() }

    private fun isIgnored(
        name: String,
        relPath: String,
        presets: Set<ExcludePreset> = AndroidIgnoreRules.defaultPresets,
        customPatterns: List<String> = emptyList()
    ): Boolean = AndroidIgnoreRules.isIgnored(name, relPath, presets, customPatterns)

    private fun str(id: Int, vararg args: Any): String = LocaleManager.wrap(context).getString(id, *args)
    private fun now() = System.currentTimeMillis()
    private fun clock() = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date())

    /** True when the battery is low and not charging (background work then waits). */
    fun isLowBattery(): Boolean {
        return try {
            val ifilter = android.content.IntentFilter(android.content.Intent.ACTION_BATTERY_CHANGED)
            val batteryStatus = context.registerReceiver(null, ifilter) ?: return false
            val status = batteryStatus.getIntExtra(android.os.BatteryManager.EXTRA_STATUS, -1)
            val isCharging = status == android.os.BatteryManager.BATTERY_STATUS_CHARGING ||
                    status == android.os.BatteryManager.BATTERY_STATUS_FULL
            val level = batteryStatus.getIntExtra(android.os.BatteryManager.EXTRA_LEVEL, -1)
            val scale = batteryStatus.getIntExtra(android.os.BatteryManager.EXTRA_SCALE, -1)
            !isCharging && level * 100 / scale.toFloat() <= 20f
        } catch (_: Exception) { false }
    }

    // ---------------------------------------------------------------- scanning

    /**
     * Walks a folder tree. A file whose size and modification time match what was recorded for this endpoint keeps its
     * recorded hash instead of being read again (battery and time), unless [force] asks for a full re-read.
     */
    fun scanEndpoint(
        endpoint: AndroidEndpoint,
        baseline: Map<String, Baseline>,
        force: Boolean,
        presets: Set<ExcludePreset> = AndroidIgnoreRules.defaultPresets,
        customPatterns: List<String> = emptyList()
    ): Map<String, ScannedDocFile> {
        val root = safAdapter.getDocumentTree(Uri.parse(endpoint.uriString)) ?: return emptyMap()
        val result = mutableMapOf<String, ScannedDocFile>()

        fun walk(dir: DocumentFile, prefix: String) {
            for (child in dir.listFiles()) {
                val name = child.name ?: continue
                val rel = if (prefix.isEmpty()) name else "$prefix/$name"
                if (isIgnored(name, rel, presets, customPatterns)) continue
                if (child.isDirectory) {
                    walk(child, rel)
                } else if (child.isFile) {
                    val size = child.length(); val mtime = child.lastModified()
                    val rec = baseline[rel]
                    val hash = if (!force && rec != null && rec.eps[endpoint.id] == (size to mtime)) rec.hash
                               else computeSha256(child) ?: continue
                    result[rel] = ScannedDocFile(rel, name, size, mtime, hash, child)
                }
            }
        }
        walk(root, "")
        return result
    }

    private fun computeSha256(file: DocumentFile): String? = try {
        safAdapter.openInputStream(file.uri)?.use { input ->
            val md = MessageDigest.getInstance("SHA-256")
            val buffer = ByteArray(1024 * 1024)
            var read: Int
            while (input.read(buffer).also { read = it } != -1) md.update(buffer, 0, read)
            md.digest().joinToString("") { "%02x".format(it) }
        }
    } catch (_: Exception) { null }

    private fun scanAll(
        groupId: String,
        endpoints: List<AndroidEndpoint>,
        force: Boolean,
        presets: Set<ExcludePreset> = AndroidIgnoreRules.defaultPresets,
        customPatterns: List<String> = emptyList()
    ): Map<String, Map<String, ScannedDocFile>> {
        val base = state(groupId).baselineSnapshot()
        return endpoints.associate { it.id to scanEndpoint(it, base, force, presets, customPatterns) }
    }

    private fun infoMap(scan: Map<String, Map<String, ScannedDocFile>>) = scan.mapValues { (_, m) -> m.mapValues { it.value.info } }

    // ---------------------------------------------------------------- preview

    /** What a sync would do right now; changes nothing. */
    fun preview(
        groupId: String,
        endpoints: List<AndroidEndpoint>,
        presets: Set<ExcludePreset> = AndroidIgnoreRules.defaultPresets,
        customPatterns: List<String> = emptyList(),
        conflictPolicy: ConflictPolicy = ConflictPolicy.KEEP_BOTH
    ): List<PlanItem> {
        if (endpoints.size < 2) return emptyList()
        val scan = scanAll(groupId, endpoints, force = false, presets = presets, customPatterns = customPatterns)
        return SyncPlanner.plan(endpoints.map { it.id }, infoMap(scan), state(groupId).baselineSnapshot(), conflictPolicy)
    }

    // ---------------------------------------------------------------- sync

    fun sync(
        groupId: String,
        endpoints: List<AndroidEndpoint>,
        confirmed: Boolean = false,
        presets: Set<ExcludePreset> = AndroidIgnoreRules.defaultPresets,
        customPatterns: List<String> = emptyList(),
        conflictPolicy: ConflictPolicy = ConflictPolicy.KEEP_BOTH
    ): SyncExecutionReport = synchronized(opLock) {
        if (endpoints.size < 2) return SyncExecutionReport(0, 0, 0, emptyList())
        val store = state(groupId)
        store.purgeVersions(store.versionsRetentionDays, VERSION_MAX_BYTES, now())

        val logs = mutableListOf<SyncLogItem>()
        val scan = scanAll(groupId, endpoints, force = false, presets = presets, customPatterns = customPatterns)
        val snaps = infoMap(scan)
        val plan = SyncPlanner.plan(endpoints.map { it.id }, snaps, store.baselineSnapshot(), conflictPolicy)
        val byId = endpoints.associateBy { it.id }

        // DeletionGuard safety check on major overwrites / changes
        val overwritesCount = plan.count { it.overwrites || it.kind == PlanKind.CONFLICT }
        val totalTracked = store.baselineSnapshot().size
        val guard = DeletionGuard()
        if (guard.requiresConfirmation(overwritesCount, totalTracked) && !confirmed) {
            val reason = "預計變更/覆蓋 $overwritesCount 個檔案（共追蹤 $totalTracked 個），超過安全門檻，請確認後再執行"
            val preview = plan.take(50).map { "[${byId[it.source]?.displayName ?: it.source} -> ${byId[it.target]?.displayName ?: it.target}] ${it.path}" }
            val pending = PendingConfirmation(groupId, reason, preview, plan.size, thresholdLimit = guard.maxAbsolute)
            logs += SyncLogItem(clock(), "安全防護", reason, false)
            return SyncExecutionReport(totalTracked, 0, 0, logs, pending)
        }

        var transfers = 0
        var newConflicts = 0
        val finalHash = HashMap<String, MutableMap<String, String>>()       // path -> endpoint -> hash after this run
        val finalStat = HashMap<String, MutableMap<String, Pair<Long, Long>>>()
        for ((ep, files) in snaps) for ((p, i) in files) {
            finalHash.getOrPut(p) { HashMap() }[ep] = i.hash
            finalStat.getOrPut(p) { HashMap() }[ep] = i.size to i.mtime
        }

        for (item in plan) {
            val src = scan[item.source]?.get(item.path) ?: continue
            val target = byId[item.target] ?: continue
            val existing = if (item.overwrites) findDoc(target, item.path) else null
            if (item.kind == PlanKind.CONFLICT && existing != null) {
                val kept = saveConflictCopy(groupId, target, item.path, existing)
                if (kept != null) {
                    newConflicts++
                    logs += SyncLogItem(clock(), str(R.string.log_conflict), "${target.displayName}: ${item.path}", true, kept)
                } else {
                    logs += SyncLogItem(clock(), str(R.string.log_failed), "${target.displayName}: ${item.path}", false, str(R.string.log_conflict_copy_failed))
                    continue   // never replace an edit that could not be kept
                }
            } else if (existing != null) {
                if (!archive(groupId, target, item.path, existing, "replaced")) {
                    logs += SyncLogItem(clock(), str(R.string.log_failed), "${target.displayName}: ${item.path}", false, str(R.string.log_archive_failed))
                    continue
                }
            }
            val dest = copyFileToEndpoint(src, target, item.path)
            if (dest != null) {
                transfers++
                finalHash.getOrPut(item.path) { HashMap() }[item.target] = item.hash
                finalStat.getOrPut(item.path) { HashMap() }[item.target] = dest.length() to dest.lastModified()
                logs += SyncLogItem(clock(), str(R.string.log_copy), "${byId[item.source]?.displayName} -> ${target.displayName}: ${item.path}", true)
            } else {
                logs += SyncLogItem(clock(), str(R.string.log_failed), "${target.displayName}: ${item.path}", false, str(R.string.log_write_failed))
            }
        }

        // remember files that now agree everywhere
        for ((path, hashes) in finalHash) {
            val distinct = hashes.values.toSet()
            if (hashes.size == endpoints.size && distinct.size == 1) {
                store.setBaseline(path, Baseline(distinct.first(), finalStat[path] ?: emptyMap()))
            }
        }
        store.persist()
        return SyncExecutionReport(finalHash.size, transfers, newConflicts, logs, null)
    }

    // ---------------------------------------------------------------- file helpers

    private fun findDoc(ep: AndroidEndpoint, relPath: String): DocumentFile? {
        var cur = safAdapter.getDocumentTree(Uri.parse(ep.uriString)) ?: return null
        for (part in relPath.split("/")) cur = cur.findFile(part) ?: return null
        return cur
    }

    private fun mimeFor(name: String): String =
        MimeTypeMap.getSingleton().getMimeTypeFromExtension(name.substringAfterLast('.', "").lowercase()) ?: "application/octet-stream"

    /** Creates (or reuses) the folder chain and the file, returning the destination document. */
    private fun ensureDoc(ep: AndroidEndpoint, relPath: String): DocumentFile? {
        var dir = safAdapter.getDocumentTree(Uri.parse(ep.uriString)) ?: return null
        val parts = relPath.split("/")
        for (i in 0 until parts.size - 1) dir = dir.findFile(parts[i]) ?: dir.createDirectory(parts[i]) ?: return null
        val name = parts.last()
        return dir.findFile(name) ?: dir.createFile(mimeFor(name), name)
    }

    private fun pump(input: InputStream, output: OutputStream) {
        input.use { i -> output.use { o ->
            val buffer = ByteArray(1024 * 1024)
            var n: Int
            while (i.read(buffer).also { n = it } != -1) o.write(buffer, 0, n)
            o.flush()
        } }
    }

    private fun copyFileToEndpoint(source: ScannedDocFile, targetEp: AndroidEndpoint, relPath: String): DocumentFile? = try {
        val dest = ensureDoc(targetEp, relPath)
        val input = safAdapter.openInputStream(source.docFile.uri)
        val output = dest?.let { safAdapter.openOutputStream(it.uri) }
        if (dest == null || input == null || output == null) { input?.close(); output?.close(); null }
        else { pump(input, output); dest }
    } catch (_: Exception) { null }

    /** Keeps a copy of [doc] in the version archive before it is replaced or discarded. */
    private fun archive(groupId: String, ep: AndroidEndpoint, relPath: String, doc: DocumentFile, reason: String): Boolean = try {
        val store = state(groupId)
        val name = "${now()}-${(Math.random() * 1_000_000).toInt()}.bin"
        val out = File(store.versionsDir, name)
        val input = safAdapter.openInputStream(doc.uri) ?: return false
        pump(input, out.outputStream())
        store.addVersion(ep.id, relPath, out.length(), reason, now(), name)
        true
    } catch (_: Exception) { false }

    /** Saves the endpoint's own edit next to the file as a conflict copy; returns the copy's name, or null on failure. */
    private fun saveConflictCopy(groupId: String, ep: AndroidEndpoint, relPath: String, doc: DocumentFile): String? = try {
        val dirPrefix = relPath.substringBeforeLast('/', "")
        val name = SyncPlanner.conflictName(relPath.substringAfterLast('/'), ep.id, java.util.Date())
        val copyPath = if (dirPrefix.isEmpty()) name else "$dirPrefix/$name"
        val dest = ensureDoc(ep, copyPath)
        val input = safAdapter.openInputStream(doc.uri)
        val output = dest?.let { safAdapter.openOutputStream(it.uri) }
        if (dest == null || input == null || output == null) { input?.close(); output?.close(); null }
        else {
            pump(input, output)
            state(groupId).addConflict(ep.id, relPath, copyPath, now())
            name
        }
    } catch (_: Exception) { null }

    // ---------------------------------------------------------------- conflicts

    /** keepMain: discard the conflict copy (archived). Otherwise the copy replaces the main file and then spreads. */
    fun resolveConflict(groupId: String, endpoints: List<AndroidEndpoint>, conflictId: Long, keepMain: Boolean): Boolean = synchronized(opLock) {
        val store = state(groupId)
        val c = store.openConflicts().firstOrNull { it.id == conflictId } ?: return false
        val ep = endpoints.firstOrNull { it.id == c.endpoint } ?: return false
        val copy = findDoc(ep, c.copyPath)
        if (copy == null) { store.closeConflict(c.id); return true }     // already dealt with in the file manager
        if (keepMain) {
            if (!archive(groupId, ep, c.path, copy, "conflict-copy")) return false
            copy.delete()
        } else {
            findDoc(ep, c.path)?.let { if (!archive(groupId, ep, c.path, it, "replaced")) return false }
            val dest = ensureDoc(ep, c.path) ?: return false
            val input = safAdapter.openInputStream(copy.uri) ?: return false
            val output = safAdapter.openOutputStream(dest.uri) ?: run { input.close(); return false }
            pump(input, output)
            copy.delete()
            store.dropBaselineEndpoint(c.path, ep.id)       // this endpoint's file is now a fresh edit that spreads on the next sync
        }
        store.closeConflict(c.id)
        return true
    }

    // ---------------------------------------------------------------- versions

    fun restoreVersion(groupId: String, endpoints: List<AndroidEndpoint>, versionId: Long): Boolean = synchronized(opLock) {
        val store = state(groupId)
        val v = store.versionList().firstOrNull { it.id == versionId } ?: return false
        val ep = endpoints.firstOrNull { it.id == v.endpoint } ?: return false
        val saved = File(store.versionsDir, v.file)
        if (!saved.exists()) return false
        findDoc(ep, v.path)?.let { if (!archive(groupId, ep, v.path, it, "replaced-by-restore")) return false }
        val dest = ensureDoc(ep, v.path) ?: return false
        val output = safAdapter.openOutputStream(dest.uri) ?: return false
        pump(saved.inputStream(), output)
        store.dropBaselineEndpoint(v.path, ep.id)           // the restored file counts as an edit and spreads on the next sync
        return true
    }

    fun deleteVersion(groupId: String, versionId: Long) = state(groupId).removeVersion(versionId)

    // ---------------------------------------------------------------- verification

    /** Re-reads every file and compares with what was recorded. Changes nothing but the verification history. */
    fun verify(groupId: String, endpoints: List<AndroidEndpoint>): VerifyRun = synchronized(opLock) {
        val started = now()
        val scan = scanAll(groupId, endpoints, force = true)
        val store = state(groupId)
        val issues = SyncPlanner.integrity(infoMap(scan), store.baselineSnapshot())
        val run = VerifyRun(started, scan.values.sumOf { it.size }, issues.size, now() - started)
        store.recordVerification(run, issues)
        return run
    }

    /** restore: put the good copy (from another endpoint) back, archiving the damaged one. Otherwise accept what is there now. */
    fun resolveIntegrity(groupId: String, endpoints: List<AndroidEndpoint>, issue: IntegrityIssue, restore: Boolean): Boolean = synchronized(opLock) {
        val store = state(groupId)
        val base = store.baselineOf(issue.path) ?: run { store.clearIntegrity(issue); return true }
        val ep = endpoints.firstOrNull { it.id == issue.endpoint } ?: return false
        if (restore) {
            val damaged = findDoc(ep, issue.path) ?: return false
            val good = endpoints.filter { it.id != ep.id }.mapNotNull { other ->
                findDoc(other, issue.path)?.takeIf { it.isFile && computeSha256(it) == base.hash }
            }.firstOrNull() ?: return false
            if (!archive(groupId, ep, issue.path, damaged, "damaged")) return false
            val input = safAdapter.openInputStream(good.uri) ?: return false
            val output = safAdapter.openOutputStream(damaged.uri) ?: run { input.close(); return false }
            pump(input, output)
            store.setBaseline(issue.path, base.copy(eps = base.eps + (ep.id to (damaged.length() to damaged.lastModified()))))
            store.persist()
        } else {
            store.dropBaselineEndpoint(issue.path, ep.id)   // seen as an edit on the next sync
        }
        store.clearIntegrity(issue)
        return true
    }

    companion object {
        const val VERSION_DAYS = 30
        const val VERSION_MAX_BYTES = 1L * 1024 * 1024 * 1024
    }
}
