// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// BattleBrute : Changes some defaults.
// Most notable thing is his shield. shields are cool :) (note: it is visual only.. health remains the same)
// also has seeking rockets when using rangedprojectile as osrocket or rocketmk2
// ===============================================================

class BattleBrute expands Brute;

//Shield Stuff:
var (Shield) float ShieldPercent; //amount of health transfered into shield.
var(Shield) enum EShieldColor
{
  Red,
  Blue,
  Green,
  Gold
} ShieldColor;   //shield color to use?
var (Shield) enum EShieldStyle
{
  UnrealI,
  UT
} ShieldStyle;  //unreal or ut?

//Locking odds (to work rangedprojectile must be osrocket or rocketmk2):
var () float SeekingOdds; //odds of seeking rockets at easy difficulty
var () float SeekingDifficultyVariation;  //seekingodds are added by difficulty*this number.
//active vars for shield:
var int ShieldBase; //amount of shield at start
var int ShieldAmount; //amount of shield currently.

var BruteShieldBeltEffect MyEffect; //either unreal's or UTs......
var class<UT_ShieldBelt> ReferenceShield; //rip defaults from here.

function PostBeginPlay(){
  Super.PostBeginPlay();
  if (RangedProjectile==class'OSRocket'&&level.netmode!=NM_StandAlone) //1.3 oops.. I should have updated the rocket simcode..
    RangedProjectile=class'RocketMK2';
  ShieldPercent=fclamp(ShieldPercent,0,1);
  ShieldBase=ShieldPercent*Health;
  if (ShieldBase==0)
    return; //no shield.
  ShieldAmount=ShieldBase;
  if (ShieldStyle==UnrealI)
    ReferenceShield=class<UT_ShieldBelt>(DynamicLoadObject("olweapons.osshieldbelt",class'class'));
  else
    ReferenceShield=class'UT_ShieldBelt';
  MyEffect=Spawn(class'BruteShieldBeltEffect',self);
  SetEffectTexture();
}

function SetEffectTexture()
{
  local byte SHByte;
  SHByte=ShieldColor;
  if (level.game.class==class'MonsterSmash')
    SHByte=rand(4);
  if ( shbyte != 3 )  //gold
    MyEffect.ScaleGlow = 0.5;
  else
    MyEffect.ScaleGlow = 1.0;
  MyEffect.ScaleGlow *= (0.25 + 0.75 * ShieldAmount/ShieldBase);
  MyEffect.Texture = ReferenceShield.default.TeamFireTextures[ShByte];
  MyEffect.RepLowDetailTexture = ReferenceShield.default.TeamTextures[ShByte];
  MyEffect.Mesh = Mesh;
  MyEffect.DrawScale = Drawscale;
//  broadcastmessage ("Texture is "$MyEffect.Texture@"and lowdetail is"$Myeffect.RepLowDetailTexture);
  MyEffect.BaseScaleGlow=MyEffect.ScaleGlow;
}
//shield check.  returns true if shield handled all damage (no hit anims/momentum transfer)
function bool CheckShield (int Damage){
  if (Health==0||MyEffect==none)
    return false;
  if (Damage==0)
    return true; //?
  PlaySound(ReferenceShield.default.DeActivateSound, SLOT_None, 2.7*SoundDampening);
  MyEffect.ScaleGlow = 4.0;
  MyEffect.Fatness = 255;
  ShieldAmount-=Damage;
  if (ShieldAmount<=0){
    MyEffect.Destroy();
    MyEffect=none;
    return false;
  }
  if ( ShieldColor != Gold )
    MyEffect.BaseScaleGlow = 0.5;
  else
    MyEffect.BaseScaleGlow = 1.0;
  MyEffect.BaseScaleGlow *= (0.25 + 0.75 * ShieldAmount/ShieldBase);
  return true;
}
function Destroyed()
{
  if ( MyEffect != None )
    MyEffect.Destroy();
  Super.Destroyed();
}
function Died(pawn Killer, name damageType, vector HitLocation)
{
  Super.Died(killer,damageType,HitLocation);
  if (Myeffect!=none&&health<=0)
    MyEffect.Destroy();
}

//rewritten to allow for shield use:
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
            Vector momentum, name damageType)
{
  local int actualDamage;
  local bool bAlreadyDead;

  if ( Role < ROLE_Authority )
  {
    log(self$" client damage type "$damageType$" by "$instigatedBy);
    return;
  }

  bAlreadyDead = (Health <= 0);

  if (Physics == PHYS_None)
    SetMovementPhysics();
  if (Physics == PHYS_Walking)
    momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
  if ( instigatedBy == self )
    momentum *= 0.6;
  momentum = momentum/Mass;

  actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
  if ( (InstigatedBy != None) &&
        (InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
    ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
  else if ( (ReducedDamageType == 'All') ||
    ((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
    actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

  class'UTC_GameInfo'.static.B227_ModifyDamage(self, InstigatedBy, ActualDamage, HitLocation, DamageType, Momentum);
  //-if ( Level.Game.DamageMutator != None )
  //-  Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );
  Health -= actualDamage;
  if (CheckShield(actualdamage)){ //no anims/blood
   if ( (instigatedBy != None) && (instigatedBy != Self) )
      damageAttitudeTo(instigatedBy);
    return;
  }
  AddVelocity( momentum );
  if (CarriedDecoration != None)
    DropDecoration();
  if ( HitLocation == vect(0,0,0) )
    HitLocation = Location;
  if (Health > 0)
  {
    if ( (instigatedBy != None) && (instigatedBy != Self) )
      damageAttitudeTo(instigatedBy);
    PlayHit(actualDamage, hitLocation, damageType, Momentum.Z);
  }
  else if ( !bAlreadyDead )
  {
    //log(self$" died");
    NextState = '';
    PlayDeathHit(actualDamage, hitLocation, damageType);
    if ( actualDamage > mass )
      Health = -1 * actualDamage;
    if ( (instigatedBy != None) && (instigatedBy != Self) )
      damageAttitudeTo(instigatedBy);
    Died(instigatedBy, damageType, HitLocation);
  }
  else
  {
     Destroy();
  }
  MakeNoise(1.0);
}

//locked rocket stuff:  (I HATE final functions!)
function SpawnLeftShot()
{
  FireLockedProjectile( vect(1.2,0.7,0.4), 750);
}

function SpawnRightShot()
{
  FireLockedProjectile( vect(1.2,-0.7,0.4), 750);
}
function GutShotTarget()
{
  FireLockedProjectile( vect(1.2,-0.55,0.0), 800);
}
final function FireLockedProjectile(vector StartOffset, int Accuracy)
{
  local vector X,Y,Z, projStart;
  local class<projectile> Projectile;
  local projectile proj;
  MakeNoise(1.0);
  GetAxes(Rotation,X,Y,Z);
  projStart = Location + StartOffset.X * CollisionRadius * X
          + StartOffset.Y * CollisionRadius * Y
          + StartOffset.Z * CollisionRadius * Z;
  if (CheckTarget(ProjStart)){
    if (RangedProjectile==class'OSRocket')
      Projectile=class'OSSeekingRocket';
    else if (RangedProjectile==class'RocketMk2')
      Projectile=class'UT_SeekingRocket';
    Accuracy/=3;
  }
  else
    Projectile=class<Projectile>(RangedProjectile);
  proj=spawn(Projectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, Accuracy, bLeadTarget, bWarnTarget));
  proj.speed=projectilespeed;
  proj.Velocity = projectilespeed*vector(proj.rotation);
  if (proj.Region.Zone.bWaterZone&&(Proj.Isa('Rocket')||Proj.Isa('RocketMk2')))
    proj.velocity*=0.6;
  if (Proj.Isa('UT_SeekingRocket'))
    UT_SeekingRocket(proj).Seeking=Enemy;
  else if (Proj.Isa('Rocket'))
    Rocket(proj).seeking=Enemy;
}
//quite simple check (locked if view fine and if passes)
function bool CheckTarget(vector Start)
{
  local rotator AimRot;
  local int diff;

  if (Enemy == None )
    return false;
  if (frand()>SeekingOdds+Skill*SeekingDifficultyVariation)
    return false;
  AimRot = rotator(Enemy.Location - Start);
  diff = abs((AimRot.Yaw & 65535) - (Rotation.Yaw & 65535));
  if ( (diff > 7200) && (diff < 58335) )
    return false;
  return True;
}

defaultproperties
{
     ShieldPercent=1.000000
     ShieldColor=Gold
     SeekingOdds=0.400000
     SeekingDifficultyVariation=0.200000
     WhipDamage=25
     RefireRate=0.500000
     bLeadTarget=True
     RangedProjectile=Class'olweapons.OSRocket'
     ProjectileSpeed=1000.000000
     GroundSpeed=200.000000
     AccelRate=400.000000
     SightRadius=2000.000000
     Intelligence=BRAINS_HUMAN
     MenuName="Battle Brute"
     Skin=Texture'UnrealI.Skins.Brute2'
     DrawScale=0.900000
     CollisionRadius=47.000000
     CollisionHeight=47.000000
     Mass=350.000000
     Buoyancy=220.000000
}
