// ============================================================
// OlWeapons.OLGESBioRifle: decal/network GES biorifle... (Green Explosive S**t)
// Psychic_313: unchanged
// ============================================================

class OLGESBioRifle expands UIweapons;

var float ChargeSize,Count;
var bool bBurst;

function float RateSelf( out int bUseAltMode )
{
  local float EnemyDist;
  local bool bRetreating;
  local vector EnemyDir;

  if ( AmmoType.AmmoAmount <=0 )
    return -2;
  if ( Pawn(Owner).Enemy == None )
  {
    bUseAltMode = 0;
    return AIRating;
  }

  EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  if ( EnemyDist > 1400 )
  {
    bUseAltMode = 0;
    return 0;
  }
  bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
  if ( (EnemyDist > 500) && (EnemyDir.Z > -0.4 * EnemyDist) )
  {
    // only use if enemy not too far and retreating
    if ( (EnemyDist > 800) || !bRetreating )
    {
      bUseAltMode = 0;
      return 0;
    }
    return AIRating;
  }

  bUseAltMode = int( bRetreating && (FRand() < 0.3) );

  if ( bRetreating || (EnemyDir.Z < -0.7 * EnemyDist) )
    return (AIRating + 0.15);
  return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
  return -0.3;
}

function float SuggestDefenseStyle()
{
  return -0.2;
}

function AltFire( float Value )
{
  bPointing=True;
  if ( AmmoType.UseAmmo(1) )
  {
    CheckVisibility();
    GoToState('AltFiring');
    bCanClientFire = true;
    ClientAltFire(Value);
  }
}

function bool ClientAltFire( float Value )
{
  local bool bResult;

  InstFlash = 0.0;
  bResult = Super.ClientAltFire(value);
  InstFlash = Default.InstFlash;
  return bResult;
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
  local Vector Start, X,Y,Z;

  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  AdjustedAim = pawn(owner).AdjustToss(ProjSpeed, Start, 0, True, (bWarn || (FRand() < 0.4)));
  if ( Owner.IsA('PlayerPawn') )
    PlayerPawn(Owner).ClientInstantFlash( -0.3, vect( 278, 435, 143));
  return Spawn(B227_GetProjClass(ProjClass),,, Start, AdjustedAim);
}

///////////////////////////////////////////////////////
//better in net mode.......
function PlayAltFiring()         //screwy
{
  Owner.PlaySound(Misc1Sound, SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);   //loading goop
  PlayAnim('Charging',0.24,0.05);
}

state AltFiring         //another attempt....
{
  function Tick( float DeltaTime )
  {
    ChargeSize += DeltaTime;
    if( (pawn(Owner).bAltFire==0))
      GoToState('ShootLoad');
    Count += DeltaTime;
    if (Count > 1.0)
    {
      Count = 0.0;
      if ( (PlayerPawn(Owner) == None) && (FRand() < 0.3) )
        GoToState('ShootLoad');
      else if (!AmmoType.UseAmmo(1))
        GoToState('ShootLoad');
    }
  }
  function Animend()     //so it goes to the right place (tourney weapon screws this up)
  {
   GoToState('ShootLoad');
  }

Begin:
  ChargeSize = 0.0;
  Count = 0.0;
}

state ShootLoad
{
  function ForceFire()
  {
    bForceFire = true;
  }

  function ForceAltFire()
  {
    bForceAltFire = true;
  }

  function BeginState()
  {
    Local Projectile Gel;

    Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
    Gel.DrawScale = 0.5 + ChargeSize/3.5;
    PlayAltBurst();
  }

Begin:
  FinishAnim();
  Finish();
}

function PlayAltBurst()
{
  if ( Owner.IsA('PlayerPawn') )
    PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
  Owner.PlaySound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,fMax(0.5,1.35-ChargeSize/8.0) );  //shoot goop
  PlayAnim('Fire',0.4, 0.05);
}
// Finish a firing sequence
function Finish()
{
  local bool bForce, bForceAlt;

  bForce = bForceFire;
  bForceAlt = bForceAltFire;
  bForceFire = false;
  bForceAltFire = false;
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( PlayerPawn(Owner) == None )
  {
    Pawn(Owner).bAltFire = 0;
    Super.Finish();
  }
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if ( (Pawn(Owner).bFire!=0) || bForce )
    Global.Fire(0);
  //else if ( (Pawn(Owner).bAltFire!=0) || bForceAlt )
    //Global.AltFire(0);
  else
    GotoState('Idle');
}


function PlayFiring()
{
  Owner.PlaySound(AltFireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);  //fast fire goop
  PlayAnim('Fire',1.1, 0.05);
}
///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
  if (VSize(Owner.Velocity) > 10)
    PlayAnim('Walking',0.3,0.3);
  else if (FRand() < 0.3 )
    PlayAnim('Drip', 0.1,0.3);
  else
    TweenAnim('Still', 1.0);
  Enable('AnimEnd');
}

function DripSound()
{
  Owner.PlaySound(Misc2Sound, SLOT_None, 0.5*Pawn(Owner).SoundDampening);  // Drip
}

// B227 addition
function class<Projectile> B227_GetProjClass(class<Projectile> ProjClass)
{
	if (class'UIweapons'.default.B227_bUseClassicProjectiles)
	{
		if (ProjClass == class'OSBioGel')
			return class'BioGel';
		if (ProjClass == class'OSBigBiogel')
			return class'BigBiogel';
	}
	return ProjClass;
}

defaultproperties
{
     WeaponDescription="Classification: Toxic Tarydium waste Rifle\n\nPrimary Fire: Tarydium sludge projectiles explode on contact with living tissue and adhere to most other surfaces for a short time before exploding.\n\nSecondary Fire: Hold down the secondary fire button to launch a larger, more powerful glob of sludge  The longer you hold down the secondary fire button, the bigger the glob (up to 500% sludge).\n\nTechniques: Remember that unlike its newer version, this version will not hold globs forever.  Timing is critical!"
     InstFlash=-0.150000
     InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
     AmmoName=Class'UnrealI.Sludge'
     PickupAmmoCount=25
     bAltWarnTarget=True
     FireOffset=(X=12.000000,Y=-9.000000,Z=-16.000000)
     ProjectileClass=Class'OLweapons.OSBioGel'
     AltProjectileClass=Class'OLweapons.OSBigBiogel'
     AIRating=0.600000
     RefireRate=0.900000
     AltRefireRate=0.700000
     FireSound=Sound'UnrealI.BioRifle.GelShot'
     AltFireSound=Sound'UnrealI.BioRifle.GelShot'
     CockingSound=Sound'UnrealI.BioRifle.GelLoad'
     SelectSound=Sound'UnrealI.BioRifle.GelSelect'
     Misc1Sound=Sound'UnrealI.BioRifle.GelLoad'
     Misc2Sound=Sound'UnrealI.BioRifle.GelDrip'
     DeathMessage="%o drank a glass of %k's dripping green load."
     NameColor=(R=0,B=0)
     AutoSwitchPriority=8
     InventoryGroup=8
     PickupMessage="You got the GES BioRifle"
     ItemName="GES Bio Rifle"
     PlayerViewOffset=(X=2.000000,Y=-0.700000,Z=-1.150000)
     PlayerViewMesh=LodMesh'UnrealI.BRifle'
     PickupViewMesh=LodMesh'UnrealI.BRiflePick'
     ThirdPersonMesh=LodMesh'UnrealI.BRifle3'
     StatusIcon=Texture'botpack.Icons.UseBio'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'botpack.Icons.UseBio'
     Mesh=LodMesh'UnrealI.BRiflePick'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=15.000000
}
