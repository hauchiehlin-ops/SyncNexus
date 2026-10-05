package com.syncnexus.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

data class ConflictRecord(val id: Long, val endpoint: String, val path: String, val copyPath: String, val time: Long)
data class VersionItem(val id: Long, val endpoint: String, val path: String, val time: Long, val size: Long, val reason: String, val file: String)
data class VerifyRun(val time: Long, val checked: Int, val issues: Int, val durationMs: Long)

/**
 * Everything the engine remembers about one sync group, in the app's private storage:
 * the last agreed state of every file (baseline), open conflicts, archived versions, and verification history.
 * Small JSON file, rewritten after every change; all access is synchronized.
 */
class GroupStateStore(context: Context, val groupId: String) {
    private val dir = File(context.filesDir, "syncnexus/$groupId").apply { mkdirs() }
    val versionsDir = File(dir, "versions").apply { mkdirs() }
    private val file = File(dir, "state.json")

    private val baseline = LinkedHashMap<String, Baseline>()
    private val conflicts = mutableListOf<ConflictRecord>()
    private val versions = mutableListOf<VersionItem>()
    private val runs = mutableListOf<VerifyRun>()
    private val integrity = mutableListOf<IntegrityIssue>()
    private var nextId = 1L

    init { load() }

    // ---- reads (copies, safe to hand to the UI) ----
    @Synchronized fun baselineSnapshot(): Map<String, Baseline> = HashMap(baseline)
    @Synchronized fun baselineOf(path: String): Baseline? = baseline[path]
    @Synchronized fun openConflicts(): List<ConflictRecord> = conflicts.sortedByDescending { it.time }
    @Synchronized fun versionList(): List<VersionItem> = versions.sortedByDescending { it.time }
    @Synchronized fun verifyRuns(): List<VerifyRun> = runs.sortedByDescending { it.time }
    @Synchronized fun integrityIssues(): List<IntegrityIssue> = integrity.toList()

    // ---- writes ----
    @Synchronized fun setBaseline(path: String, b: Baseline) { baseline[path] = b }
    @Synchronized fun dropBaselineEndpoint(path: String, endpoint: String) {
        val b = baseline[path] ?: return
        baseline[path] = b.copy(eps = b.eps - endpoint)
        save()
    }

    @Synchronized fun addConflict(endpoint: String, path: String, copyPath: String, time: Long) {
        conflicts.removeAll { it.endpoint == endpoint && it.copyPath == copyPath }
        conflicts += ConflictRecord(nextId++, endpoint, path, copyPath, time)
    }
    @Synchronized fun closeConflict(id: Long) { conflicts.removeAll { it.id == id }; save() }

    @Synchronized fun addVersion(endpoint: String, path: String, size: Long, reason: String, time: Long, fileName: String) {
        versions += VersionItem(nextId++, endpoint, path, time, size, reason, fileName)
    }
    @Synchronized fun removeVersion(id: Long) {
        versions.firstOrNull { it.id == id }?.let { File(versionsDir, it.file).delete() }
        versions.removeAll { it.id == id }
        save()
    }

    /** Drops versions older than [days] and, beyond [maxBytes], the oldest ones; returns how many were removed. */
    @Synchronized fun purgeVersions(days: Int, maxBytes: Long, now: Long): Int {
        var removed = 0
        val cutoff = now - days * 86_400_000L
        for (v in versions.toList()) {
            val f = File(versionsDir, v.file)
            if (v.time < cutoff || !f.exists()) { f.delete(); versions.remove(v); removed++ }
        }
        var total = versions.sumOf { it.size }
        for (v in versions.sortedBy { it.time }) {
            if (total <= maxBytes) break
            File(versionsDir, v.file).delete(); versions.remove(v); total -= v.size; removed++
        }
        if (removed > 0) save()
        return removed
    }

    @Synchronized fun recordVerification(run: VerifyRun, issues: List<IntegrityIssue>) {
        runs += run
        if (runs.size > 50) runs.removeAt(0)
        integrity.clear(); integrity += issues
        save()
    }
    @Synchronized fun clearIntegrity(issue: IntegrityIssue) { integrity.remove(issue); save() }

    @Synchronized fun persist() = save()

    // ---- JSON ----
    private fun save() {
        val o = JSONObject()
        o.put("nextId", nextId)
        o.put("baseline", JSONObject().also { m ->
            for ((p, b) in baseline) m.put(p, JSONObject().put("h", b.hash).put("e", JSONObject().also { e ->
                for ((ep, sm) in b.eps) e.put(ep, JSONArray().put(sm.first).put(sm.second))
            }))
        })
        o.put("conflicts", JSONArray().also { a -> conflicts.forEach {
            a.put(JSONObject().put("id", it.id).put("ep", it.endpoint).put("path", it.path).put("copy", it.copyPath).put("t", it.time))
        } })
        o.put("versions", JSONArray().also { a -> versions.forEach {
            a.put(JSONObject().put("id", it.id).put("ep", it.endpoint).put("path", it.path).put("t", it.time)
                .put("size", it.size).put("reason", it.reason).put("file", it.file))
        } })
        o.put("runs", JSONArray().also { a -> runs.forEach {
            a.put(JSONObject().put("t", it.time).put("checked", it.checked).put("issues", it.issues).put("ms", it.durationMs))
        } })
        o.put("integrity", JSONArray().also { a -> integrity.forEach { a.put(JSONObject().put("ep", it.endpoint).put("path", it.path)) } })
        val tmp = File(dir, "state.json.tmp")
        tmp.writeText(o.toString())
        tmp.renameTo(file)
    }

    private fun load() {
        if (!file.exists()) return
        try {
            val o = JSONObject(file.readText())
            nextId = o.optLong("nextId", 1)
            o.optJSONObject("baseline")?.let { m ->
                for (p in m.keys()) {
                    val b = m.getJSONObject(p)
                    val eps = HashMap<String, Pair<Long, Long>>()
                    b.optJSONObject("e")?.let { e -> for (ep in e.keys()) { val a = e.getJSONArray(ep); eps[ep] = a.getLong(0) to a.getLong(1) } }
                    baseline[p] = Baseline(b.getString("h"), eps)
                }
            }
            o.optJSONArray("conflicts")?.let { a -> for (i in 0 until a.length()) a.getJSONObject(i).let {
                conflicts += ConflictRecord(it.getLong("id"), it.getString("ep"), it.getString("path"), it.getString("copy"), it.getLong("t")) } }
            o.optJSONArray("versions")?.let { a -> for (i in 0 until a.length()) a.getJSONObject(i).let {
                versions += VersionItem(it.getLong("id"), it.getString("ep"), it.getString("path"), it.getLong("t"), it.getLong("size"), it.optString("reason"), it.getString("file")) } }
            o.optJSONArray("runs")?.let { a -> for (i in 0 until a.length()) a.getJSONObject(i).let {
                runs += VerifyRun(it.getLong("t"), it.getInt("checked"), it.getInt("issues"), it.getLong("ms")) } }
            o.optJSONArray("integrity")?.let { a -> for (i in 0 until a.length()) a.getJSONObject(i).let {
                integrity += IntegrityIssue(it.getString("ep"), it.getString("path")) } }
        } catch (_: Exception) {
            // damaged state: start from an empty baseline. Files are never deleted by the engine, so the worst case is
            // a round of "differing files" being kept as conflict copies.
            baseline.clear()
        }
    }

    /** Removes everything remembered for this group (the folders' files are not touched). */
    fun deleteAll() { dir.deleteRecursively() }
}
