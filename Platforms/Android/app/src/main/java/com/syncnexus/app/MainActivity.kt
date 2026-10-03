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
                        SyncNexusEngineBridge.addEndpoint(endpoint)?.let { otherGroupId ->
                            if (otherGroupId == SyncNexusEngineBridge.NESTED_IN_GROUP) {
                                android.widget.Toast.makeText(this, getString(R.string.folder_nested_in_group), android.widget.Toast.LENGTH_LONG).show()
                                return@let
                            }
                            val other = SyncNexusEngineBridge.groups.value.firstOrNull { it.id == otherGroupId }
                            val shown = other?.let { SyncGroupNaming.display(this, it, SyncNexusEngineBridge.groups.value) } ?: otherGroupId
                            android.widget.Toast.makeText(this, getString(R.string.group_folder_in_use, shown), android.widget.Toast.LENGTH_LONG).show()
                        }
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
    val groups by SyncNexusEngineBridge.groups.collectAsState()
    val activeGroupId by SyncNexusEngineBridge.activeGroupId.collectAsState()
    val nearbyDevices by peerDiscovery.nearbyDevices.collectAsState()
    val scope = rememberCoroutineScope()

    val folderPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocumentTree()
    ) { uri: Uri? ->
        uri?.let { onAddFolder(it) }
    }

    Scaffold(
        topBar = {
            val context = androidx.compose.ui.platform.LocalContext.current
            var showLangMenu by remember { mutableStateOf(false) }

            TopAppBar(
                title = { Text(stringResource(R.string.app_name), fontWeight = FontWeight.Bold) },
                actions = {
                    // 介面語系下拉選單按鈕
                    IconButton(onClick = { showLangMenu = true }) {
                        Text("🌐", fontSize = 18.sp)
                    }
                    DropdownMenu(
                        expanded = showLangMenu,
                        onDismissRequest = { showLangMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("繁體中文") },
                            onClick = { showLangMenu = false }
                        )
                        DropdownMenuItem(
                            text = { Text("简体中文") },
                            onClick = { showLangMenu = false }
                        )
                        DropdownMenuItem(
                            text = { Text("English") },
                            onClick = { showLangMenu = false }
                        )
                        DropdownMenuItem(
                            text = { Text("日本語") },
                            onClick = { showLangMenu = false }
                        )
                        DropdownMenuItem(
                            text = { Text("한국어") },
                            onClick = { showLangMenu = false }
                        )
                        DropdownMenuItem(
                            text = { Text("ภาษาไทย") },
                            onClick = { showLangMenu = false }
                        )
                    }

                    // 操作說明手冊按鈕
                    IconButton(onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/hauchiehlin-ops/SyncNexus/blob/main/docs/manual/android/MANUAL_android_zh-Hant.md"))
                        context.startActivity(intent)
                    }) {
                        Text("📖", fontSize = 18.sp)
                    }

                    // 隱私權政策按鈕
                    IconButton(onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/hauchiehlin-ops/SyncNexus/blob/main/docs/privacy/android/PRIVACY_android_zh-Hant.md"))
                        context.startActivity(intent)
                    }) {
                        Text("🛡️", fontSize = 18.sp)
                    }
                },
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

            SyncGroupCard(groups = groups, activeGroupId = activeGroupId)

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

private val groupIconEmoji = linkedMapOf(
    "folder" to "📁", "briefcase" to "💼", "doc.text" to "📄", "camera" to "📷", "graduationcap" to "🎓",
    "heart" to "❤️", "externaldrive" to "💾", "building.2" to "🏢", "tag" to "🏷️", "star" to "⭐"
)

/** Group switcher: chips for each group, plus new / edit / delete for the active one. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SyncGroupCard(groups: List<SyncGroup>, activeGroupId: String) {
    val context = androidx.compose.ui.platform.LocalContext.current
    var editing by remember { mutableStateOf<SyncGroup?>(null) }
    var creating by remember { mutableStateOf(false) }
    var confirmDelete by remember { mutableStateOf<SyncGroup?>(null) }
    val active = groups.firstOrNull { it.id == activeGroupId }

    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp)) {
        Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(stringResource(R.string.group_selector_title), fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Spacer(modifier = Modifier.weight(1f))
                TextButton(onClick = { creating = true }) { Text("＋ " + stringResource(R.string.group_add_button)) }
            }
            androidx.compose.foundation.lazy.LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(groups, key = { it.id }) { g ->
                    FilterChip(
                        selected = g.id == activeGroupId,
                        onClick = { SyncNexusEngineBridge.selectGroup(g.id) },
                        label = { Text((groupIconEmoji[g.icon] ?: "📁") + " " + SyncGroupNaming.display(context, g, groups)) }
                    )
                }
            }
            if (active != null) {
                Row {
                    TextButton(onClick = { editing = active }) { Text(stringResource(R.string.group_edit_title)) }
                    GroupBackupMenu()
                    if (groups.size > 1) {
                        TextButton(onClick = { confirmDelete = active }) {
                            Text(stringResource(R.string.group_delete_button), color = Color(0xFFC62828))
                        }
                    }
                }
            }
        }
    }

    if (creating) {
        GroupEditDialog(
            title = stringResource(R.string.group_add_title),
            initialName = "", initialIcon = "folder", allowEmptyName = true,
            onDismiss = { creating = false },
            onSave = { name, icon -> SyncNexusEngineBridge.createGroup(name, icon); creating = false }
        )
    }
    editing?.let { g ->
        GroupEditDialog(
            title = stringResource(R.string.group_edit_title),
            initialName = if (g.id == SyncGroupOps.DEFAULT_ID && SyncGroupNaming.display(context, g, groups) != g.name) "" else g.name,
            initialIcon = g.icon, allowEmptyName = g.name.isEmpty(),
            onDismiss = { editing = null },
            onSave = { name, icon -> SyncNexusEngineBridge.updateGroup(g.id, name, icon); editing = null }
        )
    }
    confirmDelete?.let { g ->
        AlertDialog(
            onDismissRequest = { confirmDelete = null },
            title = { Text(stringResource(R.string.group_delete_confirm_title, SyncGroupNaming.display(context, g, groups))) },
            text = { Text(stringResource(R.string.group_delete_confirm_desc)) },
            confirmButton = {
                TextButton(onClick = { SyncNexusEngineBridge.deleteGroup(g.id); confirmDelete = null }) {
                    Text(stringResource(R.string.group_delete_button), color = Color(0xFFC62828))
                }
            },
            dismissButton = { TextButton(onClick = { confirmDelete = null }) { Text(stringResource(R.string.group_cancel)) } }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GroupEditDialog(
    title: String,
    initialName: String,
    initialIcon: String,
    allowEmptyName: Boolean,
    onDismiss: () -> Unit,
    onSave: (String, String) -> Unit
) {
    var name by remember { mutableStateOf(initialName) }
    var icon by remember { mutableStateOf(initialIcon) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = name, onValueChange = { name = it }, singleLine = true,
                    label = { Text(stringResource(R.string.group_name_label)) },
                    placeholder = { Text(stringResource(R.string.group_name_placeholder)) }
                )
                androidx.compose.foundation.lazy.LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    items(groupIconEmoji.keys.toList()) { key ->
                        FilterChip(selected = icon == key, onClick = { icon = key }, label = { Text(groupIconEmoji[key] ?: "📁") })
                    }
                }
            }
        },
        confirmButton = {
            TextButton(enabled = allowEmptyName || name.isNotBlank(), onClick = { onSave(name, icon) }) {
                Text(stringResource(R.string.group_save))
            }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.group_cancel)) } }
    )
}

/** Backup & restore menu: restore an automatic backup, export settings to a file, import settings from a file. */
@Composable
fun GroupBackupMenu() {
    val context = androidx.compose.ui.platform.LocalContext.current
    var menuOpen by remember { mutableStateOf(false) }
    var listOpen by remember { mutableStateOf(false) }
    var pendingRestore by remember { mutableStateOf<GroupBackupLogic.BackupMeta?>(null) }
    val toast = { text: String -> android.widget.Toast.makeText(context, text, android.widget.Toast.LENGTH_LONG).show() }

    val exportLauncher = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("application/json")) { uri ->
        if (uri != null && !SyncNexusEngineBridge.exportSettings(context, uri)) toast(context.getString(R.string.import_failed))
    }
    val importLauncher = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) {
            val r = SyncNexusEngineBridge.importSettings(context, uri)
            toast(
                when {
                    r == null -> context.getString(R.string.import_failed)
                    r.imported.isEmpty() -> context.getString(R.string.import_nothing_new)
                    else -> context.getString(R.string.import_ok, r.imported.size, r.endpointCount)
                }
            )
        }
    }

    Box {
        TextButton(onClick = { menuOpen = true }) { Text(stringResource(R.string.backup_menu)) }
        DropdownMenu(expanded = menuOpen, onDismissRequest = { menuOpen = false }) {
            DropdownMenuItem(text = { Text(stringResource(R.string.backup_restore_title)) }, onClick = { menuOpen = false; listOpen = true })
            DropdownMenuItem(text = { Text(stringResource(R.string.backup_export)) }, onClick = { menuOpen = false; exportLauncher.launch("syncnexus-settings.json") })
            DropdownMenuItem(text = { Text(stringResource(R.string.backup_import)) }, onClick = { menuOpen = false; importLauncher.launch(arrayOf("application/json", "*/*")) })
        }
    }

    if (listOpen) {
        val backups = remember { SyncNexusEngineBridge.listBackups() }
        AlertDialog(
            onDismissRequest = { listOpen = false },
            title = { Text(stringResource(R.string.backup_restore_title)) },
            text = {
                if (backups.isEmpty()) Text(stringResource(R.string.backup_none))
                else androidx.compose.foundation.lazy.LazyColumn {
                    items(backups, key = { it.name }) { b ->
                        TextButton(onClick = { listOpen = false; pendingRestore = b }) {
                            val whenText = java.text.DateFormat.getDateTimeInstance(java.text.DateFormat.MEDIUM, java.text.DateFormat.SHORT).format(java.util.Date(b.time))
                            Text("$whenText\n${b.groupNames.joinToString(", ")} (${b.endpointTotal})")
                        }
                    }
                }
            },
            confirmButton = { TextButton(onClick = { listOpen = false }) { Text(stringResource(R.string.group_cancel)) } }
        )
    }
    pendingRestore?.let { b ->
        AlertDialog(
            onDismissRequest = { pendingRestore = null },
            title = { Text(stringResource(R.string.backup_restore_confirm_title)) },
            text = { Text(stringResource(R.string.backup_restore_confirm_desc)) },
            confirmButton = {
                TextButton(onClick = {
                    pendingRestore = null
                    toast(
                        if (SyncNexusEngineBridge.restoreBackup(b.name)) context.getString(R.string.backup_restore_ok, b.groupNames.size, b.endpointTotal)
                        else context.getString(R.string.import_failed)
                    )
                }) { Text(stringResource(R.string.backup_restore_button)) }
            },
            dismissButton = { TextButton(onClick = { pendingRestore = null }) { Text(stringResource(R.string.group_cancel)) } }
        )
    }
}
