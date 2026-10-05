package com.syncnexus.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SyncPlannerTest {
    private val eps = listOf("A", "B")
    private fun f(h: String, t: Long = 100) = FileInfo(h, 10, t)

    @Test
    fun newFileIsCopiedToTheOtherEndpoint() {
        val plan = SyncPlanner.plan(eps, mapOf("A" to mapOf("x.txt" to f("1")), "B" to emptyMap()), emptyMap())
        assertEquals(1, plan.size)
        assertEquals(PlanKind.COPY, plan[0].kind)
        assertEquals("A", plan[0].source); assertEquals("B", plan[0].target)
        assertEquals(false, plan[0].overwrites)
    }

    @Test
    fun identicalFilesNeedNothing() {
        val snap = mapOf("A" to mapOf("x" to f("1")), "B" to mapOf("x" to f("1")))
        assertTrue(SyncPlanner.plan(eps, snap, mapOf("x" to Baseline("1"))).isEmpty())
    }

    @Test
    fun editOnOneSideSpreadsEvenIfTheOtherSideIsNewerByClock() {
        // B has a newer mtime but did not change since the last alignment; A's edit is the only real change
        val snap = mapOf("A" to mapOf("x" to f("2", 50)), "B" to mapOf("x" to f("1", 900)))
        val plan = SyncPlanner.plan(eps, snap, mapOf("x" to Baseline("1")))
        assertEquals(1, plan.size)
        assertEquals("A", plan[0].source); assertEquals("B", plan[0].target)
        assertEquals(PlanKind.COPY, plan[0].kind); assertEquals(true, plan[0].overwrites)
    }

    @Test
    fun editsOnBothSidesAreAConflictAndTheNewerOneWins() {
        val snap = mapOf("A" to mapOf("x" to f("2", 100)), "B" to mapOf("x" to f("3", 200)))
        val plan = SyncPlanner.plan(eps, snap, mapOf("x" to Baseline("1")))
        assertEquals(1, plan.size)
        assertEquals(PlanKind.CONFLICT, plan[0].kind)
        assertEquals("B", plan[0].source); assertEquals("A", plan[0].target)
    }

    @Test
    fun differingFilesWithoutHistoryAreAConflict() {
        val snap = mapOf("A" to mapOf("x" to f("2", 100)), "B" to mapOf("x" to f("3", 200)))
        assertEquals(PlanKind.CONFLICT, SyncPlanner.plan(eps, snap, emptyMap())[0].kind)
    }

    @Test
    fun threeEndpointsOnlyTheEditedSideSpreadsToBoth() {
        val three = listOf("A", "B", "C")
        val snap = mapOf("A" to mapOf("x" to f("2")), "B" to mapOf("x" to f("1")), "C" to emptyMap())
        val plan = SyncPlanner.plan(three, snap, mapOf("x" to Baseline("1")))
        assertEquals(setOf("B", "C"), plan.map { it.target }.toSet())
        assertTrue(plan.all { it.source == "A" && it.kind == PlanKind.COPY })
    }

    @Test
    fun deletionIsNotPropagated() {
        // x was aligned before, is now gone on B: it is copied back, never deleted on A
        val snap = mapOf("A" to mapOf("x" to f("1")), "B" to emptyMap())
        val plan = SyncPlanner.plan(eps, snap, mapOf("x" to Baseline("1")))
        assertEquals("B", plan.single().target)
    }

    @Test
    fun unchangedSizeAndMtimeWithDifferentContentIsFlaggedAsCorruption() {
        val base = mapOf("x" to Baseline("1", mapOf("A" to (10L to 100L), "B" to (10L to 100L))))
        val snap = mapOf("A" to mapOf("x" to f("1", 100)), "B" to mapOf("x" to f("9", 100)))
        assertEquals(listOf(IntegrityIssue("B", "x")), SyncPlanner.integrity(snap, base))
        // an ordinary edit changes the mtime and is not an issue
        val edited = mapOf("A" to mapOf("x" to f("1", 100)), "B" to mapOf("x" to f("9", 300)))
        assertTrue(SyncPlanner.integrity(edited, base).isEmpty())
    }

    @Test
    fun conflictNamesRoundTrip() {
        val n = SyncPlanner.conflictName("report.docx", "Disk:1", java.util.Date(0))
        assertTrue(n.startsWith("report (conflict Disk_1 "))
        assertTrue(n.endsWith(").docx"))
        assertTrue(SyncPlanner.isConflictName(n))
        assertTrue(!SyncPlanner.isConflictName("report.docx"))
        assertTrue(SyncPlanner.isConflictName(SyncPlanner.conflictName("Makefile", "A", java.util.Date(0))))
    }
}
