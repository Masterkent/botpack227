// ===============================================================
// SevenB.SBBloodRipper: bloodpack ripper
// ===============================================================

class SBBloodRipper extends ripper;

var bool bInvGroupChecked;

function PlayAltFiring() //15% slower
{
  LoopAnim('Fire', 0.34 + 0.26 * FireAdjust,0.05);
  Owner.PlaySound(class'Razor2Alt'.Default.SpawnSound, SLOT_None,4.2);
}

function SetSwitchPriority(pawn Other)   //priority stuff
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'ripper' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'ripper';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }
  }
}

function PostBeginPlay()
{
	bInvGroupChecked = true;
	if (Level.Game.bDeathMatch)
		InventoryGroup = 6;
	else if (tvsp(Level.Game) != none || tvcoop(Level.Game) != none)
		InventoryGroup = 7;
}

defaultproperties
{
     ProjectileClass=Class'SevenB.SBRazor2'
     AltProjectileClass=Class'SevenB.SBRazor2Alt'
     AIRating=0.600000
     InventoryGroup=6
     bAmbientGlow=False
     PickupMessage="You got the Bloodpack Ripper."
     ItemName="Bloodpack Ripper"
     RotationRate=(Yaw=0)
}
