// ===============================================================
// XidiaMPack.ScriptedXan2: the xan model
// forces requirement on BP4.  I could not get the source model :/
// ===============================================================

class ScriptedXan2 expands ScriptedHuman;

#exec OBJ LOAD FILE="SkeletalChars.u"

var () bool bDestruct; //blow up when dead
var pawn KilledMe; //who killed me?

function PlayDying(name DamageType, vector HitLoc)
{
  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();

  if ( DamageType == 'Suicided' )
  {
    PlayAnim('Dead8',, 0.1);
    return;
  }

  // check for head hit
  if ( (DamageType == 'Decapitated') && !Level.Game.bVeryLowGore )
  {
    PlayDecap();
    return;
  }

  if ( FRand() < 0.15 )
  {
    PlayAnim('Dead2',,0.1);
    return;
  }

  // check for big hit
  if ( (Velocity.Z > 250) && (FRand() < 0.75) )
  {
    if ( FRand() < 0.5 )
      PlayAnim('Dead1',,0.1);
    else
      PlayAnim('Dead11',, 0.1);
    return;
  }

  // check for repeater death
  if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
  {
    PlayAnim('Dead9',, 0.1);
    return;
  }

  if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !Level.Game.bVeryLowGore )
  {
    if ( FRand() < 0.5 )
      PlayDecap();
    else
      PlayAnim('Dead7',, 0.1);
    return;
  }

  if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
    PlayAnim('Dead3',, 0.1);
  else
    PlayAnim('Dead8',, 0.1);
}

function PlayDecap()
{
  PlayAnim('Dead4',, 0.1);
}

function PlayGutHit(float tweentime)
{
  if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
  {
    if (FRand() < 0.5)
      TweenAnim('LeftHit', tweentime);
    else
      TweenAnim('RightHit', tweentime);
  }
  else if ( FRand() < 0.6 )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('Dead8', tweentime);

}

function PlayHeadHit(float tweentime)
{
  if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead7') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('HeadHit', tweentime);
  else
    TweenAnim('Dead7', tweentime);
}

function PlayLeftHit(float tweentime)
{
  if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead9') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('LeftHit', tweentime);
  else
    TweenAnim('Dead9', tweentime);
}

function PlayRightHit(float tweentime)
{
  if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('RightHit', tweentime);
  else
    TweenAnim('Dead1', tweentime);
}

//exploding stuff
function Died(pawn Killer, name damageType, vector HitLocation)
{
  //-if ( Level.Game.BaseMutator.PreventDeath(self, Killer, damageType, HitLocation) )
  if (class'UTC_GameInfo'.static.B227_PreventDeath(self, Killer, damageType))
  {
    Health = max(Health, 1); //mutator should set this higher
    return;
  }
  if ( bDeleteMe )
    return; //already destroyed
  if ( bDestruct )
  {
    Health = 100;
    PlayDuck();
    //sound here?
    KilledMe=Killer;
    if ( CarriedDecoration != None )
      DropDecoration();
    Level.Game.DiscardInventory(self);
    GotoState('SelfDestruct');
  }
  else
    Super.Died(Killer, damageType, HitLocation);
}
State SelfDestruct
{
ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died;

  function Timer(){
    local actor a;
    local pawn OtherPawn;
    if ( Event != '' )
      ForEach AllActors( class'Actor', A, Event )
        A.Trigger( Self, Enemy );
    if (level.netmode==nm_standalone)
      spawn(Class'NuclearMark',,,,rot(-16368,0,0));   //hack
    spawn(class'ShockWave'); //does damage
    for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
      OtherPawn.Killed(KilledMe, self, '');
    level.game.Killed(KilledMe, self, '');
    Destroy();
  }

  function BeginState()
  {
    bStasis = false;
    SetPhysics(PHYS_None);
    SetTimer(3.0,false);
  }

}

//dif blood:
function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
  local Bubble1 bub;
  local bool bOptionalTakeHit;
  local vector BloodOffset;

  if (Damage > 1) //spawn some blood
  {
    if (damageType == 'Drowned')
    {
      bub = spawn(class 'Bubble1',,, Location
        + 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
      if (bub != None)
        bub.DrawScale = FRand()*0.06+0.04;
    }
    else if ( damageType != 'Corroded' )
    {
      BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
      BloodOffset.Z = BloodOffset.Z * 0.5;
      spawn(class 'UT_Sparks',,,hitLocation + BloodOffset, rotator(BloodOffset));  //do sparks
    }
  }

  if ( (Weapon != None) && Weapon.bPointing && !bIsPlayer )
  {
    bFire = 0;
    bAltFire = 0;
  }

  bOptionalTakeHit = bIsWuss || ( (Level.TimeSeconds - LastPainTime > 0.3 + 0.25 * skill)
            && (Damage * FRand() > 0.08 * Health) && (Skill < 3)
            && (GetAnimGroup(AnimSequence) != 'MovingAttack')
            && (GetAnimGroup(AnimSequence) != 'Attack') );
  if ( (!bIsPlayer || (Weapon == None) || !Weapon.bPointing)
    && (bOptionalTakeHit || (MomentumZ > 140) || (bFirstShot && (Damage > 0.015 * (skill + 6) * Health))
       || (Damage * FRand() > (0.17 + 0.04 * skill) * Health)) )
  {
    PlayTakeHitSound(Damage, damageType, 3);
    PlayHitAnim(HitLocation, Damage);
  }
  else if (NextState == 'TakeHit')
  {
    PlayTakeHitSound(Damage, damageType, 2);
    NextState = '';
  }
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType);

defaultproperties
{
     Voice=Class'BotPack.VoiceBotBoss'
     drown=Sound'BotPack.MaleSounds.drownM02'
     HitSound3=Sound'BotPack.Boss.BInjur3'
     HitSound4=Sound'BotPack.Boss.BInjur4'
     Deaths(0)=Sound'BotPack.Boss.BDeath1'
     Deaths(1)=Sound'BotPack.Boss.BDeath1'
     Deaths(2)=Sound'BotPack.Boss.BDeath3'
     Deaths(3)=Sound'BotPack.Boss.BDeath4'
     Deaths(4)=Sound'BotPack.Boss.BDeath3'
     Deaths(5)=Sound'BotPack.Boss.BDeath4'
     UWHit1=Sound'BotPack.MaleSounds.UWinjur41'
     UWHit2=Sound'BotPack.MaleSounds.UWinjur41'
     LandGrunt=Sound'BotPack.Boss.Bland01'
     CarcassType=Class'Botpack.TBossCarcass'
     bGreenBlood=True
     GroundSpeed=475.000000
     HitSound1=Sound'BotPack.MaleSounds.injurL2'
     HitSound2=Sound'BotPack.MaleSounds.injurL04'
     Die=Sound'BotPack.MaleSounds.deathc1'
     MenuName="Xan Mark ]["
     Mesh=SkeletalMesh'SkeletalChars.NewXan'
     MultiSkins(0)=Texture'SkeletalChars.Skins.XanRed'
}
