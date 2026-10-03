package com.syncnexus.app

/** Pure logic for the per-group summary shown in notifications (no Android dependency, unit-tested). */
object GroupStatusLogic {
    enum class Status { OK, SYNCING, ATTENTION, NEEDS_FOLDERS }

    data class GroupLine(val name: String, val folders: Int, val status: Status, val conflicts: Int = 0)

    /** The state of one group. An error or open conflicts need attention; fewer than 2 folders cannot sync yet. */
    fun statusOf(folders: Int, syncing: Boolean, conflicts: Int, error: String?): Status = when {
        error != null || conflicts > 0 -> Status.ATTENTION
        syncing -> Status.SYNCING
        folders < 2 -> Status.NEEDS_FOLDERS
        else -> Status.OK
    }

    /** One state for the whole app: attention first, then syncing; groups that merely wait for folders do not spoil "all in sync". */
    fun overall(lines: List<GroupLine>): Status = when {
        lines.any { it.status == Status.ATTENTION } -> Status.ATTENTION
        lines.any { it.status == Status.SYNCING } -> Status.SYNCING
        lines.isNotEmpty() && lines.all { it.status == Status.NEEDS_FOLDERS } -> Status.NEEDS_FOLDERS
        else -> Status.OK
    }
}
