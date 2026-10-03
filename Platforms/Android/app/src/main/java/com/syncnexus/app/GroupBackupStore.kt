package com.syncnexus.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** JSON codec + on-disk backups (files/Backups/Registry/<timestamp>/snapshot.json) for the group registry. */
class GroupBackupStore(context: Context) {
    private val root = File(context.applicationContext.filesDir, "Backups/Registry")

    companion object {
        fun encode(s: GroupBackupLogic.Snapshot, time: Long = System.currentTimeMillis()): String {
            val groups = JSONArray()
            for (g in s.groups) {
                val eps = JSONArray()
                for (e in s.endpoints[g.id] ?: emptyList()) {
                    eps.put(JSONObject().put("id", e.id).put("uriString", e.uriString).put("displayName", e.displayName))
                }
                groups.put(JSONObject().put("id", g.id).put("name", g.name).put("icon", g.icon).put("createdAt", g.createdAt).put("endpoints", eps))
            }
            return JSONObject().put("format", 1).put("time", time).put("groups", groups).toString()
        }

        /** Tolerant: missing fields fall back to defaults; throws only when the text is not a snapshot at all. */
        fun decode(text: String): GroupBackupLogic.Snapshot {
            val root = JSONObject(text)
            val array = root.getJSONArray("groups")
            val groups = mutableListOf<SyncGroup>()
            val endpoints = mutableMapOf<String, List<AndroidEndpoint>>()
            for (i in 0 until array.length()) {
                val o = array.getJSONObject(i)
                val g = SyncGroup(
                    id = o.optString("id", SyncGroupOps.DEFAULT_ID),
                    name = o.optString("name", SyncGroupOps.DEFAULT_MARKER_NAME),
                    icon = o.optString("icon", "folder"),
                    createdAt = o.optLong("createdAt", System.currentTimeMillis())
                )
                groups.add(g)
                val list = mutableListOf<AndroidEndpoint>()
                val eps = o.optJSONArray("endpoints") ?: JSONArray()
                for (j in 0 until eps.length()) {
                    val e = eps.getJSONObject(j)
                    list.add(AndroidEndpoint(e.getString("id"), e.getString("uriString"), e.optString("displayName", e.getString("id"))))
                }
                endpoints[g.id] = list
            }
            return GroupBackupLogic.Snapshot(groups, endpoints)
        }
    }

    private fun dirs(): List<File> =
        (root.listFiles() ?: emptyArray()).filter { File(it, "snapshot.json").exists() }.sortedBy { it.name }

    fun list(): List<GroupBackupLogic.BackupMeta> = dirs().mapNotNull { d ->
        try {
            val snap = decode(File(d, "snapshot.json").readText())
            val time = JSONObject(File(d, "snapshot.json").readText()).optLong("time", d.lastModified())
            GroupBackupLogic.BackupMeta(d.name, time, GroupBackupLogic.fingerprint(snap), snap.groups.map { it.name }, snap.endpointTotal)
        } catch (_: Exception) {
            null
        }
    }

    /** Snapshots the given state unless nothing changed. Returns the backup name, or null when skipped / failed. */
    fun backup(snapshot: GroupBackupLogic.Snapshot, force: Boolean = false): String? {
        val existing = list()
        if (!GroupBackupLogic.shouldBackup(snapshot, existing, force)) return null
        val base = SimpleDateFormat("yyyyMMdd-HHmmss", Locale.US).format(Date())
        var dir = File(root, base)
        var n = 1
        while (dir.exists()) { n += 1; dir = File(root, "$base-$n") }   // never reuse (or delete) an existing backup
        return try {
            dir.mkdirs()
            File(dir, "snapshot.json").writeText(encode(snapshot))
            GroupBackupLogic.toDelete(list()).forEach { File(root, it).deleteRecursively() }
            dir.name
        } catch (_: Exception) {
            dir.deleteRecursively()
            null
        }
    }

    fun load(name: String): GroupBackupLogic.Snapshot? = try {
        decode(File(File(root, name), "snapshot.json").readText())
    } catch (_: Exception) {
        null
    }
}
