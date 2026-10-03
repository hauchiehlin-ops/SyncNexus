package com.syncnexus.app

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/**
 * Display names for sync groups. Unnamed groups store an empty name (never a language-specific text) and are shown
 * as "New Group", "New Group 2"... in the current language. The built-in default group is recognised by id and by
 * any of its known localized names. Names the user typed are returned unchanged.
 */
object SyncGroupNaming {
    private val supportedLocales = listOf(
        Locale.ENGLISH, Locale.TRADITIONAL_CHINESE, Locale.SIMPLIFIED_CHINESE,
        Locale.JAPANESE, Locale.KOREAN, Locale("th")
    )

    /** Pure logic (no Android dependency). */
    fun display(
        group: SyncGroup,
        all: List<SyncGroup>,
        defaultGroupName: String,
        newGroupName: String,
        defaultGroupNameVariants: Collection<String>
    ): String {
        if (group.id == "default" && group.name in defaultGroupNameVariants) return defaultGroupName
        if (group.name.isEmpty()) {
            val n = all.filter { it.name.isEmpty() }.indexOfFirst { it.id == group.id }.coerceAtLeast(0) + 1
            return if (n > 1) "$newGroupName $n" else newGroupName
        }
        return group.name
    }

    /** Name shown in the UI, in the language the app is currently using. */
    fun display(context: Context, group: SyncGroup, all: List<SyncGroup>): String =
        display(
            group, all,
            context.getString(R.string.group_default_name),
            context.getString(R.string.group_new_default_name),
            defaultNameVariants(context)
        )

    private fun defaultNameVariants(context: Context): Set<String> {
        val names = supportedLocales.map { locale ->
            val config = Configuration(context.resources.configuration).apply { setLocale(locale) }
            context.createConfigurationContext(config).getString(R.string.group_default_name)
        }
        return (names + listOf("預設群組", "預設同步群組")).toSet()
    }

    /** Creating a group: an empty name is kept empty so that it follows the language later. */
    fun newGroup(name: String, icon: String = "folder"): SyncGroup =
        SyncGroup(id = "group_" + java.util.UUID.randomUUID().toString().replace("-", "").take(8), name = name.trim(), icon = icon)
}
