package com.syncnexus.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private val safAdapter by lazy { SAFStorageAdapter(this) }
    private val peerDiscovery by lazy { LocalPeerDiscovery(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 初始化核心同步橋接層
        SyncNexusEngineBridge.initialize(applicationContext)

        // 啟動電池約束的定期背景排程 (WorkManager)
        SyncWorker.enqueuePeriodic(applicationContext)

        // 啟動局域網 P2P 設備發現
        peerDiscovery.start()

        // 啟動前台同步服務
        val serviceIntent = Intent(this, SyncForegroundService::class.java).apply {
            action = SyncForegroundService.ACTION_START
        }
        startService(serviceIntent)

        setContent {
            MaterialTheme {
                SyncNexusScreen(
                    peerDiscovery = peerDiscovery,
                    onAddFolder = { uri ->
                        safAdapter.takePersistablePermission(uri)
                        val folderName = uri.lastPathSegment?.substringAfterLast(':')
                            ?: getString(R.string.custom_folder_fallback)
                        val endpoint = AndroidEndpoint(
                            id = folderName,
                            uriString = uri.toString(),
                            displayName = folderName
                        )
                        SyncNexusEngineBridge.addEndpoint(endpoint)
                    },
                    onRemoveFolder = { epId ->
                        SyncNexusEngineBridge.removeEndpoint(epId)
                    },
                    onSyncNow = {
                        SyncNexusEngineBridge.runReconciliation()
                    }
                )
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        peerDiscovery.stop()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SyncNexusScreen(
    peerDiscovery: LocalPeerDiscovery,
    onAddFolder: (Uri) -> Unit,
    onRemoveFolder: (String) -> Unit,
    onSyncNow: () -> Unit
) {
    val snapshot by SyncNexusEngineBridge.snapshot.collectAsState()
    val endpoints by SyncNexusEngineBridge.endpoints.collectAsState()
    val nearbyDevices by peerDiscovery.nearbyDevices.collectAsState()
    val scope = rememberCoroutineScope()

    val folderPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocumentTree()
    ) { uri: Uri? ->
        uri?.let { onAddFolder(it) }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.app_name), fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // 狀態概覽卡片
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = if (snapshot.phase == "SYNCING") stringResource(R.string.status_card_title_syncing) else stringResource(R.string.status_card_title_ready),
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (snapshot.phase == "SYNCING") Color(0xFF1976D2) else Color(0xFF2E7D32)
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(stringResource(R.string.status_folder_count, endpoints.size), fontSize = 14.sp)
                    Text(stringResource(R.string.status_tracked_files, snapshot.trackedFilesCount), fontSize = 14.sp)
                    Text(stringResource(R.string.status_recent_transfers, snapshot.recentTransfers), fontSize = 14.sp)
                    Text(stringResource(R.string.status_last_sync_time, snapshot.lastSyncTime), fontSize = 14.sp)
                    if (snapshot.error != null) {
                        Text(stringResource(R.string.status_error_prefix, snapshot.error ?: ""), fontSize = 13.sp, color = Color.Red)
                    }
                }
            }

            // 功能按鈕
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Button(
                    onClick = { folderPickerLauncher.launch(null) },
                    modifier = Modifier.weight(1f)
                ) {
                    Text(stringResource(R.string.btn_add_folder))
                }
                OutlinedButton(
                    onClick = { scope.launch { onSyncNow() } },
                    enabled = endpoints.size >= 2 && snapshot.phase != "SYNCING",
                    modifier = Modifier.weight(1f)
                ) {
                    Text(stringResource(R.string.btn_sync_now))
                }
            }

            // 同 Wi-Fi 局域網近端設備卡片 (P2P 直連零雲端)
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.5f))
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(stringResource(R.string.nearby_devices_title), fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Spacer(modifier = Modifier.weight(1f))
                        Text(
                            if (nearbyDevices.isEmpty()) stringResource(R.string.nearby_devices_searching)
                            else stringResource(R.string.nearby_devices_found, nearbyDevices.size),
                            fontSize = 12.sp,
                            color = Color.Gray
                        )
                    }
                    if (nearbyDevices.isEmpty()) {
                        Text(stringResource(R.string.nearby_devices_hint), fontSize = 12.sp, color = Color.Gray)
                    } else {
                        nearbyDevices.forEach { dev ->
                            Text("• ${dev.name} (${dev.host})", fontSize = 13.sp, color = Color(0xFF1B5E20))
                        }
                    }
                }
            }

            Text(stringResource(R.string.section_folders_title), fontWeight = FontWeight.SemiBold, fontSize = 16.sp)

            if (endpoints.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(0.35f),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        stringResource(R.string.empty_folders_hint),
                        color = Color.Gray,
                        lineHeight = 20.sp
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier.weight(0.35f),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(endpoints, key = { it.uriString }) { ep ->
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Row(
                                modifier = Modifier
                                    .padding(12.dp)
                                    .fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(ep.displayName, fontWeight = FontWeight.Bold)
                                    Text(
                                        ep.uriString,
                                        fontSize = 11.sp,
                                        color = Color.Gray,
                                        maxLines = 1
                                    )
                                }
                                TextButton(
                                    onClick = { onRemoveFolder(ep.id) }
                                ) {
                                    Text(stringResource(R.string.btn_remove), color = Color(0xFFC62828))
                                }
                            }
                        }
                    }
                }
            }

            // 即時同步日誌
            Text(stringResource(R.string.section_logs_title), fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
            if (snapshot.logs.isEmpty()) {
                Text(stringResource(R.string.logs_empty), fontSize = 13.sp, color = Color.Gray)
            } else {
                LazyColumn(
                    modifier = Modifier.weight(0.35f),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    items(snapshot.logs) { log ->
                        Text(
                            text = "[${log.timestamp}] ${log.operation} - ${log.filePath}",
                            fontSize = 12.sp,
                            color = if (log.isSuccess) Color(0xFF2E7D32) else Color.Red
                        )
                    }
                }
            }
        }
    }
}
