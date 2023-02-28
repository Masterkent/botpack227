// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Tvpbolt : A reskinned plasma beam.
// Features: Now reflects off walls up to 5 times or until length maxes out.
// ===============================================================

class Tvpbolt expands pbolt;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

var float BeamLength; //total length beam is taking. max: 810 units
var byte NumHits; //amount of times beam has hit wall. max times: 8
var Pbolt BaseBolt; //stores damage and time. life becomes much easier...'

simulated function CheckBeam(vector X, float DeltaTime)
{
  local actor HitActor;
  local vector HitLocation, HitNormal;
  local float DamageMult;
  local int bCanHitInstigator;

    if (B227_BeamStarter != none)
        DamageMult = FMax(1, B227_BeamStarter.B227_DamageMult);
    else
    {
        DamageMult = 1;
        if (TvStarterBolt(self) != none)
            B227_BeamStarter = self;
    }

  // check to see if hits something, else spawn or orient child

  //-HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
  B227_bCanHitInstigator = true;
  HitActor = B227_TraceBeam(X, HitLocation, HitNormal, bCanHitInstigator);

  if ( (HitActor != None)  && (HitActor != Instigator || Position>0)
    && (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers))
    && ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, X)) )
  {
    if ( Level.Netmode != NM_Client && HitActor != Level && (!HitActor.Isa('mover')||mover(HitACtor).bDamageTriggered))
    {
      if ( BaseBolt.DamagedActor == None )
      {
        BaseBolt.AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - BaseBolt.LastHitTime), 0.1);
        HitActor.TakeDamage(
          B227_GetDamage() * BaseBolt.AccumulatedDamage * DamageMult,
          Instigator,
          HitLocation,
          (MomentumTransfer * X * BaseBolt.AccumulatedDamage),
          MyDamageType);
        BaseBolt.AccumulatedDamage = 0;
      }
      else if ( BaseBolt.DamagedActor != HitActor)
      {
        BaseBolt.DamagedActor.TakeDamage(
          B227_GetDamage() * BaseBolt.AccumulatedDamage * DamageMult,
          Instigator,
          BaseBolt.DamagedActor.Location - X * 1.2 * BaseBolt.DamagedActor.CollisionRadius,
          (MomentumTransfer * X * BaseBolt.AccumulatedDamage),
          MyDamageType);
        BaseBolt.AccumulatedDamage = 0;
      }
      BaseBolt.LastHitTime = Level.TimeSeconds;
      BaseBolt.DamagedActor = HitActor;
      BaseBolt.AccumulatedDamage += DeltaTime;
      if ( BaseBolt.AccumulatedDamage > 0.22 )
      {
        if ( HitActor.IsA('Carcass') && (FRand() < 0.09) )
          BaseBolt.AccumulatedDamage = 35/damage;
        HitActor.TakeDamage(
          B227_GetDamage() * BaseBolt.AccumulatedDamage * DamageMult,
          Instigator,
          HitLocation,
          (MomentumTransfer * X * BaseBolt.AccumulatedDamage),
          MyDamageType);
        BaseBolt.AccumulatedDamage = 0;
      }
    }
    if (Level.NetMode != NM_DedicatedServer){
      if (HitActor!=level&&!HitActor.IsA('mover'))
        HitNormal=-X;
      if ( HitActor.bIsPawn )  //note: effect is still shown during reflection to mask out bolt anim sinc problems (I could hack around it, but too lazy)
      {
        if ( WallEffect != None )
          WallEffect.Destroy();
      }
      else if ( (WallEffect == None) || WallEffect.bDeleteMe ){
        WallEffect = Spawn(class'PlasmaHit',,, HitLocation + 5 * HitNormal);
   //     WallEffect.Texture=Texture'XidiaMPack.BlueBoltCap.pEnd_a00';
//        WallEffect.LightHue=170;
      }
      else if ( !WallEffect.IsA('PlasmaHit') )
      {
        WallEffect.Destroy();
        WallEffect = Spawn(class'PlasmaHit',,, HitLocation + 5 * HitNormal);
      //  WallEffect.Texture=Texture'XidiaMPack.BlueBoltCap.pEnd_a00';
      //  WallEffect.LightHue=170;
      }
      else
        WallEffect.SetLocation(HitLocation + 5 * HitNormal);

      if (HitActor == Level || HitActor.Isa('mover')){
        Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));
      }
    }
    if (HitActor == Level || HitActor.Isa('mover'))
        NumHits++;
    if (NumHits>8 || (HitActor != Level && !HitActor.Isa('mover')))
    {
      if (PlasmaBeam != None){
        PlasmaBeam.Destroy();
        PlasmaBeam = None;
      }
      return;
    }
  }
  else if ( (Level.Netmode != NM_Client) && (BaseBolt.DamagedActor != None) && BeamLength>=810)
  {
    BaseBolt.DamagedActor.TakeDamage(
      B227_GetDamage() * BaseBolt.AccumulatedDamage * DamageMult,
      Instigator,
      BaseBolt.DamagedActor.Location - X * 1.2 * BaseBolt.DamagedActor.CollisionRadius,
      (MomentumTransfer * X * BaseBolt.AccumulatedDamage),
      MyDamageType);
    BaseBolt.AccumulatedDamage = 0;
    BaseBolt.DamagedActor = None;
  }


  if ( BeamLength>=810 )
  {
    if (Level.NetMode != NM_DedicatedServer){
      if ( (WallEffect == None) || WallEffect.bDeleteMe ){
        WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
 //       WallEffect.Texture=Texture'XidiaMPack.BlueBoltHit.phit_a00';
 //       WallEffect.LightHue=170;
      }
      else if ( WallEffect.IsA('PlasmaHit') )
      {
        WallEffect.Destroy();
        WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
    //    WallEffect.Texture=Texture'XidiaMPack.BlueBoltHit.phit_a00';
    //    WallEffect.LightHue=170;
      }
      else
        WallEffect.SetLocation(Location + (BeamSize - 4) * X);
    }
    if (PlasmaBeam != None){ //in case of beams in front of this...
      PlasmaBeam.Destroy();
      PlasmaBeam = None;
    }
  }
  else
  {
    if (HitActor!=none && (HitActor==Level|| HitActor.Isa('mover'))){
       X -= 2 * ( X dot HitNormal) * HitNormal;
       X=normal(x);
       BeamLength+=vsize(HitLocation-Location);
    }
    else if ( WallEffect != None )
    {
      WallEffect.Destroy();
      WallEffect = None;
      BeamLength+=BeamSize;
      //-HitLocation = Location + BeamSize * X;
    }
    else{
      BeamLength+=BeamSize;
      //-HitLocation = Location + BeamSize * X;
    }
    if ( PlasmaBeam == None )
    {
      PlasmaBeam = Spawn(class'TvPBolt',,, HitLocation, rotator(X));
      PlasmaBeam.Position = Position + 1;
      TvPBolt(PlasmaBeam).BaseBolt = BaseBolt;
      PlasmaBeam.B227_BeamStarter = B227_BeamStarter;
    }
    else
      TVPBolt(PlasmaBeam).UpdatePBeam(self, X, HitLocation, DeltaTime);

    B227_ModifyLighting(PlasmaBeam);
  }
}

simulated function UpdatePBeam(TvPBolt ParentBolt, vector Dir, vector Loc, float DeltaTime)
{
  if (ParentBolt.B227_bHitPortal && class'B227_Config'.static.WarpedBeamOffset() > 0)
  {
    PrePivot = default.PrePivot - class'B227_Config'.static.WarpedBeamOffset() * Dir;
    SetLocation(Loc - (PrePivot - default.PrePivot));
  }
  else
  {
    PrePivot = default.PrePivot;
    SetLocation(Loc);
  }
  SpriteFrame = ParentBolt.SpriteFrame;
  Skin = SpriteAnim[SpriteFrame];
  SetRotation(rotator(Dir));
  BeamLength = ParentBolt.BeamLength;
  NumHits = ParentBolt.NumHits;
  CheckBeam(Dir, DeltaTime);
}

defaultproperties
{
}
