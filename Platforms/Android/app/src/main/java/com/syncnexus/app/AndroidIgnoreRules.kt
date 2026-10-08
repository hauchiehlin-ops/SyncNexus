package com.syncnexus.app

enum class ExcludePreset(val id: String, val titleRes: Int, val whyRes: Int) {
    NODE_MODULES("nodeModules", R.string.preset_node_modules, R.string.preset_node_modules_desc),
    GIT("git", R.string.preset_git, R.string.preset_git_desc),
    DATABASES("databases", R.string.preset_databases, R.string.preset_databases_desc),
    PHOTOS_LIBRARIES("photosLibraries", R.string.preset_photos, R.string.preset_photos_desc),
    BUILD_CACHES("buildCaches", R.string.preset_build_caches, R.string.preset_build_caches_desc),
    PYTHON_ENVIRONMENTS("pythonEnvironments", R.string.preset_python, R.string.preset_python_desc)
}

/** 系統暫存與垃圾檔案排除規則（結合 SyncCore 與 Android 行動端特定相簿快取與 .nomedia）。Pure logic, unit-tested. */
object AndroidIgnoreRules {
    val defaultPresets: Set<ExcludePreset> = ExcludePreset.values().toSet()

    private val ignoredExact = setOf(
        ".ds_store", ".trashes", ".spotlight-v100", ".fseventsd", ".temporaryitems",
        ".documentrevisions-v100", "thumbs.db", "desktop.ini", "\$recycle.bin",
        "system volume information", ".syncnexus-endpoint", ".localized", ".syncnexus-history",
        ".nomedia", ".thumbnails", ".thumb", ".cache", "albumthumbs", "lost.dir",
        "icon\r", ".syncnexus-icon.ico"
    )
    private val ignoredPrefixes = listOf("._", "~$", ".~lock.", ".nexus-")
    private val ignoredSuffixes = listOf(
        ".nexus-part", ".tmp", ".part", ".crdownload", ".tmp.drivedownload",
        ".gdoc", ".gsheet", ".gslides", ".gscript", ".gform", ".gdraw", ".gsite", ".gmap", ".gjam", ".gtable"
    )

    private val buildCacheNames = setOf(
        ".build", "build", "target", ".gradle", "deriveddata", "pods",
        "cmakefiles", "cmakescripts", "cmakecache.txt", "compile_commands.json"
    )
    private val buildCachePrefixes = listOf("build-", "build_", "cmake-build-")
    private val buildCacheSuffixes = listOf(".o", ".obj", ".d", ".a", ".dylib.dsym")

    private val pythonNames = setOf("venv", ".venv", "env", "__pycache__", ".pytest_cache", ".mypy_cache", ".tox")

    fun isIgnored(
        name: String,
        relPath: String = "",
        presets: Set<ExcludePreset> = defaultPresets,
        customPatterns: List<String> = emptyList()
    ): Boolean {
        val lowerName = name.lowercase()
        if (ignoredExact.contains(lowerName)) return true
        if (ignoredPrefixes.any { lowerName.startsWith(it) }) return true
        if (ignoredSuffixes.any { lowerName.endsWith(it) }) return true
        if (lowerName.startsWith(".") && lowerName.endsWith(".icloud")) return true
        if (SyncPlanner.isConflictName(name)) return true

        if (presets.contains(ExcludePreset.NODE_MODULES)) {
            if (lowerName == "node_modules") return true
        }
        if (presets.contains(ExcludePreset.GIT)) {
            if (lowerName == ".git") return true
        }
        if (presets.contains(ExcludePreset.DATABASES)) {
            if (lowerName.endsWith("-wal") || lowerName.endsWith("-shm") || lowerName.endsWith("-journal") ||
                lowerName.endsWith(".sqlite-wal") || lowerName.endsWith(".sqlite-shm")) return true
        }
        if (presets.contains(ExcludePreset.PHOTOS_LIBRARIES)) {
            if (lowerName.endsWith(".photoslibrary") || lowerName.endsWith(".photolibrary")) return true
        }
        if (presets.contains(ExcludePreset.BUILD_CACHES)) {
            if (buildCacheNames.contains(lowerName)) return true
            if (buildCachePrefixes.any { lowerName.startsWith(it) }) return true
            if (buildCacheSuffixes.any { lowerName.endsWith(it) }) return true
        }
        if (presets.contains(ExcludePreset.PYTHON_ENVIRONMENTS)) {
            if (pythonNames.contains(lowerName)) return true
        }

        if (customPatterns.isNotEmpty()) {
            val cleanPath = relPath.trim('/')
            for (raw in customPatterns) {
                val pat = raw.trim().trim('/')
                if (pat.isEmpty()) continue
                if (pat.contains("/")) {
                    if (cleanPath.equals(pat, ignoreCase = true) || cleanPath.startsWith("$pat/", ignoreCase = true)) return true
                } else {
                    if (lowerName == pat.lowercase()) return true
                    if (cleanPath.equals(pat, ignoreCase = true) || cleanPath.startsWith("$pat/", ignoreCase = true)) return true
                }
            }
        }

        return false
    }
}
