//=============================================================================
// PulseGun.
//=============================================================================
class PulseGun extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float Angle, Count;
var PBolt PlasmaBeam;
var() sound DownSound;

// Auxiliary
var private int B227_Handedness;
var private float B227_FireOffsetX, B227_FireOffsetY, B227_FireOffsetZ;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		B227_Handedness,
		B227_FireOffsetX,
		B227_FireOffsetY,
		B227_FireOffsetZ;

	reliable if (Role < ROLE_Authority)
		B227_SetRightHandedness;
}

simulated event RenderOverlays( canvas Canvas )
{
	Texture'Ammoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'Ammoled'.NotifyActor = None;

	B227_AdjustHand();
}

simulated function Destroyed()
{
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();

	Super.Destroyed();
}

function AnimEnd()
{
	/*-
	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
	{
		if ( AnimSequence == 'SpinDown' )
			AnimSequence = 'Idle';
		PlayIdleAnim();
	}
	*/
}
// set which hand is holding weapon
function SetHand(float Hand)
{
	Hand = Clamp(Hand, -1, 2);

	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		if ( PlasmaBeam != None )
			PlasmaBeam.bCenter = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	if ( Hand == 1 )
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = false;
			PlasmaBeam.bRight = true;
		}
		FireOffset.Y = Default.FireOffset.Y;
		Mesh = mesh'Botpack.PulseGunL';
	}
	else
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = Hand == 0;
			PlasmaBeam.bRight = false;
		}
		FireOffset.Y = Default.FireOffset.Y * Hand;
		Mesh = mesh'PulseGunR';
	}

	B227_Handedness = Hand;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 1000 )
		return 0.4;
	else
		return 0;
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);
	if ( (P.Enemy == None) || (Bot(Owner) != none && Bot(Owner).bQuickFire) )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	if ( P.Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return (AIRating + 0.4);
	}
	else
		bUseAltMode = int( 700 > VSize(P.Enemy.Location - Owner.Location) );

	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

function PlayFiring()
{
	FlashCount++;
	AmbientSound = FireSound;
	SoundVolume = B227_SoundDampening() * 255;
	LoopAnim( 'shootLOOP', 1 + 0.5 * FireAdjust, 0.0);
	bWarnTarget = (FRand() < 0.2);
}

function PlayAltFiring()
{
	AmbientSound = AltFireSound;
	SoundVolume = B227_SoundDampening() * 255;
	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim( 'boltloop');
	else
		PlayAnim( 'boltstart' );
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(value);
		if (PlasmaBeam == none || PlasmaBeam.bDeleteMe)
			B227_EmitBeam();
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

	Tex.DrawTile( 30, 100, (Min(AmmoType.AmmoAmount,AmmoType.Default.AmmoAmount)*196)/AmmoType.Default.AmmoAmount, 10, 0, 0, 1, 1, Texture'AmmoCountBar', False );

	if(AmmoType.AmmoAmount < 10)
	{
		C.R = 255;
		C.G = 0;
		C.B = 0;
	}
	else
	{
		C.R = 0;
		C.G = 0;
		C.B = 255;
	}

	Tex.DrawColoredText( 56, 14, Temp, Font'LEDFont', C );
}

///////////////////////////////////////////////////////
state NormalFire
{
	ignores AnimEnd;

	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Vector Start, X,Y,Z;
		local Projectile Proj;
		local float DamageMult;

		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;
		Angle += 1.8;
		Proj = Spawn(ProjClass,,, Start,AdjustedAim);
		if (B227_ShouldUseEnergyAmplifier() && Proj != none)
		{
			DamageMult = B227_AmplifyDamage(Proj.Damage);
			Proj.Damage *= DamageMult;
			if (B227_ShouldModifyPlasmaLighting())
				Proj.LightRadius = Clamp(Proj.LightRadius * Sqrt(DamageMult), default.LightRadius, 255);
		}
		return Proj;
	}

	function Tick( float DeltaTime )
	{
		if (Owner==None)
			GotoState('Pickup');
	}

	function BeginState()
	{
		Super.BeginState();
		Angle = 0;
		AmbientGlow = 200;
	}

	function EndState()
	{
		PlaySpinDown();
		AmbientSound = None;
		AmbientGlow = 0;
		OldFlashCount = FlashCount;
		Super.EndState();
	}

Begin:
	Sleep(0.18);
	Finish();
}

function PlaySpinDown()
{
	if ( (Mesh != PickupViewMesh) && (Owner != None) )
	{
		PlayAnim('Spindown', 1.0, 0.0);
		Owner.PlaySound(DownSound, SLOT_None, 1.0 * Pawn(Owner).SoundDampening);
	}
}

/* Weapon's client states are removed in this conversion
state ClientFiring
{
	simulated function Tick( float DeltaTime )
	{
		if ( (Pawn(Owner) != None) && (Pawn(Owner).bFire != 0) )
			AmbientSound = FireSound;
		else
			AmbientSound = None;
	}

	simulated function AnimEnd()
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		{
			PlaySpinDown();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlaySpinDown();
			GotoState('');
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlaySpinDown();
			GotoState('');
		}
	}
}

///////////////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( AmmoType.AmmoAmount <= 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bAltFire != 0 )
			LoopAnim('BoltLoop');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}
*/

state AltFiring
{
	ignores AnimEnd;

	function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if ( P == None )
		{
			GotoState('Pickup');
			return;
		}

		if (P.bAltFire == 0 ||
			Bot(P) != none && (P.Enemy == none || Level.TimeSeconds - Bot(P).LastSeenTime > 5))
		{
			P.bAltFire = 0;
			Finish();
			return;
		}

		Count += Deltatime;
		if ( Count > 0.24 )
		{
			if ( Owner.IsA('PlayerPawn') )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
			if ( Affector != None )
				Affector.FireEffect();
			Count -= 0.24;
			if (AmmoType.UseAmmo(1))
			{
				if (PlasmaBeam == none || PlasmaBeam.bDeleteMe)
					B227_EmitBeam();
				if (B227_ShouldUseEnergyAmplifier() && PlasmaBeam != none)
					PlasmaBeam.B227_DamageMult = B227_AmplifyDamage(Max(1, PlasmaBeam.Damage * 0.24));
				SoundVolume = P.SoundDampening * 255;
			}
			else
				Finish();
		}
	}

	function EndState()
	{
		AmbientGlow = 0;
		AmbientSound = None;
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}
		Super.EndState();
	}

Begin:
	AmbientGlow = 200;
	FinishAnim();
	LoopAnim( 'boltloop');
}

state Idle
{
Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);

	Disable('AnimEnd');
	PlayIdleAnim();
	FinishAnim();
	PlayIdleAnim();
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim('BoltEnd');
	else if ( AnimSequence != 'SpinDown' )
		TweenAnim('Idle', 0.1);
}

function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		TweenAnim('Down', 0.26);
}

static function bool B227_ShouldAllowCenterView()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bPulseGunAllowCenterView;
}

function B227_SetRightHandedness()
{
	SetHand(-1);
}

simulated function B227_AdjustHand()
{
	if (B227_Handedness == 0 && !B227_ShouldAllowCenterView())
	{
		B227_Handedness = -1;
		B227_SetRightHandedness();
	}
}

function B227_EmitBeam()
{
	PlasmaBeam = PBolt(ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget));
	if (PlasmaBeam == none)
		return;

	if (FireOffset.Y == 0)
		PlasmaBeam.bCenter = true;
	else if (Mesh == mesh'PulseGunR')
		PlasmaBeam.bRight = false;

	PlasmaBeam.B227_bGuidedByWeapon = B227_ShouldGuideBeam();
	PlasmaBeam.B227_BeamStarter = PlasmaBeam;
	PlasmaBeam.B227_bTraceFireThroughWarpZones = B227_ShouldTraceFireThroughWarpZones();
	PlasmaBeam.B227_bLimitWallEffect = B227_ShouldLimitWallEffect();
}

simulated function vector B227_PlayerViewOffset()
{
	local vector ViewOffset;

	if (B227_Handedness != 0)
		return PlayerViewOffset;

	ViewOffset = default.PlayerViewOffset;
	ViewOffset.Y = -1.81;

	if (B227_ViewOffsetMode() == 2 && Pawn(Owner) != none)
		ViewOffset.Y *= Pawn(Owner).FOVAngle / 90.0;
	return ViewOffset * 100;
}

simulated function int B227_ViewRotationRoll(int Hand)
{
	if (B227_Handedness == 0 && B227_ShouldAllowCenterView())
		return 1536 * 2;
	return super.B227_ViewRotationRoll(Hand);
}

simulated function B227_GuidePlasmaBeam(PBolt Beam)
{
	local Pawn P;
	local vector WeapFireOffset, Offset;
	local vector Start, X, Y, Z;

	P = Pawn(Owner);
	GetAxes(P.ViewRotation, X, Y, Z);

	if (Level.NetMode != NM_Client)
	{
		B227_FireOffsetX = FireOffset.X;
		B227_FireOffsetY = FireOffset.Y;
		B227_FireOffsetZ = FireOffset.Z;
		WeapFireOffset = FireOffset;
	}
	else
	{
		WeapFireOffset.X = B227_FireOffsetX;
		WeapFireOffset.Y = B227_FireOffsetY;
		WeapFireOffset.Z = B227_FireOffsetZ;
	}

	Offset = class'PBolt'.default.FireOffset - default.FireOffset;
	Offset.X += WeapFireOffset.X;
	Offset.Z += WeapFireOffset.Z;

	if (class'PBolt'.default.FireOffset.Y * WeapFireOffset.Y > 0)
		Offset.Y += WeapFireOffset.Y;
	else if (class'PBolt'.default.FireOffset.Y * WeapFireOffset.Y < 0)
		Offset.Y = WeapFireOffset.Y - Offset.Y;
	else
		Offset.Y = 0;

	if (Beam.bCenter)
		Offset.Z += class'PBolt'.default.FireOffset.Z * 0.5;

	Start = P.Location + CalcDrawOffset() + Offset.X * X + Offset.Y * Y + Offset.Z * Z;

	Beam.SetLocation(Start);
	Beam.SetRotation(P.ViewRotation);

	// replication
	Beam.B227_SetBeamRepMovement(Start, P.ViewRotation);
}

static function bool B227_ShouldGuideBeam()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bPulseGunGuideBeam;
}

static function bool B227_ShouldUseHardcoreDamage(Projectile Proj)
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bPulseGunHardcoreDamage &&
		!Proj.Level.Game.bDeathMatch &&
		PlayerPawn(Proj.Instigator) != none;
}

static function int B227_ModifyDamage(Projectile Proj, int Damage)
{
	if (B227_ShouldUseHardcoreDamage(Proj))
		return Damage * 1.5;
	return Damage;
}

static function bool B227_ShouldAdjustNPCAccuracy()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bPulseGunAdjustNPCAccuracy;
}

static function bool B227_ShouldLimitWallEffect()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bPulseGunLimitWallEffect;
}

static function bool B227_ShouldModifyPlasmaLighting()
{
	return class'B227_Config'.static.ShouldModifyProjectilesLighting();
}

function B227_AdjustNPCFirePosition()
{
	if (Instigator.IsA('SkaarjTrooper'))
	{
		SetHand(1);
		PlayerViewOffset.Z = -700 * Instigator.DrawScale;
	}
}

defaultproperties
{
	DownSound=Sound'Botpack.PulseGun.PulseDown'
	WeaponDescription="Classification: Plasma Rifle\n\nPrimary Fire: Medium sized, fast moving plasma balls are fired at a fast rate of fire.\n\nSecondary Fire: A bolt of green lightning is expelled for 100 meters, which will shock all opponents.\n\nTechniques: Firing and keeping the secondary fire's lightning on an opponent will melt them in seconds."
	InstFlash=-0.150000
	InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
	AmmoName=Class'Botpack.PAmmo'
	PickupAmmoCount=60
	bRapidFire=True
	FireOffset=(X=15.000000,Y=-15.000000,Z=2.000000)
	ProjectileClass=Class'Botpack.PlasmaSphere'
	AltProjectileClass=Class'Botpack.StarterBolt'
	shakemag=135.000000
	shakevert=8.000000
	AIRating=0.700000
	RefireRate=0.950000
	AltRefireRate=0.990000
	FireSound=Sound'Botpack.PulseGun.PulseFire'
	AltFireSound=Sound'Botpack.PulseGun.PulseBolt'
	SelectSound=Sound'Botpack.PulseGun.PulsePickup'
	MessageNoAmmo=" has no Plasma."
	DeathMessage="%o ate %k's burning plasma death."
	NameColor=(R=128,B=128)
	FlashLength=0.020000
	AutoSwitchPriority=5
	InventoryGroup=5
	PickupMessage="You got a Pulse Gun"
	ItemName="Pulse Gun"
	PlayerViewOffset=(X=1.500000,Z=-2.000000)
	PlayerViewMesh=LodMesh'Botpack.PulseGunR'
	PickupViewMesh=LodMesh'Botpack.PulsePickup'
	ThirdPersonMesh=LodMesh'Botpack.PulseGun3rd'
	ThirdPersonScale=0.400000
	StatusIcon=Texture'Botpack.Icons.UsePulse'
	bMuzzleFlashParticles=True
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'Botpack.muzzPF3'
	MuzzleFlashScale=0.400000
	MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyPulse'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UsePulse'
	Mesh=LodMesh'Botpack.PulsePickup'
	bNoSmooth=False
	SoundRadius=64
	SoundVolume=255
	CollisionRadius=32.000000
	B227_Handedness=-1
}
