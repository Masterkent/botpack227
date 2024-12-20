//=============================================================================
// PlasmaSphere.
//=============================================================================
class PlasmaSphere extends Projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool bExploded, bExplosionEffect, bHitPawn;
var() texture ExpType;
var() Sound EffectSound1;
var() texture SpriteAnim[20];
var() int NumFrames;
var Float AnimTime;

var private class<Weapon> B227_DamageWeaponClass;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.8, true);
	if ( Level.NetMode == NM_Client )
		LifeSpan = 2.0;
	else
	{
		Velocity = Speed * vector(Rotation);
		B227_SetDamageWeaponClass(class'B227_Projectile'.default.B227_DamageWeaponClass);
	}
	if ( Level.bDropDetail )
		LightType = LT_None;
}

simulated function Timer()
{
	if ( Level.bDropDetail )
		LightType = LT_None;
	if ( (Physics == PHYS_None) && (LifeSpan > 0.5) )
		LifeSpan = 0.5;
}

simulated function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	bExploded = True;
}

function BlowUp(vector HitLocation)
{
	PlaySound(EffectSound1,,7.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( !bExplosionEffect )
	{
		if ( Role == ROLE_Authority )
			BlowUp(HitLocation);
		bExplosionEffect = true;
		if ( !Level.bHighDetailMode || bHitPawn || Level.bDropDetail )
		{
			if ( bExploded )
			{
				Destroy();
				return;
			}
			else
				DrawScale *= 0.45 / default.DrawScale;
		}
		else
			DrawScale *= 0.65 / default.DrawScale;

		LightType = LT_Steady;
		LightRadius = Clamp(LightRadius * 5 / default.LightRadius, 5, 255);
		SetCollision(false,false,false);
		LifeSpan = 0.5;
		Texture = ExpType;
		DrawType = DT_SpriteAnimOnce;
		Style = STY_Translucent;
		if ( Region.Zone.bMoveProjectiles && (Region.Zone.ZoneVelocity != vect(0,0,0)) )
		{
			bBounce = true;
			Velocity = Region.Zone.ZoneVelocity;
		}
		else
			SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( Other!=Instigator  && PlasmaSphere(Other)==None )
	{
		if ( Other.bIsPawn )
		{
			bHitPawn = true;
			bExploded = !Level.bHighDetailMode || Level.bDropDetail;
		}
		if ( Role == ROLE_Authority )
		{
			class'UTC_GameInfo'.static.B227_SetDamageWeaponClass(Level, B227_GetDamageWeaponClass());
			Other.TakeDamage(
				B227_GetDamage(),
				Instigator,
				HitLocation,
				MomentumTransfer * vector(Rotation),
				MyDamageType);
			class'UTC_GameInfo'.static.B227_ResetDamageWeaponClass(Level);
		}

		Explode(HitLocation, vect(0,0,1));
	}
}

auto State Flying
{
Begin:
	LifeSpan = 2.0;
}

function int B227_GetDamage()
{
	return class'PulseGun'.static.B227_ModifyDamage(self, Damage);
}

function class<Weapon> B227_GetDamageWeaponClass()
{
	return B227_DamageWeaponClass;
}

function B227_SetDamageWeaponClass(class<Weapon> WeaponClass)
{
	B227_DamageWeaponClass = WeaponClass;
}

defaultproperties
{
	ExpType=Texture'Botpack.PlasmaExplo.pblst_a00'
	EffectSound1=Sound'Botpack.PulseGun.PulseExp'
	NumFrames=11
	speed=1450.000000
	Damage=20.000000
	MomentumTransfer=10000
	MyDamageType=Pulsed
	ExploWallOut=10.000000
	ExplosionDecal=Class'Botpack.BoltScorch'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.500000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'Botpack.PlasmaExplo.pblst_a00'
	DrawScale=0.190000
	AmbientGlow=187
	bUnlit=True
	SoundRadius=10
	SoundVolume=218
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=83
	LightRadius=3
	bFixedRotationDir=True
}
