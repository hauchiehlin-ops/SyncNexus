package com.syncnexus.app

import java.util.UUID

/** Pure list operations for sync groups (no Android dependency, unit-tested). */
object SyncGroupOps {
    const val DEFAULT_ID = "default"
    const val DEFAULT_MARKER_NAME = "預設群組"   // fixed marker; shown in the current language by SyncGroupNaming

    fun initial(): List<SyncGroup> = listOf(SyncGroup(DEFAULT_ID, DEFAULT_MARKER_NAME, "folder"))

    fun add(groups: List<SyncGroup>, name: String, icon: String = "folder"): Pair<List<SyncGroup>, SyncGroup> {
        val g = SyncGroupNaming.newGroup(name, icon)
        return (groups + g) to g
    }

    fun update(groups: List<SyncGroup>, id: String, name: String, icon: String): List<SyncGroup> {
        val current = groups.firstOrNull { it.id == id } ?: return groups
        // an unnamed group may stay unnamed; anything else needs text
        if (name.isBlank() && current.name.isNotEmpty()) return groups
        return groups.map { if (it.id == id) it.copy(name = name.trim(), icon = icon) else it }
    }

    /** Never removes the last group. */
    fun remove(groups: List<SyncGroup>, id: String): List<SyncGroup> =
        if (groups.size <= 1 || groups.none { it.id == id }) groups else groups.filterNot { it.id == id }

    /** The default group keeps its original preferences key so existing installs keep their folders. */
    fun endpointsKey(groupId: String): String = if (groupId == DEFAULT_ID) "endpoints_json" else "endpoints_json_$groupId"

    /** The document id inside a SAF tree URI, e.g. "primary:Documents/A" (percent-decoded, no trailing slash). */
    fun treeDocumentId(uriString: String): String {
        val tail = uriString.substringAfter("/tree/", uriString).substringBefore("/document/")
        return java.net.URLDecoder.decode(tail, "UTF-8").trimEnd('/')
    }

    /** True when both folders are the same, or one lies inside the other (they would sync the same files twice). */
    fun overlaps(a: String, b: String): Boolean {
        val x = treeDocumentId(a)
        val y = treeDocumentId(b)
        return x == y || x.startsWith("$y/") || y.startsWith("$x/")
    }

    /** A folder may belong to only one group, otherwise two groups would sync the same files. Same or nested counts. */
    fun groupUsing(uriString: String, endpointsByGroup: Map<String, List<AndroidEndpoint>>, exceptGroup: String): String? =
        endpointsByGroup.entries.firstOrNull { (gid, list) -> gid != exceptGroup && list.any { overlaps(it.uriString, uriString) } }?.key

    /** Another folder of the same group that contains, or lies inside, [uriString] (not the identical folder: that is just re-adding it). */
    fun nestedInSameGroup(uriString: String, groupEndpoints: List<AndroidEndpoint>): AndroidEndpoint? =
        groupEndpoints.firstOrNull { it.uriString != uriString && overlaps(it.uriString, uriString) }

    @Suppress("unused")
    fun randomId(): String = "group_" + UUID.randomUUID().toString().replace("-", "").take(8)
}
