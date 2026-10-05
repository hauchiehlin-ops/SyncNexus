package com.syncnexus.app

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/** In-app language choice. `null` follows the system language. Applied by wrapping the base context of each component. */
object LocaleManager {
    /** Language tag to show in the picker, in the order of the menu. Names are written in their own language. */
    val options = listOf(
        "zh-TW" to "繁體中文",
        "zh-CN" to "简体中文",
        "en" to "English",
        "ja" to "日本語",
        "ko" to "한국어",
        "th" to "ภาษาไทย",
    )

    private const val PREFS = "syncnexus_prefs"
    private const val KEY = "ui_language"

    fun saved(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)

    fun save(context: Context, tag: String?) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().apply {
            if (tag == null) remove(KEY) else putString(KEY, tag)
        }.apply()
    }

    fun wrap(base: Context): Context {
        val tag = saved(base) ?: return base
        val config = Configuration(base.resources.configuration)
        val locale = Locale.forLanguageTag(tag)
        Locale.setDefault(locale)
        config.setLocale(locale)
        return base.createConfigurationContext(config)
    }

    /** Which documentation language exists for this UI language (Android docs: Traditional Chinese and English). */
    fun docSuffix(context: Context): String {
        val tag = saved(context) ?: Locale.getDefault().toLanguageTag()
        return if (tag.startsWith("zh-TW") || tag.startsWith("zh-Hant") || tag.startsWith("zh-HK")) "zh-Hant" else "en"
    }
}
