// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PlayerAlterZone : This zone is made for Tonnberry.
// For use with altering jumpsounds and jumpz
// ===============================================================

class PlayerAlterZone expands ZoneInfo;

var () float JumpZ;
var () Sound JumpSounds[3];

simulated event ActorEntered( actor Other )
{
  local byte i;
  Super.ActorEntered(Other);
  if (Other.bIsPawn&&Other.Role>Role_SimulatedProxy&&Pawn(Other).bIsPlayer){
    if (Other.Role==Role_Authority)
      Pawn(Other).JumpZ=JumpZ;
    if (Other.IsA('tvplayer'))
      for (i=0;i<3;i++)
        tvPlayer(Other).Jumpsounds[i]=JumpSounds[i];
  }
}

simulated event ActorLeaving( actor Other )
{
  local byte i;
  Super.ActorLeaving(Other);
  if (Other.bIsPawn&&Other.Role>Role_SimulatedProxy&&Pawn(Other).bIsPlayer){
    if (Other.Role==Role_Authority)
      Pawn(Other).JumpZ=Pawn(Other).default.JumpZ;
    if (Other.IsA('tvplayer'))
      for (i=0;i<3;i++)
        tvPlayer(Other).Jumpsounds[i]=tvPlayer(Other).default.JumpSounds[i];
  }
}

defaultproperties
{
     JumpZ=325.000000
     JumpSounds(0)=Sound'olextras.OLJUMP1'
     JumpSounds(1)=Sound'olextras.OLJUMP2'
     JumpSounds(2)=Sound'olextras.OLJUMP3'
}
