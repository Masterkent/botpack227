// The fighting Nali
// Code by Sergey 'Eater' Levin, 2001/2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles
#exec OBJ LOAD FILE="EpicCustomModels.u"

class NaliWarrior extends ScriptedPawn;

var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var bool AttackSuccess;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;

var 	name phrase;
var		byte phrasesyllable;
var		float	voicePitch;
var() class<weapon> WeaponType;
var	  Weapon myWeapon;
var   float  duckTime;

function eAttitude AttitudeToCreature(Pawn Other)
{
	if (PlayerPawn(Other) != none)
		return AttitudeToPlayer;
	else if (NaliWarrior(Other) != none)
		return ATTITUDE_Friendly;
	else if ( (Skaarj(Other) != none) && (NaliWarrior(Other) == none) )
		return ATTITUDE_Hate;
	else if ( Pupae(Other) != none )
		return ATTITUDE_Hate;
	else if ( Nali(Other) != none )
		return ATTITUDE_Friendly;
	else if ( Warlord(Other) != none || Queen(Other) != none)
		return ATTITUDE_Hate;
	else if (ScriptedPawn(Other) != none && ScriptedPawn(Other).attitudeToPlayer < ATTITUDE_Ignore) // hate them as much as they hate us
		return ScriptedPawn(Other).attitudeToPlayer;
	else
		return ATTITUDE_Ignore;
}

function damageAttitudeTo(pawn Other)
{
	local eAttitude OldAttitude;

	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;
	if( Other.bIsPlayer ) //change attitude to player
	{
		if (AttitudeToPlayer == ATTITUDE_Ignore) AttitudeToPlayer = ATTITUDE_Threaten;
		else if (AttitudeToPlayer == ATTITUDE_Threaten) AttitudeToPlayer = ATTITUDE_Hate;
		else if (AttitudeToPlayer == ATTITUDE_Hate) Hated = Other;
	}
	else
	{
		OldAttitude = AttitudeToCreature(Other);
		if (OldAttitude > ATTITUDE_Ignore )
			return;
		else if ( OldAttitude > ATTITUDE_Frenzy )
		{
			//log(class$" hates "$Other.class);
			Hated = Other;
		}
	}
	SetEnemy(Other);
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemy;
	local float newStrength;

	if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
		return false;
	if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) )
		return false;
	if ( !NewEnemy.bIsPlayer && (ScriptedPawn(NewEnemy) == None) )
		return false;

	noOldEnemy = (Enemy == None);
	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( !noOldEnemy )
	{
		if (Enemy == NewEnemy)
			return true;
		else if ( newAttitude == ATTITUDE_Friendly )
		{
			if ( bIgnoreFriends )
				return false;
			if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) )
			{
				if ( AttitudeTo(NewEnemy.Enemy) < AttitudeTo(Enemy) )
				{
					OldEnemy = Enemy;
					Enemy = NewEnemy.Enemy;
					result = true;
				}
			}
		}
		else
		{
			oldAttitude = AttitudeTo(Enemy);
			if ( (newAttitude < oldAttitude) ||
				( (newAttitude == oldAttitude)
					&& ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location))
						|| !LineOfSightTo(Enemy)) ) )
			{
				if ( bIsPlayer && Enemy.IsA('PlayerPawn') && !NewEnemy.IsA('PlayerPawn') )
				{
					newStrength = relativeStrength(NewEnemy);
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
				else
				{
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		result = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
		if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) )
		{
			result = true;
			//log("his enemy is my enemy");
			Enemy = NewEnemy.Enemy;
			if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
				Hated = Enemy;
		}
	}

	if ( result )
	{
		//log(class$" has new enemy - "$enemy.class);
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
	}
	else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
		OldEnemy = NewEnemy;

	return result;
}

state Acquisition
{
ignores falling, landed;
	function BeginState()
	{
		//Disable('Tick');
		SetAlertness(-0.5);
	}
}

function Tick(float DeltaTime) {
	local pawn p;

	if (!isInState('Attacking') && !isInState('TacticalMove') && !isInState('Retreating') &&
	    !isInState('Charging') && !isInState('TakeHit') && !isInState('MeleeAttack') && !isInState('RangedAttack') &&
	    !isInState('TriggerAlarm') && !isInState('Greeting') && !isInState('Dying') && !isInState('Startup')) {
		foreach visiblecollidingactors(class'pawn',p,SightRadius) { // doesn't judge visibility or peripheral vision
			if (p.health > 0 && AttitudeToCreature(p) < ATTITUDE_Ignore) {
				setenemy(p);
				if (enemy == p) {
					goToState('Attacking');
				}
			}
		}
		//if (enemy.health > 0 && enemy != none && !isInState('Attacking'))
		//	goToState('Attacking');
	}
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	bCanSpeak = true;
	voicePitch = Default.voicePitch + 0.6 * Default.voicePitch * FRand();

	if ( CombatStyle == Default.CombatStyle)
		CombatStyle = CombatStyle + 0.3 * FRand() - 0.15;

	if ( skill > 2 )
		ProjectileSpeed *= 1.1;

	if ( TimeBetweenAttacks == Default.TimeBetweenAttacks )
		TimeBetweenAttacks = TimeBetweenAttacks + (3 - Skill) * 0.3;
	bHasRangedAttack = false;
	bMovingRangedAttack = false;
}

function ChangedWeapon()
{
	Super.ChangedWeapon();
	bIsPlayer = false;
	bMovingRangedAttack = true;
	bHasRangedAttack = true;
	Weapon.AimError += 200;
	Weapon.FireOffset = Weapon.FireOffset * 1.5 * DrawScale;
	Weapon.PlayerViewOffset = Weapon.PlayerViewOffset * 1.5 * DrawScale;
	//Weapon.SetHand(0);
}

function TossWeapon()
{
	if ( Weapon == None )
		return;
	Weapon.FireOffset = Weapon.Default.FireOffset;
	Weapon.PlayerViewOffset = Weapon.Default.PlayerViewOffset;
	Super.TossWeapon();
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	bIsPlayer = false;
	Super.Died(Killer, damageType, HitLocation);
}

auto state Startup
{
	function BeginState()
	{
		Super.BeginState();
		bIsPlayer = true; // temporarily, till have weapon
		if ( WeaponType != None )
		{
			bIsPlayer = true;
			myWeapon = Spawn(WeaponType);
			if ( myWeapon != None )
				myWeapon.ReSpawnTime = 0.0;
		}
	}

	function SetHome()
	{
		Super.SetHome();
		if ( myWeapon != None )
			myWeapon.Touch(self);
	}
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	local float MaxSpeed, enemyDist;
	local eAttitude att;
	local vector X,Y,Z, enemyDir;

	att = AttitudeTo(shooter);
	if ( (att == ATTITUDE_Ignore) || (att == ATTITUDE_Threaten) )
	{
		if ( intelligence >= BRAINS_Mammal )
			damageAttitudeTo(shooter);
		if (att == ATTITUDE_Ignore)
			return;
	}

	// AI controlled creatures may duck if not falling
	if ( (Enemy == None) || (Physics == PHYS_Falling) || (FRand() > 0.4 + 0.2 * skill) )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Location);
	duckTime = enemyDist/projSpeed;
	if (duckTime < 0.1 + 0.15 * FRand()) //FIXME - pick right value
		return;

	// only if tight FOV
	GetAxes(Rotation,X,Y,Z);
	enemyDir = (shooter.Location - Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft;
	local actor HitActor;
	local float decision;

	duckDir.Z = 0;
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	if (HitActor != None)
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	}

	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir - MaxStepHeight * vect(0,0,1), Location + 200 * duckDir, false, Extent);

	SetFall();
	if ( duckLeft )
		PlayAnim('DodgeL', 1.35);
	else
		PlayAnim('DodgeR', 1.35);
	Velocity = duckDir * GroundSpeed;
	Velocity.Z = 200;
	SetPhysics(PHYS_Falling);
	GotoState('FallingState','Ducking');
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.8);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}

	if ( Weapon == None )
		return false;

	GetAxes(Rotation,X,Y,Z);
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( HitActor == Enemy )
		return true;
	if ( (HitActor != None) && (VSize(HitLocation - Location) < 200) )
		return false;
	if ( (Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) > ATTITUDE_Ignore) )
		return false;

	return true;
}

function PlayCock()
{
	if ( Weapon != None )
	{
		if ( Weapon.CockingSound != None )
			PlaySound(Weapon.CockingSound, SLOT_Interact,,,700);
		else if ( Weapon.SelectSound != None )
			PlaySound(Weapon.CockingSound, SLOT_Interact,,,700);
	}
}

//Skaarj animations
function PlayPatrolStop()
{
	local float decision;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	SetAlertness(0.2);
	LoopAnim('Breath1', 0.3 + 0.6 * FRand());
}

function PlayChallenge()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( TryToCrouch() )
	{
		TweenAnim('DuckwlkS', 0.12);
		return;
	}
	PlayThreateningSound();
	PlayAnim('StillSmFr', 0.8 + 0.5 * FRand(), 0.1);
}

function PlayRunning()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;

	bFire = 0;
	bAltFire = 0;
	DesiredSpeed = MaxDesiredSpeed;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	if (Focus == Destination)
	{
		LoopAnim('RunSm', 0.9,, 0.5);
		return;
	}
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		LoopAnim('RunSm',0.9,, 0.5);
	else if (strafeMag < -0.8)
		LoopAnim('RunSm',0.9,, 0.5);
	else
	{
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0)
		{
			LoopAnim('StrafeR');
		}
		else
		{
			LoopAnim('StrafeL');
		}
	}
}

function PlayMovingAttack()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;
	local int bUseAltMode;

	if (Weapon != None)
	{
		if ( Weapon.AmmoType != None )
			Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
		Weapon.RateSelf(bUseAltMode);
		ViewRotation = Rotation;
		if ( bUseAltMode == 0 )
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
		else
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
	}
	else
	{
		PlayRunning();
		return;
	}

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	DesiredSpeed = MaxDesiredSpeed;

	if (Focus == Destination)
	{
		LoopAnim('RunSmFr',0.9,, 0.4);
		return;
	}
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		LoopAnim('RunSmFr',0.9,, 0.4);
	else if (strafeMag < -0.8)
		LoopAnim('RunSmFr',0.9,, 0.4);
	else
	{
		MoveTimer += 0.2;
		DesiredSpeed = 0.6;
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0)
		{
			if ( (AnimSequence == 'StrafeR') || (AnimSequence == 'StrafeR') )
				LoopAnim('StrafeR', 0.9,, 1.0);
			else
				LoopAnim('StrafeR', 0.9,0.1, 1.0);
		}
		else
		{
			if ( (AnimSequence == 'StrafeL') || (AnimSequence == 'StrafeL') )
				LoopAnim('StrafeL', 0.9,, 1.0);
			else
				LoopAnim('StrafeL',0.9, 1.0);
		}
	}
}

function PlayThreatening()
{
	local float decision, animspeed;

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	decision = FRand();
	animspeed = 0.4 + 0.6 * FRand();

	if ( decision < 0.7 )
		PlayAnim('Breath2', animspeed, 0.3);
	else
	{
		PlayThreateningSound();
		PlayAnim('StillSmFr', animspeed, 0.3);
	}
}

function PlayRangedAttack()
{
	PlayFiring();
}

function PlayFiring()
{
	TweenAnim('StillSmFr', 0.2);
	if ( (Weapon != None) && (Weapon.AmmoType != None) )
		Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
}

function PlayVictoryDance()
{
	PlayAnim('Taunt1', 0.6, 0.1);
}

state TakeHit
{
ignores seeplayer, hearnoise, bump, hitwall;
	function Landed(vector HitNormal)
	{
		local float landVol;

		if ( AnimSequence == 'Dead' )
		{
			landVol = 0.75 + Velocity.Z * 0.004;
			LandVol = Mass * landVol * landVol * 0.01;
			PlaySound(sound'thump', SLOT_Interact, landVol);
			GotoState('FallingState', 'RiseUp');
		}
		else
			Super.Landed(HitNormal);
	}

	function PlayTakeHit(float tweentime, vector HitLoc, int damage)
	{
		if ( AnimSequence != 'Dead' )
			Global.PlayTakeHit(tweentime, HitLoc, damage);
	}

	function BeginState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.BeginState();
		If ( AnimSequence == 'Dead' )
			GotoState('FallingState');
	}
}

state Retreating
{
ignores SeePlayer, EnemyNotVisible, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state Charging
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;

Begin:
	if (enemy != none) {
		goToState('RangedAttack');
	}
	else {
		GotoState('Waiting');
		PlayWaiting();
	}
}

function RunStep()
{
	if (FRand() < 0.6)
		PlaySound(FootStep, SLOT_Interact,0.8,,900);
	else
		PlaySound(FootStep2, SLOT_Interact,0.8,,900);
}

function WalkStep()
{
	if (FRand() < 0.6)
		PlaySound(FootStep, SLOT_Interact,0.2,,500);
	else
		PlaySound(FootStep2, SLOT_Interact,0.2,,500);
}

function ZoneChange(ZoneInfo newZone)
{
	bCanSwim = newZone.bWaterZone; //only when it must

	if ( newZone.bWaterZone )
		CombatStyle = 1.0; //always charges when in the water
	else if (Physics == PHYS_Swimming)
		CombatStyle = Default.CombatStyle;

	Super.ZoneChange(newZone);
}

function PreSetMovement()
{
	MaxDesiredSpeed = 0.7 + 0.1 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = true;
	if ( Intelligence > BRAINS_Mammal )
		bCanDoSpecial = true;
	bCanDuck = true;
}

function SetMovementPhysics()
{
	if ( Region.Zone.bWaterZone )
		SetPhysics(PHYS_Swimming);
	else if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking);
}

//=========================================================================================
// Speech

function SpeechTimer()
{
	//last syllable expired.  Decide whether to keep the floor or quit
	if (FRand() < 0.3)
	{
		bIsSpeaking = false;
		if (TeamLeader != None)
			TeamLeader.bTeamSpeaking = false;
	}
	else
		Speak();
}

function SpeakOrderTo(ScriptedPawn TeamMember)
{
	phrase = '';
	if ( !TeamMember.bCanSpeak || (FRand() < 0.5) )
		Speak();
	else
	{
		if (NaliWarrior(TeamMember) != None)
			NaliWarrior(TeamMember).phrase = '';
		TeamMember.Speak();
	}
}

function SpeakTo(ScriptedPawn Other)
{
	if (Other.bIsSpeaking || ((TeamLeader != None) && TeamLeader.bTeamSpeaking) )
		return;

	phrase = '';
	Speak();
}

function Speak()
{
	local float decision, inflection, pitch;

	//if (phrase != '')
	//	SpeakPhrase();
	bIsSpeaking = true;
	if ( FRand() < 0.65)
	{
		inflection = 0.6 + 0.5 * FRand();
		pitch = voicePitch + 0.4 * FRand();
	}
	else
	{
		inflection = 1.3 + 0.5 * FRand();
		pitch = voicePitch + 0.8 * FRand();
	}
	decision = FRand();
	if (TeamLeader != None)
		TeamLeader.bTeamSpeaking = true;
	if (decision < 0.167)
		PlaySound(Syllable1,SLOT_Talk,inflection,,, pitch);
	else if (decision < 0.333)
		PlaySound(Syllable2,SLOT_Talk,inflection,,, pitch);
	else if (decision < 0.5)
		PlaySound(Syllable3,SLOT_Talk,inflection,,, pitch);
	else if (decision < 0.667)
		PlaySound(Syllable4,SLOT_Talk,inflection,,, pitch);
	else if (decision < 0.833)
		PlaySound(Syllable5,SLOT_Talk,inflection,,, pitch);
	else
		PlaySound(Syllable6,SLOT_Talk,inflection,,, pitch);

	SpeechTime = 0.1 + 0.3 * FRand();
}

function PlayAcquisitionSound()
{
	if ( bCanSpeak && (TeamLeader != None) && !TeamLeader.bTeamSpeaking )
	{
		phrase = 'Acquisition';
		phrasesyllable = 0;
		Speak();
		return;
	}
	Super.PlayAcquisitionSound();
}

function PlayFearSound()
{
	if ( bCanSpeak && (TeamLeader != None) && !TeamLeader.bTeamSpeaking )
	{
		phrase = 'Fear';
		phrasesyllable = 0;
		Speak();
		return;
	}
	Super.PlayFearSound();
}

function PlayRoamingSound()
{
	if ( bCanSpeak && (TeamLeader != None) && !TeamLeader.bTeamSpeaking  && (FRand() < 0.5) )
	{
		phrase = '';
		Speak();
		return;
	}
	Super.PlayRoamingSound();
}

function PlayThreateningSound()
{
	if ( bCanSpeak && (FRand() < 0.6) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
	{
		phrase = 'Threaten';
		phrasesyllable = 0;
		Speak();
		return;
	}
	Super.PlayThreateningSound();
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	animspeed = 0.3 + 0.6 * FRand(); //vary speed
	decision = FRand();
	if (AnimSequence == 'Breath')
	{
		SetAlertness(0.0);
		if (decision < 0.15)
		{
			PlayAnim('GunCock', AnimSpeed, 0.7);
			if ( !bQuiet )
				PlaySound(Roam, SLOT_Talk);
		}
		else if ( decision < 0.28 )
		{
			PlayAnim('Look', AnimSpeed);
		}
		else
			LoopAnim('Breath', AnimSpeed);
		return;
	}
	else if ( AnimSequence == 'Breath2' )
	{
		if (decision < 0.2)
		{
			SetAlertness(0.3);
			LoopAnim('Breath1', 0.2 + 0.5 * FRand());
		}
		else
			LoopAnim('Breath2', AnimSpeed);
		return;
	}
	else if ( AnimSequence == 'GunCock' )
	{
		SetAlertness(-0.3);
		if (decision < 0.25)
		{
			PlayCock();
			LoopAnim('GunCockL', animspeed);
		}
		else if (decision < 0.37)
			PlayAnim('Look', animspeed);
		else
			LoopAnim('GunCock', animspeed);
		return;
 	}
	else if ( AnimSequence == 'Look' )
	{
		if (decision < 0.7)
		{
			SetAlertness(-0.3);
			LoopAnim('GunCock', animspeed);
		}
		else if (decision < 0.85)
		{
			SetAlertness(0.0);
			PlayAnim('Breath2', AnimSpeed, 0.7);
		}
		else
		{
			SetAlertness(0.5);
			LoopAnim('Look', AnimSpeed);
		}
		return;
	}
	else if ( AnimSequence == 'Look' )
	{
		if (decision < 0.1)
		{
			SetAlertness(0.0);
			PlayAnim('Breath2', AnimSpeed, 0.7);
		}
		else
		{
			SetAlertness(0.6);
			LoopAnim('Look', AnimSpeed);
			if ( !bQuiet )
				PlaySound(Roam, SLOT_Talk);
		}
		return;
	}
	else if ( AnimSequence == 'CockGunL' )
	{
		SetAlertness(-0.4);
		if (decision < 0.87)
			LoopAnim('CockGun', AnimSpeed);
		else
		{
			PlayCock();
			LoopAnim('CockGunL', AnimSpeed);
		}
		return;
	}
	else
	{
		SetAlertness(-0.3);
		PlayAnim('Breath1', animspeed, 0.6);
		return;
	}
}

function PlayWaitingAmbush()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if (FRand() < 0.8)
		LoopAnim('Breath2', 0.3 + 0.6 * FRand());
	else
		LoopAnim('Breath1', 0.3 + 0.6 * FRand());
}

function PlayDive()
{
	TweenToSwimming(0.2);
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('cockgun', tweentime);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if ( (AnimSequence == 'Dead') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else
		TweenAnim('StillSmFr', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if ( (AnimSequence == 'Dead') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else if ( ((AnimSequence != 'RunSm') && (AnimSequence != 'RunSmFr')) || !bAnimLoop )
		TweenAnim('RunSm', tweentime);
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('WalkSm', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('Breath1', tweentime);
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	LoopAnim('WalkSm', 0.88);
}

function TweenToSwimming(float tweentime)
{
	if ( (AnimSequence != 'treadSm') || !bAnimLoop )
		TweenAnim('treadSm', tweentime);
}

function PlaySwimming()
{
	LoopAnim('treadSm', -1.0/WaterSpeed,, 0.5);
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( (AnimSequence == 'Dead') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else
		TweenAnim('TurnSm', 0.3);
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	if ( (Nali(Other) != None || NaliWarrior(Other) != None) && Killer != none && Killer.bIsPlayer ) {
		//AttitudeToPlayer = ATTITUDE_Hate;
		//if (Enemy == none || Enemy.health <= 0)
		if (FastTrace(killer.location,location)) { // if we can see the player
			damageAttitudeTo(killer);
		}
	}
	Super(scriptedpawn).Killed(Killer, Other, damageType);
}

function PlayBigDeath(name DamageType)
{
	PlayAnim('Dead4',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayHeadDeath(name DamageType)
{
	local carcass carc;

	if ( ((DamageType == 'Decapitated') || ((Health < -20) && (FRand() < 0.5)))
		 && !Level.Game.bVeryLowGore )
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Mesh = mesh'NaliHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead3',0.7,0.1);
	}
	else if ( FRand() < 0.5 )
		PlayAnim('Dead',0.7,0.1);
	else
		PlayAnim('Dead4',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayLeftDeath(name DamageType)
{
	if ( FRand() < 0.5 )
		PlayAnim('Dead',0.7,0.1);
	else
		PlayAnim('Dead2',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayRightDeath(name DamageType)
{
	if ( FRand() < 0.3 )
		PlayAnim('Dead2',0.7,0.1);
	else
		PlayAnim('Dead',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayGutDeath(name DamageType)
{
	PlayAnim('Dead',0.7, 0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float decision;

	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

	decision = FRand(); //FIXME - modify based on damage
	if (decision < 0.25)
		PlaySound(HitSound1, SLOT_Pain, 2.0 * Mult);
	else if (decision < 0.5)
		PlaySound(HitSound2, SLOT_Pain, 2.0 * Mult);
	else if (decision < 0.75)
		PlaySound(Hitsound1, SLOT_Pain, 2.0 * Mult);
	else
		PlaySound(Hitsound2, SLOT_Pain, 2.0 * Mult);
}

function TweenToFalling()
{
	// B227 note: tnalimesh has no such animations
	//-if ( FRand() < 0.5 )
	//-	TweenAnim('Jog', 0.2);
	//-else
	//-	PlayAnim('Jump',0.7,0.1);
}

function PlayInAir()
{
	if ( AnimSequence == 'RunSm')
		PlayAnim('RunSm', 0.9);
	else if ( AnimSequence == 'RunSmFr')
		PlayAnim('RunSmFr', 0.9);
	else
		TweenAnim('JumpSMFR',0.4);
}

function PlayOutOfWater()
{
	TweenAnim('LandSmFr', 0.8);
}

function PlayLanded(float impactVel)
{
	if (impactVel > 1.7 * JumpZ)
		TweenAnim('LandSmFr',0.1);
	else
		TweenAnim('LandSmFr', 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( (Velocity.Z > 120) && (Health < 0.4 * Default.Health) && (FRand() < 0.33) )
		PlayAnim('Dead',0.7);
	else if ( AnimSequence != 'Dead' )
		Super.PlayTakeHit(tweentime, HitLoc, damage);
}

/*function SpinDamageTarget()
{
	if (MeleeDamageTarget(SpinDamage, (SpinDamage * 1000 * Normal(Target.Location - Location))) )
		PlaySound(slice, SLOT_Interact);
}

function ClawDamageTarget()
{
	if ( MeleeDamageTarget(ClawDamage, (ClawDamage * 900 * Normal(Target.Location - Location))) )
		PlaySound(slice, SLOT_Interact);
}*/

state FallingState
{
ignores Bump, Hitwall, HearNoise, WarnTarget;

	function Landed(vector HitNormal)
	{
		local float landVol;

		if ( AnimSequence == 'Dead' )
		{
			landVol = 0.75 + Velocity.Z * 0.004;
			LandVol = Mass * landVol * landVol * 0.01;
			PlaySound(sound'Thump', SLOT_Interact, landVol);
			GotoState('FallingState', 'RiseUp');
		}
		else if ( (AnimSequence == 'DodgeL') || (AnimSequence == 'DodgeR') )
		{
			landVol = Velocity.Z/JumpZ;
			landVol = 0.008 * Mass * landVol * landVol;
			if ( !FootRegion.Zone.bWaterZone )
				PlaySound(Land, SLOT_Interact, FMin(20, landVol));
			GotoState('FallingState', 'FinishDodge');
		}
		else
			Super.Landed(HitNormal);
	}

	function PlayTakeHit(float tweentime, vector HitLoc, int damage)
	{
		if ( AnimSequence != 'Dead' )
			Global.PlayTakeHit(tweentime, HitLoc, damage);
	}

LongFall:
	if ( AnimSequence == 'Death2' )
	{
		Sleep(1.5);
		Goto('RiseUp');
	}
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	TweenToFighter(0.2);
	if ( bHasRangedAttack && (Enemy != None) )
	{
		TurnToward(Enemy);
		FinishAnim();
		if ( CanFireAtEnemy() )
		{
			PlayRangedAttack();
			FinishAnim();
		}
		PlayChallenge();
		FinishAnim();
	}
	TweenToFalling();
	if ( Velocity.Z > -150 ) //stuck
	{
		SetPhysics(PHYS_Falling);
		if ( Enemy != None )
			Velocity = groundspeed * normal(Enemy.Location - Location);
		else
			Velocity = groundspeed * VRand();

		Velocity.Z = FMax(JumpZ, 250);
	}
	Goto('LongFall');
RiseUp:
	FinishAnim();
	bCanDuck = false;
	DesiredRotation = Rotation;
	Acceleration = vect(0,0,0);
	PlayAnim('JumpSmFr', 0.7);
FinishDodge:
	FinishAnim();
	bCanDuck = true;
	Goto('Done');
}

state Hunting
{
ignores EnemyNotVisible;

	function BeginState()
	{
		bCanSwim = true;
		Super.BeginState();
	}

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		if ( !Region.Zone.bWaterZone )
			bCanSwim = false;
		if ( !Region.Zone.bWaterZone )
			bCanSwim = false;
		Super.EndState();
	}
}

state RangedAttack
{
ignores SeePlayer, HearNoise;

	function Bump (Actor Other)
	{
		/*if ( (GetAnimGroup(AnimSequence) == 'Shielded') && (Other == Enemy) )
		{
			PlayAnim('ShldDown');
			GotoState('MeleeAttack', 'ShieldDown');
			return;
		}
		if ( AttackSuccess || (AnimSequence != 'Lunge') )
		{
			Disable('Bump');
			return;
		}
		else
			LungeDamageTarget();

		if (!AttackSuccess && Pawn(Other) != None) //always add momentum
			Pawn(Other).AddVelocity((60000.0 * (Normal(Other.Location - Location)))/Other.Mass);*/
	}

	function PlayRangedAttack()
	{
		local float dist;

		//dist = VSize(Target.Location - Location + vect(0,0,1) * (CollisionHeight - Target.CollisionHeight));
		/*if ( (FRand() < 0.2) && (dist < 150 + CollisionRadius + Target.CollisionRadius) && (Region.Zone.bWaterZone || !Target.Region.Zone.bWaterZone) )
		{
			PlaySound(Lunge, SLOT_Interact);
	 		Velocity = 500 * (Target.Location - Location)/dist; //instant acceleration in that direction
	 		Velocity.Z += 1.5 * dist;
	 		if (Physics != PHYS_Swimming)
	 			SetPhysics(PHYS_Falling);
	 		Enable('Bump');
	 		PlayAnim('DodgeF');
	 	}
		else
		{*/
			Disable('Bump');
			FireWeapon();
		//}
	}

	function KeepAttacking()
	{
		if ( bFiringPaused )
			return;
		if ( (Enemy == None) || (Enemy.Health <= 0))
		{
			GotoState('Waiting');
			PlayWaiting();
		}
		else if (!CanFireAtEnemy())
			GotoState('Attacking');
	}


	function AnimEnd()
	{
		if ( (FRand() < 0.5) || ((bFire == 0) && (bAltFire == 0)) )
			GotoState('RangedAttack', 'DoneFiring');
		else
			TweenAnim('StillSmFr', 0.5);
	}

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}

Challenge:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	TweenToFighter(0.15);

FaceTarget:
	Disable('AnimEnd');
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();

ReadyToAttack:
	if (!bHasRangedAttack)
		GotoState('Attacking');
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayRangedAttack();
	Enable('AnimEnd');
Firing:
	TurnToward(Enemy);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
	KeepAttacking();
	Goto('FaceTarget');
}

defaultproperties
{
     syllable1=Sound'UnrealShare.Nali.syl1n'
     syllable2=Sound'UnrealShare.Nali.syl2n'
     syllable3=Sound'UnrealShare.Nali.syl3n'
     syllable4=Sound'UnrealShare.Nali.syl4n'
     syllable5=Sound'UnrealShare.Nali.syl5n'
     syllable6=Sound'UnrealShare.Nali.syl6n'
     footstep=Sound'UnrealShare.Cow.walkC'
     Footstep2=Sound'UnrealShare.Cow.walkC'
     WeaponType=Class'NaliChronicles.NCQuadbow'
     CarcassType=Class'UnrealShare.NaliCarcass'
     TimeBetweenAttacks=0.500000
     Aggressiveness=0.500000
     RefireRate=0.500000
     bHasRangedAttack=True
     bMovingRangedAttack=True
     Acquire=Sound'UnrealShare.Nali.contct1n'
     Fear=Sound'UnrealShare.Nali.fear1n'
     Roam=Sound'UnrealShare.Nali.breath1n'
     Threaten=Sound'UnrealShare.Nali.contct3n'
     bCanStrafe=True
     GroundSpeed=300.000000
     WaterSpeed=100.000000
     AccelRate=900.000000
     JumpZ=200.000000
     SightRadius=1500.000000
     Health=120
     UnderWaterTime=6.000000
     AttitudeToPlayer=ATTITUDE_Friendly
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'UnrealShare.Nali.injur1n'
     HitSound2=Sound'UnrealShare.Nali.injur2n'
     Die=Sound'UnrealShare.Nali.death1n'
     CombatStyle=0.300000
     DrawType=DT_Mesh
     Skin=Texture'NaliChronicles.Skins.JNaliWarrior'
     Mesh=LodMesh'epiccustommodels.tnalimesh'
     DrawScale=1.300000
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     Buoyancy=95.000000
     RotationRate=(Pitch=2048,Yaw=40000,Roll=0)
}
