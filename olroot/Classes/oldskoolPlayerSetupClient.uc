// ============================================================
// olroot.oldskoolPlayerSetupClient: all it does is hide various classes......
// ============================================================

class oldskoolPlayerSetupClient expands olUTPlayerSetupClient;
function LoadClasses()     //hide various ones......
{
  local int NumPlayerClasses;
  local string NextPlayer, NextDesc;

  GetPlayerOwner().GetNextIntDesc("TournamentPlayer", 0, NextPlayer, NextDesc);
  while( (NextPlayer != "") && (NumPlayerClasses < 64) )
  {
    if (!(NextPlayer ~= "oldskool.sktrooper")&&!(Left(NextPlayer,6) ~= "u4etc."))       //no skaarj or U4e d00dz allowed.....
      ClassCombo.AddItem(NextDesc, NextPlayer, 0);

    NumPlayerClasses++;
    GetPlayerOwner().GetNextIntDesc("TournamentPlayer", NumPlayerClasses, NextPlayer, NextDesc);
  }

  ClassCombo.Sort();
}

defaultproperties
{
}
