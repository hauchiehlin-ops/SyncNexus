package com.syncnexus.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
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

    override fun attachBaseContext(newBase: android.content.Context) = super.attachBaseContext(LocaleManager.wrap(newBase))

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

private enum class Section(val labelRes: Int, val icon: String) {
    OVERVIEW(R.string.nav_overview, "🏠"),
    PREVIEW(R.string.nav_preview, "🔍"),
    FOLDERS(R.string.nav_folders, "📁"),
    ACTIVITY(R.string.nav_activity, "📈"),
    CONFLICTS(R.string.nav_conflicts, "⚠️"),
    VERSIONS(R.string.nav_versions, "🕘"),
    VERIFY(R.string.nav_verify, "🛡️"),
    SETTINGS(R.string.nav_settings, "⚙️"),
}

private fun openDoc(context: android.content.Context, kind: String) {
    val suffix = LocaleManager.docSuffix(context)
    val url = "https://github.com/hauchiehlin-ops/SyncNexus/blob/main/docs/$kind/android/${if (kind == "manual") "MANUAL" else "PRIVACY"}_android_$suffix.md"
    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
}

/** Applies the chosen UI language and recreates the screen so every string is re-read. */
private fun switchLanguage(context: android.content.Context, tag: String?) {
    LocaleManager.save(context, tag)
    (context as? android.app.Activity)?.recreate()
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
    val openConflicts by SyncNexusEngineBridge.conflicts.collectAsState().let { st -> derivedStateOf { st.value.size } }
    val scope = rememberCoroutineScope()
    val context = androidx.compose.ui.platform.LocalContext.current
    val drawerState = rememberDrawerState(DrawerValue.Closed)
    var section by rememberSaveable { mutableStateOf(Section.OVERVIEW) }
    var showLangMenu by remember { mutableStateOf(false) }

    val folderPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocumentTree()
    ) { uri: Uri? ->
        uri?.let { onAddFolder(it) }
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(modifier = Modifier.verticalScroll(rememberScrollState())) {
                Text(
                    stringResource(R.string.app_name),
                    fontWeight = FontWeight.Bold, fontSize = 22.sp,
                    modifier = Modifier.padding(horizontal = 28.dp, vertical = 24.dp)
                )
                Section.values().forEach { s ->
                    NavigationDrawerItem(
                        icon = { Text(s.icon, fontSize = 18.sp) },
                        label = { Text(stringResource(s.labelRes)) },
                        badge = {
                            if (s == Section.CONFLICTS && openConflicts > 0) Badge { Text(openConflicts.toString()) }
                        },
                        selected = s == section,
                        onClick = { section = s; scope.launch { drawerState.close() } },
                        modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
                    )
                }
                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp, horizontal = 16.dp))
                NavigationDrawerItem(
                    icon = { Text("📖", fontSize = 18.sp) },
                    label = { Text(stringResource(R.string.nav_manual)) },
                    selected = false,
                    onClick = { openDoc(context, "manual") },
                    modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
                )
                NavigationDrawerItem(
                    icon = { Text("🛡️", fontSize = 18.sp) },
                    label = { Text(stringResource(R.string.nav_privacy)) },
                    selected = false,
                    onClick = { openDoc(context, "privacy") },
                    modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
                )
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text(stringResource(section.labelRes), fontWeight = FontWeight.Bold) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Text("☰", fontSize = 20.sp)
                        }
                    },
                    actions = {
                        IconButton(onClick = { showLangMenu = true }) { Text("🌐", fontSize = 18.sp) }
                        LanguageMenu(showLangMenu, onDismiss = { showLangMenu = false }) { switchLanguage(context, it) }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    )
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize().padding(padding)) {
                when (section) {
                    Section.OVERVIEW -> OverviewSection(
                        snapshot, endpoints.size, groups, activeGroupId, nearbyDevices,
                        onAddFolder = { folderPickerLauncher.launch(null) },
                        onSyncNow = { scope.launch { onSyncNow() } }
                    )
                    Section.PREVIEW -> PreviewSection(endpoints.size)
                    Section.CONFLICTS -> ConflictsSection()
                    Section.VERSIONS -> VersionsSection()
                    Section.VERIFY -> VerifySection(endpoints.size)
                    Section.FOLDERS -> FoldersSection(endpoints, onAdd = { folderPickerLauncher.launch(null) }, onRemoveFolder)
                    Section.ACTIVITY -> ActivitySection(snapshot)
                    Section.SETTINGS -> SettingsSection(context)
                }
            }
        }
    }
}

/** Dropdown of UI languages; the current one is ticked. */
@Composable
private fun LanguageMenu(expanded: Boolean, onDismiss: () -> Unit, onPick: (String?) -> Unit) {
    val context = androidx.compose.ui.platform.LocalContext.current
    val current = LocaleManager.saved(context)
    DropdownMenu(expanded = expanded, onDismissRequest = onDismiss) {
        DropdownMenuItem(
            text = { Text((if (current == null) "✓ " else "") + stringResource(R.string.settings_language_system)) },
            onClick = { onDismiss(); if (current != null) onPick(null) }
        )
        LocaleManager.options.forEach { (tag, name) ->
            DropdownMenuItem(
                text = { Text((if (current == tag) "✓ " else "") + name) },
                onClick = { onDismiss(); if (current != tag) onPick(tag) }
            )
        }
    }
}

@Composable
private fun OverviewSection(
    snapshot: SyncSnapshotState,
    folderCount: Int,
    groups: List<SyncGroup>,
    activeGroupId: String,
    nearbyDevices: List<DiscoveredDevice>,
    onAddFolder: () -> Unit,
    onSyncNow: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
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
                Text(stringResource(R.string.status_folder_count, folderCount), fontSize = 14.sp)
                Text(stringResource(R.string.status_tracked_files, snapshot.trackedFilesCount), fontSize = 14.sp)
                Text(stringResource(R.string.status_recent_transfers, snapshot.recentTransfers), fontSize = 14.sp)
                Text(
                    stringResource(
                        R.string.status_last_sync_time,
                        snapshot.lastSyncTime.ifEmpty { stringResource(R.string.status_last_sync_never) }
                    ),
                    fontSize = 14.sp
                )
                if (snapshot.error != null) {
                    Text(stringResource(R.string.status_error_prefix, snapshot.error ?: ""), fontSize = 13.sp, color = Color.Red)
                }
            }
        }

        SyncGroupCard(groups = groups, activeGroupId = activeGroupId)

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Button(onClick = onAddFolder, modifier = Modifier.weight(1f)) {
                Text(stringResource(R.string.btn_add_folder))
            }
            OutlinedButton(
                onClick = onSyncNow,
                enabled = folderCount >= 2 && snapshot.phase != "SYNCING",
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
    }
}

@Composable
private fun FoldersSection(endpoints: List<AndroidEndpoint>, onAdd: () -> Unit, onRemoveFolder: (String) -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Button(onClick = onAdd, modifier = Modifier.fillMaxWidth()) { Text(stringResource(R.string.btn_add_folder)) }
        if (endpoints.isEmpty()) {
            Box(modifier = Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                Text(stringResource(R.string.empty_folders_hint), color = Color.Gray, lineHeight = 20.sp)
            }
        } else {
            LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(endpoints, key = { it.uriString }) { ep ->
                    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(8.dp)) {
                        Row(
                            modifier = Modifier.padding(12.dp).fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(ep.displayName, fontWeight = FontWeight.Bold)
                                Text(ep.uriString, fontSize = 11.sp, color = Color.Gray, maxLines = 1)
                            }
                            TextButton(onClick = { onRemoveFolder(ep.id) }) {
                                Text(stringResource(R.string.btn_remove), color = Color(0xFFC62828))
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ActivitySection(snapshot: SyncSnapshotState) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        if (snapshot.logs.isEmpty()) {
            Text(stringResource(R.string.logs_empty), fontSize = 13.sp, color = Color.Gray)
        } else {
            LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
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

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
private fun SettingsSection(context: android.content.Context) {
    val current = LocaleManager.saved(context)
    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(stringResource(R.string.settings_language_title), fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
        androidx.compose.foundation.layout.FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = current == null,
                onClick = { if (current != null) switchLanguage(context, null) },
                label = { Text(stringResource(R.string.settings_language_system)) }
            )
            LocaleManager.options.forEach { (tag, name) ->
                FilterChip(
                    selected = current == tag,
                    onClick = { if (current != tag) switchLanguage(context, tag) },
                    label = { Text(name) }
                )
            }
        }
        HorizontalDivider()
        OutlinedButton(onClick = { openDoc(context, "manual") }, modifier = Modifier.fillMaxWidth()) {
            Text("📖  " + stringResource(R.string.nav_manual))
        }
        OutlinedButton(onClick = { openDoc(context, "privacy") }, modifier = Modifier.fillMaxWidth()) {
            Text("🛡️  " + stringResource(R.string.nav_privacy))
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
