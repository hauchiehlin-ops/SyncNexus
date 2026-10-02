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

    private val _snapshot = MutableStateFlow(SyncSnapshotState())
    val snapshot: StateFlow<SyncSnapshotState> = _snapshot.asStateFlow()

    private val _endpoints = MutableStateFlow<List<AndroidEndpoint>>(emptyList())
    val endpoints: StateFlow<List<AndroidEndpoint>> = _endpoints.asStateFlow()

    private var syncEngine: SyncEngine? = null
    private var appContext: Context? = null

    fun initialize(context: Context) {
        appContext = context.applicationContext
        val safAdapter = SAFStorageAdapter(context)
        syncEngine = SyncEngine(context, safAdapter)
        loadEndpoints(context)
    }

    private fun loadEndpoints(context: Context) {
        val sp = context.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE)
        val raw = sp.getString("endpoints_json", null) ?: return
        try {
            val list = mutableListOf<AndroidEndpoint>()
            val array = org.json.JSONArray(raw)
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                list.add(
                    AndroidEndpoint(
                        id = obj.getString("id"),
                        uriString = obj.getString("uriString"),
                        displayName = obj.getString("displayName")
                    )
                )
            }
            _endpoints.value = list
            _snapshot.value = _snapshot.value.copy(endpointsCount = list.size)
        } catch (_: Exception) {}
    }

    private fun saveEndpoints(context: Context, list: List<AndroidEndpoint>) {
        val sp = context.getSharedPreferences("syncnexus_endpoints", Context.MODE_PRIVATE)
        val array = org.json.JSONArray()
        for (ep in list) {
            val obj = org.json.JSONObject()
            obj.put("id", ep.id)
            obj.put("uriString", ep.uriString)
            obj.put("displayName", ep.displayName)
            array.put(obj)
        }
        sp.edit().putString("endpoints_json", array.toString()).apply()
    }

    fun addEndpoint(endpoint: AndroidEndpoint) {
        val current = _endpoints.value.toMutableList()
        current.removeAll { it.uriString == endpoint.uriString }
        current.add(endpoint)
        _endpoints.value = current
        _snapshot.value = _snapshot.value.copy(endpointsCount = current.size)
        appContext?.let { saveEndpoints(it, current) }
        runReconciliation()
    }

    fun removeEndpoint(endpointId: String) {
        val current = _endpoints.value.toMutableList()
        current.removeAll { it.id == endpointId }
        _endpoints.value = current
        _snapshot.value = _snapshot.value.copy(endpointsCount = current.size)
        appContext?.let { saveEndpoints(it, current) }
    }

    fun runReconciliation() {
        val engine = syncEngine ?: return
        val currentEps = _endpoints.value
        if (currentEps.size < 2) {
            _snapshot.value = _snapshot.value.copy(
                phase = "IDLE",
                lastSyncTime = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date())
            )
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            _snapshot.value = _snapshot.value.copy(phase = "SYNCING")
            try {
                val report = engine.sync(currentEps)
                _snapshot.value = _snapshot.value.copy(
                    phase = "IDLE",
                    trackedFilesCount = report.trackedFiles,
                    recentTransfers = report.syncedTransfers,
                    conflictsCount = report.conflicts,
                    logs = report.logs.takeLast(20).reversed(),
                    lastSyncTime = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date()),
                    error = null
                )
            } catch (e: Exception) {
                _snapshot.value = _snapshot.value.copy(
                    phase = "IDLE",
                    error = e.localizedMessage
                )
            }
        }
    }
}
