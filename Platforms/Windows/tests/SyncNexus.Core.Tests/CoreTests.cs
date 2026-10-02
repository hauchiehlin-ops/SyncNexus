using SyncNexus.Core.Engine;
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
}

