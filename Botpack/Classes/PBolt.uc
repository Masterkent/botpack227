//=============================================================================
// pbolt.
//=============================================================================
class PBolt extends projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() texture SpriteAnim[5];
var int SpriteFrame;
var PBolt PlasmaBeam;
var PlasmaCap WallEffect;
var int Position;
var vector FireOffset;
var float BeamSize;
var bool bRight, bCenter;
var float AccumulatedDamage, LastHitTime;
var Actor DamagedActor;

var bool B227_bGuidedByWeapon;
var bool B227_bTraceFireThroughWarpZones;
var bool B227_bLimitWallEffect;

var class<PBolt> B227_PBoltClass;
var PBolt B227_BeamStarter;
var PlasmaCap B227_BeamEnd;
var bool B227_bCanHitInstigator, B227_bNextCanHitInstigator;
var float B227_DamageMult;

replication
{
	// Things the server should send to the client.
	reliable if (Role == ROLE_Authority)
		bRight, bCenter;

	reliable if (Role == ROLE_Authority)
		B227_bGuidedByWeapon,
		B227_bTraceFireThroughWarpZones,
		B227_bLimitWallEffect,
		B227_DamageMult;
}

simulated function Destroyed()
{
	super.Destroyed();
	if (PlasmaBeam != none)
		PlasmaBeam.Destroy();
	if (WallEffect != none)
		WallEffect.Destroy();
	if (B227_BeamEnd != none)
		B227_BeamEnd.Destroy();
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local int bCanHitInstigator;
	local float DamageMult;

	if (B227_BeamStarter != none)
		DamageMult = FMax(1, B227_BeamStarter.B227_DamageMult);
	else
	{
		DamageMult = 1;
		if (StarterBolt(self) != none)
			B227_BeamStarter = self;
	}

	// check to see if hits something, else spawn or orient child

	HitActor = B227_TraceBeam(X, HitLocation, HitNormal, bCanHitInstigator);

	if (HitActor != none)
	{
		if ( Level.Netmode != NM_Client )
		{
			if ( DamagedActor == None )
			{
				AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - LastHitTime), 0.1);
				HitActor.TakeDamage(
					B227_GetDamage() * AccumulatedDamage * DamageMult,
					Instigator,
					HitLocation,
					(MomentumTransfer * X * AccumulatedDamage),
					MyDamageType);
				AccumulatedDamage = 0;
			}
			else if ( DamagedActor != HitActor )
			{
				DamagedActor.TakeDamage(
					B227_GetDamage() * AccumulatedDamage * DamageMult,
					Instigator,
					HitLocation,
					(MomentumTransfer * X * AccumulatedDamage),
					MyDamageType);
				AccumulatedDamage = 0;
			}
			LastHitTime = Level.TimeSeconds;
			DamagedActor = HitActor;
			AccumulatedDamage += DeltaTime;
			if ( AccumulatedDamage > 0.22 )
			{
				if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
					AccumulatedDamage = 35/damage;
				DamagedActor.TakeDamage(
					B227_GetDamage() * AccumulatedDamage * DamageMult,
					Instigator,
					HitLocation,
					(MomentumTransfer * X * AccumulatedDamage),
					MyDamageType);
				AccumulatedDamage = 0;
			}
		}
		if (HitActor.bIsPawn && Pawn(HitActor).bIsPlayer || B227_DisableWallEffect(HitActor))
		{
			if ( WallEffect != None )
				WallEffect.Destroy();
		}
		else if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		else if ( !WallEffect.IsA('PlasmaHit') )
		{
			WallEffect.Destroy();
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		}
		else
			WallEffect.SetLocation(HitLocation - 5 * X);

		if ( (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));

		if ( PlasmaBeam != None )
		{
			AccumulatedDamage += PlasmaBeam.AccumulatedDamage;
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}

		B227_UpdatePlasmaBeamEnd(HitLocation, X);
		B227_AdjustWallEffect();

		return;
	}
	else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
	{
		DamagedActor.TakeDamage(
			B227_GetDamage() * AccumulatedDamage * DamageMult,
			Instigator,
			DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
			(MomentumTransfer * X * AccumulatedDamage),
			MyDamageType);
		AccumulatedDamage = 0;
		DamagedActor = None;
	}

	if (Position >= 9)
	{
		if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'PlasmaCap',,, HitLocation - 4 * X);
		else if ( WallEffect.IsA('PlasmaHit') )
		{
			WallEffect.Destroy();
			WallEffect = Spawn(class'PlasmaCap',,, HitLocation - 4 * X);
		}
		else
			WallEffect.SetLocation(HitLocation - 4 * X);
	
		if (PlasmaBeam != none)
		{
			PlasmaBeam.Destroy();
			PlasmaBeam = none;
		}

		B227_AdjustWallEffect();
	}
	else
	{
		if (wallEffect != none)
		{
			WallEffect.Destroy();
			WallEffect = none;
		}
		if (PlasmaBeam == none || PlasmaBeam.bDeleteMe)
		{
			PlasmaBeam = Spawn(B227_PBoltClass,,, HitLocation, rotator(X)); 
			PlasmaBeam.Position = Position + 1;
			PlasmaBeam.B227_BeamStarter = B227_BeamStarter;
			PlasmaBeam.B227_bCanHitInstigator = bool(bCanHitInstigator);
		}
		else
			PlasmaBeam.B227_UpdateBeam(self, HitLocation, X, bool(bCanHitInstigator), DeltaTime);

		B227_ModifyLighting(PlasmaBeam);
	}

	B227_UpdatePlasmaBeamEnd(HitLocation, X);
}

// [B227] This function is preserved for subclasses
simulated function UpdateBeam(PBolt ParentBolt, vector Dir, float DeltaTime)
{
	B227_UpdateBeam(ParentBolt, ParentBolt.Location + ParentBolt.BeamSize * Dir, Dir, false, DeltaTime);
}

simulated function B227_UpdateBeam(PBolt ParentBolt, vector Pos, vector Dir, bool bCanHitInstigator, float DeltaTime)
{
	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	SetLocation(Pos);
	SetRotation(rotator(Dir));
	B227_bCanHitInstigator = bCanHitInstigator;
	CheckBeam(Dir, DeltaTime);
}

simulated function Actor B227_TraceBeam(out vector Dir, out vector HitLocation, out vector HitNormal, out int bCanHitInstigator)
{
	local Actor Tracer, HitActor;
	local vector StartTrace, EndTrace;
	local int MaxWarps;

	if (B227_bCanHitInstigator || Instigator == none)
		Tracer = self;
	else
		Tracer = Instigator;
	StartTrace = Location;
	EndTrace = StartTrace + BeamSize * Dir;
	HitActor = class'UTC_Weapon'.static.B227_TraceShot(Tracer, StartTrace, EndTrace, HitLocation, HitNormal);
	MaxWarps = 1;

	if (B227_BeamStarter != none &&
		B227_BeamStarter.B227_bTraceFireThroughWarpZones &&
		class'UTC_Weapon'.static.B227_AdjustTraceResult(Level, StartTrace, EndTrace, HitActor, HitLocation, HitNormal, MaxWarps, Dir))
	{
		// Dir is set above
		HitLocation = StartTrace;
		bCanHitInstigator = 1;
		return none;
	}
	// Dir and HitLocation are set above
	bCanHitInstigator = int(B227_bCanHitInstigator);
	return HitActor;
}

function B227_SetBeamRepMovement(vector Pos, rotator Dir);

simulated function B227_ModifyLighting(PBolt Beam)
{
	if (Beam != none &&
		B227_BeamStarter != none &&
		class'PulseGun'.static.B227_ShouldModifyPlasmaLighting())
	{
		Beam.LightType = B227_BeamStarter.LightType;
		Beam.LightEffect = B227_BeamStarter.LightEffect;
		Beam.LightBrightness = B227_BeamStarter.LightBrightness;
		Beam.LightHue = B227_BeamStarter.LightHue;
		Beam.LightSaturation = B227_BeamStarter.LightSaturation;
		Beam.LightRadius = B227_BeamStarter.LightRadius;
	}
}

simulated function B227_UpdatePlasmaBeamEnd(vector HitLocation, vector Dir)
{
	if (class'PulseGun'.static.B227_ShouldModifyPlasmaLighting() &&
		(PlasmaBeam == none || PlasmaBeam.bDeleteMe) &&
		B227_BeamEnd == none)
	{
		B227_BeamEnd = Spawn(class'PlasmaCap',,, HitLocation - 4 * Dir);
	}
	else if (PlasmaBeam != none && !PlasmaBeam.bDeleteMe && B227_BeamEnd != none)
	{
		B227_BeamEnd.Destroy();
		B227_BeamEnd = none;
	}

	if (B227_BeamEnd != none)
	{
		if (class'PulseGun'.static.B227_ShouldModifyPlasmaLighting())
			B227_BeamEnd.B227_SetAdvancedLighting(self);
		if (B227_BeamStarter != none && B227_BeamStarter.B227_bTraceFireThroughWarpZones)
			class'UTC_Actor'.static.B227_WarpActor(B227_BeamEnd);
	}
}

simulated function B227_AdjustWallEffect()
{
	if (WallEffect != none && B227_BeamStarter != none && B227_BeamStarter.B227_bTraceFireThroughWarpZones)
		class'UTC_Actor'.static.B227_WarpActor(WallEffect);
}

function int B227_GetDamage()
{
	return class'PulseGun'.static.B227_ModifyDamage(self, Damage);
}

// Auxiliary
function simulated bool B227_DisableWallEffect(Actor HitActor)
{
	return
		B227_BeamStarter != none &&
		B227_BeamStarter.B227_bLimitWallEffect &&
		HitActor != Level &&
		!HitActor.bWorldGeometry &&
		HitActor.bProjTarget;
}

defaultproperties
{
	SpriteAnim(0)=Texture'Botpack.Skins.pbolt0'
	SpriteAnim(1)=Texture'Botpack.Skins.pbolt1'
	SpriteAnim(2)=Texture'Botpack.Skins.pbolt2'
	SpriteAnim(3)=Texture'Botpack.Skins.pbolt3'
	SpriteAnim(4)=Texture'Botpack.Skins.pbolt4'
	FireOffset=(X=16.000000,Y=-14.000000,Z=-8.000000)
	BeamSize=81.000000
	bRight=True
	MaxSpeed=0.000000
	Damage=72.000000
	MomentumTransfer=8500
	MyDamageType=zapped
	ExplosionDecal=Class'Botpack.BoltScorch'
	bNetTemporary=False
	Physics=PHYS_None
	RemoteRole=ROLE_None
	LifeSpan=60.000000
	AmbientSound=Sound'Botpack.PulseGun.PulseBolt'
	Style=STY_Translucent
	Texture=Texture'Botpack.Skins.pbolt0'
	Skin=Texture'Botpack.Skins.pbolt0'
	Mesh=LodMesh'Botpack.PBolt'
	bUnlit=True
	SoundRadius=12
	SoundVolume=255
	bCollideActors=False
	bCollideWorld=False
	B227_PBoltClass=Class'Botpack.PBolt'
}
