//=============================================================================
// MinigunCannon.
//=============================================================================
class MinigunCannon extends TeamCannon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var Actor MuzzFlash;
 
function PostBeginPlay()
{
	Super.PostBeginPlay();
	MuzzFlash = Spawn(class'CannonMuzzle');
	MuzzFlash.SetBase(self);
}

function Name PickAnim()
{
	Drop = 0;
	if (DesiredRotation.Pitch < -1000 )
	{
		if ( DesiredRotation.Pitch < -4000 )
			return 'Fire5';
		else 
			return 'Fire3';
	}
	else if (DesiredRotation.Pitch > 1000 ) 
	{
		if ( DesiredRotation.Pitch > 4000 )
			return 'Fire9';
		else 
			return 'Fire7';
	}
	else 
		return 'Fire1';
}

simulated function SpawnBase()
{
	GunBase = Spawn(class'GrBase', self);
	GunBase.bAnimByOwner = true;
}

function PlayDeactivate()
{
	TweenAnim('Activate', 1.5);
}

function StartDeactivate()
{
	PlaySound(ActivateSound, SLOT_None,5.0);
	Mesh = mesh'Botpack.GrMockGunM';
	AnimSequence = 'Fire1';
	AnimFrame = 0.0;
	SetPhysics(PHYS_Rotating);
	DesiredRotation = StartingRotation;
	PrePivot = vect(0,0,0);
}

function ActivateComplete()
{
	Mesh = mesh'Botpack.GrFinalGunM';
	PrePivot = vect(0,0,40);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;
	local UT_Shellcase s;

	s = Spawn(class'UT_ShellCase',, '', PrePivot + Location + 20 * X + 10 * Y + 30 * Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
	if (Other == Level) 
		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other != None) ) 
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		rndDam = 5 + Rand(4);
		if (DeathMatchPlus(Level.Game) != none && DeathMatchPlus(Level.Game).bNoviceMode)
			rnddam *= (0.4 + 0.15 * Level.game.Difficulty);
		Other.TakeDamage(rndDam, self, HitLocation, rndDam*500.0*X, 'shot');
	}
}

function Shoot()
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal, ProjStart, X,Y,Z;
	local rotator ShootRot;
	if (DesiredRotation.Pitch < -10000) Return;
	if ( AmbientSound == None )
		PlaySound(FireSound, SLOT_None,5.0);

	GetAxes(Rotation,X,Y,Z);
	ProjStart = PrePivot + Location + X*20 + 12 * Y + 16 * Z;
	ShootRot = rotator(Target.Location - ProjStart);
	ShootRot.Yaw = ShootRot.Yaw + 1024 - Rand(2048 + 1);
	DesiredRotation = ShootRot;
	ShootRot.Pitch = ShootRot.Pitch + 256 - Rand(512 + 1);
	GetAxes(ShootRot,X,Y,Z);
	PlayAnim(PickAnim());
	MuzzFlash.SetLocation(ProjStart);
	if ( FRand() < 0.4 )
		Spawn(class'MTracer',,, ProjStart, ShootRot);
	HitActor = TraceShot(HitLocation,HitNormal,ProjStart + 10000 * X,ProjStart);
	ProcessTraceHit(HitActor, HitLocation, HitNormal, X,Y,Z);
	bShoot = false;
	ShootRot.Pitch = ShootRot.Pitch & 65535;
	if ( ShootRot.Pitch < 32768 )
		ShootRot.Pitch = Min(ShootRot.Pitch, 5000);
	else
		ShootRot.Pitch = Max(ShootRot.Pitch, 60535);
	MuzzFlash.SetRotation(ShootRot);
	ShootRot.Pitch = 0;
	SetRotation(ShootRot);
}

state ActiveCannon
{
	ignores SeePlayer;

	function Timer()
	{
		if (B227_EnemyNotVisible())
		{
			if (Enemy != none)
				SetTimer(SampleTime, true);
			return;
		}

		DesiredRotation = rotator(Enemy.Location - Location - PrePivot);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		MuzzFlash.bHidden = false;
		if ( bShoot )
			Shoot();
		else 
		{
			TweenAnim(PickAnim(), 0.2);
			bShoot=True;
			SetTimer(SampleTime,True);
		}
	}

	function BeginState()
	{
		Super.BeginState();
	}

	function EndState()
	{
		AmbientSound = None;
		MuzzFlash.bHidden = true;
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
	AmbientSound = Class'Minigun2'.Default.FireSound;
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

		DesiredRotation = rotator(Target.Location - Location - PrePivot);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		MuzzFlash.bHidden = false;

		if ( bShoot )
			Shoot();
		else 
		{
			TweenAnim(PickAnim(), 0.2);
			bShoot=True;
			SetTimer(SampleTime,True);
		}
	}

	event EndState()
	{
		AmbientSound = none;
		MuzzFlash.bHidden = true;
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
	AmbientSound = class'Minigun2'.default.FireSound;
	bShoot=True;

FaceEnemy:
	if (B227_LostTarget())
		FindEnemy();
	TurnToward(Target);
	Goto('FaceEnemy');
}

defaultproperties
{
	FireSound=Sound'UnrealI.Rifle.RifleShot'
	SampleTime=0.100000
	Mesh=LodMesh'Botpack.grmockgunM'
	SoundRadius=96
	SoundVolume=255
	CollisionHeight=24.000000
}
