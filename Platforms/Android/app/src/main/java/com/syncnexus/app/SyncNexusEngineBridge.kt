package com.syncnexus.app

import android.content.Context
import android.net.Uri
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
    val lastSyncTime: String = "",   // empty = never; the screen shows the localized text
    val conflictsCount: Int = 0,
    val recentTransfers: Int = 0,
    val logs: List<SyncLogItem> = emptyList(),
    val error: String? = null,
    val lastDeepVerifyTime: Long? = null,
    val integrityIssuesCount: Int = 0,
    val versionsBytes: Long = 0L,
    val versionsCount: Int = 0,
    val versionsRetentionDays: Int = 30
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

    // ---- per-group extras shown in the sidebar sections (conflicts, versions, verification, diff preview) ----
    data class PreviewState(val running: Boolean = false, val ready: Boolean = false, val items: List<PlanItem> = emptyList())

    private val _conflicts = MutableStateFlow<List<ConflictRecord>>(emptyList())
    val conflicts: StateFlow<List<ConflictRecord>> = _conflicts.asStateFlow()
    private val _versions = MutableStateFlow<List<VersionItem>>(emptyList())
    val versions: StateFlow<List<VersionItem>> = _versions.asStateFlow()
    private val _verifyRuns = MutableStateFlow<List<VerifyRun>>(emptyList())
    val verifyRuns: StateFlow<List<VerifyRun>> = _verifyRuns.asStateFlow()
    private val _integrity = MutableStateFlow<List<IntegrityIssue>>(emptyList())
    val integrity: StateFlow<List<IntegrityIssue>> = _integrity.asStateFlow()
    private val _preview = MutableStateFlow(PreviewState())
    val preview: StateFlow<PreviewState> = _preview.asStateFlow()
    private val _verifying = MutableStateFlow(false)
    val verifying: StateFlow<Boolean> = _verifying.asStateFlow()
    private val syncRunning = java.util.concurrent.atomic.AtomicBoolean(false)

    // ---- Safety & Pending Confirmations ----
    private val _pendingConfirmations = MutableStateFlow<Map<String, PendingConfirmation>>(emptyMap())
    val pendingConfirmations: StateFlow<Map<String, PendingConfirmation>> = _pendingConfirmations.asStateFlow()

    // ---- Settings States ----
    private val _conflictPolicy = MutableStateFlow(ConflictPolicy.KEEP_BOTH)
    val conflictPolicy: StateFlow<ConflictPolicy> = _conflictPolicy.asStateFlow()

    private val _excludePresets = MutableStateFlow(AndroidIgnoreRules.defaultPresets)
    val excludePresets: StateFlow<Set<ExcludePreset>> = _excludePresets.asStateFlow()

    private val _customExcludes = MutableStateFlow<List<String>>(emptyList())
    val customExcludes: StateFlow<List<String>> = _customExcludes.asStateFlow()

    private val _autoExcludeNestedGroups = MutableStateFlow(true)
    val autoExcludeNestedGroups: StateFlow<Boolean> = _autoExcludeNestedGroups.asStateFlow()

    private val _cloudSpaceSaving = MutableStateFlow(true)
    val cloudSpaceSaving: StateFlow<Boolean> = _cloudSpaceSaving.asStateFlow()

    private val _bootStartEnabled = MutableStateFlow(true)
    val bootStartEnabled: StateFlow<Boolean> = _bootStartEnabled.asStateFlow()

    private val _pausedGroups = MutableStateFlow<Set<String>>(emptySet())
    val pausedGroups: StateFlow<Set<String>> = _pausedGroups.asStateFlow()

    private fun refreshExtras() {
        val engine = syncEngine ?: return
        val gid = _activeGroupId.value
        val st = engine.state(gid)
        _conflicts.value = st.openConflicts()
        _versions.value = st.versionList()
        _verifyRuns.value = st.verifyRuns()
        _integrity.value = st.integrityIssues()

        _snapshot.value = _snapshot.value.copy(
            trackedFilesCount = st.baselineSnapshot().size,
            lastDeepVerifyTime = st.lastDeepVerifyTime(),
            integrityIssuesCount = st.integrityIssues().size,
            versionsBytes = st.versionsTotalBytes(),
            versionsCount = st.versionsCount(),
            versionsRetentionDays = st.versionsRetentionDays
        )
    }

    /** Runs [block] off the main thread against the active group, then refreshes the extras. */
    private fun withActiveGroup(block: (SyncEngine, String, List<AndroidEndpoint>) -> Unit) {
        val engine = syncEngine ?: return
        val gid = _activeGroupId.value
        val eps = endpointsByGroup[gid] ?: emptyList()
        CoroutineScope(Dispatchers.IO).launch {
            try { block(engine, gid, eps) } catch (_: Exception) {}
            refreshExtras()
            publishGroupStates()
        }
    }

    private fun effectiveCustomPatterns(forGroupId: String): List<String> {
        val patterns = _customExcludes.value.toMutableList()
        if (_autoExcludeNestedGroups.value) {
            val myEps = endpointsByGroup[forGroupId] ?: emptyList()
            for (myEp in myEps) {
                for ((otherGid, otherEps) in endpointsByGroup) {
                    if (otherGid == forGroupId) continue
                    for (otherEp in otherEps) {
                        if (otherEp.uriString.startsWith(myEp.uriString + "/")) {
                            val rel = otherEp.uriString.removePrefix(myEp.uriString + "/").trim('/')
                            if (rel.isNotEmpty()) patterns.add(rel)
                        }
                    }
                }
            }
        }
        return patterns
    }

    /** Diff preview: what a sync would do right now, without changing anything. */
    fun requestPreview() {
        _preview.value = PreviewState(running = true)
        withActiveGroup { e, gid, eps ->
            val items = e.preview(
                gid, eps,
                presets = _excludePresets.value,
                customPatterns = effectiveCustomPatterns(gid),
                conflictPolicy = _conflictPolicy.value
            )
            _preview.value = PreviewState(ready = true, items = items)
        }
    }

    fun resolveConflict(id: Long, keepMain: Boolean) = withActiveGroup { e, gid, eps ->
        if (e.resolveConflict(gid, eps, id, keepMain) && !keepMain) runReconciliation()
    }

    fun restoreVersion(id: Long) = withActiveGroup { e, gid, eps -> if (e.restoreVersion(gid, eps, id)) runReconciliation() }
    fun deleteVersion(id: Long) = withActiveGroup { e, gid, _ -> e.deleteVersion(gid, id) }

    fun setVersionsRetention(days: Int) {
        val engine = syncEngine ?: return
        val gid = _activeGroupId.value
        engine.state(gid).setRetentionDays(days)
        _snapshot.value = _snapshot.value.copy(versionsRetentionDays = days)
        refreshExtras()
    }

    fun purgeExpiredVersions() = withActiveGroup { e, gid, _ ->
        e.state(gid).purgeExpiredVersions()
    }

    fun purgeAllVersions() = withActiveGroup { e, gid, _ ->
        e.state(gid).purgeAllVersions()
    }

    fun runVerification() {
        if (_verifying.value) return
        _verifying.value = true
        withActiveGroup { e, gid, eps -> try { e.verify(gid, eps) } finally { _verifying.value = false } }
    }

    fun resolveIntegrity(issue: IntegrityIssue, restore: Boolean) = withActiveGroup { e, gid, eps ->
        if (e.resolveIntegrity(gid, eps, issue, restore) && !restore) runReconciliation()
    }

    // ---- Confirmation Management ----

    fun approveConfirmation(groupId: String) {
        _pendingConfirmations.value = _pendingConfirmations.value - groupId
        runReconciliationForGroup(groupId, confirmed = true)
    }

    fun declineConfirmation(groupId: String) {
        _pendingConfirmations.value = _pendingConfirmations.value - groupId
    }

    fun approveAllConfirmations() {
        val all = _pendingConfirmations.value.keys.toList()
        _pendingConfirmations.value = emptyMap()
        for (gid in all) {
            runReconciliationForGroup(gid, confirmed = true)
        }
    }

    // ---- Settings Actions ----

    fun setConflictPolicy(policy: ConflictPolicy) {
        _conflictPolicy.value = policy
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putString("conflict_policy", policy.name)?.apply()
    }

    fun toggleExcludePreset(preset: ExcludePreset) {
        val current = _excludePresets.value
        val updated = if (current.contains(preset)) current - preset else current + preset
        _excludePresets.value = updated
        val setStrings = updated.map { it.name }.toSet()
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putStringSet("exclude_presets", setStrings)?.apply()
    }

    fun addCustomExclude(pattern: String) {
        val trimmed = pattern.trim()
        if (trimmed.isEmpty() || _customExcludes.value.contains(trimmed)) return
        val updated = _customExcludes.value + trimmed
        _customExcludes.value = updated
        val setStrings = updated.toSet()
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putStringSet("custom_excludes", setStrings)?.apply()
    }

    fun removeCustomExclude(pattern: String) {
        val updated = _customExcludes.value - pattern
        _customExcludes.value = updated
        val setStrings = updated.toSet()
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putStringSet("custom_excludes", setStrings)?.apply()
    }

    fun setAutoExcludeNestedGroups(enabled: Boolean) {
        _autoExcludeNestedGroups.value = enabled
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putBoolean("auto_exclude_nested", enabled)?.apply()
    }

    fun setCloudSpaceSaving(enabled: Boolean) {
        _cloudSpaceSaving.value = enabled
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putBoolean("cloud_space_saving", enabled)?.apply()
    }

    fun setBootStartEnabled(enabled: Boolean) {
        _bootStartEnabled.value = enabled
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putBoolean("boot_start_enabled", enabled)?.apply()
    }

    fun pauseGroup(groupId: String) {
        _pausedGroups.value = _pausedGroups.value + groupId
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putStringSet("paused_groups", _pausedGroups.value)?.apply()
        publishGroupStates()
    }

    fun resumeGroup(groupId: String) {
        _pausedGroups.value = _pausedGroups.value - groupId
        appContext?.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
            ?.edit()?.putStringSet("paused_groups", _pausedGroups.value)?.apply()
        publishGroupStates()
        runReconciliationForGroup(groupId)
    }

    fun isGroupPaused(groupId: String): Boolean = _pausedGroups.value.contains(groupId)

    fun changeEndpointFolder(endpointId: String, newUri: Uri) {
        val gid = _activeGroupId.value
        val list = (endpointsByGroup[gid] ?: emptyList()).toMutableList()
        val index = list.indexOfFirst { it.id == endpointId }
        if (index != -1) {
            val old = list[index]
            val newName = newUri.lastPathSegment?.substringAfterLast(':') ?: old.displayName
            list[index] = old.copy(uriString = newUri.toString(), displayName = newName)
            endpointsByGroup[gid] = list
            publishActive()
            appContext?.let { saveEndpoints(it, gid, list) }
            runReconciliation()
        }
    }

    /** What the last reconciliation of one group found (kept per group, so the notification can list every group). */
    data class GroupRunResult(val syncing: Boolean = false, val conflicts: Int = 0, val error: String? = null)

    /** A group with its own state, for notifications and summaries that cover all groups. */
    data class GroupState(val group: SyncGroup, val folders: Int, val status: GroupStatusLogic.Status, val conflicts: Int)

    private val runResults = java.util.concurrent.ConcurrentHashMap<String, GroupRunResult>()
    private val _groupStates = MutableStateFlow<List<GroupState>>(emptyList())
    val groupStates: StateFlow<List<GroupState>> = _groupStates.asStateFlow()

    private fun publishGroupStates() {
        _groupStates.value = _groups.value.map { g ->
            val folders = endpointsByGroup[g.id]?.size ?: 0
            val r = runResults[g.id] ?: GroupRunResult()
            val isPaused = _pausedGroups.value.contains(g.id)
            val baseStatus = if (isPaused) GroupStatusLogic.Status.ATTENTION else GroupStatusLogic.statusOf(folders, r.syncing, r.conflicts, r.error)
            GroupState(g, folders, baseStatus, r.conflicts)
        }
    }

    private var syncEngine: SyncEngine? = null
    private var appContext: Context? = null

    fun initialize(context: Context) {
        appContext = context.applicationContext
        val safAdapter = SAFStorageAdapter(context)
        syncEngine = SyncEngine(context, safAdapter)
        loadSettings(context)
        loadGroups(context)
        backups = GroupBackupStore(context)
        backups?.backup(currentSnapshot())
        refreshExtras()
    }

    private fun loadSettings(context: Context) {
        val sp = context.getSharedPreferences("syncnexus_settings", Context.MODE_PRIVATE)
        val policyStr = sp.getString("conflict_policy", ConflictPolicy.KEEP_BOTH.name)
        _conflictPolicy.value = try { ConflictPolicy.valueOf(policyStr ?: ConflictPolicy.KEEP_BOTH.name) } catch (_: Exception) { ConflictPolicy.KEEP_BOTH }

        val presetStrings = sp.getStringSet("exclude_presets", null)
        if (presetStrings != null) {
            _excludePresets.value = presetStrings.mapNotNull { name ->
                try { ExcludePreset.valueOf(name) } catch (_: Exception) { null }
            }.toSet()
        }

        val customSet = sp.getStringSet("custom_excludes", null)
        if (customSet != null) _customExcludes.value = customSet.toList().sorted()

        _autoExcludeNestedGroups.value = sp.getBoolean("auto_exclude_nested", true)
        _cloudSpaceSaving.value = sp.getBoolean("cloud_space_saving", true)
        _bootStartEnabled.value = sp.getBoolean("boot_start_enabled", true)
        val paused = sp.getStringSet("paused_groups", null)
        if (paused != null) _pausedGroups.value = paused
    }

    private var backups: GroupBackupStore? = null

    // ---- backups, restore, export / import ----

    private fun currentSnapshot() = GroupBackupLogic.Snapshot(_groups.value, endpointsByGroup.toMap())

    fun listBackups(): List<GroupBackupLogic.BackupMeta> = backups?.list()?.reversed() ?: emptyList()

    private fun applySnapshot(snapshot: GroupBackupLogic.Snapshot) {
        val ctx = appContext ?: return
        _groups.value = snapshot.groups
        endpointsByGroup.clear()
        for (g in snapshot.groups) endpointsByGroup[g.id] = snapshot.endpoints[g.id] ?: emptyList()
        if (_groups.value.none { it.id == _activeGroupId.value }) _activeGroupId.value = snapshot.groups.first().id
        for (g in snapshot.groups) saveEndpoints(ctx, g.id, endpointsByGroup[g.id] ?: emptyList())
        saveGroups(ctx)
        publishActive()
    }

    fun restoreBackup(name: String): Boolean {
        val store = backups ?: return false
        val snap = store.load(name) ?: return false
        if (snap.groups.isEmpty()) return false
        store.backup(currentSnapshot(), force = true)
        applySnapshot(snap)
        return true
    }

    fun exportSettings(context: Context, uri: Uri): Boolean = try {
        context.contentResolver.openOutputStream(uri)?.use { it.write(GroupBackupStore.encode(currentSnapshot()).toByteArray()) } != null
    } catch (_: Exception) {
        false
    }

    fun importSettings(context: Context, uri: Uri): GroupBackupLogic.MergeResult? {
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
            } catch (_: Exception) {}
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
        _preview.value = PreviewState()
        publishActive()
        refreshExtras()
        appContext?.let { saveGroups(it) }
    }

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

    fun deleteGroup(id: String): Boolean {
        val remaining = SyncGroupOps.remove(_groups.value, id)
        if (remaining.size == _groups.value.size) return false
        _groups.value = remaining
        endpointsByGroup.remove(id)
        runResults.remove(id)
        _pendingConfirmations.value = _pendingConfirmations.value - id
        syncEngine?.forget(id)
        if (_activeGroupId.value == id) _activeGroupId.value = remaining.first().id
        publishActive()
        appContext?.let { ctx ->
            ctx.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE).edit().remove(SyncGroupOps.endpointsKey(id)).apply()
            saveGroups(ctx)
        }
        return true
    }

    // ---- endpoints of the active group ----

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

    /** Reconciles a specific group, optionally with explicit confirmation */
    fun runReconciliationForGroup(groupId: String, confirmed: Boolean = false) {
        val engine = syncEngine ?: return
        val eps = endpointsByGroup[groupId] ?: return
        if (eps.size < 2 || _pausedGroups.value.contains(groupId)) return
        CoroutineScope(Dispatchers.IO).launch {
            try {
                runResults[groupId] = GroupRunResult(syncing = true)
                publishGroupStates()
                val report = engine.sync(
                    groupId, eps,
                    confirmed = confirmed,
                    presets = _excludePresets.value,
                    customPatterns = effectiveCustomPatterns(groupId),
                    conflictPolicy = _conflictPolicy.value
                )
                if (report.pendingConfirmation != null) {
                    _pendingConfirmations.value = _pendingConfirmations.value + (groupId to report.pendingConfirmation)
                } else {
                    _pendingConfirmations.value = _pendingConfirmations.value - groupId
                }
                val open = engine.state(groupId).openConflicts().size
                runResults[groupId] = GroupRunResult(conflicts = open)
                if (groupId == _activeGroupId.value) {
                    _snapshot.value = _snapshot.value.copy(
                        trackedFilesCount = report.trackedFiles,
                        recentTransfers = report.syncedTransfers,
                        conflictsCount = open,
                        logs = report.logs.takeLast(20).reversed()
                    )
                }
            } catch (e: Exception) {
                runResults[groupId] = GroupRunResult(error = e.localizedMessage ?: e.javaClass.simpleName)
            }
            publishGroupStates()
            refreshExtras()
        }
    }

    /** Reconciles every unpaused group independently; the screen reports the active group. */
    fun runReconciliation() {
        val engine = syncEngine ?: return
        val timeText = { java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date()) }
        val activeId = _activeGroupId.value
        val jobs = endpointsByGroup.filter { (gid, eps) -> eps.size >= 2 && !_pausedGroups.value.contains(gid) }

        if (jobs.isEmpty()) {
            _snapshot.value = _snapshot.value.copy(phase = "IDLE", lastSyncTime = timeText())
            return
        }

        if (!syncRunning.compareAndSet(false, true)) return
        CoroutineScope(Dispatchers.IO).launch {
            _snapshot.value = _snapshot.value.copy(phase = "SYNCING")
            var error: String? = null
            for ((gid, eps) in jobs) {
                runResults[gid] = GroupRunResult(syncing = true)
                publishGroupStates()
                try {
                    val report = engine.sync(
                        gid, eps,
                        confirmed = false,
                        presets = _excludePresets.value,
                        customPatterns = effectiveCustomPatterns(gid),
                        conflictPolicy = _conflictPolicy.value
                    )
                    if (report.pendingConfirmation != null) {
                        _pendingConfirmations.value = _pendingConfirmations.value + (gid to report.pendingConfirmation)
                    } else {
                        _pendingConfirmations.value = _pendingConfirmations.value - gid
                    }
                    val open = engine.state(gid).openConflicts().size
                    runResults[gid] = GroupRunResult(conflicts = open)
                    if (gid == _activeGroupId.value) {
                        _snapshot.value = _snapshot.value.copy(
                            trackedFilesCount = report.trackedFiles,
                            recentTransfers = report.syncedTransfers,
                            conflictsCount = open,
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
            refreshExtras()
            syncRunning.set(false)
        }
    }
}
