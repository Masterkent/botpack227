//=============================================================================
// Minigun.
//=============================================================================
class Minigun2 extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float ShotAccuracy, LastShellSpawn;
var int Count;
var bool bOutOfAmmo, bFiredShot;
var() texture MuzzleFlashVariations[10];

// set which hand is holding weapon
function setHand(float Hand)
{
	B227_SetHandedness(Hand);

	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	FireOffset.Y = Hand * Default.FireOffset.Y;
	PlayerViewOffset.Y *= Hand;
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("Botpack.Minigun2L", class'Mesh'));
	else
	{
		Mesh = mesh'Minigun2m';
		if ( Hand == 0 )
		{
			PlayerViewOffset.X = Default.PlayerViewOffset.X * 95;
			PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 105;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	if (AmmoType == none)
		return;

	Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 2, 10, Temp, Font'LEDFont2', C );
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
	if ( dist > 1200 )
	{
		if ( dist > 1700 )
			bUseAltMode = 0;
		return (AIRating * FMin(Pawn(Owner).DamageScaling, 1.5) + FMin(0.0001 * dist, 0.3));
	}
	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

simulated event RenderOverlays( canvas Canvas )
{
	local Actor NotifyActor;
	local float Hand;

	if ( bSteadyFlash3rd )
	{
		bMuzzleFlash = 1;
		bSetFlashTime = false;
		if ( !Level.bDropDetail )
			MFTexture = MuzzleFlashVariations[Rand(10)];
		else
			MFTexture = MuzzleFlashVariations[Rand(5)];
	}
	else
		bMuzzleFlash = 0;
	FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
	if (B227_GetKnownHandedness(Hand) && Hand == 0)
		FlashO = B227_GetMuzzleFlashOffset(true) * (4 + 0.15 * FRand());
	else
		FlashO = B227_GetMuzzleFlashOffset(false) * (1 + 0.15 * FRand());

	NotifyActor = Texture'MiniAmmoled'.NotifyActor;
	Texture'MiniAmmoled'.NotifyActor = self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = NotifyActor;

	if ( bSteadyFlash3rd && Level.bHighDetailMode && (Level.TimeSeconds - LastShellSpawn > 0.125)
		&& (Level.Pauser=="") )
	{
		LastShellSpawn = Level.TimeSeconds;
		B227_SpawnShellCase();
	}
}

function GenerateBullet()
{
	LightType = LT_Steady;
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
	local vector HitLocation, HitNormal, X, Y, Z, AimDir;
	local actor Other;
	local MTracer MTracer;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	B227_FireStartTrace = B227_GetFireStartTrace();
	AdjustedAim = pawn(owner).AdjustAim(1000000, B227_FireStartTrace, 2.75*AimError, False, False);
	B227_FireEndTrace = B227_FireStartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	AimDir = vector(AdjustedAim);
	B227_FireEndTrace += (10000 * AimDir);
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,B227_FireEndTrace,B227_FireStartTrace);

	Count++;
	if ( Count == 4 )
	{
		Count = 0;
		if ( VSize(HitLocation - B227_FireStartTrace) > 250 )
			Spawn(class'MTracer',,, B227_FireStartTrace + 96 * AimDir, rotator(B227_FireEndTrace - B227_FireStartTrace));
		else if (WarpZoneInfo(Level.GetLocZone(HitLocation + HitNormal).Zone) != none)
		{
			MTracer = Spawn(class'MTracer',,, B227_FireStartTrace, rotator(B227_FireEndTrace - B227_FireStartTrace));
			if (MTracer != none)
				MTracer.AutonomousPhysics(96 / FMax(1.0, MTracer.speed));
		}
	}
	ProcessTraceHit(Other, HitLocation, HitNormal, Normal(B227_FireEndTrace - B227_FireStartTrace), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if (B227_ShouldTraceFireThroughWarpZones())
		B227_WarpedTraceFire(self, B227_FireStartTrace, B227_FireEndTrace, 8, Other, HitLocation, HitNormal, X);

	if (Other == Level)
		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

		if ( Other.IsA('Bot') && (FRand() < 0.2) )
			Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
		rndDam = 9 + Rand(6);
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
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ShotAccuracy = 0.2;
		ClientFire(value);
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}

function AltFire( float Value )
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
		ShotAccuracy = 0.95;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		ClientAltFire(value);
		GoToState('AltFiring');
	}
	else GoToState('Idle');
}

function PlayFiring()
{
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('Shoot1',1 + 0.6 * FireAdjust, 0.05);
	AmbientGlow = 250;
	AmbientSound = FireSound;
	bSteadyFlash3rd = true;
}

function PlayAltFiring()
{
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('Shoot1',1 + 0.3 * FireAdjust, 0.05);
	AmbientGlow = 250;
	AmbientSound = FireSound;
	bSteadyFlash3rd = true;
}

function PlayUnwind()
{
	if ( Owner != None )
	{
		PlaySound(Misc1Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening);  //Finish firing, power down
		PlayAnim('UnWind',1.5, 0.05);
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
	FinishAnim();
	Finish();
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if (Owner==None)
			AmbientSound = None;
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
		AmbientGlow = 250;
		AmbientSound = FireSound;
		bSteadyFlash3rd = true;
		Super.BeginState();
	}

	function EndState()
	{
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		LightType = LT_None;
		AmbientSound = None;
		Super.EndState();
	}

Begin:
	Sleep(0.13);
	GenerateBullet();
	Goto('Begin');
}

/* Weapon's client states are removed in this conversion
state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
		{
			PlayUnwind();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayUnwind();
			GotoState('ClientFinish');
		}
	}

	simulated function BeginState()
	{
		AmbientSound = FireSound;
		bSteadyFlash3rd = true;
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		Super.EndState();
	}
}

////////////////////////////////////////////////////////

state ClientFinish
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		bForceFire = false;
		bForceAltFire = false;
		AmbientSound = None;
	}

	simulated function BeginState()
	{
		bSteadyFlash3rd = false;
		bForceFire = false;
		bForceAltFire = false;
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
		{
			PlayUnwind();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bAltFire != 0 )
		{
			if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
			{
				AmbientSound = AltFireSound;
				SoundVolume = 255*Pawn(Owner).SoundDampening;
				LoopAnim('Shoot2',1.9);
			}
			else if ( AmbientSound == None )
				AmbientSound = FireSound;

			if ( Affector != None )
				Affector.FireEffect();
			if ( PlayerPawn(Owner) != None )
				PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayUnwind();
			bSteadyFlash3rd = false;
			GotoState('ClientFinish');
		}
	}

	simulated function BeginState()
	{
		bSteadyFlash3rd = true;
		AmbientSound = FireSound;
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		Super.EndState();
	}
}
*/

state AltFiring
{
	function Tick( float DeltaTime )
	{
		if (Owner==None)
		{
			AmbientSound = None;
			GotoState('Pickup');
		}

		if ( bFiredShot && ((pawn(Owner).bAltFire==0) || bOutOfAmmo) )
			GoToState('FinishFire');
	}

	function AnimEnd()
	{
		SoundVolume = 255 * B227_SoundDampening();
		if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
		{
			AmbientSound = AltFireSound;
			LoopAnim('Shoot2',1.9);
		}
		else if ( AmbientSound == None )
			AmbientSound = FireSound;
		if ( Affector != None )
			Affector.FireEffect();
	}

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = FireSound;
		AmbientGlow = 250;
		bFiredShot = false;
		bSteadyFlash3rd = true;
	}

	function EndState()
	{
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		LightType = LT_None;
		AmbientSound = None;
		Super.EndState();
	}

Begin:
	Sleep(0.13);
	GenerateBullet();
	if ( AnimSequence == 'Shoot2' )
		Goto('FastShoot');
	Goto('Begin');
FastShoot:
	Sleep(0.08);
	GenerateBullet();
	Goto('FastShoot');
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

function vector B227_GetFireStartTrace()
{
	local vector X, Y, Z;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	return Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
}

function B227_AdjustNPCFirePosition()
{
	if (Instigator.IsA('SkaarjTrooper'))
	{
		SetHand(1);
		PlayerViewOffset.Z = -700 * Instigator.DrawScale;
	}
}

static function bool B227_ShouldAdjustMuzzleFlashOffset()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bMinigunAdjustMuzzleFlashOffset;
}

simulated function float B227_GetMuzzleFlashOffset(bool bCentered)
{
	if (bCentered &&
		B227_ShouldAdjustMuzzleFlashOffset() &&
		B227_ViewOffsetMode() != 2 &&
		default.FlashO == class'Minigun2'.default.FlashO)
	{
		return 0.019;
	}
	return default.FlashO;
}

static function float B227_MuzzleFlashScale()
{
	return class'B227_Config'.default.MinigunMuzzleFlashScale;
}

simulated function B227_SpawnShellCase()
{
	local UT_Shellcase s;
	local vector X, Y, Z;
	local float dir;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

	if ( PlayerViewOffset.Y >= 0 )
		dir = 1;
	else
		dir = -1;

	s = Spawn(class'MiniShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
	if (s != none)
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
}

defaultproperties
{
	MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
	MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
	MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
	MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
	MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
	MuzzleFlashVariations(5)=Texture'Botpack.Skins.Muz6'
	MuzzleFlashVariations(6)=Texture'Botpack.Skins.Muz7'
	MuzzleFlashVariations(7)=Texture'Botpack.Skins.Muz8'
	MuzzleFlashVariations(8)=Texture'Botpack.Skins.Muz9'
	MuzzleFlashVariations(9)=Texture'Botpack.Skins.Muz9'
	WeaponDescription="Classification: Gatling Gun\n\nPrimary Fire: Bullets are sprayed forth at a medium to fast rate of fire and good accuracy.\n\nSecondary Fire: Minigun fires twice as fast and is half as accurate.\n\nTechniques: Secondary fire is much more useful at close range, but can eat up tons of ammunition."
	AmmoName=Class'Botpack.Miniammo'
	PickupAmmoCount=50
	bInstantHit=True
	bAltInstantHit=True
	bRapidFire=True
	FireOffset=(X=8.000000,Y=-5.000000,Z=-4.000000)
	MyDamageType=shot
	shakemag=135.000000
	shakevert=8.000000
	AIRating=0.730000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'Botpack.minigun2.M2RegFire'
	AltFireSound=Sound'Botpack.minigun2.M2AltFire'
	SelectSound=Sound'UnrealI.Minigun.MiniSelect'
	Misc1Sound=Sound'Botpack.minigun2.M2WindDown'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=2.000000
	FlashY=0.180000
	FlashO=0.022000
	FlashC=0.006000
	FlashLength=0.200000
	FlashS=128
	MFTexture=Texture'Botpack.Skins.Muz9'
	AutoSwitchPriority=7
	InventoryGroup=7
	PickupMessage="You got the Minigun."
	ItemName="Minigun"
	PlayerViewOffset=(X=2.100000,Y=-0.350000,Z=-1.700000)
	PlayerViewMesh=LodMesh'Botpack.Minigun2m'
	BobDamping=0.975000
	PickupViewMesh=LodMesh'Botpack.MinigunPick'
	ThirdPersonMesh=LodMesh'Botpack.MiniHand'
	StatusIcon=Texture'Botpack.Icons.UseMini'
	bMuzzleFlashParticles=True
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
	MuzzleFlashScale=0.250000
	MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseMini'
	Mesh=LodMesh'Botpack.MinigunPick'
	bNoSmooth=False
	SoundRadius=96
	SoundVolume=255
	CollisionRadius=34.000000
	CollisionHeight=8.000000
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=28
	LightSaturation=32
	LightRadius=6
}
