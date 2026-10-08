package com.syncnexus.app

/** What a scan found for one file on one endpoint. */
data class FileInfo(val hash: String, val size: Long, val mtime: Long)

/** The state both sides agreed on the last time the file was aligned (hash, plus what each endpoint's file looked like). */
data class Baseline(val hash: String, val eps: Map<String, Pair<Long, Long>> = emptyMap())

enum class ConflictPolicy {
    KEEP_BOTH,
    NEWER_WINS
}

enum class PlanKind {
    /** Bring [PlanItem.target] up to the winning version (it was missing or older). */
    COPY,
    /** The target holds its own, different edit: keep it as a conflict copy, then bring it up to the winning version. */
    CONFLICT
}

data class PlanItem(
    val kind: PlanKind,
    val path: String,
    val source: String,
    val target: String,
    /** True when the target already has a file that will be replaced (it is archived first). */
    val overwrites: Boolean,
    val hash: String
)

data class IntegrityIssue(val endpoint: String, val path: String)

data class PendingConfirmation(
    val groupId: String,
    val reason: String,
    val preview: List<String>,
    val totalCount: Int,
    val thresholdLimit: Int = 25
) {
    val message: String get() = reason
}

data class DeletionGuard(
    val maxAbsolute: Int = 25,
    val maxFraction: Double = 0.25,
    val minTrackedForFraction: Int = 20
) {
    fun requiresConfirmation(plannedChanges: Int, totalTracked: Int): Boolean {
        if (plannedChanges <= 0) return false
        if (plannedChanges > maxAbsolute) return true
        if (totalTracked < minTrackedForFraction) return false
        return (plannedChanges.toDouble() / totalTracked.toDouble()) > maxFraction
    }
}

/**
 * Pure decision logic (no file access), so it can be unit-tested on the JVM.
 * Three-way comparison against the last agreed state: an edit on one side spreads, edits on several sides to
 * different content are a conflict. Deletions are never propagated (files are only ever added or updated).
 */
object SyncPlanner {

    fun plan(
        endpoints: List<String>,
        snapshots: Map<String, Map<String, FileInfo>>,
        baseline: Map<String, Baseline>,
        conflictPolicy: ConflictPolicy = ConflictPolicy.KEEP_BOTH
    ): List<PlanItem> {
        val paths = snapshots.values.flatMap { it.keys }.toSortedSet()
        val out = mutableListOf<PlanItem>()
        for (path in paths) {
            val holders = endpoints.mapNotNull { ep -> snapshots[ep]?.get(path)?.let { ep to it } }
            if (holders.isEmpty()) continue
            val baseHash = baseline[path]?.hash
            val changed = holders.filter { it.second.hash != baseHash }
            val changedHashes = changed.map { it.second.hash }.toSet()
            // winner: the only changed version; with several, the newest one (ties: first endpoint in the list)
            val pool = if (changed.isEmpty()) holders else changed
            val winner = pool.maxWithOrNull(compareBy({ it.second.mtime }, { -endpoints.indexOf(it.first) }))!!
            val winnerHash = winner.second.hash
            val conflict = changedHashes.size >= 2
            for (ep in endpoints) {
                if (ep == winner.first) continue
                val has = snapshots[ep]?.get(path)
                if (has != null && has.hash == winnerHash) continue

                var keepsOwnEdit = false
                if (conflict && has != null && has.hash != baseHash) {
                    if (conflictPolicy == ConflictPolicy.NEWER_WINS) {
                        val diff = winner.second.mtime - has.mtime
                        // If winner is distinctly newer (> 2 seconds), adopt newer edit; otherwise keep both
                        keepsOwnEdit = diff <= 2000L
                    } else {
                        keepsOwnEdit = true
                    }
                }

                out += PlanItem(
                    kind = if (keepsOwnEdit) PlanKind.CONFLICT else PlanKind.COPY,
                    path = path, source = winner.first, target = ep,
                    overwrites = has != null, hash = winnerHash
                )
            }
        }
        return out
    }

    /**
     * Deep verification: a file whose size and modification time still match what was recorded but whose content hash
     * does not is a sign of silent corruption (a normal edit changes the modification time).
     */
    fun integrity(
        snapshots: Map<String, Map<String, FileInfo>>,
        baseline: Map<String, Baseline>
    ): List<IntegrityIssue> {
        val out = mutableListOf<IntegrityIssue>()
        for ((ep, files) in snapshots) for ((path, info) in files) {
            val b = baseline[path] ?: continue
            val rec = b.eps[ep] ?: continue
            if (rec.first == info.size && rec.second == info.mtime && b.hash != info.hash) out += IntegrityIssue(ep, path)
        }
        return out.sortedWith(compareBy({ it.path }, { it.endpoint }))
    }

    /** `report.docx` -> `report (conflict Disk 2026-10-02 14-30).docx` (same naming as the Mac and Windows apps). */
    fun conflictName(original: String, endpoint: String, time: java.util.Date): String {
        val stamp = java.text.SimpleDateFormat("yyyy-MM-dd HH-mm", java.util.Locale.US).format(time)
        val safe = endpoint.map { if (it in "<>:\"/\\|?*") '_' else it }.joinToString("")
        val dot = original.lastIndexOf('.')
        val hasExt = dot > 0 && dot < original.length - 1
        val stem = if (hasExt) original.substring(0, dot) else original
        val suffix = " (conflict $safe $stamp)"
        return if (hasExt) stem + suffix + original.substring(dot) else stem + suffix
    }

    private val conflictRegex = Regex(""" \(conflict .+ \d{4}-\d{2}-\d{2} \d{2}-\d{2}\)(\.[^./]*)?$""")
    fun isConflictName(name: String) = conflictRegex.containsMatchIn(name)
}
