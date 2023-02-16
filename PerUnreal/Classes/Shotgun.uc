//=============================================================================
// Shotgun.
//=============================================================================
class Shotgun extends TournamentWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var() int hitdamage;
var bool bOutOfAmmo, bFiredShot;
var float ShotAccuracy;
var(Sounds) sound 	ShotgunFire[6];

function PostBeginPlay()
{
local int rnd;

	super.PostBeginPlay();

	rnd = Rand(6);
	FireSound = ShotgunFire[rnd];
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local bot B;

	B = Bot(Owner);
	if ( (B != None) && B.bNovice )
		return 0.2;
	return 0.4;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, rating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}
	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
	if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return AIRating + 0.3;
	}
	if ( EnemyDist > 900 )
	{
		bUseAltMode = 0;
		if ( EnemyDist > 2000 )
		{
			if ( EnemyDist > 3500 )
				return 0.2;
			return (AIRating - 0.3);
		}
		if ( EnemyDir.Z < -0.5 * EnemyDist )
		{
			bUseAltMode = 1;
			return (AIRating - 0.3);
		}
	}
	else if ( (EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon )
	{
		bUseAltMode = 0;
		return (AIRating + 0.3);
	}
	else if ( (EnemyDist < 340) || (EnemyDir.Z > 30) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.2);
	}
	else
		bUseAltMode = int( FRand() < 0.65 );
	return rating;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float dist;
	local vector Momentum;
	local float DefaultMass;
	local vector DeltaEnergy;
	local vector NewSquareVelocity;
	local vector NewVelocity;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);

	dist = VSize(Location - Other.Location);

	DefaultMass = 100.0;
	DeltaEnergy = Square(1600) * X;
	if (Other.Physics == PHYS_Walking || Other.Physics == PHYS_None)
		DeltaEnergy += Square(1000) * Z;
	DeltaEnergy *= (DefaultMass / (2 * 9)) * 0.5;
	NewSquareVelocity = Other.Velocity * VSize(Other.Velocity) + DeltaEnergy * 2 / FMax(1.0, Other.Mass);
	NewVelocity = Normal(NewSquareVelocity) * Sqrt(VSize(NewSquareVelocity));
	Momentum = (NewVelocity - Other.Velocity) * Other.Mass;
	Momentum.Z = FMax(0, Momentum.Z);

	//-Momentum = -0.5 * Other.Velocity + 1600 * X + 1000 * Z;
	//-Momentum.Z = 7000000.0/((0.4 * dist + 350) * Other.Mass);

	if (Other == Level)
	{
			Spawn(class'PKWallHit2',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ((Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( FRand() < 0.2 )
			X *= 5;
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, Momentum, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		{
			if ( FRand() < 0.2 )
			spawn(class'PKSpriteSmokePuff',,,HitLocation+HitNormal*9);
			else return;
		}
		else
			{
			//-Other.Velocity = (Momentum);
			//-Other.SetPhysics(PHYS_Falling);
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
			}
	}
}

function FlashOff()
{
	AmbientGlow = 0;
}

function GenerateBullet()
{
	AmbientGlow = 250;

	bFiredShot = true;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
	if ( AmmoType.UseAmmo(0) )
	{
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
		TraceFire(ShotAccuracy);
	}
	else
		GotoState('FinishFire');
}

function TraceFire( float Accuracy )
{
	local vector RealOffset;

	hitdamage = 10 + 5*FRand();
	RealOffset = FireOffset;
	FireOffset *= 0.35;
	Super.TraceFire(Accuracy);
	FireOffset = RealOffset;
}

function Fire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		ShotAccuracy = 2.0;
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientAltFire(value);
		ShotAccuracy = 2.0;
		GotoState('AltFiring');
	}
	else GoToState('Idle');
}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, B227_SoundDampening(),,, Level.TimeDilation-0.2*FRand());
	PlayAnim( 'Fire', 0.5, 0.05);
	bMuzzleFlash++;
}

function PlayAltFiring()
{
	PlaySound(FireSound, SLOT_None, B227_SoundDampening(),,, Level.TimeDilation-0.2*FRand());
	PlayAnim('Fire', 0.5, 0.05);
	bMuzzleFlash++;
}

function Reload()
{
	local PKShotgunShell s;
	local vector realLoc;
	local vector X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);

	realLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'PKShotgunShell',, '', realLoc + 16 * X -10 * Z + 2 * Y + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*120);

	PlaySound(CockingSound,, (0.7 + 0.3*FRand()) * B227_SoundDampening(),,, Level.TimeDilation-0.2*FRand());
}

function PlayReloading()
{
	PlayAnim('Loading',0.6, 0.05);
}

/////////////////////////////////////////////////////////////

state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayReloading();
		else
			Finish();
	}

Begin:
	GenerateBullet();
	FlashCount++;
}

state AltFiring
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayReloading();
		else
			Finish();
	}

Begin:
	GenerateBullet();
	FlashCount++;
}

///////////////////////////////////////////////////////////
function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else if ( AmmoType.AmmoAmount < 1 )
		TweenAnim('Select', 0.5);
	else
		PlayAnim('Down',1.0, 0.05);
}

state Idle
{

Begin:
	if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0) AltFire(0.0);
	LoopAnim('Idle');
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	Disable('AnimEnd');
}

function PlayIdleAnim()
{
	LoopAnim('Idle');
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',0.4,0.0);

	Owner.PlaySound(SelectSound, SLOT_Misc, B227_SoundDampening(),,, Level.TimeDilation+0.1*FRand());
}

simulated event RenderOverlays(canvas Canvas)
{
	Default.MuzzleScale = 2.0 + 2.0 * FRand();
	Super.RenderOverlays(Canvas);
}

defaultproperties
{
     hitdamage=10
     ShotgunFire(0)=Sound'PerUnreal.Shotgun.SGfire1'
     ShotgunFire(1)=Sound'PerUnreal.Shotgun.SGfire2'
     ShotgunFire(2)=Sound'PerUnreal.Shotgun.SGfire3'
     ShotgunFire(3)=Sound'PerUnreal.Shotgun.SGfire4'
     ShotgunFire(4)=Sound'PerUnreal.Shotgun.SGfire5'
     ShotgunFire(5)=Sound'PerUnreal.Shotgun.SGfire6'
     InstFlash=-0.400000
     InstFog=(X=650.000000,Y=450.000000,Z=190.000000)
     AmmoName=Class'PerUnreal.PKSGAmmo'
     PickupAmmoCount=10
     bInstantHit=True
     bAltInstantHit=True
     FireOffset=(X=12.000000,Y=-10.000000,Z=-15.000000)
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     AIRating=0.750000
     FireSound=Sound'PerUnreal.Shotgun.SGfire1'
     AltFireSound=Sound'PerUnreal.flak.PKflakfire'
     CockingSound=Sound'PerUnreal.Shotgun.SGreload'
     SelectSound=Sound'PerUnreal.Shotgun.SGselect'
     DeathMessage="%o was blasted by %k's %w."
     NameColor=(G=96,B=0)
     bDrawMuzzleFlash=True
     FlashY=0.120000
     FlashO=0.010000
     FlashC=0.100000
     FlashLength=0.060000
     FlashS=64
     MFTexture=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the Shotgun."
     ItemName="Shotgun"
     RespawnTime=6.000000
     PlayerViewOffset=(X=0.000000,Y=-1.000000,Z=-1.000000)
     PlayerViewMesh=LodMesh'PerUnreal.sgun'
     PlayerViewScale=0.100000
     BobDamping=0.972000
     PickupViewMesh=LodMesh'PerUnreal.sgunpick'
     ThirdPersonMesh=LodMesh'PerUnreal.sgun3rd'
     StatusIcon=Texture'Botpack.Icons.UseBio'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzPF3'
     MuzzleFlashScale=0.300000
     MuzzleFlashTexture=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Mesh=LodMesh'PerUnreal.sgun'
     bNoSmooth=False
     CollisionHeight=20.000000
}
