using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;
using Xunit;

namespace SyncNexus.Core.Tests;

public class CoreTests
{
    [Fact]
    public void PortableName_DetectsForbiddenCharacters()
    {
        var problems = PortableName.ProblemsInComponent("hello:world.txt");
        Assert.Single(problems);
        Assert.Equal(NameProblemType.ForbiddenCharacter, problems[0].Type);

        var problems2 = PortableName.ProblemsInComponent("test<1>.jpg");
        Assert.Equal(2, problems2.Count); // '<' and '>'
    }

    [Fact]
    public void PortableName_DetectsReservedNames()
    {
        var problems = PortableName.ProblemsInComponent("aux.txt");
        Assert.Single(problems);
        Assert.Equal(NameProblemType.ReservedName, problems[0].Type);

        var problemsCom = PortableName.ProblemsInComponent("COM3.log");
        Assert.Single(problemsCom);
        Assert.Equal(NameProblemType.ReservedName, problemsCom[0].Type);
    }

    [Fact]
    public void PortableName_DetectsTrailingDotOrSpace()
    {
        var p1 = PortableName.ProblemsInComponent("folder. ");
        Assert.Contains(p1, p => p.Type == NameProblemType.TrailingDotOrSpace);

        var p2 = PortableName.ProblemsInComponent("data.");
        Assert.Contains(p2, p => p.Type == NameProblemType.TrailingDotOrSpace);
    }

    [Fact]
    public void IgnoreRules_DetectsMacOSAndWindowsLitter()
    {
        var rules = IgnoreRules.Default;

        // macOS litter
        Assert.True(rules.IsLitter(".DS_Store"));
        Assert.True(rules.IsLitter("._somefile.txt"));
        Assert.True(rules.IsLitter(".Spotlight-V100"));
        Assert.True(rules.IsLitter(".Trashes"));

        // Windows litter
        Assert.True(rules.IsLitter("Thumbs.db"));
        Assert.True(rules.IsLitter("desktop.ini"));
        Assert.True(rules.IsLitter("$RECYCLE.BIN"));
        Assert.True(rules.IsLitter("System Volume Information"));

        // Cloud & Office temporaries
        Assert.True(rules.IsLitter("~$Document.docx"));
        Assert.True(rules.IsLitter("notes.gdoc"));
        Assert.True(rules.IsLitter("sheet.gsheet"));
        Assert.True(rules.IsLitter(".photo.jpg.icloud"));

        // Normal files should not be litter
        Assert.False(rules.IsLitter("Document.docx"));
        Assert.False(rules.IsLitter("photo.jpg"));
    }

    [Fact]
    public void ConflictNaming_GeneratesAndParsesCorrectly()
    {
        var dt = new DateTime(2026, 10, 2, 14, 30, 0, DateTimeKind.Utc);
        var name = ConflictNaming.Name("report.docx", "Disk", dt);

        Assert.Equal("report (conflict Disk 2026-10-02 14-30).docx", name);
        Assert.True(ConflictNaming.IsConflictName(name));
        Assert.True(IgnoreRules.Default.IsIgnored(name)); // Conflict files are ignored from general scan
        Assert.False(ConflictNaming.IsConflictName("report.docx"));
    }

    [Fact]
    public void Reconciler_ThreeWayDecisions()
    {
        var stateA = Model.FileState.MakeFile("hashA", 100);
        var stateB = Model.FileState.MakeFile("hashB", 200);

        // 1. No changes
        var obsNoop = new Model.PathObservation(stateA, stateA, 1);
        var cons1 = new Model.ConsensusEntry(stateA, 1);
        Assert.Equal(Model.Decision.Noop, Reconciler.Decide(obsNoop, cons1));

        // 2. Endpoint changed alone
        var obsLocalEdit = new Model.PathObservation(stateA, stateB, 1);
        Assert.Equal(Model.Decision.AdoptEndpoint, Reconciler.Decide(obsLocalEdit, cons1));

        // 3. Remote consensus changed alone
        var cons2 = new Model.ConsensusEntry(stateB, 2);
        var obsRemoteChanged = new Model.PathObservation(stateA, stateA, 1);
        Assert.Equal(Model.Decision.ApplyConsensus, Reconciler.Decide(obsRemoteChanged, cons2));

        // 4. Concurrent identical edits -> MarkSeen
        var obsIdentical = new Model.PathObservation(stateA, stateB, 1);
        Assert.Equal(Model.Decision.MarkSeen, Reconciler.Decide(obsIdentical, cons2));

        // 5. Delete vs Modify -> Modification wins!
        var obsDeleted = new Model.PathObservation(stateA, null, 1);
        Assert.Equal(Model.Decision.ApplyConsensus, Reconciler.Decide(obsDeleted, cons2)); // Remote modify wins

        var obsModified = new Model.PathObservation(stateA, stateB, 1);
        var consDeleted = new Model.ConsensusEntry(null, 2);
        Assert.Equal(Model.Decision.AdoptEndpoint, Reconciler.Decide(obsModified, consDeleted)); // Local modify wins

        // 6. Conflicting edits
        var stateC = Model.FileState.MakeFile("hashC", 300);
        var obsConflict = new Model.PathObservation(stateA, stateC, 1);
        Assert.Equal(Model.Decision.Conflict, Reconciler.Decide(obsConflict, cons2));
    }

    [Fact]
    public void SqliteStore_RoundTrip()
    {
        var tempDb = Path.Combine(Path.GetTempPath(), $"syncnexus_test_{Guid.NewGuid():N}.db");
        try
        {
            using var store = new Storage.SqliteStore(tempDb);

            var ep = new Model.EndpointConfig("test-local", @"C:\Test", removable: false, portableNames: true);
            store.SaveEndpoint(ep);

            var loaded = store.GetEndpoints();
            Assert.Single(loaded);
            Assert.Equal("test-local", loaded[0].Id);
            Assert.True(loaded[0].PortableNames);

            store.SetConsensus("doc.txt", Model.FileState.MakeFile("hash1", 50), 1);
            var cons = store.GetConsensus("doc.txt");
            Assert.NotNull(cons);
            Assert.Equal(1, cons.Rev);
            Assert.Equal("hash1", cons.State?.Hash);
        }
        finally
        {
            if (File.Exists(tempDb))
            {
                try { File.Delete(tempDb); } catch { }
            }
        }
    }

    [Fact]
    public void CloudProviderProbe_ExecutesWithoutExceptions()
    {
        var discovered = IO.CloudProviderProbe.ProbeAll();
        Assert.NotNull(discovered);
    }

    [Fact]
    public void SyncLock_PreventsConcurrentAccess()
    {
        var lockFile = Path.Combine(Path.GetTempPath(), $"syncnexus_lock_{Guid.NewGuid():N}.lock");
        try
        {
            using var lock1 = SyncLock.TryAcquire(lockFile);
            Assert.NotNull(lock1);

            // Second attempt should fail
            using var lock2 = SyncLock.TryAcquire(lockFile);
            Assert.Null(lock2);
        }
        finally
        {
            if (File.Exists(lockFile))
            {
                try { File.Delete(lockFile); } catch { }
            }
        }
    }

    [Fact]
    public void SyncEngine_FullSync_TwoFolders_PropagatesChanges()
    {
        var baseDir = Path.Combine(Path.GetTempPath(), $"syncnexus_test_{Guid.NewGuid():N}");
        var dirA = Path.Combine(baseDir, "endpointA");
        var dirB = Path.Combine(baseDir, "endpointB");
        var dbPath = Path.Combine(baseDir, "state.db");

        Directory.CreateDirectory(dirA);
        Directory.CreateDirectory(dirB);

        try
        {
            using var store = new Storage.SqliteStore(dbPath);
            var epA = new Model.EndpointConfig("epA", dirA);
            var epB = new Model.EndpointConfig("epB", dirB);
            store.SaveEndpoint(epA);
            store.SaveEndpoint(epB);

            var engine = new SyncEngine(store);

            // Step 1: Write file in endpoint A
            var fileA = Path.Combine(dirA, "hello.txt");
            File.WriteAllText(fileA, "Hello World from Windows!");

            // Run first sync
            var report1 = engine.SyncAll();
            Assert.True(report1.IsSuccess);
            Assert.True(report1.Actions > 0);

            // Verify file propagated to endpoint B!
            var fileB = Path.Combine(dirB, "hello.txt");
            Assert.True(File.Exists(fileB));
            Assert.Equal("Hello World from Windows!", File.ReadAllText(fileB));

            // Step 2: Edit file in endpoint B
            File.WriteAllText(fileB, "Updated in Endpoint B!");
            var report2 = engine.SyncAll();
            Assert.True(report2.IsSuccess);

            // Verify updated content propagated back to endpoint A!
            Assert.Equal("Updated in Endpoint B!", File.ReadAllText(fileA));
        }
        finally
        {
            if (Directory.Exists(baseDir))
            {
                try { Directory.Delete(baseDir, true); } catch { }
            }
        }
    }

    private static readonly string[] DefaultNames = { "預設群組", "默认群组", "Default Group", "預設同步群組" };

    [Fact]
    public void GroupNaming_UnnamedGroupsAreNumberedAndLocalized()
    {
        var a = new SyncGroup("group_a", "");
        var b = new SyncGroup("group_b", "");
        var named = new SyncGroup("group_c", "家庭相片");
        var all = new List<SyncGroup> { a, named, b };

        Assert.Equal("새 그룹", SyncGroupNaming.Display(a, all, "기본 그룹", "새 그룹", DefaultNames));
        Assert.Equal("새 그룹 2", SyncGroupNaming.Display(b, all, "기본 그룹", "새 그룹", DefaultNames));
        Assert.Equal("家庭相片", SyncGroupNaming.Display(named, all, "기본 그룹", "새 그룹", DefaultNames));
    }

    [Fact]
    public void GroupNaming_BuiltInDefaultFollowsLanguage()
    {
        var def = new SyncGroup("default", "預設群組");
        Assert.Equal("Default Group", SyncGroupNaming.Display(def, new[] { def }, "Default Group", "New Group", DefaultNames));
        // a user who renamed the default group keeps their name
        var renamed = new SyncGroup("default", "測試群組");
        Assert.Equal("測試群組", SyncGroupNaming.Display(renamed, new[] { renamed }, "Default Group", "New Group", DefaultNames));
    }

    private static string TempDir()
    {
        var d = Path.Combine(Path.GetTempPath(), "sg-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(d);
        return d;
    }

    [Fact]
    public void GroupRegistry_StartsWithDefaultAndPersistsEmptyNames()
    {
        var dir = TempDir();
        try
        {
            var reg = new SyncGroupRegistry(dir);
            Assert.Single(reg.All());
            Assert.Equal("default", reg.All()[0].Id);

            var created = reg.Add("   ", "star");
            Assert.Equal("", created.Name);   // stored empty, shown per language later

            var reloaded = new SyncGroupRegistry(dir);
            Assert.Equal(2, reloaded.All().Count);
            Assert.Equal("", reloaded.Get(created.Id)!.Name);
            Assert.EndsWith("state.db", reloaded.DbPath("default"));
            Assert.Contains(created.Id, reloaded.DbPath(created.Id));
        }
        finally { Directory.Delete(dir, true); }
    }

    [Fact]
    public void GroupRegistry_RulesForUpdateAndRemove()
    {
        var dir = TempDir();
        try
        {
            var reg = new SyncGroupRegistry(dir);
            var g = reg.Add("");
            Assert.True(reg.Update(g.Id, "", "heart"));                 // unnamed may stay unnamed
            Assert.False(reg.Update("default", "  ", "heart"));         // a named group needs text
            Assert.True(reg.Update("default", "工作", "heart"));
            Assert.True(reg.Remove(g.Id));
            Assert.False(reg.Remove("default"));                        // never the last one
        }
        finally { Directory.Delete(dir, true); }
    }

    [Fact]
    public void GroupRegistry_DamagedFileIsKeptAndNotOverwritten()
    {
        var dir = TempDir();
        try
        {
            File.WriteAllText(Path.Combine(dir, "groups.json"), "{ not json");
            var reg = new SyncGroupRegistry(dir);
            Assert.Single(reg.All());                                   // in-memory default only
            Assert.Equal("{ not json", File.ReadAllText(Path.Combine(dir, "groups.json")));
            Assert.Single(Directory.GetFiles(dir, "groups.json.corrupted-*"));
        }
        finally { Directory.Delete(dir, true); }
    }

    // ---- backups, restore, legacy import, folder overlap ----

    private static void MakeDb(string path, params (string Id, string Root)[] endpoints)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        using var store = new SyncNexus.Core.Storage.SqliteStore(path);
        foreach (var (id, root) in endpoints)
        {
            store.SaveEndpoint(new EndpointConfig { Id = id, Root = root });
        }
        store.Dispose();
        Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools();   // release the file so it can be copied / deleted
    }

    [Fact]
    public void Backup_SkipsUnchangedAndEmpty_RestoresFiles()
    {
        var dir = TempDir();
        try
        {
            var reg = new SyncGroupRegistry(dir);
            var backups = new GroupBackups(reg);
            Assert.NotNull(backups.BackupNow());                 // first launch (empty state is fine when no backup exists)
            Assert.Null(backups.BackupNow());                    // unchanged

            MakeDb(reg.DbPath("default"), ("a", @"C:\a"), ("b", @"C:\b"));
            Assert.NotNull(backups.BackupNow());                 // changed, has folders
            Assert.Equal(2, backups.ListBackups()[0].EndpointCount);

            // simulate the overwrite: database wiped, group renamed
            Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools();
            File.Delete(reg.DbPath("default"));
            reg.Update("default", "被覆蓋", "folder");
            Assert.Null(backups.BackupNow());                    // an empty state must not evict the good backup

            backups.RestoreFiles(backups.ListBackups().First(b => b.EndpointCount == 2));
            Assert.Equal("預設群組", reg.Get("default")!.Name);
            Assert.Equal(2, GroupDatabaseFiles.CountEndpoints(reg.DbPath("default")));
        }
        finally { Directory.Delete(dir, true); }
    }

    [Fact]
    public void LegacyImport_ReadsGroupsAndSkipsEmptyDatabases()
    {
        var legacy = TempDir();
        try
        {
            var src = new SyncGroupRegistry(legacy);
            var second = src.Add("第二次測試");
            MakeDb(src.DbPath("default"), ("a", @"C:\a"));
            MakeDb(src.DbPath(second.Id));                       // no endpoints -> skipped

            var items = LegacyImport.Read(legacy);
            try
            {
                Assert.Single(items);
                Assert.Equal("default", items[0].Group.Id);
                Assert.Equal(1, items[0].Endpoints);
            }
            finally { LegacyImport.Cleanup(items); }

            Assert.Throws<LegacyImportException>(() => LegacyImport.Read(Path.Combine(legacy, "does-not-exist")));
        }
        finally { Directory.Delete(legacy, true); }
    }

    [Fact]
    public void FolderOverlap_SameOrNestedButNotSiblings()
    {
        Assert.True(FolderOverlap.Overlaps(@"C:\Work", @"c:\work\"));
        Assert.True(FolderOverlap.Overlaps(@"C:\Work", @"C:\Work\Sub"));
        Assert.True(FolderOverlap.Overlaps(@"C:\Work\Sub", @"C:\Work"));
        Assert.False(FolderOverlap.Overlaps(@"C:\Work", @"C:\Workshop"));
        Assert.True(FolderOverlap.IsNested(@"C:\Work", @"C:\Work\Sub"));
        Assert.False(FolderOverlap.IsNested(@"C:\Work", @"C:\Work"));
    }

    [Fact]
    public void GroupStatus_EvaluatesAndAggregatesAcrossGroups()
    {
        Assert.Equal(GroupHealth.Attention, GroupStatusLogic.Evaluate(3, 0, 2));    // open conflicts
        Assert.Equal(GroupHealth.Attention, GroupStatusLogic.Evaluate(3, 1, 0));    // a folder is offline
        Assert.Equal(GroupHealth.NeedsFolders, GroupStatusLogic.Evaluate(1, 0, 0));
        Assert.Equal(GroupHealth.Ok, GroupStatusLogic.Evaluate(2, 0, 0));

        // an unfinished new group does not spoil "all in sync"
        Assert.Equal(GroupHealth.Ok, GroupStatusLogic.Overall(new[] { GroupHealth.Ok, GroupHealth.NeedsFolders }));
        Assert.Equal(GroupHealth.NeedsFolders, GroupStatusLogic.Overall(new[] { GroupHealth.NeedsFolders }));
        Assert.Equal(GroupHealth.Attention, GroupStatusLogic.Overall(new[] { GroupHealth.Ok, GroupHealth.Attention, GroupHealth.NeedsFolders }));
        Assert.Equal(GroupHealth.Ok, GroupStatusLogic.Overall(Array.Empty<GroupHealth>()));
    }

    [Fact]
    public void FolderIconFiles_AreNeverSynced()
    {
        var rules = SyncNexus.Core.Engine.IgnoreRules.Default;
        Assert.True(rules.IsIgnored("Icon\r"));                  // macOS custom folder icon
        Assert.True(rules.IsIgnored("._Icon\r"));                // its AppleDouble twin on exFAT
        Assert.True(rules.IsIgnored(".syncnexus-icon.ico"));      // Windows folder icon
        Assert.True(rules.IsIgnored("desktop.ini"));
        Assert.False(rules.IsIgnored("Icon.png"));
    }
}
