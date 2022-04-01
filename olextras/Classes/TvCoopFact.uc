// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvCoopFact : More stuff for direct-query gametype
// ===============================================================

class TvCoopFact expands UBrowserGSpyFact;

/*-
function Query(optional bool bBySuperset, optional bool bInitial)
{
  Super(UBrowserServerListFactory).Query(bBySuperset, bInitial);

  Link = GetPlayerOwner().GetEntryLevel().Spawn(class'Tvcooplink');

  Link.MasterServerAddress = MasterServerAddress;
  Link.MasterServerTCPPort = MasterServerTCPPort;
  Link.Region = Region;
  Link.MasterServerTimeout = MasterServerTimeout;
  Link.GameName = GameName;
  Link.OwnerFactory = Self;
  Link.Start();
}
*/

defaultproperties
{
}
