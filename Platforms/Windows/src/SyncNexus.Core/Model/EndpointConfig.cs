namespace SyncNexus.Core.Model;

public enum EndpointRole
{
    Mirror,
    Archive
}

public class EndpointConfig
{
    public string Id { get; set; } = string.Empty;
    public string Root { get; set; } = string.Empty;
    public bool Removable { get; set; }
    public bool PortableNames { get; set; }
    public string Uuid { get; set; } = Guid.NewGuid().ToString().ToUpperInvariant();
    public string? VolumeUuid { get; set; }
    public EndpointRole Role { get; set; } = EndpointRole.Mirror;
    public string? BookmarkData { get; set; }

    public EndpointConfig() { }

    public EndpointConfig(
        string id,
        string root,
        bool removable = false,
        bool portableNames = false,
        string? uuid = null,
        string? volumeUuid = null,
        EndpointRole role = EndpointRole.Mirror,
        string? bookmarkData = null)
    {
        Id = id;
        Root = root;
        Removable = removable;
        PortableNames = portableNames;
        Uuid = uuid ?? Guid.NewGuid().ToString().ToUpperInvariant();
        VolumeUuid = volumeUuid;
        Role = role;
        BookmarkData = bookmarkData;
    }
}

public class EndpointRow
{
    public FileState? State { get; set; }
    public long MtimeNs { get; set; }
    public int SeenRev { get; set; }
}
