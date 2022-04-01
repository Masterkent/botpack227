// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// LaserBeam : Intended to be placed into the world by a mapper.  Will then generate further telsas.
// Toggle activation with bActive!
// when it hits something it will trigger an event, provided that something fits teh triggering type
// Set damage to control amount of damage the bolt does...
// ===============================================================

class LaserBeam expands TelsaBolt;

//mapper configurable:
var () bool bWallHitEffect; //show wall hit effect?
var () bool bActive; //Is it active initially? triggering this toggles.
var() enum ETriggerType
{
  TT_GoodGuyProximity,  // Trigger is activated by player proximity.
  TT_PawnProximity,  // Trigger is activated by any pawn's proximity
  TT_ClassProximity,  // Trigger is activated by actor of that class only
  TT_AnyProximity,    // Trigger is activated by any actor in proximity.
} TriggeringType;
var() class<actor> ClassProximityType; //what class can set off?
var() bool CallEventOnceOnly; //call event once only?


//internal:
var vector X;
var PlasmaCap BackWallEffect;
var float AnimTime;
var bool bNoTrigger;

replication{
  reliable if (role==role_authority)
    bActive, bWallHitEffect;
}

function bool IsRelevant( actor Other )
{
  if( !bActive || bNoTrigger)
    return false;
  switch( TriggeringType )
  {
    case TT_GoodGuyProximity:
      return Pawn(Other)!=None && (Pawn(Other).bIsPlayer);
    case TT_PawnProximity:
      return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None );
    case TT_ClassProximity:
      return ClassIsChildOf(Other.Class, ClassProximityType);
    return true;
  }
}

//triggering:
function HitSomething(actor Other){
  local Actor A;
  if (!IsRelevant(Other))
    return;
  if (CallEventOnceOnly)
    bNoTrigger=true;
  if( Event != '' )
    foreach AllActors( class 'Actor', A, Event )
      A.Trigger( Other, Other.Instigator );
  if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
    Pawn(Other).SpecialGoal = None;
}

function Trigger( actor Other, pawn EventInstigator )
{
  bActive=!bActive;
}

simulated function Destroyed()
{
  Super.Destroyed();
  if ( BackWallEffect != None )
    WallEffect.Destroy();
}

simulated function float GetDamage(vector HitLocation){
  return Damage;
}
simulated function byte GetVolume(float Damage){
  return SoundVolume;
}
simulated function bool DoWallHit(){
  return bWallHitEffect;
}
simulated function PostBeginPlay()
{
  Super.PostBeginPlay();
  Sentinel=self;
  Skin=SpriteAnim[0];
  oldsound=ambientsound;
}

simulated function Tick(float DeltaTime){
  SetHidden(!bActive);
  if (!bActive){
    if (PlasmaBeam != none){
      PlasmaBeam.Destroy();
      PlasmaBeam = none;
    }
    return;
  }
  AnimTime += DeltaTime;
  if ( AnimTime > 0.05 )
  {
    AnimTime -= 0.05;
    SpriteFrame++;
    if ( SpriteFrame == 5 )
      SpriteFrame = 0;
    if (skin!=none)
      Skin = SpriteAnim[SpriteFrame];
  }
  if (X==vect(0,0,0)){
    X=vector(Rotation);
    if (bWallHitEffect)
      SpawnWallHit();
  }
  CheckBeam(X, DeltaTime);
}

simulated function SpawnWallHit(){
  local vector HitLocation, HitNormal;
  if (Trace(HitLocation, HitNormal, Location - BeamSize * X, Location) != None){
      BackWallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X); //temp.. always stays.
      BackWallEffect.Texture=Texture'XidiaMPack.BlueBoltCap.pEnd_a00';
      BackWallEffect.LightHue=170;
  }
}

defaultproperties
{
     bActive=True
     CallEventOnceOnly=True
     DoCap=True
     MaxPos=9
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=67
     LightRadius=5
}
