//=============================================================================
// ShockRifle.
//=============================================================================
class ShockRifle extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() int HitDamage;
var Projectile Tracked;
var bool bBotSpecialMove;
var float TapTime;

var int B227_ShockBeamNumPoints;

function AltFire( float Value )
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Start;

	if ( Owner == None )
		return;

	if ( Bot(Owner) != none || Bots(Owner) != none ) //make sure won't blow self up
	{
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Z * vect(0,0,1);
		if ( Pawn(Owner).Enemy != None )
			HitActor = Trace(HitLocation, HitNormal, Start + 250 * Normal(Pawn(Owner).Enemy.Location - Start), Start, false, vect(12,12,12));
		else
			HitActor = self;
		if ( HitActor != None )
		{
			Global.Fire(Value);
			return;
		}
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		if ( Bot(Owner) != none || Bots(Owner) != none )
		{
			if ( Owner.IsInState('TacticalMove') && (Owner.Target == Pawn(Owner).Enemy)
			 && (Owner.Physics == PHYS_Walking) && (Bot(Owner) == none || !Bot(Owner).bNovice)
			 && (FRand() * 6 < Pawn(Owner).Skill) )
				Pawn(Owner).SpecialFire();
		}
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bPointing=True;
		ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		ClientAltFire(value);
	}
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, X, Y, Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	B227_FireStartTrace = B227_GetFireStartTrace();
	B227_FireEndTrace = B227_FireStartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	if ( bBotSpecialMove && (Tracked != None)
		&& (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)) )
		B227_FireEndTrace += 10000 * Normal(Tracked.Location - B227_FireStartTrace);
	else
	{
		bSplashDamage = false;
		AdjustedAim = pawn(owner).AdjustAim(1000000, B227_FireStartTrace, 2.75 * AimError, false, false);
		bSplashDamage = default.bSplashDamage;
		B227_FireEndTrace += (10000 * vector(AdjustedAim));
	}

	Tracked = None;
	bBotSpecialMove = false;

	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, B227_FireEndTrace, B227_FireStartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, Normal(B227_FireEndTrace - B227_FireStartTrace), Y, Z);
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P;
	local bool bNovice;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);
	bNovice = ( (Bot(Owner) == None) || Bot(Owner).bNovice ) && Bots(Owner) == none;
	if ( P.Enemy == None )
		bUseAltMode = 0;
	else if ( P.Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 1;
		return (AIRating + 0.4);
	}
	else if ( !bNovice && (P.IsInState('Hunting') || P.IsInState('StakeOut')
		|| P.IsInState('RangedAttack')
		|| (Level.TimeSeconds - P.LastSeenTime > 0.8)) )
	{
		bUseAltMode = 1;
		return (AIRating + 0.3);
	}
	else if ( !bNovice && (P.Acceleration == vect(0,0,0)) )
		bUseAltMode = 1;
	else if ( !bNovice && (VSize(P.Enemy.Location - P.Location) > 1200) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.05 + FMin(0.00009 * VSize(P.Enemy.Location - P.Location), 0.3));
	}
	else if ( P.Enemy.Location.Z > P.Location.Z + 200 )
	{
		bUseAltMode = int( FRand() < 0.6 );
		return (AIRating + 0.15);
	}
	else
		bUseAltMode = int( FRand() < 0.4 );

	return AIRating;
}

function Timer()
{
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;
	local Pawn P;

	bestAim = 0.95;
	P = Pawn(Owner);
	if ( P == None )
	{
		GotoState('');
		return;
	}
	FireDir = vector(P.ViewRotation);
	targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		bPointing = true;
		Pawn(targ).WarnTarget(P, 300, FireDir);
		SetTimer(1 + 4 * FRand(), false);
	}
	else
	{
		SetTimer(0.5 + 2 * FRand(), false);
		if ( (P.bFire == 0) && (P.bAltFire == 0) )
			bPointing = false;
	}
}

function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	if ( !bChangeWeapon && (Tracked != None) && !Tracked.bDeleteMe && (Owner != None)
		&& (Bot(Owner) != none || Bots(Owner) != none) && (Pawn(Owner).Enemy != None) && (FRand() < 0.3 + 0.35 * Pawn(Owner).skill)
		&& (AmmoType.AmmoAmount > 0) )
	{
		if ( (Owner.Acceleration == vect(0,0,0)) ||
			(Abs(Normal(Owner.Velocity) dot Normal(Tracked.Velocity)) > 0.95) )
		{
			bBotSpecialMove = true;
			GotoState('ComboMove');
			return;
		}
	}

	bBotSpecialMove = false;
	Tracked = None;
	Super.Finish();
}

///////////////////////////////////////////////////////
function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.30 + 0.30 * FireAdjust,0.05);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local PlayerPawn PlayerOwner;
	local Projectile Proj;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	bSplashDamage = false;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	bSplashDamage = default.bSplashDamage;

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	class'B227_Projectile'.default.B227_DamageWeaponClass = Class;
	Proj = Spawn(ProjClass,,, Start,AdjustedAim);
	class'B227_Projectile'.default.B227_DamageWeaponClass = none;
	if (B227_ShouldUseEnergyAmplifier() && Proj != none)
		Proj.Damage *= B227_AmplifyDamage(80);
	Tracked = Proj;
	if ( Level.Game.IsA('DeathMatchPlus') && DeathmatchPlus(Level.Game).bNoviceMode )
		Tracked = None; //no combo move
	return Proj;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local PlayerPawn PlayerOwner;
	local float DamageMult;
	local UT_RingExplosion3 AmpRingEffect;

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));

	B227_SpawnBeamEffects(Other, HitLocation, HitNormal, X, Y, Z);

	DamageMult = 1;
	if (B227_ShouldUseEnergyAmplifier())
		DamageMult = B227_AmplifyDamage(100);

	if (ShockProj(Other) != none)
	{
		if (B227_ShouldModifyComboDamage())
		{
			ShockProj(Other).Damage *= (2 + int(AmmoType.UseAmmo(1)) + int(AmmoType.UseAmmo(1))) / 4.0;
			Other.Instigator = Pawn(Owner);
		}
		else
			AmmoType.UseAmmo(2);

		ShockProj(Other).SuperExplosion();
	}
	else
	{
		if (DamageMult > 1.5)
		{
			AmpRingEffect = Spawn(class'UT_RingExplosion3',,, HitLocation + HitNormal * 8, rotator(HitNormal));
			if (AmpRingEffect != none)
			{
				AmpRingEffect.DrawScale = 1.5;
				AmpRingEffect.B227_bSpawnDecal = true;
			}
		}
		else
			Spawn(class'UT_RingExplosion5',,, HitLocation + HitNormal * 8, rotator(HitNormal));
	}

	if (Other != self && Other != Owner && Other != none)
		Other.TakeDamage(HitDamage * DamageMult, Pawn(Owner), HitLocation, 60000.0 * X, MyDamageType);
}


function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	B227_SpawnShockBeam(self, SmokeLocation, SmokeRotation, DVector / NumPoints, NumPoints - 1);
	B227_ShockBeamNumPoints += NumPoints;
}

function PlayAltFiring()
{
	PlaySound(AltFireSound, SLOT_None,Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire2',0.4 + 0.4 * FireAdjust,0.05);
}


function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Still',0.04,0.3);
}

state Idle
{
	function BeginState()
	{
		bPointing = false;
		SetTimer(0.5 + 2 * FRand(), false);
		Super.BeginState();
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}
}

state ComboMove
{
	function Fire(float F);
	function AltFire(float F);

	function Tick(float DeltaTime)
	{
		if ( (Owner == None) || (Pawn(Owner).Enemy == None) )
		{
			Tracked = None;
			bBotSpecialMove = false;
			Finish();
			return;
		}
		if ( (Tracked == None) || Tracked.bDeleteMe
			|| (((Tracked.Location - Owner.Location)
				dot (Tracked.Location - Pawn(Owner).Enemy.Location)) >= 0)
			|| (VSize(Tracked.Location - Pawn(Owner).Enemy.Location) < 100) )
			Global.Fire(0);
	}

Begin:
	Sleep(7.0);
	Tracked = None;
	bBotSpecialMove = false;
	Global.Fire(0);
}

/* Weapon's client states are removed in this conversion
state ClientFiring
{
	simulated function bool ClientFire(float Value)
	{
		if ( Level.TimeSeconds - TapTime < 0.2 )
			return false;
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		if ( Level.TimeSeconds - TapTime < 0.2 )
			return false;
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		local bool bForce, bForceAlt;

		bForce = bForceFire;
		bForceAlt = bForceAltFire;
		bForceFire = false;
		bForceAltFire = false;

		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForce || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAlt || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}
		Super.AnimEnd();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		TapTime = Level.TimeSeconds;
		bForceFire = false;
		bForceAltFire = false;
	}
}
*/

static function bool B227_ShouldModifyComboDamage()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bModifyShockComboDamage;
}

function B227_AdjustNPCFirePosition()
{
	if (Instigator.IsA('SkaarjTrooper'))
	{
		SetHand(1);
		PlayerViewOffset.Z = -500 * Instigator.DrawScale;
	}
}

function vector B227_GetFireStartTrace()
{
	local vector X, Y, Z;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	return Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
}

static function Actor B227_SpawnShockBeam(Actor Spawner, vector BeamLocation, rotator BeamRotation, vector MoveAmount, int NumPuffs)
{
	local ShockBeam Beam;

	Beam = Spawner.Spawn(class'ShockBeam',,, BeamLocation, BeamRotation);
	if (Beam == none)
		return none;
	Beam.MoveAmount = MoveAmount;
	Beam.NumPuffs = NumPuffs;
	return Beam;
}

// Auxiliary

function B227_SpawnBeamEffects(out Actor HitActor, out vector HitLocation, out vector HitNormal, out vector X, vector Y, vector Z)
{
	local vector StartTrace, BeamStart;
	local int MaxWarps;
	local bool bWarped;

	B227_ShockBeamNumPoints = 0;
	StartTrace = B227_FireStartTrace;
	MaxWarps = 8;

	if (B227_ShouldTraceFireThroughWarpZones())
		bWarped = B227_AdjustTraceResult(Level, StartTrace, B227_FireEndTrace, HitActor, HitLocation, HitNormal, MaxWarps);
	SpawnEffect(HitLocation, B227_FireStartTrace);
	if (B227_ShouldTraceFireThroughWarpZones() && bWarped)
	{
		HitActor = B227_TraceShot(self, StartTrace, B227_FireEndTrace, HitLocation, HitNormal);
		BeamStart = StartTrace;
		while (B227_AdjustTraceResult(Level, StartTrace, B227_FireEndTrace, HitActor, HitLocation, HitNormal, MaxWarps))
		{
			B227_SpawnEffectExtension(HitLocation, BeamStart);
			HitActor = B227_TraceShot(self, StartTrace, B227_FireEndTrace, HitLocation, HitNormal);
			BeamStart = StartTrace;
		}
		B227_SpawnEffectExtension(HitLocation, BeamStart);
	}
}

function B227_SpawnEffectExtension(vector HitLocation, vector BeamLocation)
{
	local Vector DVector;
	local int NumPoints;
	local rotator BeamRotation;

	DVector = HitLocation - BeamLocation;
	NumPoints = VSize(DVector) / 135.0;
	if (NumPoints < 1)
		return;
	BeamRotation = rotator(DVector);
	BeamRotation.Roll = Rand(65535);

	class'B227_ShockBeamExtension'.static.Make(
		self,
		Class,
		BeamLocation,
		BeamRotation,
		0.05 * B227_ShockBeamNumPoints,
		DVector/NumPoints,
		NumPoints - 1);
	B227_ShockBeamNumPoints += NumPoints;
}

defaultproperties
{
	hitdamage=40
	WeaponDescription="Classification: Energy Rifle\n\nPrimary Fire: Instant hit laser beam.\n\nSecondary Fire: Large, slow moving plasma balls.\n\nTechniques: Hitting the secondary fire plasma balls with the regular fire's laser beam will cause an immensely powerful explosion."
	InstFlash=-0.400000
	InstFog=(Z=800.000000)
	AmmoName=Class'Botpack.ShockCore'
	PickupAmmoCount=20
	bInstantHit=True
	bAltWarnTarget=True
	bSplashDamage=True
	FiringSpeed=2.000000
	FireOffset=(X=10.000000,Y=-5.000000,Z=-8.000000)
	AltProjectileClass=Class'Botpack.ShockProj'
	MyDamageType=jolted
	AIRating=0.630000
	AltRefireRate=0.700000
	FireSound=Sound'UnrealShare.ASMD.TazerFire'
	AltFireSound=Sound'UnrealShare.ASMD.TazerAltFire'
	SelectSound=Sound'UnrealShare.ASMD.TazerSelect'
	DeathMessage="%k inflicted mortal damage upon %o with the %w."
	NameColor=(R=128,G=0)
	AutoSwitchPriority=4
	InventoryGroup=4
	PickupMessage="You got the ASMD Shock Rifle."
	ItemName="Shock Rifle"
	PlayerViewOffset=(X=4.400000,Y=-1.700000,Z=-1.600000)
	PlayerViewMesh=LodMesh'Botpack.ASMD2M'
	PlayerViewScale=2.000000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'Botpack.ASMD2pick'
	ThirdPersonMesh=LodMesh'Botpack.ASMD2hand'
	StatusIcon=Texture'Botpack.Icons.UseASMD'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseASMD'
	Mesh=LodMesh'Botpack.ASMD2pick'
	bNoSmooth=False
	CollisionRadius=34.000000
	CollisionHeight=8.000000
	Mass=50.000000
}
