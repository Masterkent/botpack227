// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TelsaBolt : Much like a pbolt. some variations however....
// Uses actor.oddsofappearing to scale :)
// Tesla, Telsa, whatever.
// ============================================================

class TelsaBolt expands Projectile;
var (LaserBeam) texture SpriteAnim[5];
var int SpriteFrame;
var TelsaBolt PlasmaBeam;   //next beam
var TelsaBolt Sentinel; //parent of all. (starter or laser beam)
var int Position;
var (LaserBeam) float BeamSize;
var PlasmaCap WallEffect;
//stuff only valid for sentinel.
var Actor DamagedActor;
var (LaserBeam) bool DoCap; //if false, hide :)
var (LaserBeam) int MaxPos; //maximum position...
var sound oldsound;

replication
{
  // Things the server should send to the client.
  unreliable if( Role==ROLE_Authority )
    MaxPos, DoCap;
}
simulated function Destroyed()
{
  Super.Destroyed();
  if ( PlasmaBeam != None )
    PlasmaBeam.Destroy();
  if ( WallEffect != None )
    WallEffect.Destroy();
}

simulated function float GetDamage(vector HitLocation);
simulated function byte GetVolume(float Damage);
simulated function bool DoWallHit(){
  return true;
}
simulated function HitSomething(actor HitActor);

simulated function CheckBeam(vector X, float DeltaTime)
{
  local actor HitActor;
  local vector HitLocation, HitNormal;

  // check to see if hits something, else spawn or orient child

  HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
  if ( (HitActor != None)
    && (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers))
    && ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, X)) )
  {
    Sentinel.HitSomething(HitActor);
    if (skin==none)
      Sentinel.SetHidden(false);
    damage=Sentinel.GetDamage(HitLocation);       //calc instant damage
    SoundVolume=Sentinel.GetVolume(damage);
    Sentinel.LightBrightness=SoundVolume;
    if (WallEffect!=none)
      WallEffect.LightBrightness=SoundVolume;
    SoundVolume*=3;
    Sentinel.SoundVolume=SoundVolume;
    if ( Level.Netmode != NM_Client && damage != 0.0)
    {
      if ( Sentinel.DamagedActor == None )
      {
/*        MomentumTransfer=-118*damage; //does negative momentum, as electrical force :)
        Sentinel.AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - Sentinel.LastHitTime), 0.1);
        HitActor.TakeDamage(Sentinel.AccumulatedDamage*damage, Instigator,HitLocation,
          (MomentumTransfer * X * Sentinel.AccumulatedDamage), MyDamageType);
        Sentinel.AccumulatedDamage = 0;*/
        HitActor.OddsofAppearing=fmax(HitActor.OddsofAppearing-1,0);
      }
      else if ( Sentinel.DamagedActor != HitActor )
      {
/*        Sentinel.DamagedActor.TakeDamage(Sentinel.AccumulatedDamage, Instigator,HitLocation,
          (-118*X * Sentinel.AccumulatedDamage), MyDamageType);
        Sentinel.AccumulatedDamage = 0;*/
        Sentinel.DamagedActor.OddsofAppearing+=1;
        HitActor.OddsofAppearing=fmax(HitActor.OddsofAppearing-1,0);
      }
//      Sentinel.LastHitTime = Level.TimeSeconds;
      Sentinel.DamagedActor = HitActor;
//      Sentinel.AccumulatedDamage += DeltaTime*damage;
      Sentinel.DamagedActor.OddsOfAppearing +=  DeltaTime*damage;
      if (  sentinel.DamagedActor.OddsOfAppearing > 1.00)
      {
        if ( sentinel.DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
          Sentinel.DamagedActor.OddsOfAppearing = 35/Sentinel.DamagedActor.OddsOfAppearing;
        sentinel.DamagedActor.TakeDamage(int(Sentinel.DamagedActor.OddsOfAppearing), instigator,HitLocation,
          vect(0,0,0), MyDamageType); //no momentum=electric shock!
        Sentinel.DamagedActor.OddsOfAppearing -=int(Sentinel.DamagedActor.OddsOfAppearing);
      }
    }
    if ( HitActor.bIsPawn && Pawn(HitActor).bIsPlayer )
    {
      if ( WallEffect != None )
        WallEffect.Destroy();
    }
    else if ( Sentinel.DoWallHit() && (WallEffect == None || WallEffect.bDeleteMe )){
      WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
      WallEffect.Texture=Texture'XidiaMPack.BlueBoltCap.pEnd_a00';
      WallEffect.LightHue=170;
    }
    else if ( Sentinel.DoWallHit() && !WallEffect.IsA('PlasmaHit') )
    {
      WallEffect.Destroy();
      WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
      WallEffect.Texture=Texture'XidiaMPack.BlueBoltCap.pEnd_a00';
      WallEffect.LightHue=170;
    }
    else
      WallEffect.SetLocation(HitLocation - 5 * X);

    if ( Sentinel.DoWallHit() && (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) )
      Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));

    if ( PlasmaBeam != None )
    {
      PlasmaBeam.Destroy();
      PlasmaBeam = None;
    }

    return;
  }
  else if ( (Level.Netmode != NM_Client) && (Sentinel.DamagedActor != None) )
  {
 /*   sentinel.DamagedActor.TakeDamage(Sentinel.AccumulatedDamage, instigator, sentinel.DamagedActor.Location - X * 1.2 * sentinel.DamagedActor.CollisionRadius,
      (-118 * X * Sentinel.AccumulatedDamage), MyDamageType);
    sentinel.AccumulatedDamage = 0;
    sentinel.DamagedActor = None;*/
     Sentinel.DamagedActor.OddsofAppearing+=1;
     Sentinel.DamagedActor=none;
  }


  if ( Position >= Sentinel.MaxPos )
  {
    Sentinel.LightBrightness=0;
    if (Sentinel.DoCap){
      if ( (WallEffect == None) || WallEffect.bDeleteMe ){
        WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
        WallEffect.Texture=Texture'XidiaMPack.BlueBoltHit.phit_a00';
        WallEffect.LightHue=170;
      }
      else if ( WallEffect.IsA('PlasmaHit') )
      {
        WallEffect.Destroy();
        WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
        WallEffect.Texture=Texture'XidiaMPack.BlueBoltHit.phit_a00';
        WallEffect.LightHue=170;
      }
      else
        WallEffect.SetLocation(Location + (BeamSize - 4) * X);
    }
    else {
      if (WallEffect!=none)
        Walleffect.Destroy();
      Sentinel.SetHidden(true);
    }
  }
  else
  {
    if ( WallEffect != None )
    {
      WallEffect.Destroy();
      WallEffect = None;
    }
    if ( PlasmaBeam == None )
    {
      PlasmaBeam = Spawn(class'TelsaBolt',,, Location + BeamSize * X);
      PlasmaBeam.Position = Position + 1;
      PlasmaBeam.Sentinel=Sentinel;
      PlasmaBeam.bhidden=bhidden;
      PlasmaBeam.AmbientSound=AmbientSound;
      PlasmaBeam.Mesh=Mesh;
      PlasmaBeam.BeamSize=BeamSize;

    }
    else
      PlasmaBeam.UpdateBeam(self, X, DeltaTime);
  }
}

simulated function UpdateBeam(TelsaBolt ParentBolt, vector Dir, float DeltaTime)
{
  SoundVolume = ParentBolt.SoundVolume;
  //SpriteFrame = ParentBolt.SpriteFrame;
  Skin = ParentBolt.Skin;
  SetLocation(ParentBolt.Location + BeamSize * Dir);
  SetRotation(ParentBolt.Rotation);
  CheckBeam(Dir, DeltaTime);
}

simulated function SetHidden(bool hide){ //fake hide all bolts...
  bhidden=hide;
  if (hide)
    AmbientSound=none;
  else
    AmbientSound=Sentinel.oldsound;
  if (PlasmaBeam!=none)
    PlasmaBeam.SetHidden(hide);
}

defaultproperties
{
     SpriteAnim(0)=Texture'XidiaMPack.Skins.pbbolt0'
     SpriteAnim(1)=Texture'XidiaMPack.Skins.pbbolt1'
     SpriteAnim(2)=Texture'XidiaMPack.Skins.pbbolt2'
     SpriteAnim(3)=Texture'XidiaMPack.Skins.pbbolt3'
     SpriteAnim(4)=Texture'XidiaMPack.Skins.pbbolt4'
     BeamSize=81.000000
     MaxSpeed=0.000000
     Damage=72.000000
     MomentumTransfer=8500
     MyDamageType=zapped
     ExplosionDecal=Class'BotPack.BoltScorch'
     bNetTemporary=False
     Physics=PHYS_None
     RemoteRole=ROLE_None
     LifeSpan=60.000000
     AmbientSound=Sound'BotPack.PulseGun.PulseBolt'
     Style=STY_Translucent
     Texture=Texture'XidiaMPack.Skins.pbbolt0'
     Mesh=LodMesh'BotPack.PBolt'
     bUnlit=True
     SoundRadius=45
     SoundVolume=255
     bCollideActors=False
     bCollideWorld=False
}
