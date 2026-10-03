package com.syncnexus.app

/** Pure logic for registry backups and settings import (no Android dependency, unit-tested). */
object GroupBackupLogic {
    const val KEEP = 10

    data class Snapshot(val groups: List<SyncGroup>, val endpoints: Map<String, List<AndroidEndpoint>>) {
        val endpointTotal: Int get() = groups.sumOf { endpoints[it.id]?.size ?: 0 }
    }

    data class BackupMeta(
        val name: String,            // folder name, sorts oldest -> newest
        val time: Long,
        val fingerprint: String,
        val groupNames: List<String>,
        val endpointTotal: Int
    )

    data class MergeResult(
        val merged: Snapshot,
        val imported: List<SyncGroup>,
        val kept: List<SyncGroup>,
        val endpointCount: Int
    )

    fun fingerprint(s: Snapshot): String =
        s.groups.joinToString(";") { "${it.id}|${it.name}|${it.icon}" } + "#" +
            s.groups.joinToString(";") { g ->
                (s.endpoints[g.id] ?: emptyList()).sortedBy { it.id }.joinToString(",") { "${it.id}=${it.uriString}" }
            }

    /** Skips unchanged state, and never lets an empty state push out good backups. */
    fun shouldBackup(snapshot: Snapshot, existing: List<BackupMeta>, force: Boolean): Boolean {
        if (force) return true
        if (snapshot.endpointTotal == 0 && existing.isNotEmpty()) return false
        val last = existing.maxByOrNull { it.name }
        return last == null || last.fingerprint != fingerprint(snapshot)
    }

    /** Keeps the newest [keep] backups plus the newest one that still holds folders. */
    fun toDelete(existing: List<BackupMeta>, keep: Int = KEEP): List<String> {
        val sorted = existing.sortedBy { it.name }
        if (sorted.size <= keep) return emptyList()
        val keepGood = sorted.lastOrNull { it.endpointTotal > 0 }?.name
        return sorted.dropLast(keep).map { it.name }.filter { it != keepGood }
    }

    /** Import rule: configured groups are never overwritten; empty ones are filled; unknown ones are added. */
    fun merge(current: Snapshot, incoming: Snapshot): MergeResult {
        var groups = current.groups
        val eps = current.endpoints.toMutableMap()
        val imported = mutableListOf<SyncGroup>()
        val kept = mutableListOf<SyncGroup>()
        var count = 0

        for (g in incoming.groups) {
            // a folder may belong to one group only: drop incoming folders another group already uses
            val usedElsewhere = eps.filterKeys { it != g.id }.values.flatten().map { it.uriString }.toSet()
            val wanted = (incoming.endpoints[g.id] ?: emptyList()).filter { it.uriString !in usedElsewhere }
            if (wanted.isEmpty()) continue

            val existing = groups.firstOrNull { it.id == g.id }
            if (existing != null && (eps[g.id]?.size ?: 0) > 0) {
                kept.add(existing)
                continue
            }
            groups = if (existing != null) groups.map { if (it.id == g.id) g else it } else groups + g
            eps[g.id] = wanted
            imported.add(g)
            count += wanted.size
        }
        return MergeResult(Snapshot(groups, eps), imported, kept, count)
    }
}
