// ============================================================
// OLweapons.OLminigun: Network/decal minigun...
// Psychic_313: unchanged
// ============================================================

class OLminigun expands UIweapons;
var float ShotAccuracy, Count;
var bool bOutOfAmmo, bFiredShot;
var OverHeatLight s;

function GenerateBullet()
{
  if ( LightType == LT_None )
      LightType = LT_Steady;
  else
    LightType = LT_None;
  bFiredShot = true;
  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
  if ( AmmoType.UseAmmo(1) )
    TraceFire(ShotAccuracy);
  else
    GotoState('FinishFire');
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local int rndDam;

  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);

  if (Other == Level)
    Spawn(class'OSLightWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
  {
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
    if ( Other.IsA('ScriptedPawn') && (FRand() < 0.2) )
      Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
    rndDam = 8 + Rand(6);
    if ( FRand() < 0.2 )
      X *= 2;
    Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, 'shot');
  }
}

function Fire( float Value )
{
  Enable('Tick');
  if ( (Count<1) && AmmoType.UseAmmo(1) )
  {
    CheckVisibility();
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    AmbientSound = FireSound;
    SoundVolume = 255*Pawn(Owner).SoundDampening;
    //so it uses the recoil animation.....
    Pawn(Owner).PlayRecoil(FiringSpeed);
    bCanClientFire = true;
    bPointing=True;
    ShotAccuracy = 0.1;
    //PlayFiring();
    ClientFire(value);
    GotoState('NormalFire');
  }
  else GoToState('Idle');
}

function AltFire( float Value )
{
  Enable('Tick');
  if ( (Count<1) && AmmoType.UseAmmo(1) )
  {
    CheckVisibility();
    bPointing=True;
    ShotAccuracy = 0.8;
    bCanClientFire = true;
    Pawn(Owner).PlayRecoil(FiringSpeed);
    AmbientSound = FireSound;
    SoundVolume = 255*Pawn(Owner).SoundDampening;
    //PlayAltFiring();
    ClientAltFire(value);
    GoToState('AltFiring');
  }
  else GoToState('Idle');
}


function PlayFiring()
{
  LoopAnim('Shoot1',0.8, 0.05);
}

function PlayAltFiring()
{
  PlayAnim('Shoot1',0.8, 0.05);
}
function PlayUnwind()
{
  if ( Owner != None )
  {
    Owner.PlaySound(Misc1Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening);  //Finish firing, power down
    PlayAnim('UnWind',0.8, 0.05);
  }
}
////////////////////////////////////////////////////////
state FinishFire                      //from minigun2
{
  function Fire(float F) {}
  function AltFire(float F) {}

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
    PlayUnwind();
  }

Begin:
  FinishAnim();
  Finish();
}


///////////////////////////////////////////////////////
state NormalFire
{
  function Tick( float DeltaTime )
  {
    if (Owner==None)
      AmbientSound = None;
    else
      SetLocation(Owner.Location);
  }

  function AnimEnd()
  {
    if (Pawn(Owner).Weapon != self) GotoState('');
    else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
    {
      if ( (PlayerPawn(Owner) != None) || (FRand() < ReFireRate) )
        Global.Fire(0);
      else
      {
        Pawn(Owner).bFire = 0;
        GotoState('FinishFire');
      }
    }
    else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
      Global.AltFire(0);
    else
      GotoState('FinishFire');
  }

  function EndState()
  {
    LightType = LT_None;
    AmbientSound = None;
    Super.EndState();
  }

Begin:
  SetLocation(Owner.Location);
  Sleep(0.13);
  GenerateBullet();
  Goto('Begin');
}

state AltFiring
{
  function Tick( float DeltaTime )
  {
    if (Owner==None)
    {
      AmbientSound = None;
      GotoState('Pickup');
    }
    else
      SetLocation(Owner.Location);
    if ( (PlayerPawn(Owner) == None) && bFiredShot && (FRand() < DeltaTime/AltReFireRate) )
      Pawn(Owner).bAltFire = 0;
    if  ( bFiredShot && ((pawn(Owner).bAltFire==0) || bOutOfAmmo) )
      GoToState('FinishFire');
  }

  function AnimEnd()
  {
    if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
    {
      AmbientSound = AltFireSound;
      SoundVolume = 255*Pawn(Owner).SoundDampening;
      LoopAnim('Shoot2',0.8);
    }
  }

  function EndState()
  {
    LightType = LT_None;
    AmbientSound = None;
    Super.EndState();
  }

  function BeginState()
  {
    Super.BeginState();
    bFiredShot = false;
  }

Begin:
  SetLocation(Owner.Location);
  Sleep(0.13);
  GenerateBullet();
  if ( AnimSequence == 'Shoot2' )
    Goto('FastShoot');
  Goto('Begin');
FastShoot:
  Sleep(0.07);
  GenerateBullet();
  Goto('FastShoot');
}



///////////////////////////////////////////////////////////
state Idle
{


Begin:
  if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0) Fire(0.0);
  if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0) AltFire(0.0);
  PlayAnim('Still');
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  Disable('AnimEnd');
  PlayIdleAnim();
}

defaultproperties
{
     WeaponDescription="Classification: Gatling Gun\n\nPrimary Fire: Steady Stream of bullets, fast, accurate.\n\nSecondary Fire: More rapid, but less accurate stream of bullets.\n\nTechniques: Secondary fire is much more useful at close range, but can eat up tons of ammunition."
     AmmoName=Class'UnrealShare.ShellBox'
     PickupAmmoCount=50
     bInstantHit=True
     bAltInstantHit=True
     FireOffset=(Y=-5.000000,Z=-4.000000)
     shakemag=135.000000
     shakevert=8.000000
     AIRating=0.600000
     RefireRate=0.900000
     AltRefireRate=0.930000
     FireSound=Sound'UnrealI.Minigun.RegF1'
     AltFireSound=Sound'UnrealI.Minigun.AltF1'
     SelectSound=Sound'UnrealI.Minigun.MiniSelect'
     Misc1Sound=Sound'UnrealI.Minigun.WindD2'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     AutoSwitchPriority=10
     InventoryGroup=10
     PickupMessage="You got the Minigun"
     ItemName="Minigun"
     PlayerViewOffset=(X=5.600000,Y=-1.500000,Z=-1.800000)
     PlayerViewMesh=LodMesh'UnrealI.minigunM'
     PickupViewMesh=LodMesh'UnrealI.minipick'
     ThirdPersonMesh=LodMesh'UnrealI.SMini3'
     StatusIcon=Texture'botpack.Icons.UseMini'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'botpack.Icons.UseMini'
     Mesh=LodMesh'UnrealI.minipick'
     bNoSmooth=False
     SoundRadius=64
     SoundVolume=255
     CollisionRadius=28.000000
     CollisionHeight=8.000000
     LightEffect=LE_NonIncidence
     LightBrightness=250
     LightHue=28
     LightSaturation=32
     LightRadius=6
}
