package com.syncnexus.app

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.DateFormat
import java.util.Date

private fun dateText(ms: Long): String = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(Date(ms))
private fun sizeText(bytes: Long): String = when {
    bytes < 1024 -> "$bytes B"
    bytes < 1024 * 1024 -> "%.1f KB".format(bytes / 1024.0)
    else -> "%.1f MB".format(bytes / 1024.0 / 1024.0)
}

@Composable
private fun SectionIntro(text: String) = Text(text, fontSize = 13.sp, color = Color.Gray, lineHeight = 18.sp)

@Composable
private fun EmptyNote(text: String) = Box(Modifier.fillMaxWidth().padding(vertical = 32.dp), contentAlignment = Alignment.Center) {
    Text(text, color = Color.Gray)
}

/** Diff preview: the plan the next sync would carry out. */
@Composable
fun PreviewSection(folderCount: Int) {
    val state by SyncNexusEngineBridge.preview.collectAsState()
    val busy = state.running
    Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionIntro(stringResource(R.string.preview_desc))
        Button(onClick = { SyncNexusEngineBridge.requestPreview() }, enabled = folderCount >= 2 && !busy, modifier = Modifier.fillMaxWidth()) {
            Text(stringResource(if (busy) R.string.preview_running else R.string.preview_run))
        }
        if (folderCount < 2) EmptyNote(stringResource(R.string.preview_need_two))
        else if (state.ready) {
            if (state.items.isEmpty()) EmptyNote(stringResource(R.string.preview_empty))
            else {
                Text(stringResource(R.string.preview_summary, state.items.size), fontWeight = FontWeight.SemiBold)
                LazyColumn(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(state.items) { it ->
                        Card(Modifier.fillMaxWidth(), shape = RoundedCornerShape(8.dp)) {
                            Column(Modifier.padding(12.dp)) {
                                Text(it.path, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                val what = when {
                                    it.kind == PlanKind.CONFLICT -> stringResource(R.string.preview_conflict, it.target)
                                    it.overwrites -> stringResource(R.string.preview_update, it.target)
                                    else -> stringResource(R.string.preview_new, it.target)
                                }
                                Text(what, fontSize = 13.sp, color = if (it.kind == PlanKind.CONFLICT) Color(0xFFC62828) else Color(0xFF2E7D32))
                                Text(stringResource(R.string.preview_from, it.source), fontSize = 12.sp, color = Color.Gray)
                            }
                        }
                    }
                }
            }
        }
    }
}

/** Open conflicts: the same file was edited in two places. */
@Composable
fun ConflictsSection() {
    val conflicts by SyncNexusEngineBridge.conflicts.collectAsState()
    Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionIntro(stringResource(R.string.conflicts_desc))
        if (conflicts.isEmpty()) EmptyNote(stringResource(R.string.conflicts_empty))
        else LazyColumn(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            items(conflicts, key = { it.id }) { c ->
                Card(Modifier.fillMaxWidth(), shape = RoundedCornerShape(10.dp)) {
                    Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text(c.path, fontWeight = FontWeight.Bold)
                        Text(stringResource(R.string.conflict_where, c.endpoint) + " · " + dateText(c.time), fontSize = 12.sp, color = Color.Gray)
                        Text(c.copyPath.substringAfterLast('/'), fontSize = 12.sp, color = Color(0xFFC62828))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Button(onClick = { SyncNexusEngineBridge.resolveConflict(c.id, keepMain = true) }, modifier = Modifier.weight(1f)) {
                                Text(stringResource(R.string.conflict_keep_main), fontSize = 12.sp)
                            }
                            OutlinedButton(onClick = { SyncNexusEngineBridge.resolveConflict(c.id, keepMain = false) }, modifier = Modifier.weight(1f)) {
                                Text(stringResource(R.string.conflict_keep_copy), fontSize = 12.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun reasonText(reason: String): String = stringResource(
    when (reason) {
        "conflict-copy" -> R.string.version_reason_conflict
        "damaged" -> R.string.version_reason_damaged
        "replaced-by-restore" -> R.string.version_reason_restore
        else -> R.string.version_reason_replaced
    }
)

/** Files that were replaced during sync, kept so nothing is lost. */
@Composable
fun VersionsSection() {
    val versions by SyncNexusEngineBridge.versions.collectAsState()
    var confirmRestore by remember { mutableStateOf<VersionItem?>(null) }
    Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionIntro(stringResource(R.string.versions_desc, SyncEngine.VERSION_DAYS))
        if (versions.isEmpty()) EmptyNote(stringResource(R.string.versions_empty))
        else LazyColumn(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(versions, key = { it.id }) { v ->
                Card(Modifier.fillMaxWidth(), shape = RoundedCornerShape(8.dp)) {
                    Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(v.path, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text(stringResource(R.string.versions_from, v.endpoint, dateText(v.time)) + " · " + sizeText(v.size), fontSize = 12.sp, color = Color.Gray)
                        Text(reasonText(v.reason), fontSize = 12.sp)
                        Row {
                            TextButton(onClick = { confirmRestore = v }) { Text(stringResource(R.string.versions_restore)) }
                            TextButton(onClick = { SyncNexusEngineBridge.deleteVersion(v.id) }) {
                                Text(stringResource(R.string.versions_delete), color = Color(0xFFC62828))
                            }
                        }
                    }
                }
            }
        }
    }
    confirmRestore?.let { v ->
        AlertDialog(
            onDismissRequest = { confirmRestore = null },
            title = { Text(stringResource(R.string.versions_restore) + "？") },
            text = { Text(v.path) },
            confirmButton = { TextButton(onClick = { SyncNexusEngineBridge.restoreVersion(v.id); confirmRestore = null }) { Text(stringResource(R.string.versions_restore)) } },
            dismissButton = { TextButton(onClick = { confirmRestore = null }) { Text(stringResource(R.string.group_cancel)) } }
        )
    }
}

/** Verification: re-read everything and compare with the record. */
@Composable
fun VerifySection(folderCount: Int) {
    val runs by SyncNexusEngineBridge.verifyRuns.collectAsState()
    val issues by SyncNexusEngineBridge.integrity.collectAsState()
    val verifying by SyncNexusEngineBridge.verifying.collectAsState()
    Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionIntro(stringResource(R.string.verify_desc))
        Button(onClick = { SyncNexusEngineBridge.runVerification() }, enabled = folderCount >= 1 && !verifying, modifier = Modifier.fillMaxWidth()) {
            Text(stringResource(if (verifying) R.string.verify_running else R.string.verify_run))
        }
        LazyColumn(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            if (issues.isNotEmpty()) {
                item { Text(stringResource(R.string.verify_issues_title), fontWeight = FontWeight.SemiBold, color = Color(0xFFC62828)) }
                items(issues, key = { it.endpoint + "\u0000" + it.path }) { i ->
                    Card(Modifier.fillMaxWidth(), shape = RoundedCornerShape(8.dp)) {
                        Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(i.path, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                            Text(stringResource(R.string.verify_issue_desc, i.endpoint), fontSize = 12.sp, color = Color(0xFFC62828))
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                Button(onClick = { SyncNexusEngineBridge.resolveIntegrity(i, restore = true) }, modifier = Modifier.weight(1f)) {
                                    Text(stringResource(R.string.verify_restore), fontSize = 12.sp)
                                }
                                OutlinedButton(onClick = { SyncNexusEngineBridge.resolveIntegrity(i, restore = false) }, modifier = Modifier.weight(1f)) {
                                    Text(stringResource(R.string.verify_accept), fontSize = 12.sp)
                                }
                            }
                        }
                    }
                }
            }
            item { Text(stringResource(R.string.verify_history), fontWeight = FontWeight.SemiBold) }
            if (runs.isEmpty()) item { Text(stringResource(R.string.verify_history_empty), color = Color.Gray, fontSize = 13.sp) }
            items(runs, key = { it.time }) { r ->
                val result = if (r.issues == 0) stringResource(R.string.verify_all_ok) else stringResource(R.string.verify_n_issues, r.issues)
                Text(
                    stringResource(R.string.verify_line, dateText(r.time), r.checked, result),
                    fontSize = 13.sp, color = if (r.issues == 0) Color(0xFF2E7D32) else Color(0xFFC62828)
                )
            }
        }
    }
}
