package com.syncnexus.app

import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class SyncSnapshotState(
    val phase: String = "IDLE", // IDLE, SYNCING, PAUSED
    val endpointsCount: Int = 0,
    val trackedFilesCount: Int = 0,
    val lastSyncTime: String = "尚未同步",
    val conflictsCount: Int = 0,
    val recentTransfers: Int = 0,
    val logs: List<SyncLogItem> = emptyList(),
    val error: String? = null
)

/**
 * Android 核心引擎橋接層
 * 負責端點持久化 (SharedPreferences) 與實體同步任務排程
 */
object SyncNexusEngineBridge {

    /** Returned by [addEndpoint] when the folder lies inside, or contains, another folder of the same group. */
    const val NESTED_IN_GROUP = "\u0000nested"

    private val _snapshot = MutableStateFlow(SyncSnapshotState())
    val snapshot: StateFlow<SyncSnapshotState> = _snapshot.asStateFlow()

    private val _groups = MutableStateFlow(SyncGroupOps.initial())
    val groups: StateFlow<List<SyncGroup>> = _groups.asStateFlow()

    private val _activeGroupId = MutableStateFlow(SyncGroupOps.DEFAULT_ID)
    val activeGroupId: StateFlow<String> = _activeGroupId.asStateFlow()

    /** Endpoints of the active group (what the screen shows). */
    private val _endpoints = MutableStateFlow<List<AndroidEndpoint>>(emptyList())
    val endpoints: StateFlow<List<AndroidEndpoint>> = _endpoints.asStateFlow()

    private val endpointsByGroup = mutableMapOf<String, List<AndroidEndpoint>>()

    /** What the last reconciliation of one group found (kept per group, so the notification can list every group). */
    data class GroupRunResult(val syncing: Boolean = false, val conflicts: Int = 0, val error: String? = null)

    /** A group with its own state, for notifications and summaries that cover all groups. */
    data class GroupState(val group: SyncGroup, val folders: Int, val status: GroupStatusLogic.Status, val conflicts: Int)

    private val runResults = java.util.concurrent.ConcurrentHashMap<String, GroupRunResult>()   // written by the sync coroutine, read by the UI
    private val _groupStates = MutableStateFlow<List<GroupState>>(emptyList())
    val groupStates: StateFlow<List<GroupState>> = _groupStates.asStateFlow()

    private fun publishGroupStates() {
        _groupStates.value = _groups.value.map { g ->
            val folders = endpointsByGroup[g.id]?.size ?: 0
            val r = runResults[g.id] ?: GroupRunResult()
            GroupState(g, folders, GroupStatusLogic.statusOf(folders, r.syncing, r.conflicts, r.error), r.conflicts)
        }
    }

    private var syncEngine: SyncEngine? = null
    private var appContext: Context? = null

    fun initialize(context: Context) {
        appContext = context.applicationContext
        val safAdapter = SAFStorageAdapter(context)
        syncEngine = SyncEngine(context, safAdapter)
        loadGroups(context)
        backups = GroupBackupStore(context)
        backups?.backup(currentSnapshot())   // every start: skipped when nothing changed
    }

    private var backups: GroupBackupStore? = null

    // ---- backups, restore, export / import ----

    private fun currentSnapshot() = GroupBackupLogic.Snapshot(_groups.value, endpointsByGroup.toMap())

    fun listBackups(): List<GroupBackupLogic.BackupMeta> = backups?.list()?.reversed() ?: emptyList()

    private fun applySnapshot(snapshot: GroupBackupLogic.Snapshot) {
        val ctx = appContext ?: return
        // forget folders that are no longer referenced, then write everything
        _groups.value = snapshot.groups
        endpointsByGroup.clear()
        for (g in snapshot.groups) endpointsByGroup[g.id] = snapshot.endpoints[g.id] ?: emptyList()
        if (_groups.value.none { it.id == _activeGroupId.value }) _activeGroupId.value = snapshot.groups.first().id
        for (g in snapshot.groups) saveEndpoints(ctx, g.id, endpointsByGroup[g.id] ?: emptyList())
        saveGroups(ctx)
        publishActive()
    }

    /** Replaces the current groups with a backup. The current state is backed up first, so the restore can be undone. */
    fun restoreBackup(name: String): Boolean {
        val store = backups ?: return false
        val snap = store.load(name) ?: return false
        if (snap.groups.isEmpty()) return false
        store.backup(currentSnapshot(), force = true)
        applySnapshot(snap)
        return true
    }

    fun exportSettings(context: Context, uri: android.net.Uri): Boolean = try {
        context.contentResolver.openOutputStream(uri)?.use { it.write(GroupBackupStore.encode(currentSnapshot()).toByteArray()) } != null
    } catch (_: Exception) {
        false
    }

    /** Merges settings exported earlier (or from another device). Configured groups are never overwritten. */
    fun importSettings(context: Context, uri: android.net.Uri): GroupBackupLogic.MergeResult? {
        val text = try {
            context.contentResolver.openInputStream(uri)?.use { String(it.readBytes()) }
        } catch (_: Exception) { null } ?: return null
        val incoming = try { GroupBackupStore.decode(text) } catch (_: Exception) { return null }
        backups?.backup(currentSnapshot(), force = true)
        val result = GroupBackupLogic.merge(currentSnapshot(), incoming)
        if (result.imported.isNotEmpty()) applySnapshot(result.merged)
        return result
    }

    // ---- persistence ----

    private fun loadGroups(context: Context) {
        val sp = context.getSharedPreferences("syncnexus_groups", Context.MODE_PRIVATE)
        var groups = SyncGroupOps.initial()
        val raw = sp.getString("groups_json", null)
        if (raw != null) {
            try {
                val array = org.json.JSONArray(raw)
                val list = mutableListOf<SyncGroup>()
                for (i in 0 until array.length()) {
                    val o = array.getJSONObject(i)
                    list.add(
                        SyncGroup(
                            id = o.optString("id", SyncGroupOps.DEFAULT_ID),
                            name = o.optString("name", SyncGroupOps.DEFAULT_MARKER_NAME),
                            icon = o.optString("icon", "folder"),
                            createdAt = o.optLong("createdAt", System.currentTimeMillis())
                        )
                    )
                }
                if (list.isNotEmpty()) groups = list
            } catch (_: Exception) {
                // damaged file: keep it untouched and fall back to the default group in memory only
            }
        }
        _groups.value = groups
        _activeGroupId.value = sp.getString("active_group", null)?.takeIf { id -> groups.any { it.id == id } } ?: groups.first().id
        endpointsByGroup.clear()
        for (g in groups) endpointsByGroup[g.id] = loadEndpoints(context, g.id)
        publishActive()
    }

    private fun saveGroups(context: Context) {
        val array = org.json.JSONArray()
        for (g in _groups.value) {
            array.put(
                org.json.JSONObject()
                    .put("id", g.id).put("name", g.name).put("icon", g.icon).put("createdAt", g.createdAt)
            )
        }
        context.getSharedPreferences("syncnexus_groups", Context.MODE_PRIVATE).edit()
            .putString("groups_json", array.toString())
            .putString("active_group", _activeGroupId.value)
            .apply()
    }

    private fun loadEndpoints(context: Context, groupId: String): List<AndroidEndpoint> {
        val sp = context.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE)
        val raw = sp.getString(SyncGroupOps.endpointsKey(groupId), null) ?: return emptyList()
        return try {
            val list = mutableListOf<AndroidEndpoint>()
            val array = org.json.JSONArray(raw)
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                list.add(AndroidEndpoint(id = obj.getString("id"), uriString = obj.getString("uriString"), displayName = obj.getString("displayName")))
            }
            list
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun saveEndpoints(context: Context, groupId: String, list: List<AndroidEndpoint>) {
        val sp = context.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE)
        val array = org.json.JSONArray()
        for (ep in list) {
            array.put(org.json.JSONObject().put("id", ep.id).put("uriString", ep.uriString).put("displayName", ep.displayName))
        }
        sp.edit().putString(SyncGroupOps.endpointsKey(groupId), array.toString()).apply()
    }

    private fun publishActive() {
        val list = endpointsByGroup[_activeGroupId.value] ?: emptyList()
        _endpoints.value = list
        _snapshot.value = _snapshot.value.copy(endpointsCount = list.size)
        publishGroupStates()
    }

    // ---- groups ----

    fun selectGroup(id: String) {
        if (id == _activeGroupId.value || _groups.value.none { it.id == id }) return
        _activeGroupId.value = id
        publishActive()
        appContext?.let { saveGroups(it) }
    }

    /** An empty name creates an unnamed group, shown as "New Group" in the current language. */
    fun createGroup(name: String, icon: String = "folder"): SyncGroup {
        val (list, group) = SyncGroupOps.add(_groups.value, name, icon)
        _groups.value = list
        endpointsByGroup[group.id] = emptyList()
        _activeGroupId.value = group.id
        publishActive()
        appContext?.let { saveGroups(it) }
        return group
    }

    fun updateGroup(id: String, name: String, icon: String) {
        _groups.value = SyncGroupOps.update(_groups.value, id, name, icon)
        appContext?.let { saveGroups(it) }
    }

    /** Removes only the group's settings; the folders' files are never touched. Returns false for the last group. */
    fun deleteGroup(id: String): Boolean {
        val remaining = SyncGroupOps.remove(_groups.value, id)
        if (remaining.size == _groups.value.size) return false
        _groups.value = remaining
        endpointsByGroup.remove(id)
        runResults.remove(id)
        if (_activeGroupId.value == id) _activeGroupId.value = remaining.first().id
        publishActive()
        appContext?.let { ctx ->
            ctx.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE).edit().remove(SyncGroupOps.endpointsKey(id)).apply()
            saveGroups(ctx)
        }
        return true
    }

    // ---- endpoints of the active group ----

    /** Returns the id of the other group already using this folder, or null when the folder was added. */
    fun addEndpoint(endpoint: AndroidEndpoint): String? {
        val gid = _activeGroupId.value
        SyncGroupOps.groupUsing(endpoint.uriString, endpointsByGroup, gid)?.let { return it }
        if (SyncGroupOps.nestedInSameGroup(endpoint.uriString, endpointsByGroup[gid] ?: emptyList()) != null) return NESTED_IN_GROUP
        val current = (endpointsByGroup[gid] ?: emptyList()).toMutableList()
        current.removeAll { it.uriString == endpoint.uriString }
        current.add(endpoint)
        endpointsByGroup[gid] = current
        publishActive()
        appContext?.let { saveEndpoints(it, gid, current) }
        runReconciliation()
        return null
    }

    fun removeEndpoint(endpointId: String) {
        val gid = _activeGroupId.value
        val current = (endpointsByGroup[gid] ?: emptyList()).toMutableList()
        current.removeAll { it.id == endpointId }
        endpointsByGroup[gid] = current
        publishActive()
        appContext?.let { saveEndpoints(it, gid, current) }
    }

    /** Reconciles every group independently; the screen reports the active group. */
    fun runReconciliation() {
        val engine = syncEngine ?: return
        val timeText = { java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date()) }
        val activeId = _activeGroupId.value
        val jobs = endpointsByGroup.filterValues { it.size >= 2 }

        if (jobs.isEmpty()) {
            _snapshot.value = _snapshot.value.copy(phase = "IDLE", lastSyncTime = timeText())
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            _snapshot.value = _snapshot.value.copy(phase = "SYNCING")
            var error: String? = null
            for ((gid, eps) in jobs) {
                runResults[gid] = GroupRunResult(syncing = true)
                publishGroupStates()
                try {
                    val report = engine.sync(eps)
                    runResults[gid] = GroupRunResult(conflicts = report.conflicts)
                    if (gid == _activeGroupId.value) {
                        _snapshot.value = _snapshot.value.copy(
                            trackedFilesCount = report.trackedFiles,
                            recentTransfers = report.syncedTransfers,
                            conflictsCount = report.conflicts,
                            logs = report.logs.takeLast(20).reversed()
                        )
                    }
                } catch (e: Exception) {
                    runResults[gid] = GroupRunResult(error = e.localizedMessage ?: e.javaClass.simpleName)
                    if (gid == activeId) error = e.localizedMessage
                }
                publishGroupStates()
            }
            _snapshot.value = _snapshot.value.copy(phase = "IDLE", lastSyncTime = timeText(), error = error)
        }
    }
}
