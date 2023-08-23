//=============================================================================
// TeamCannon.
//=============================================================================
class TeamCannon extends StationaryPawn;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() sound FireSound;
var() sound ActivateSound;
var() sound DeActivateSound;
var float SampleTime; 			// How often we sample Instigator's location
var int   TrackingRate;			// How fast Cannon tracks Instigator
var float Drop;					// How far down to drop spawning of projectile
var() bool bLeadTarget;
var bool bShoot;
var() Class<Projectile> ProjectileType;
var rotator StartingRotation;
var() int MyTeam;
var Actor GunBase;
var() localized string PreKillMessage, PostKillMessage;

var bool B227_bAttackAnyDamageInstigators;
var bool B227_bPermanentDamagedState;

function PostBeginPlay()
{
	SpawnBase();
	Super.PostBeginPlay();
	StartingRotation = Rotation;
}

function string KillMessage( name damageType, pawn Other )
{
	if (UTC_GameInfo(Level.Game) != none)
		return PreKillMessage @ Other.GetHumanName() @ PostKillMessage;
	return " " $ PostKillMessage;
}

simulated function Destroyed()
{
	Super.Destroyed();
	if ( GunBase != None )
		GunBase.Destroy();
}

simulated function Tick(float DeltaTime)
{
	if ( GunBase == None )
		SpawnBase();
	Disable('Tick');
}

simulated function SpawnBase()
{
	GunBase = Spawn(class'CeilingGunBase', self);
}

function SetTeam(int TeamNum)
{
	MyTeam = TeamNum;
}

function bool SameTeamAs(int TeamNum)
{
	return (MyTeam == TeamNum);
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	MakeNoise(1.0);
	if (instigatedBy != none)
		NDamage *= instigatedBy.DamageScaling;
	Health -= NDamage;
	if (Health <= 0)
	{
		PlaySound(DeActivateSound, SLOT_None,5.0);
		NextState = 'Idle';
		Enemy = None;
		Spawn(class'UT_BlackSmoke');
		GotoState('DamagedState');
	}
	else if (instigatedBy == none)
		return;
	else if (Enemy == none &&
		!IsInState('TrackWarhead') &&
		B227_IsPotentialDamageEnemy(instigatedBy))
	{
		Enemy = instigatedBy;
		GotoState('ActiveCannon');
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	GotoState('DeActivated');
}

function StartDeactivate()
{
	SetPhysics(PHYS_Rotating);
	DesiredRotation = StartingRotation;
}

function PlayDeactivate()
{
	PlaySound(ActivateSound, SLOT_None,5.0);
	TweenAnim('Activate', 1.5);
}

function PlayActivate()
{
	PlayAnim(AnimSequence);
	PlaySound(ActivateSound, SLOT_None, 2.0);
}

function ActivateComplete();

function Name PickAnim()
{
	if (DesiredRotation.Pitch < -13400 )
	{
		Drop = 35;
		return 'Fire6';
	}
	else if (DesiredRotation.Pitch < -10600 )
	{
		Drop = 30;
		return 'Fire5';
	}
	else if (DesiredRotation.Pitch < -7400 )
	{
		Drop = 25;
		return 'Fire4';
	}
	else if (DesiredRotation.Pitch < -4200 )
	{
		Drop = 20;
		return 'Fire3';
	}
	else if (DesiredRotation.Pitch < -1000 )
	{
		Drop = 15;
		return 'Fire2';
	}
	else
	{
		Drop = 10;
		return 'Fire1';
	}
}

function Shoot()
{
	local Vector FireSpot, ProjStart;
	local Projectile P;
	local rotator FireRotation;

	if (DesiredRotation.Pitch < -20000 || ProjectileType == none)
		return;
	PlaySound(FireSound, SLOT_None,5.0);
	PlayAnim(PickAnim());

	ProjStart = Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop;
	if ( bLeadTarget )
	{
		FireSpot = Target.Location + FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * VSize(Target.Location - ProjStart)/ProjectileType.Default.Speed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
		FireRotation = Rotator(FireSpot - ProjStart);
	}
	else
		FireRotation = DesiredRotation;
	P = Spawn(ProjectileType,,, ProjStart, FireRotation);
	B227_ModifyProjectileDamage(P);
	//-if ( Target.IsA('WarShell') )
	//-	p.speed *= 2;
	bShoot=False;
	SetTimer(0.05,True);
}

auto state Idle
{
	ignores EnemyNotVisible;

	function SeePlayer(Actor SeenPlayer)
	{
		if (SeenPlayer.bCollideActors && !B227_SameTeamAsOf(Pawn(SeenPlayer)))
		{
			Enemy = Pawn(SeenPlayer);
			GotoState('ActiveCannon');
		}
	}

	function BeginState()
	{
		Enemy = None;
	}

Begin:
	TweenAnim(AnimSequence, 0.25);
	Sleep(5.0);
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	Sleep(2.0);
	SetPhysics(PHYS_None);
}

state DeActivated
{
	ignores SeePlayer, EnemyNotVisible, TakeDamage;

Begin:
	Health = -1;
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
	Sleep(6.0);
	SetPhysics(PHYS_None);
}

state DamagedState
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible;

Begin:
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	if (B227_bPermanentDamagedState)
		stop;
	Sleep(13.0);
	Health = Default.Health;
	GotoState(NextState);
}

state ActiveCannon
{
	ignores SeePlayer;

	function EnemyNotVisible()
	{
		Enemy = none;
		if (!B227_FindEnemy())
			GotoState('Idle');
	}

	function Killed(pawn Killer, pawn Other, name damageType)
	{
		if ( Other == Enemy )
			EnemyNotVisible();
	}

	function Timer()
	{
		if (B227_EnemyNotVisible())
		{
			if (Enemy != none)
				SetTimer(SampleTime, true);
			return;
		}

		DesiredRotation = rotator(Enemy.Location - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		if ( bShoot && (DesiredRotation.Pitch < 2000)
			&& ((Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 1000)
			|| (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 64535)) )
			Shoot();
		else
		{
			TweenAnim(PickAnim(), 0.25);
			bShoot=True;
			SetTimer(SampleTime,True);
		}
	}

	function BeginState()
	{
		Target = Enemy;
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	bShoot=True;

FaceEnemy:
	B227_EnemyNotVisible(); // Calls EnemyNotVisible if there is no enemy in line of sight
	TurnToward(Enemy);
	Goto('FaceEnemy');
}


state TrackWarhead
{
	ignores SeePlayer, EnemyNotVisible;

	function Timer()
	{
		if (B227_LostTarget())
		{
			FindEnemy();
			return;
		}

		DesiredRotation = rotator(Target.Location - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		if ( bShoot && (DesiredRotation.Pitch < 2000)
			&& ((Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 2000)
			|| (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 63535)) )
			Shoot();
		else
		{
			TweenAnim(PickAnim(), 0.25);
			bShoot=True;
			SetTimer(SampleTime, true);
		}
	}

	function FindEnemy()
	{
		Target = None;
		Enemy = None;
		if (B227_FindEnemy())
			GotoState('ActiveCannon');
		else
			GotoState('Idle');
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	bShoot=True;

FaceEnemy:
	if (B227_LostTarget())
		FindEnemy();
	TurnToward(Target);
	Goto('FaceEnemy');
}


state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, WarnTarget, Died;

	function BeginState()
	{
		Destroy();
	}
}

// Auxiliary B227 functions

function bool B227_SameTeamAsOf(Pawn P)
{
	if (TeamCannon(P) != none)
		return !Level.Game.bTeamGame || TeamCannon(P).MyTeam == MyTeam;

	return
		Level.Game.bTeamGame &&
		P != none &&
		P.PlayerReplicationInfo != none &&
		SameTeamAs(P.PlayerReplicationInfo.Team);
}

function bool B227_IsPotentialEnemy(Pawn P)
{
	return P.bIsPlayer && P.Health > 0 && !P.bDeleteMe && !B227_SameTeamAsOf(P);
}

function bool B227_IsPotentialDamageEnemy(Pawn P)
{
	if (P.Health <= 0 || P.bDeleteMe)
		return false;
	return B227_bAttackAnyDamageInstigators && TeamCannon(P) == none || !B227_SameTeamAsOf(P);
}

function bool B227_FindEnemy()
{
	local Pawn P;

	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.bCollideActors &&
			B227_IsPotentialEnemy(P) &&
			!P.IsA('TeamCannon') &&
			LineOfSightTo(P))
		{
			Enemy = P;
			Target = Enemy;
			return true;
		}
	return false;
}

function B227_WarnAboutWarShell(Projectile Proj)
{
	if ((IsInState('Idle') || IsInState('ActiveCannon')) &&
		VSize(Location - Proj.Location) <= SightRadius &&
		LineOfSightTo(Proj) &&
		!B227_SameTeamAsOf(Proj.Instigator) &&
		Proj.bCollideActors &&
		Proj.bProjTarget)
	{
		Target = Proj;
		GotoState('TrackWarhead');
	}
}

function bool B227_LostTarget()
{
	return Target == none || Target.bDeleteme || VSize(Location - Target.Location) > SightRadius + default.SightRadius;
}

function B227_ModifyProjectileDamage(Projectile Proj)
{
	if (DeathMatchPlus(Level.Game) != none && DeathMatchPlus(Level.Game).bNoviceMode)
		Proj.Damage *= 0.4 + 0.15 * Level.Game.Difficulty;
}

defaultproperties
{
	FireSound=Sound'UnrealI.Cannon.CannonShot'
	ActivateSound=Sound'UnrealI.Cannon.CannonActivate'
	SampleTime=0.330000
	TrackingRate=25000
	Drop=60.000000
	ProjectileType=Class'Botpack.CannonShot'
	PostKillMessage="was killed by an automatic cannon!"
	SightRadius=3000.000000
	FovAngle=90.000000
	Health=220
	MenuName="automatic cannon!"
	NameArticle="an "
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence=Activate
	Mesh=LodMesh'Botpack.cdgunmainM'
	CollisionRadius=28.000000
	RotationRate=(Yaw=25000)
	bClientTick=True
}
