// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvCoopServerListWindow : main window for browser
// ===============================================================

class TvCoopServerListWindow expands UBrowserServerListWindow;

defaultproperties
{
     ServerListTitle="Xidia CO-OP"
     ListFactories(0)="XidiaMPack.tvcoopFact,GameType=tvcoop,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
}
