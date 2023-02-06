//=============================================================================
// ChainSaw.
//=============================================================================
class PKChainSaw extends PKWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

// Army of Darkness

// Partner 540

// Jobu SL31

// Homelite XL

// Stihl 07

// McCULLOCH

var() float Range;
var() float decision;
var() sound HitSound, DownSound, IdleSound, StartSound;
var Playerpawn LastHit;

replication
{
	unreliable if( Role==ROLE_Authority )
		HitSound, DownSound, IdleSound, StartSound;
}

function PostBeginPlay()
{
	decision = Rand(6);

	if ( decision == 1 )
	{
		StartSound=Sound'PKsawstart1';
		HitSound=Sound'PKsawfull1';
		IdleSound=Sound'PKsawidle1';
		DownSound=Sound'PKsawstop1';
	}
	else if ( decision == 2 )
	{
		StartSound=Sound'PKsawstart2';
		HitSound=Sound'PKsawfull2';
		IdleSound=Sound'PKsawidle2';
		DownSound=Sound'PKsawstop2';
	}
	else if ( decision == 3 )
	{
		StartSound=Sound'PKsawstart3';
		HitSound=Sound'PKsawfull3';
		IdleSound=Sound'PKsawidle3';
		DownSound=Sound'PKsawstop3';
	}
	else if ( decision == 4 )
	{
		StartSound=Sound'PKsawstart4';
		HitSound=Sound'PKsawfull4';
		IdleSound=Sound'PKsawidle4';
		DownSound=Sound'PKsawstop4';
	}
	else if ( decision == 5 )
	{
		StartSound=Sound'PKsawstart5';
		HitSound=Sound'PKsawfull5';
		IdleSound=Sound'PKsawidle5';
		DownSound=Sound'PKsawstop5';
	}
	else
	{
		StartSound=Sound'PKsawstart6';
		HitSound=Sound'PKsawfull6';
		IdleSound=Sound'PKsawidle6';
		DownSound=Sound'PKsawstop6';
	}

	super.PostBeginPlay();
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;

	bUseAltMode = 0;

	if ( (Pawn(Owner) == None) || (Pawn(Owner).Enemy == None) )
		return 0;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist > 400 )
		return -2;

	if ( EnemyDist < 110 )
		bUseAltMode = 1;

	return ( FMin(1.0, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 1.0;
}

function float SuggestDefenseStyle()
{
	return -0.7;
}

function Fire( float Value )
{
	GotoState('NormalFire');
}

function AltFire( float Value )
{
	GotoState('AltFiring');
}

function PlayAltFiring()
{
	AmbientSound = HitSound;
	SoundPitch=byte(default.soundpitch*level.timedilation);
	PlayAnim( 'Swipe', 0.6 );
}

function EndAltFiring()
{
	AmbientSound = IdleSound;
	TweenAnim('Idle', 1.0);
}

state NormalFire
{
	function BeginState()
	{
		AmbientSound = HitSound;
		Super.BeginState();
	}

	function EndState()
	{
		SoundPitch=byte(default.soundpitch*level.timedilation-5);
		AmbientSound = IdleSound;
		Super.EndState();
	}

Begin:
	if ( LastHit != None )
	{
		LastHit.ClientFlash( -0.38, vect(530, 90, 90));
		LastHit.ShakeView(0.25, 600, 6);
	}
	LoopAnim( 'Jab2', 0.7, 0.0 );
	Sleep(0.1);
	TraceFire(0.0);
	Goto('Begin');
}

state AltFiring
{
	function EndState()
	{
		SoundPitch=byte(default.soundpitch*level.timedilation-5);
		AmbientSound = IdleSound;
		Super.EndState();
	}

Begin:
	Sleep(0.1);
	PlayAltFiring();
	FinishAnim();
	EndAltFiring();
	FinishAnim();
	Finish();
}

state Idle
{
	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 )
		Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 )
		AltFire(0.0);
	FinishAnim();
	AnimFrame=0;
	PlayIdleAnim();
	Goto('Begin');
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim( 'Idle', 1.0, 0.0 );
}

function Slash()
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, AimError, False, False);
	EndTrace = Owner.Location + (Range * vector(AdjustedAim));
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	Other.TakeDamage(128, Pawn(Owner), HitLocation, -10000.0 * Y, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
	{
		spawn(class'PKSawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
		PlaySound(sound'PKsawiron',,4.0,,1000,level.timedilation-0.1*Frand());
	}
}


function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;
	local vector Momentum;

if (Pawn(Owner).bFire!=0)
{
	AmbientSound = HitSound;
	SoundPitch=byte(default.soundpitch*level.timedilation-5-1*FRand());
	LastHit = None;
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	Momentum = Owner.velocity + 150 * X;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + (10 + Range) * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	Other.TakeDamage(32.0, Pawn(Owner), HitLocation, -15000 * X, MyDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
	{
		Owner.Velocity = (Momentum);
		SoundPitch=byte(default.soundpitch*level.timedilation-15+5*FRand());
		spawn(class'PKSawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
		PlaySound(sound'PKsawiron',,0.1+0.5 * FRand(),,1000,level.timedilation-0.1*Frand());
	}
	else if (Pawn(Other).Health > 0)
		{
		SoundPitch=byte(default.soundpitch*level.timedilation-10+5*FRand());
		PlaySound(sound'PKsawhit',SLOT_None,,,1000,level.timedilation-0.3+0.4*Frand());
		}
	else if ( Other.IsA('PlayerPawn') && (Pawn(Other).Health > 0) )
		{
		LastHit = PlayerPawn(Other);
		SoundPitch=byte(default.soundpitch*level.timedilation-10+5*FRand());
		PlaySound(sound'PKsawhit',SLOT_None,,,1000,level.timedilation-0.3+0.4*Frand());
		}
}
else
GoToState('Idle');
}


function PlayPostSelect()
{
    AmbientSound = IdleSound;
    SoundPitch=byte(default.soundpitch*level.timedilation-5);
	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(StartSound, SLOT_Misc, Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
}

function TweenDown()
{
	PlaySound(DownSound,SLOT_None,,,,Level.TimeDilation-0.1);
	Super.TweenDown();
	AmbientSound = None;
}

defaultproperties
{
     Range=90.000000
     WeaponDescription="Classification: Melee Blade"
     bMeleeWeapon=True
     bRapidFire=True
     FireOffset=(X=10.000000,Y=-2.500000,Z=5.000000)
     MyDamageType=slashed
     AltDamageType=Decapitated
     RefireRate=1.000000
     AltRefireRate=1.000000
     DeathMessage="%o sucked %k's spinning steel."
     PickupMessage="you got a god old McCulloch chainsaw."
     ItemName="Chainsaw"
     PlayerViewOffset=(X=2.000000,Y=-1.100000,Z=-0.900000)
     PlayerViewMesh=LodMesh'Botpack.chainsawM'
     PickupViewMesh=LodMesh'Botpack.ChainSawPick'
     ThirdPersonMesh=LodMesh'Botpack.CSHand'
     StatusIcon=Texture'Botpack.Icons.UseSaw'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Icon=Texture'Botpack.Icons.UseSaw'
     Mesh=LodMesh'Botpack.ChainSawPick'
     bNoSmooth=False
     SoundVolume=255
}
