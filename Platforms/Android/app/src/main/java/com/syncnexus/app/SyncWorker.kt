package com.syncnexus.app

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/**
 * Android WorkManager 定期背景對帳任務
 * 支援低耗電模式下的定時喚醒校驗
 */
class SyncWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        return try {
            // 執行背景對帳作業
            SyncNexusEngineBridge.runReconciliation()
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }

    companion object {
        fun enqueuePeriodic(context: Context) {
            val constraints = androidx.work.Constraints.Builder()
                .setRequiresBatteryNotLow(true) // 借鏡 FolderSync：電量過低時暫緩背景定時對帳
                .build()

            val request = androidx.work.PeriodicWorkRequestBuilder<SyncWorker>(
                1, java.util.concurrent.TimeUnit.HOURS
            )
                .setConstraints(constraints)
                .build()

            androidx.work.WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "syncnexus_periodic_sync",
                androidx.work.ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }
    }
}
