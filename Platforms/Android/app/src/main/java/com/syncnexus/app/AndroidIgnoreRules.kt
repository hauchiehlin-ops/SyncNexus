package com.syncnexus.app

/** 系統暫存與垃圾檔案排除規則（結合 SyncCore 與 Android 行動端特定相簿快取與 .nomedia）。Pure logic, unit-tested. */
object AndroidIgnoreRules {
    private val ignoredExact = setOf(
        ".DS_Store", "Thumbs.db", "desktop.ini", ".syncnexus-endpoint", ".syncnexus-history",
        ".nomedia", ".thumbnails", ".thumb", ".cache", "albumthumbs", "lost.dir",
        "Icon\r", ".syncnexus-icon.ico"   // custom folder icons made by the macOS / Windows apps: local decoration, never synced
    ).map { it.lowercase() }.toSet()   // names are compared in lower case
    private val ignoredPrefixes = listOf("._", "~$", ".~lock.", ".nexus-")
    private val ignoredSuffixes = listOf(".nexus-part", ".tmp", ".part", ".crdownload")

    fun isIgnored(name: String): Boolean {
        if (ignoredExact.contains(name.lowercase())) return true
        if (ignoredPrefixes.any { name.startsWith(it) }) return true
        if (ignoredSuffixes.any { name.endsWith(it) }) return true
        if (SyncPlanner.isConflictName(name)) return true   // conflict copies stay on their endpoint until resolved
        return false
    }
}
