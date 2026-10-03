namespace SyncNexus.Core.Model;

public enum GroupHealth
{
    Ok,
    NeedsFolders,
    Attention
}

/// <summary>State of a sync group and of the whole app, for the tray menu and tooltip.</summary>
public static class GroupStatusLogic
{
    /// <summary>Open conflicts or an offline folder need attention; fewer than 2 folders cannot sync yet.</summary>
    public static GroupHealth Evaluate(int endpointCount, int offlineCount, int openConflicts)
    {
        if (openConflicts > 0 || offlineCount > 0) return GroupHealth.Attention;
        if (endpointCount < 2) return GroupHealth.NeedsFolders;
        return GroupHealth.Ok;
    }

    /// <summary>
    /// Attention first; a group that merely waits for folders does not spoil "all in sync";
    /// "needs folders" only when every group is still waiting.
    /// </summary>
    public static GroupHealth Overall(IEnumerable<GroupHealth> groups)
    {
        var list = groups.ToList();
        if (list.Any(h => h == GroupHealth.Attention)) return GroupHealth.Attention;
        if (list.Count > 0 && list.All(h => h == GroupHealth.NeedsFolders)) return GroupHealth.NeedsFolders;
        return GroupHealth.Ok;
    }
}
