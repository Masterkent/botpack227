// ===============================================================
// XidiaMPack.XidiaMinigun2: Psycho rolling crap!!!!!!!!!!!!!
// ===============================================================

class XidiaMinigun2 expands minigun2;

function Recoil (float mult){
  if (Pawn(Owner)==none||Owner.Physics==Phys_None)
    return;
  if (Owner.physics==Phys_Walking){
    Owner.SetLocation(Owner.Location+vect(0,0,12));
    Pawn(Owner).AddVelocity(-1.9*mult*Owner.Velocity);
  }
  else
    Owner.Velocity-=220*mult*vector(pawn(owner).ViewRotation);
}
function PlayFiring()
{
  if ( PlayerPawn(Owner) != None && Viewport(PlayerPawn(Owner).Player)!=none){
    ShakeMag=10000;
    if (Owner.Physics==Phys_Walking){
      ShakeMag*=fmax(vsize(Owner.Velocity)/Pawn(Owner).default.GroundSpeed,0.03);
      if (pawn(owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight) //duck
        ShakeMag*=0.1;
    }
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
  Recoil(0.7-0.5*byte(Owner.Physics==Phys_Walking&&Pawn(Owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight));
  PlayAnim('Shoot1',1 + 0.6 * FireAdjust, 0.05);
  AmbientGlow = 250;
  AmbientSound = FireSound;
  bSteadyFlash3rd = true;
}

function PlayAltFiring()
{
  if ( PlayerPawn(Owner) != None && Viewport(PlayerPawn(Owner).Player)!=none){
    ShakeMag=10000;
    if (Owner.Physics==Phys_Walking){
      ShakeMag*=fmax(vsize(Owner.Velocity)/Pawn(Owner).default.GroundSpeed,0.03);
      if (pawn(owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight) //duck
        ShakeMag*=0.1;
    }
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
  PlayAnim('Shoot1',1 + 0.3 * FireAdjust, 0.05);
  Recoil(0.7-0.5*byte(Owner.Physics==Phys_Walking&&Pawn(Owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight));
  AmbientGlow = 250;
  AmbientSound = FireSound;
  bSteadyFlash3rd = true;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local int rndDam;

  if (Other == Level)
    Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
  else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
  {
    if ( !Other.bIsPawn && !Other.IsA('Carcass') )
      spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
    else
      Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

    if ( Other.IsA('Bot') && (FRand() < 0.2) )
      Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
    rndDam = 50 + Rand(21);
    if ( FRand() < 0.2 )
      X *= 2.5;
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice) ||
        (Other.IsA('ScriptedPawn') && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        MyDamageType='Decapitated';
        rndDam*=2;
    }
    Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, MyDamageType);
    MyDamageType=default.MyDamageType;
  }
}

simulated event RenderOverlays( canvas Canvas )
{
	super.RenderOverlays(Canvas); // see B227_SpawnShellCase
}

//no firing in water code:
state NormalFire
{
  function AnimEnd()
  {
    if (Pawn(Owner).Weapon != self) GotoState('');
    else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bwaterzone)
      Global.Fire(0);
    else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bwaterzone)
      Global.AltFire(0);
    else
      GotoState('FinishFire');
  }
}

state AltFiring
{
  function AnimEnd()
  {
    if ( PlayerPawn(Owner) != None && viewport(playerpawn(owner).player)!=none){
    ShakeMag=15000;
    if (Owner.Physics==Phys_Walking){
      ShakeMag*=fmax(vsize(Owner.Velocity)/Pawn(Owner).default.GroundSpeed,0.03);
      if (pawn(owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight) //duck
        ShakeMag*=0.1;
    }
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
    if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
    {
      AmbientSound = AltFireSound;
      SoundVolume = 255*Pawn(Owner).SoundDampening;
      LoopAnim('Shoot2',1.9);
    }
    else if ( AmbientSound == None )
      AmbientSound = FireSound;
    Recoil(0.8-0.4*byte(Owner.Physics==Phys_Walking&&Pawn(Owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight));
    if ( Affector != None )
      Affector.FireEffect();
  }
  function Tick( float DeltaTime )
  {
    if (Owner==None)
    {
      AmbientSound = None;
      GotoState('Pickup');
    }

    if  ( bFiredShot && ((pawn(Owner).bAltFire==0) || bOutOfAmmo || owner.region.zone.bwaterzone) )
      GoToState('FinishFire');
  }
}

function bool clientfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientfire(value);
}

function bool clientaltfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientaltfire(value);
}

function AltFire( float Value ) {

  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.AltFire(value);

}

function Fire( float Value ) {
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.Fire(value);
}
state Idle
{

Begin:
  if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bWaterZone) Fire(0.0);
  if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bWaterZone) AltFire(0.0);
  LoopAnim('Idle',0.2,0.9);
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  Disable('AnimEnd');
}

simulated function B227_SpawnShellCase()
{
	local shellcase s;
	local vector X,Y,Z;
	local float dir;

	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);

	if ( PlayerViewOffset.Y >= 0 )
		dir = 1;
	else
		dir = -1;
	s = Spawn(class'LongShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
	if (s != none)
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
}

defaultproperties
{
     AmmoName=Class'XidiaMPack.XidiaMiniammo'
     PickupAmmoCount=25
     shaketime=0.300000
     DeathMessage="%k's %w converted %o into swiss cheese."
     InventoryGroup=7
     PickupMessage="You got the Chaingun."
     ItemName="ChainGun"
}
