// ============================================================
// OLweapons.OLrazorjack: network/decal razorjack...
// Psychic_313: unchanged
// ============================================================

class OLrazorjack expands UIweapons;
var bool clientanidone, bfirstfire;

function float SuggestAttackStyle()
{
  return -0.2;
}

function float SuggestDefenseStyle()
{
  return -0.2;
}
function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
  local Vector Start, X,Y,Z;

  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(500, 0, 650));
  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
  AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
  return Spawn(ProjClass,,, Start,AdjustedAim);
}

function tweentostill(){} //wierd bug....
function PlayFiring()
{
  PlayAnim( 'Fire', 0.7,0.05 );
}

function PlayAltFiring()
{
  PlayAnim('AltFire1', 0.9,0.05);
  bFirstFire = true;
}
function PlayRepeatFiring()
{
  PlayAnim('AltFire2', 0.4,0.05);
}
function AltFire( float Value )
{
  if (AmmoType.UseAmmo(1))
  {
    if ( Owner.bHidden )
      CheckVisibility();
    bPointing=True;
    PlayAltFiring();
    GotoState('AltFiring');
  }
}

///////////////////////////////////////////////////////////
state AltFiring
{ ignores animend;
  function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
  {
    local Vector Start, X,Y,Z;

    Owner.MakeNoise(Pawn(Owner).SoundDampening);
    GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
    Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
    AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
    AdjustedAim.Roll += 12768;
    return Spawn(ProjClass,,, Start,AdjustedAim);
  }

Begin:
  FinishAnim();
Repeater:
  ProjectileFire(AltProjectileClass,AltProjectileSpeed,bAltWarnTarget);
  PlayRepeatFiring();
  FinishAnim();
  if ( PlayerPawn(Owner) == None )
  {
    if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    {
      Pawn(Owner).StopFiring();
      Pawn(Owner).SwitchToBestWeapon();
      if ( bChangeWeapon )
        GotoState('DownWeapon');
    }
    else if ( (Pawn(Owner).bAltFire == 0) || (FRand() > AltRefireRate) )
    {
      Pawn(Owner).StopFiring();
      GotoState('Idle');
    }
  }
  if ( (Pawn(Owner).bAltFire!=0)
    && (Pawn(Owner).Weapon==Self) && AmmoType.UseAmmo(1))
  {
    goto 'Repeater';
  }
  PlayAnim('AltFire3', 0.9,0.05);
  FinishAnim();
  PlayAnim('Load',0.2,0.05);
  FinishAnim();
  if ( Pawn(Owner).bFire!=0 && Pawn(Owner).Weapon==Self)
    Global.Fire(0);
  else
    GotoState('Idle');
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
  LoopAnim('Idle', 0.4);
}

defaultproperties
{
     WeaponDescription="Classification: Skaarj Blade Launcher\n\nPrimary Fire: Single blades that richochet off walls, ceilings, and floors.\n\nSecondary Fire: Skilled users can make use of the weapon's transmitted motion signals, allowing the user to alter the trajectory of the blade after it leaves the weapon.\n\nTechniques: Aim for the necks of your opponents."
     AmmoName=Class'UnrealI.RazorAmmo'
     PickupAmmoCount=15
     FireOffset=(X=16.000000,Z=-15.000000)
     ProjectileClass=Class'OLweapons.OSRazorBlade'
     AltProjectileClass=Class'OLweapons.OSRazorBladeAlt'
     shakemag=120.000000
     AIRating=0.500000
     RefireRate=0.830000
     AltRefireRate=0.830000
     SelectSound=Sound'UnrealI.Razorjack.beam'
     DeathMessage="%k took a bloody chunk out of %o with the %w."
     AutoSwitchPriority=7
     InventoryGroup=7
     PickupMessage="You got the RazorJack"
     ItemName="Razorjack"
     PlayerViewOffset=(X=2.000000,Z=-0.900000)
     PlayerViewMesh=LodMesh'UnrealI.Razor'
     BobDamping=0.970000
     PickupViewMesh=LodMesh'UnrealI.RazPick'
     ThirdPersonMesh=LodMesh'UnrealI.Razor3rd'
     StatusIcon=Texture'botpack.Icons.UseRazor'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'botpack.Icons.UseRazor'
     Mesh=LodMesh'UnrealI.RazPick'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=7.000000
     Mass=17.000000
}
