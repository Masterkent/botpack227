// ===============================================================
// XidiaMPack.XidiaMinigun2: Psycho rolling crap!!!!!!!!!!!!!
// ===============================================================

class XidiaMinigun2 expands minigun2;

simulated function Recoil (float mult){
  if (Pawn(Owner)==none||Owner.Physics==Phys_None)
    return;
  if (Owner.physics==Phys_Walking){
    Owner.SetLocation(Owner.Location+vect(0,0,12));
    Pawn(Owner).AddVelocity(-1.9*mult*Owner.Velocity);
  }
  else
    Owner.Velocity-=220*mult*vector(pawn(owner).ViewRotation);
}
simulated function PlayFiring()
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

simulated function PlayAltFiring()
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

state ClientAltFiring
{
  simulated function AnimEnd()
  {
    if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
    {
      PlayUnwind();
      GotoState('');
    }
    else if ( !bCanClientFire )
      GotoState('');
    else if ( Pawn(Owner).bAltFire != 0 && !owner.region.zone.bwaterzone)
    {
      ShakeMag=15000;
      if (Owner.Physics==Phys_Walking){
        ShakeMag*=fmax(vsize(Owner.Velocity)/Pawn(Owner).default.GroundSpeed,0.03);
        if (pawn(owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight) //duck
          ShakeMag*=0.1;
      }
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
      if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
      {
        AmbientSound = AltFireSound;
        SoundVolume = 255*Pawn(Owner).SoundDampening;
        LoopAnim('Shoot2',1.9);
      }
      else if ( AmbientSound == None )
        AmbientSound = FireSound;

      if ( Affector != None )
        Affector.FireEffect();
      Recoil(0.8-0.4*byte(Owner.Physics==Phys_Walking&&Pawn(Owner).BaseEyeHeight!=pawn(owner).default.BaseEyeHeight));
      if ( PlayerPawn(Owner) != None )
        PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    }
    else if ( Pawn(Owner).bFire != 0 && !owner.region.zone.bwaterzone)
      Global.ClientFire(0);
    else
    {
      PlayUnwind();
      bSteadyFlash3rd = false;
      GotoState('ClientFinish');
    }
  }
}

simulated event RenderOverlays( canvas Canvas )
{
  local shellcase s;
  local vector X,Y,Z;
  local float dir;

  if ( bSteadyFlash3rd )
  {
    bMuzzleFlash = 1;
    bSetFlashTime = false;
    if ( !Level.bDropDetail )
      MFTexture = MuzzleFlashVariations[Rand(10)];
    else
      MFTexture = MuzzleFlashVariations[Rand(5)];
  }
  else
    bMuzzleFlash = 0;
  FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
  if ( !Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Handedness == 0) )
    FlashO = Default.FlashO * (4 + 0.15 * FRand());
  else
    FlashO = Default.FlashO * (1 + 0.15 * FRand());
  Texture'MiniAmmoled'.NotifyActor = Self;
  Super(TournamentWeapon).RenderOverlays(Canvas);
  Texture'MiniAmmoled'.NotifyActor = None;

  if ( bSteadyFlash3rd && Level.bHighDetailMode && (Level.TimeSeconds - LastShellSpawn > 0.125)
    && (Level.Pauser=="") )
  {
    LastShellSpawn = Level.TimeSeconds;
    GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);

    if ( PlayerViewOffset.Y >= 0 )
      dir = 1;
    else
      dir = -1;
    if ( Level.bHighDetailMode )
    {
      s = Spawn(class'LongShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
      if ( s != None )
        s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
    }
  }
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

state ClientFiring
{
  simulated function AnimEnd()
  {
    if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
    {
      PlayUnwind();
      GotoState('');
    }
    else if ( !bCanClientFire )
      GotoState('');
    else if ( Pawn(Owner).bFire != 0 && !owner.region.zone.bwaterzone)
      Global.ClientFire(0);
    else if ( Pawn(Owner).bAltFire != 0 && !owner.region.zone.bwaterzone)
      Global.ClientAltFire(0);
    else
    {
      PlayUnwind();
      GotoState('ClientFinish');
    }
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

simulated function bool clientfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientfire(value);
}

simulated function bool clientaltfire(float value){
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
