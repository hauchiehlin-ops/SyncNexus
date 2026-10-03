namespace SyncNexus.Core.Model;

/// <summary>
/// Display names for sync groups. Unnamed groups store an empty name (never a language-specific text) and are shown
/// as "New Group", "New Group 2"... in the selected language. The built-in default group is recognised by id and by
/// any of its known localized names. Names the user typed are returned unchanged.
/// </summary>
public static class SyncGroupNaming
{
    public static string Display(
        SyncGroup group,
        IReadOnlyList<SyncGroup> all,
        string defaultGroupName,
        string newGroupName,
        IEnumerable<string> defaultGroupNameVariants)
    {
        if (group.Id == "default" && defaultGroupNameVariants.Contains(group.Name))
        {
            return defaultGroupName;
        }

        if (string.IsNullOrEmpty(group.Name))
        {
            var unnamed = all.Where(g => string.IsNullOrEmpty(g.Name)).ToList();
            var index = unnamed.FindIndex(g => g.Id == group.Id);
            var n = (index < 0 ? 0 : index) + 1;
            return n > 1 ? $"{newGroupName} {n}" : newGroupName;
        }

        return group.Name;
    }
}
