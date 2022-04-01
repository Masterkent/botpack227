// ============================================================
// olroot.olUTPlayerSetupClient: eliminates maximum players to choose...
// ============================================================

class olUTPlayerSetupClient expands UMenuPlayerSetupClient;

function LoadClasses()
{
  local int NumPlayerClasses;
  local string NextPlayer, NextDesc;

  GetPlayerOwner().GetNextIntDesc("TournamentPlayer", 0, NextPlayer, NextDesc);
  while( (NextPlayer != ""))
  {
    if (!(NextPlayer ~= "Botpack.TBoss") || class'Ladder'.Default.HasBeatenGame)
      ClassCombo.AddItem(NextDesc, NextPlayer, 0);

    NumPlayerClasses++;
    GetPlayerOwner().GetNextIntDesc("TournamentPlayer", NumPlayerClasses, NextPlayer, NextDesc);
  }

  ClassCombo.Sort();
}
/*-
function IterateVoices()     //do not require ladder defeat.
{
  local int NumVoices;
  local string NextVoice, NextDesc;
  local string VoicepackMetaClass;
  local bool OldInitialized;

  OldInitialized = Initialized;
  Initialized = False;
  VoicePackCombo.Clear();
  Initialized = OldInitialized;

  if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
    VoicePackMetaClass = class<TournamentPlayer>(NewPlayerClass).default.VoicePackMetaClass;
  else
    VoicePackMetaClass = "Botpack.ChallengeVoicePack";

  // Load the base class into memory to prevent GetNextIntDesc crashing as the class isn't loadded.
  DynamicLoadObject(VoicePackMetaClass, class'Class');

  GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, 0, NextVoice, NextDesc);
  while (NextVoice != "")       //no limit
  {
      VoicePackCombo.AddItem(NextDesc, NextVoice, 0);

    numvoices++;
    GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, NumVoices, NextVoice, NextDesc);
  }

  VoicePackCombo.Sort();
}
*/

defaultproperties
{
}
