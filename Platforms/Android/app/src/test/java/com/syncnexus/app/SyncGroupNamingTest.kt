package com.syncnexus.app

import org.junit.Assert.assertEquals
import org.junit.Test

class SyncGroupNamingTest {
    private val variants = listOf("預設群組", "默认群组", "Default Group", "預設同步群組")

    @Test
    fun unnamedGroupsAreNumberedAndLocalized() {
        val a = SyncGroup("group_a", "")
        val b = SyncGroup("group_b", "")
        val named = SyncGroup("group_c", "家庭相片")
        val all = listOf(a, named, b)
        assertEquals("새 그룹", SyncGroupNaming.display(a, all, "기본 그룹", "새 그룹", variants))
        assertEquals("새 그룹 2", SyncGroupNaming.display(b, all, "기본 그룹", "새 그룹", variants))
        assertEquals("家庭相片", SyncGroupNaming.display(named, all, "기본 그룹", "새 그룹", variants))
    }

    @Test
    fun builtInDefaultFollowsLanguageButRenamedKeepsName() {
        val def = SyncGroup("default", "預設群組")
        assertEquals("Default Group", SyncGroupNaming.display(def, listOf(def), "Default Group", "New Group", variants))
        val renamed = SyncGroup("default", "測試群組")
        assertEquals("測試群組", SyncGroupNaming.display(renamed, listOf(renamed), "Default Group", "New Group", variants))
    }

    @Test
    fun newGroupKeepsEmptyName() {
        assertEquals("", SyncGroupNaming.newGroup("  ").name)
    }

    @Test
    fun opsKeepAtLeastOneGroupAndUnnamedMayStayUnnamed() {
        var groups = SyncGroupOps.initial()
        val (g2, created) = SyncGroupOps.add(groups, "")
        groups = g2
        assertEquals(2, groups.size)
        assertEquals("", created.name)
        // unnamed group can be saved unnamed (icon change), a named one cannot become blank
        assertEquals("", SyncGroupOps.update(groups, created.id, "", "star").first { it.id == created.id }.name)
        assertEquals("預設群組", SyncGroupOps.update(groups, "default", "  ", "star").first { it.id == "default" }.name)
        groups = SyncGroupOps.remove(groups, created.id)
        assertEquals(1, groups.size)
        assertEquals(1, SyncGroupOps.remove(groups, "default").size)   // never the last one
    }

    @Test
    fun endpointKeyAndFolderOwnership() {
        assertEquals("endpoints_json", SyncGroupOps.endpointsKey("default"))
        assertEquals("endpoints_json_group_x", SyncGroupOps.endpointsKey("group_x"))
        val ep = AndroidEndpoint("a", "content://x", "a")
        assertEquals("default", SyncGroupOps.groupUsing("content://x", mapOf("default" to listOf(ep), "group_x" to emptyList()), "group_x"))
        assertEquals(null, SyncGroupOps.groupUsing("content://x", mapOf("default" to listOf(ep)), "default"))
    }

    // ---- backups / import / nested paths ----

    private fun ep(id: String, uri: String) = AndroidEndpoint(id, uri, id)
    private fun snap(vararg pairs: Pair<SyncGroup, List<AndroidEndpoint>>) =
        GroupBackupLogic.Snapshot(pairs.map { it.first }, pairs.associate { it.first.id to it.second })
    private fun meta(name: String, s: GroupBackupLogic.Snapshot) =
        GroupBackupLogic.BackupMeta(name, 0, GroupBackupLogic.fingerprint(s), s.groups.map { it.name }, s.endpointTotal)

    @Test
    fun backupSkipsUnchangedAndEmptyButNotForced() {
        val def = SyncGroup("default", "預設群組")
        val full = snap(def to listOf(ep("a", "content://a"), ep("b", "content://b")))
        val empty = snap(def to emptyList())
        assertEquals(true, GroupBackupLogic.shouldBackup(full, emptyList(), false))
        assertEquals(false, GroupBackupLogic.shouldBackup(full, listOf(meta("20260101-000000", full)), false))   // unchanged
        assertEquals(false, GroupBackupLogic.shouldBackup(empty, listOf(meta("20260101-000000", full)), false))  // empty never replaces good
        assertEquals(true, GroupBackupLogic.shouldBackup(empty, listOf(meta("20260101-000000", full)), true))    // forced (before restore)
        assertEquals(true, GroupBackupLogic.shouldBackup(empty, emptyList(), false))                              // very first launch
    }

    @Test
    fun rotationKeepsNewestAndTheLastGoodOne() {
        val def = SyncGroup("default", "預設群組")
        val good = snap(def to listOf(ep("a", "content://a")))
        val empty = snap(def to emptyList())
        val metas = listOf(meta("01", good)) + (2..14).map { meta(it.toString().padStart(2, '0'), empty) }
        val del = GroupBackupLogic.toDelete(metas, keep = 10)
        assertEquals(false, "01" in del)          // oldest, but the only one that still holds folders
        assertEquals(listOf("02", "03", "04"), del)
    }

    @Test
    fun importNeverOverwritesConfiguredGroupsButFillsEmptyOnes() {
        val def = SyncGroup("default", "預設群組")
        val g2 = SyncGroup("group_x", "第二次測試")
        val current = snap(def to emptyList(), g2 to listOf(ep("n", "content://n")))
        val incoming = snap(
            SyncGroup("default", "測試群組", "doc.text") to listOf(ep("a", "content://a"), ep("b", "content://b")),
            g2 to listOf(ep("x", "content://x"))
        )
        val r = GroupBackupLogic.merge(current, incoming)
        assertEquals(listOf("測試群組"), r.imported.map { it.name })
        assertEquals(listOf("第二次測試"), r.kept.map { it.name })
        assertEquals(2, r.endpointCount)
        assertEquals(2, r.merged.endpoints["default"]?.size)
        assertEquals("content://n", r.merged.endpoints["group_x"]?.single()?.uriString)   // untouched
    }

    @Test
    fun importDropsFoldersAnotherGroupAlreadyUses() {
        val def = SyncGroup("default", "預設群組")
        val g2 = SyncGroup("group_x", "X")
        val current = snap(def to emptyList(), g2 to listOf(ep("n", "content://same")))
        val incoming = snap(def to listOf(ep("a", "content://same")))
        val r = GroupBackupLogic.merge(current, incoming)
        assertEquals(0, r.imported.size)
    }

    @Test
    fun nestedFolderDetectionOnSafTreeUris() {
        val a = "content://com.android.externalstorage.documents/tree/primary%3ADocuments%2FWork"
        val inside = "content://com.android.externalstorage.documents/tree/primary%3ADocuments%2FWork%2FSub"
        val sibling = "content://com.android.externalstorage.documents/tree/primary%3ADocuments%2FWorkshop"
        assertEquals(true, SyncGroupOps.overlaps(a, a))
        assertEquals(true, SyncGroupOps.overlaps(a, inside))
        assertEquals(true, SyncGroupOps.overlaps(inside, a))
        assertEquals(false, SyncGroupOps.overlaps(a, sibling))          // "Work" is not a parent of "Workshop"
        assertEquals("group_x", SyncGroupOps.groupUsing(inside, mapOf("group_x" to listOf(ep("w", a))), "default"))
        assertEquals("s", SyncGroupOps.nestedInSameGroup(inside, listOf(ep("s", a)))?.id)
        assertEquals(null, SyncGroupOps.nestedInSameGroup(a, listOf(ep("s", a))))   // identical = just re-adding
    }

    // ---- per-group notification state ----

    @Test
    fun groupStatusAndOverall() {
        assertEquals(GroupStatusLogic.Status.ATTENTION, GroupStatusLogic.statusOf(3, false, 2, null))
        assertEquals(GroupStatusLogic.Status.ATTENTION, GroupStatusLogic.statusOf(3, true, 0, "boom"))
        assertEquals(GroupStatusLogic.Status.SYNCING, GroupStatusLogic.statusOf(3, true, 0, null))
        assertEquals(GroupStatusLogic.Status.NEEDS_FOLDERS, GroupStatusLogic.statusOf(1, false, 0, null))
        assertEquals(GroupStatusLogic.Status.OK, GroupStatusLogic.statusOf(2, false, 0, null))

        fun line(s: GroupStatusLogic.Status) = GroupStatusLogic.GroupLine("g", 2, s)
        val ok = GroupStatusLogic.Status.OK
        val wait = GroupStatusLogic.Status.NEEDS_FOLDERS
        assertEquals(ok, GroupStatusLogic.overall(listOf(line(ok), line(wait))))     // an unfinished new group does not spoil "all in sync"
        assertEquals(wait, GroupStatusLogic.overall(listOf(line(wait))))
        assertEquals(GroupStatusLogic.Status.SYNCING, GroupStatusLogic.overall(listOf(line(ok), line(GroupStatusLogic.Status.SYNCING))))
        assertEquals(GroupStatusLogic.Status.ATTENTION, GroupStatusLogic.overall(listOf(line(GroupStatusLogic.Status.SYNCING), line(GroupStatusLogic.Status.ATTENTION))))
    }

    @Test
    fun folderIconFilesAndOsLitterAreIgnored() {
        assertEquals(true, AndroidIgnoreRules.isIgnored("Icon\r"))                 // macOS custom folder icon
        assertEquals(true, AndroidIgnoreRules.isIgnored("._Icon\r"))
        assertEquals(true, AndroidIgnoreRules.isIgnored(".syncnexus-icon.ico"))     // Windows folder icon
        assertEquals(true, AndroidIgnoreRules.isIgnored(".DS_Store"))               // was silently never matched before
        assertEquals(false, AndroidIgnoreRules.isIgnored("Icon.png"))
    }
}
