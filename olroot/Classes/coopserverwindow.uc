// ============================================================
// olroot.coopserverwindow: the magical co-op game browser :D
// ============================================================

class coopserverwindow expands UBrowserServerListWindow;

defaultproperties
{
     ServerListTitle="CO-OP"
     ListFactories(0)="UBrowser.UBrowserSubsetFact,SupersetTag=UBrowserAll,GameType=coopgame2,bCompatibleServersOnly=True"
}
