using Microsoft.Data.Sqlite;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;

namespace SyncNexus.Core.Storage;

public interface IStore : IDisposable
{
    string DbPath { get; }
    void Initialize();
    List<EndpointConfig> GetEndpoints();
    void SaveEndpoint(EndpointConfig config);
    void RemoveEndpoint(string id);
    bool EndpointHasHistory(string id);
    ConsensusEntry? GetConsensus(string path);
    Dictionary<string, ConsensusEntry> GetAllConsensus();
    void SetConsensus(string path, FileState? state, int rev, string? movedFrom = null);
    EndpointRow? GetRow(string endpoint, string path);
    Dictionary<string, EndpointRow> GetEndpointRows(string endpoint);
    void SetRow(string endpoint, string path, FileState? state, long mtimeNs, int seenRev);
    void AddConflict(string endpoint, string path, string conflictPath, DateTime detectedAt);
    List<ConflictRecord> GetOpenConflicts();
    void CloseConflict(long id, string status);
    void RecordJournal(string op, string endpoint, string path, string? detail, string status);
    List<JournalEntry> GetRecentJournal(int limit = 50);
}

public class SqliteStore : IStore
{
    private readonly SqliteConnection _conn;
    public string DbPath { get; }

    public SqliteStore(string dbPath)
    {
        DbPath = dbPath;
        var dir = Path.GetDirectoryName(dbPath);
        if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);

        var builder = new SqliteConnectionStringBuilder
        {
            DataSource = dbPath,
            Mode = SqliteOpenMode.ReadWriteCreate
        };
        _conn = new SqliteConnection(builder.ConnectionString);
        _conn.Open();

        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL; PRAGMA foreign_keys=ON;";
        cmd.ExecuteNonQuery();

        Initialize();
    }

    public void Initialize()
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = """
        CREATE TABLE IF NOT EXISTS endpoints(
          id TEXT PRIMARY KEY, root TEXT NOT NULL, removable INTEGER NOT NULL, portable INTEGER NOT NULL,
          uuid TEXT NOT NULL, volume_uuid TEXT, role TEXT NOT NULL DEFAULT 'mirror', bookmark_data TEXT);

        CREATE TABLE IF NOT EXISTS consensus(
          path TEXT PRIMARY KEY, hash TEXT, size INTEGER NOT NULL, rev INTEGER NOT NULL,
          kind INTEGER NOT NULL DEFAULT 0, moved_from TEXT, fold TEXT NOT NULL DEFAULT '');

        CREATE TABLE IF NOT EXISTS ep_state(
          endpoint TEXT NOT NULL, path TEXT NOT NULL, hash TEXT, size INTEGER NOT NULL,
          mtime_ns INTEGER NOT NULL, seen_rev INTEGER NOT NULL, kind INTEGER NOT NULL DEFAULT 0,
          fold TEXT NOT NULL DEFAULT '', PRIMARY KEY(endpoint, path));

        CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT NOT NULL);

        CREATE TABLE IF NOT EXISTS conflicts(
          id INTEGER PRIMARY KEY AUTOINCREMENT, endpoint TEXT NOT NULL, path TEXT NOT NULL,
          conflict_path TEXT NOT NULL, detected TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open');

        CREATE TABLE IF NOT EXISTS journal(
          id INTEGER PRIMARY KEY AUTOINCREMENT, ts TEXT NOT NULL, op TEXT NOT NULL,
          endpoint TEXT NOT NULL, path TEXT NOT NULL, detail TEXT, status TEXT NOT NULL);

        CREATE INDEX IF NOT EXISTS consensus_fold ON consensus(fold);
        CREATE INDEX IF NOT EXISTS ep_state_fold ON ep_state(endpoint, fold);
        """;
        cmd.ExecuteNonQuery();
    }

    public List<EndpointConfig> GetEndpoints()
    {
        var list = new List<EndpointConfig>();
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT id, root, removable, portable, uuid, volume_uuid, role, bookmark_data FROM endpoints";
        using var r = cmd.ExecuteReader();
        while (r.Read())
        {
            list.Add(new EndpointConfig(
                id: r.GetString(0),
                root: r.GetString(1),
                removable: r.GetInt32(2) != 0,
                portableNames: r.GetInt32(3) != 0,
                uuid: r.GetString(4),
                volumeUuid: r.IsDBNull(5) ? null : r.GetString(5),
                role: r.IsDBNull(6) || r.GetString(6) == "mirror" ? EndpointRole.Mirror : EndpointRole.Archive,
                bookmarkData: r.IsDBNull(7) ? null : r.GetString(7)
            ));
        }
        return list;
    }

    public void SaveEndpoint(EndpointConfig config)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = """
        INSERT INTO endpoints(id, root, removable, portable, uuid, volume_uuid, role, bookmark_data)
        VALUES ($id, $root, $rem, $port, $uuid, $vol, $role, $book)
        ON CONFLICT(id) DO UPDATE SET
          root=excluded.root, removable=excluded.removable, portable=excluded.portable,
          uuid=excluded.uuid, volume_uuid=excluded.volume_uuid, role=excluded.role, bookmark_data=excluded.bookmark_data
        """;
        cmd.Parameters.AddWithValue("$id", config.Id);
        cmd.Parameters.AddWithValue("$root", config.Root);
        cmd.Parameters.AddWithValue("$rem", config.Removable ? 1 : 0);
        cmd.Parameters.AddWithValue("$port", config.PortableNames ? 1 : 0);
        cmd.Parameters.AddWithValue("$uuid", config.Uuid);
        cmd.Parameters.AddWithValue("$vol", (object?)config.VolumeUuid ?? DBNull.Value);
        cmd.Parameters.AddWithValue("$role", config.Role == EndpointRole.Archive ? "archive" : "mirror");
        cmd.Parameters.AddWithValue("$book", (object?)config.BookmarkData ?? DBNull.Value);
        cmd.ExecuteNonQuery();
    }

    public void RemoveEndpoint(string id)
    {
        using var tx = _conn.BeginTransaction();
        using var cmd = _conn.CreateCommand();
        cmd.Transaction = tx;
        cmd.CommandText = "DELETE FROM ep_state WHERE endpoint = $id; DELETE FROM endpoints WHERE id = $id;";
        cmd.Parameters.AddWithValue("$id", id);
        cmd.ExecuteNonQuery();
        tx.Commit();
    }

    public bool EndpointHasHistory(string id)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT COUNT(*) FROM ep_state WHERE endpoint = $id";
        cmd.Parameters.AddWithValue("$id", id);
        var count = Convert.ToInt64(cmd.ExecuteScalar());
        return count > 0;
    }

    public ConsensusEntry? GetConsensus(string path)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT hash, size, rev, kind, moved_from FROM consensus WHERE path = $path";
        cmd.Parameters.AddWithValue("$path", path);
        using var r = cmd.ExecuteReader();
        if (!r.Read()) return null;
        var hash = r.IsDBNull(0) ? null : r.GetString(0);
        var size = r.GetInt64(1);
        var rev = r.GetInt32(2);
        var kind = (FileKind)r.GetInt32(3);
        var movedFrom = r.IsDBNull(4) ? null : r.GetString(4);

        FileState? state = hash != null ? new FileState(kind, hash, size) : null;
        return new ConsensusEntry(state, rev, movedFrom);
    }

    public Dictionary<string, ConsensusEntry> GetAllConsensus()
    {
        var result = new Dictionary<string, ConsensusEntry>();
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT path, hash, size, rev, kind, moved_from FROM consensus";
        using var r = cmd.ExecuteReader();
        while (r.Read())
        {
            var path = r.GetString(0);
            var hash = r.IsDBNull(1) ? null : r.GetString(1);
            var size = r.GetInt64(2);
            var rev = r.GetInt32(3);
            var kind = (FileKind)r.GetInt32(4);
            var movedFrom = r.IsDBNull(5) ? null : r.GetString(5);

            FileState? state = hash != null ? new FileState(kind, hash, size) : null;
            result[path] = new ConsensusEntry(state, rev, movedFrom);
        }
        return result;
    }

    public void SetConsensus(string path, FileState? state, int rev, string? movedFrom = null)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = """
        INSERT INTO consensus(path, hash, size, rev, kind, moved_from, fold)
        VALUES ($path, $hash, $size, $rev, $kind, $moved, $fold)
        ON CONFLICT(path) DO UPDATE SET
          hash=excluded.hash, size=excluded.size, rev=excluded.rev,
          kind=excluded.kind, moved_from=excluded.moved_from, fold=excluded.fold
        """;
        cmd.Parameters.AddWithValue("$path", path);
        cmd.Parameters.AddWithValue("$hash", (object?)state?.Hash ?? DBNull.Value);
        cmd.Parameters.AddWithValue("$size", state?.Size ?? 0);
        cmd.Parameters.AddWithValue("$rev", rev);
        cmd.Parameters.AddWithValue("$kind", (int)(state?.Kind ?? FileKind.File));
        cmd.Parameters.AddWithValue("$moved", (object?)movedFrom ?? DBNull.Value);
        cmd.Parameters.AddWithValue("$fold", PortableName.Fold(path));
        cmd.ExecuteNonQuery();
    }

    public EndpointRow? GetRow(string endpoint, string path)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT hash, size, mtime_ns, seen_rev, kind FROM ep_state WHERE endpoint = $ep AND path = $path";
        cmd.Parameters.AddWithValue("$ep", endpoint);
        cmd.Parameters.AddWithValue("$path", path);
        using var r = cmd.ExecuteReader();
        if (!r.Read()) return null;
        var hash = r.IsDBNull(0) ? null : r.GetString(0);
        var size = r.GetInt64(1);
        var mtime = r.GetInt64(2);
        var seenRev = r.GetInt32(3);
        var kind = (FileKind)r.GetInt32(4);

        FileState? state = hash != null ? new FileState(kind, hash, size) : null;
        return new EndpointRow { State = state, MtimeNs = mtime, SeenRev = seenRev };
    }

    public Dictionary<string, EndpointRow> GetEndpointRows(string endpoint)
    {
        var result = new Dictionary<string, EndpointRow>();
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT path, hash, size, mtime_ns, seen_rev, kind FROM ep_state WHERE endpoint = $ep";
        cmd.Parameters.AddWithValue("$ep", endpoint);
        using var r = cmd.ExecuteReader();
        while (r.Read())
        {
            var path = r.GetString(0);
            var hash = r.IsDBNull(1) ? null : r.GetString(1);
            var size = r.GetInt64(2);
            var mtime = r.GetInt64(3);
            var seenRev = r.GetInt32(4);
            var kind = (FileKind)r.GetInt32(5);

            FileState? state = hash != null ? new FileState(kind, hash, size) : null;
            result[path] = new EndpointRow { State = state, MtimeNs = mtime, SeenRev = seenRev };
        }
        return result;
    }

    public void SetRow(string endpoint, string path, FileState? state, long mtimeNs, int seenRev)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = """
        INSERT INTO ep_state(endpoint, path, hash, size, mtime_ns, seen_rev, kind, fold)
        VALUES ($ep, $path, $hash, $size, $mtime, $rev, $kind, $fold)
        ON CONFLICT(endpoint, path) DO UPDATE SET
          hash=excluded.hash, size=excluded.size, mtime_ns=excluded.mtime_ns,
          seen_rev=excluded.seen_rev, kind=excluded.kind, fold=excluded.fold
        """;
        cmd.Parameters.AddWithValue("$ep", endpoint);
        cmd.Parameters.AddWithValue("$path", path);
        cmd.Parameters.AddWithValue("$hash", (object?)state?.Hash ?? DBNull.Value);
        cmd.Parameters.AddWithValue("$size", state?.Size ?? 0);
        cmd.Parameters.AddWithValue("$mtime", mtimeNs);
        cmd.Parameters.AddWithValue("$rev", seenRev);
        cmd.Parameters.AddWithValue("$kind", (int)(state?.Kind ?? FileKind.File));
        cmd.Parameters.AddWithValue("$fold", PortableName.Fold(path));
        cmd.ExecuteNonQuery();
    }

    public void AddConflict(string endpoint, string path, string conflictPath, DateTime detectedAt)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "INSERT INTO conflicts(endpoint, path, conflict_path, detected) VALUES ($ep, $path, $cp, $dt)";
        cmd.Parameters.AddWithValue("$ep", endpoint);
        cmd.Parameters.AddWithValue("$path", path);
        cmd.Parameters.AddWithValue("$cp", conflictPath);
        cmd.Parameters.AddWithValue("$dt", detectedAt.ToUniversalTime().ToString("o"));
        cmd.ExecuteNonQuery();
    }

    public List<ConflictRecord> GetOpenConflicts()
    {
        var list = new List<ConflictRecord>();
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT id, endpoint, path, conflict_path, detected, status FROM conflicts WHERE status = 'open'";
        using var r = cmd.ExecuteReader();
        while (r.Read())
        {
            list.Add(new ConflictRecord(r.GetInt64(0), r.GetString(1), r.GetString(2), r.GetString(3), r.GetString(4), r.GetString(5)));
        }
        return list;
    }

    public void CloseConflict(long id, string status)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "UPDATE conflicts SET status = $st WHERE id = $id";
        cmd.Parameters.AddWithValue("$st", status);
        cmd.Parameters.AddWithValue("$id", id);
        cmd.ExecuteNonQuery();
    }

    public void RecordJournal(string op, string endpoint, string path, string? detail, string status)
    {
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "INSERT INTO journal(ts, op, endpoint, path, detail, status) VALUES ($ts, $op, $ep, $path, $detail, $status)";
        cmd.Parameters.AddWithValue("$ts", DateTime.UtcNow.ToString("o"));
        cmd.Parameters.AddWithValue("$op", op);
        cmd.Parameters.AddWithValue("$ep", endpoint);
        cmd.Parameters.AddWithValue("$path", path);
        cmd.Parameters.AddWithValue("$detail", (object?)detail ?? DBNull.Value);
        cmd.Parameters.AddWithValue("$status", status);
        cmd.ExecuteNonQuery();
    }

    public List<JournalEntry> GetRecentJournal(int limit = 50)
    {
        var list = new List<JournalEntry>();
        using var cmd = _conn.CreateCommand();
        cmd.CommandText = "SELECT id, ts, op, endpoint, path, detail, status FROM journal ORDER BY id DESC LIMIT $limit";
        cmd.Parameters.AddWithValue("$limit", limit);
        using var r = cmd.ExecuteReader();
        while (r.Read())
        {
            list.Add(new JournalEntry(
                r.GetInt64(0),
                r.GetString(1),
                r.GetString(2),
                r.GetString(3),
                r.GetString(4),
                r.IsDBNull(5) ? null : r.GetString(5),
                r.GetString(6)
            ));
        }
        return list;
    }

    public void Dispose()
    {
        _conn.Close();
        _conn.Dispose();
    }
}
