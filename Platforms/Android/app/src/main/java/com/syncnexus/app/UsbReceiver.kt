package com.syncnexus.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbManager

/**
 * 監聽 Android USB OTG 隨身碟熱插拔事件
 * （借鏡 Resilio Sync 與 FolderSync 的外接儲存設備自動感知）
 */
class UsbReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                // 外接隨身碟插入，自動觸發背景對帳
                SyncNexusEngineBridge.runReconciliation()
            }
            UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                // 外接設備拔除
                SyncNexusEngineBridge.runReconciliation()
            }
        }
    }
}
