//=============================================================================
// Sixpack Minigun.
//=============================================================================
class Sixpack extends TournamentWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var() float Range;
var float ShotAccuracy, LastShellSpawn;
var int Count;
var bool bOutOfAmmo, bFiredShot;
var() texture MuzzleFlashVariations[4];
var(Sounds) sound 	SixpackFire[4];

function PostBeginPlay()
{
	local int rnd;

	super.PostBeginPlay();

	PickupAmmoCount = 100 + 100 * FRand();

	rnd = Rand(4);
	FireSound = SixpackFire[rnd];
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( bSteadyFlash3rd )
	{
		bMuzzleFlash = 1;
		bSetFlashTime = false;
		MFTexture = MuzzleFlashVariations[Rand(4)];
	}
	else
		bMuzzleFlash = 0;
	FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
	Default.MuzzleScale = 1.0 + 4.0 * FRand();
	FlashO = Default.FlashO * (1 +  0.15 * FRand());
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	bUseAltMode = 1;
	if ( dist > 1 )
	{
		bUseAltMode = 0;
		return (AIRating * FMin(Pawn(Owner).DamageScaling, 1.5) + FMin(0.0001 * dist, 0.3));
	}
	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

function GenerateBullet()
{
	bFiredShot = true;
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
	if ( AmmoType.UseAmmo(1) )
		TraceFire(ShotAccuracy);
	else
		GotoState('FinishFire');
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	AimDir = vector(AdjustedAim);
	EndTrace += (10000 * AimDir);
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

	Count++;
	if ( Count == 4 )
	{
		Count = 0;
		if ( VSize(HitLocation - StartTrace) > 250 )
			Spawn(class'MTracer',,, StartTrace + 96 * AimDir,rotator(EndTrace - StartTrace));
	}
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function TraceFire2(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + (10 + Range) * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	Other.TakeDamage(32.0, Pawn(Owner), HitLocation, -15000 * X, MyDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
	{
		spawn(class'PKSawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
		PlaySound(sound'PKsawiron',SLOT_None,,,1000,level.timedilation-0.1*Frand());
	}
	else if (!Other.bIsPawn || Pawn(Other).Health > 0)
		PlaySound(sound'PKsawhit',SLOT_None,,,1000,level.timedilation-0.3+0.4*Frand());
	//-else if ( Other.IsA('PlayerPawn') && (Pawn(Other).Health > 0) )
	//-	PlaySound(sound'PKsawhit',SLOT_None,,,1000,level.timedilation-0.3+0.4*Frand());
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if (Other == Level)
		Spawn(class'PKWallHit1',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		{
			if ( FRand() < 0.1 )
			spawn(class'PKSpriteSmokePuff',,,HitLocation+HitNormal*9);
			else return;
		}
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

		if ( Other.IsA('Bot') && (FRand() < 0.2) )
			Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
		rndDam = 5 + Rand(5);
		if ( FRand() < 0.2 )
			X *= 2.5;
		Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, MyDamageType);
	}
}

function Fire( float Value )
{
	Enable('Tick');
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		bPointing=True;
		bCanClientFire = true;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ShotAccuracy = 1.0;
		ClientFire(value);
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}

function AltFire( float Value )
{
	Enable('Tick');
	if ( AmmoType.UseAmmo(0) )
	{
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(value);
		GoToState('AltFiring');
	}
	else GoToState('Idle');
}

function PlayFiring()
{
	LoopAnim('Shoot',0.6, 0.05);
	AmbientSound = FireSound;
	SoundVolume = default.SoundVolume * B227_SoundDampening();
	SoundPitch=byte(default.soundpitch*level.timedilation-5);
	AmbientGlow = 250;
	bSteadyFlash3rd = true;
}

function PlayAltFiring()
{
	LoopAnim('Spinn',0.6, 0.05);
	AmbientSound = AltFireSound;
	SoundVolume = default.SoundVolume * B227_SoundDampening();
	SoundPitch=byte(default.soundpitch*level.timedilation-5);
}

function PlayUnwind()
{
	if ( Owner != None )
	{
		PlaySound(Misc1Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening,,,Level.TimeDilation-0.1);  //Finish firing, power down
		AmbientSound = None;
		PlayAnim('UnWind',0.5, 0.05);
	}
}

function PlaySpinnOff()
{
	if ( Owner != None )
	{
		PlaySound(Misc2Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening,,,Level.TimeDilation-0.1);  //Finish firing, power down
		AmbientSound = None;
		PlayAnim('Spinnoff',0.5, 0.05);
	}
}

////////////////////////////////////////////////////////
state FinishFire
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function BeginState()
	{
		PlayUnwind();
	}

Begin:
	AmbientSound = None;
	bSteadyFlash3rd = false;
	AmbientGlow = 0;
	FinishAnim();
	Finish();
}

state FinishFire2
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function BeginState()
	{
		PlaySpinnOff();
	}

Begin:
	AmbientSound = None;
	FinishAnim();
	Finish();
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if (Owner==None)
		{
			GotoState('Pickup');
		}
		else
			SoundVolume = default.SoundVolume * B227_SoundDampening();

		if (FRand() < 0.5)
		{
			bSteadyFlash3rd = true;
			AmbientGlow = 250;
		}
		else
		{
			bSteadyFlash3rd = false;
			AmbientGlow = 50;
		}
	}

	function AnimEnd()
	{
		if (Pawn(Owner).Weapon != self) GotoState('');
		else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
			Global.Fire(0);
		else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
			Global.AltFire(0);
		else
			GotoState('FinishFire');
	}

	function BeginState()
	{
		bSteadyFlash3rd = true;
		AmbientGlow = 250;
		AmbientSound = FireSound;
		SoundVolume = default.SoundVolume * B227_SoundDampening();
		Super.BeginState();
	}

	function EndState()
	{
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		AmbientSound = None;
		Super.EndState();
	}

Begin:
	Sleep(0.05);
	GenerateBullet();
	Goto('Begin');
}

state AltFiring
{
	function Tick( float DeltaTime )
	{
		if (Owner==None)
		{
			AmbientSound = None;
			GotoState('Pickup');
		}
		else
			SoundVolume = default.SoundVolume * B227_SoundDampening();
	}

	function AnimEnd()
	{
		if (Pawn(Owner).Weapon != self) GotoState('');
		else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
			Global.Fire(0);
		else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
			Global.AltFire(0);
		else
			GotoState('FinishFire2');
	}

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = AltFireSound;
		SoundVolume = default.SoundVolume * B227_SoundDampening();
	}

	function EndState()
	{
		AmbientSound = None;
		PlaySpinnOff();
		Super.EndState();
	}

Begin:
	Sleep(0.1);
	TraceFire2(0.0);
	Goto('Begin');
}

///////////////////////////////////////////////////////////
state Idle
{

Begin:
	if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0) AltFire(0.0);
	LoopAnim('Idle',0.2,0.9);
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	Disable('AnimEnd');
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',0.3,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
}

function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 0.5, 0.05);
}

defaultproperties
{
     Range=90.000000
     MuzzleFlashVariations(0)=Texture'PerUnreal.Skins.RockMuz'
     MuzzleFlashVariations(1)=Texture'PerUnreal.Skins.RockMuz2'
     MuzzleFlashVariations(2)=Texture'PerUnreal.Skins.RockMuz3'
     MuzzleFlashVariations(3)=Texture'PerUnreal.Skins.RockMuz4'
     SixpackFire(0)=Sound'PerUnreal.Sixpack.SixpackFire1'
     SixpackFire(1)=Sound'PerUnreal.Sixpack.SixpackFire2'
     SixpackFire(2)=Sound'PerUnreal.Sixpack.SixpackFire3'
     SixpackFire(3)=Sound'PerUnreal.Sixpack.SixpackFire4'
     AmmoName=Class'PerUnreal.PKMiniammo'
     PickupAmmoCount=100
     bInstantHit=True
     bAltInstantHit=True
     bRapidFire=True
     FireOffset=(X=12.000000,Y=-10.000000,Z=-16.000000)
     MyDamageType=shot
     shakemag=0.000000
     shakevert=0.000000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'PerUnreal.Sixpack.SixpackFire1'
     AltFireSound=Sound'PerUnreal.Sixpack.SixpackSpinn'
     SelectSound=Sound'PerUnreal.Sixpack.SixpackSelect'
     Misc1Sound=Sound'PerUnreal.Sixpack.SixpackDown'
     Misc2Sound=Sound'PerUnreal.Sixpack.SixpackSpinnOff'
     DeathMessage="%o was mutilated by %k's %w."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=3.000000
     FlashY=0.200000
     FlashO=0.008000
     FlashC=0.002000
     FlashLength=0.040000
     FlashS=128
     MFTexture=Texture'PerUnreal.Skins.RockMuz'
     AutoSwitchPriority=7
     InventoryGroup=7
     PickupMessage="You picked up a Minigun"
     ItemName="Minigun"
     RespawnTime=6.000000
     PlayerViewOffset=(X=-0.750000,Y=-1.750000,Z=-3.500000)
     PlayerViewMesh=LodMesh'PerUnreal.Sixpack'
     PlayerViewScale=0.200000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'PerUnreal.sixpackpick'
     ThirdPersonMesh=LodMesh'PerUnreal.Sixpack'
     StatusIcon=Texture'Botpack.Icons.UseMini'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'PerUnreal.Skins.RockMuz'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Mesh=LodMesh'PerUnreal.Sixpack'
     bNoSmooth=False
     SoundRadius=96
     SoundVolume=255
     CollisionRadius=27.000000
     CollisionHeight=8.000000
}
