// ===============================================================
// SevenB.SBFlechetteCannon: More powerful flak cannon
// ===============================================================

class SBFlechetteCannon extends UT_FlakCannon;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

function SetSwitchPriority(pawn Other)   //priority stuff
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'UT_FlakCannon' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'UT_FlakCannon';
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

//using different first person skin
simulated event RenderOverlays(canvas Canvas)         //muzzle stuff.....
{
  multiskins[1]=texture'SFlak_t2';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=default.MultiSkins[1];
}

defaultproperties
{
     AltProjectileClass=Class'SevenB.SBflakslug'
     bAmbientGlow=False
     PickupMessage="You got the Flechette Cannon."
     ItemName="Flechette Cannon"
     MultiSkins(0)=Texture'SevenB.Skins.SFlak_t1'
     MultiSkins(1)=Texture'SevenB.Skins.SFlak_t'
     MultiSkins(2)=Texture'SevenB.Skins.SFlak_t3'
     MultiSkins(3)=Texture'SevenB.Skins.SFlak_t4'
     RotationRate=(Yaw=0)
}
