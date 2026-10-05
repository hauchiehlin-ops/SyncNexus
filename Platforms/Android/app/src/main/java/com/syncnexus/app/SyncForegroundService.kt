package com.syncnexus.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Android 前台同步服務 (Foreground Service)
 * 確保在背景與鎖定螢幕下，多資料夾資料傳輸不會被系統 Doze 機制強行中斷
 */
class SyncForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "syncnexus_service_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var observing = false

    override fun attachBaseContext(newBase: Context) = super.attachBaseContext(LocaleManager.wrap(newBase))

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    /** Keeps the notification current: one line per sync group, so every group can be checked from the shade. */
    private fun observeGroups() {
        if (observing) return
        observing = true
        scope.launch {
            SyncNexusEngineBridge.groupStates.collect { states ->
                if (states.isNotEmpty()) {
                    val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    manager.notify(NOTIFICATION_ID, buildGroupNotification(states))
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
            else -> {
                val notification = buildNotification(getString(R.string.sync_notification_content))
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                    )
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
                observeGroups()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.sync_notification_channel),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.sync_notification_desc)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(content: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.app_name))
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_popup_sync)
            .setOngoing(true)
            .build()
    }

    private fun statusText(status: GroupStatusLogic.Status, conflicts: Int): String = when (status) {
        GroupStatusLogic.Status.OK -> getString(R.string.sync_status_idle)
        GroupStatusLogic.Status.SYNCING -> getString(R.string.sync_status_syncing)
        GroupStatusLogic.Status.ATTENTION ->
            if (conflicts > 0) getString(R.string.notif_status_conflicts, conflicts) else getString(R.string.notif_status_attention)
        GroupStatusLogic.Status.NEEDS_FOLDERS -> getString(R.string.notif_status_needs_folders)
    }

    /** Title = state of the whole app; expanded text = one line per group ("name · n folders · status"). */
    private fun buildGroupNotification(states: List<SyncNexusEngineBridge.GroupState>): Notification {
        val allGroups = states.map { it.group }
        val lines = states.map {
            GroupStatusLogic.GroupLine(SyncGroupNaming.display(this, it.group, allGroups), it.folders, it.status, it.conflicts)
        }
        val overall = GroupStatusLogic.overall(lines)
        val title = when (overall) {
            GroupStatusLogic.Status.OK -> getString(R.string.sync_status_idle)
            GroupStatusLogic.Status.SYNCING -> getString(R.string.sync_status_syncing)
            GroupStatusLogic.Status.ATTENTION -> getString(R.string.notif_title_attention, lines.count { it.status == GroupStatusLogic.Status.ATTENTION })
            GroupStatusLogic.Status.NEEDS_FOLDERS -> getString(R.string.notif_status_needs_folders)
        }
        val inbox = NotificationCompat.InboxStyle().setBigContentTitle(title)
        val text = lines.map { l ->
            getString(R.string.notif_group_line, l.name, l.folders, statusText(l.status, l.conflicts))
        }
        text.forEach { inbox.addLine(it) }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.app_name) + " · " + title)
            .setContentText(text.firstOrNull() ?: getString(R.string.sync_notification_content))
            .setSubText(if (lines.size > 1) getString(R.string.notif_groups_count, lines.size) else null)
            .setStyle(inbox)
            .setSmallIcon(android.R.drawable.ic_popup_sync)
            .setOngoing(true)
            .build()
    }
}
