// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SuperAmmoShockRifle : This is a normal SSR, only it uses ammo!
// ============================================================

class SuperAmmoShockRifle expands SuperShockRifle;

function PostBeginPlay(){
  Super.PostBeginPlay();
  if (level.game.class==class'MonsterSmash')
    PickUpAmmoCount=3;
}

function AltFire( float Value )
{
  if ( (AmmoType == None) && (AmmoName != None) )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (B227_bUseAmmo || AmmoType.UseAmmo(1))
    Super.AltFire(Value);
}
function Fire( float Value )
{
  if ( (AmmoType == None) && (AmmoName != None) )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (B227_bUseAmmo || AmmoType.UseAmmo(1))
    Super.Fire(Value);
}
function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'SuperShockRifle' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'SuperShockRifle';
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

defaultproperties
{
     MultiSkins(1)=Texture'BotPack.Skins.SASMD_t'
}
