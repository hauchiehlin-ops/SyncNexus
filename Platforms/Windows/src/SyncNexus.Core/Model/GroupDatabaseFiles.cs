using Microsoft.Data.Sqlite;

namespace SyncNexus.Core.Model;

/// <summary>Reading and consistently copying the per-group state databases (WAL-aware).</summary>
public static class GroupDatabaseFiles
{
    private static string ConnectionString(string path, SqliteOpenMode mode) =>
        new SqliteConnectionStringBuilder { DataSource = path, Mode = mode, Pooling = false }.ToString();

    /// <summary>
    /// Copies the database (and its -wal / -shm) to a private temp folder and checkpoints it there, so a live WAL
    /// database becomes one consistent file. Returns the temp database path (caller deletes its folder), or null.
    /// </summary>
    public static string? ConsolidatedCopy(string srcDb)
    {
        if (!File.Exists(srcDb)) return null;
        var tmp = Path.Combine(Path.GetTempPath(), "syncnexus-copy-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(tmp);
        var dest = Path.Combine(tmp, "state.db");
        try
        {
            foreach (var ext in new[] { "", "-wal", "-shm" })
            {
                var f = srcDb + ext;
                if (File.Exists(f)) File.Copy(f, dest + ext);
            }
            using (var conn = new SqliteConnection(ConnectionString(dest, SqliteOpenMode.ReadWrite)))
            {
                conn.Open();
                using var cmd = conn.CreateCommand();
                cmd.CommandText = "PRAGMA wal_checkpoint(TRUNCATE)";
                cmd.ExecuteNonQuery();
            }
            foreach (var ext in new[] { "-wal", "-shm" })
            {
                try { File.Delete(dest + ext); } catch (IOException) { }
            }
            return dest;
        }
        catch (Exception)
        {
            try { Directory.Delete(tmp, recursive: true); } catch (IOException) { }
            return null;
        }
    }

    /// <summary>(id, root) of every endpoint in the database; empty when the file or table does not exist.</summary>
    public static List<(string Id, string Root)> ReadEndpoints(string dbPath)
    {
        var list = new List<(string, string)>();
        if (!File.Exists(dbPath)) return list;
        try
        {
            using var conn = new SqliteConnection(ConnectionString(dbPath, SqliteOpenMode.ReadOnly));
            conn.Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT id, root FROM endpoints ORDER BY id";
            using var reader = cmd.ExecuteReader();
            while (reader.Read()) list.Add((reader.GetString(0), reader.GetString(1)));
        }
        catch (Exception)
        {
            list.Clear();
        }
        return list;
    }

    public static int CountEndpoints(string dbPath) => ReadEndpoints(dbPath).Count;
}
