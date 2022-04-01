// ============================================================
// OLweapons.OSGrenade: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSGrenade expands Grenade;

struct B227_ReplicatedVector
{
	var float X, Y, Z;
};

var bool B227_bHandleZoneChange;
var B227_ReplicatedVector B227_SyncLocation;
var vector B227_SyncVelocity;
var bool B227_bStop;
var int B227_SyncNum;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_SyncNum;

	reliable if (Role == ROLE_Authority && !bNetInitial)
		B227_SyncLocation,
		B227_SyncVelocity,
		B227_bStop;
}

simulated event PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	if (Level.NetMode != NM_DedicatedServer)
		PlayAnim('WingIn');

	RandSpin(50000);
	B227_bHandleZoneChange = true;

	if (Role == ROLE_Authority)
	{
		SetTimer(2.5 + FRand() * 0.5, false); // Grenade begins unarmed
		if (Instigator != none)
		{
			GetAxes(Instigator.ViewRotation, X, Y, Z);
			Velocity = X * (Instigator.Velocity dot X) * 0.4 + vector(Rotation) * (Speed + FRand() * 100);
		}
		else
			Velocity = vector(Rotation) * (Speed + FRand() * 100);
		Velocity.z += 210;
		RandRot.Pitch = FRand() * 1400 - 700;
		RandRot.Yaw = FRand() * 1400 - 700;
		RandRot.Roll = FRand() * 1400 - 700;
		MaxSpeed = 1000;
		Velocity = Velocity >> RandRot;
		bCanHitOwner = false;
		if (Region.Zone.bWaterZone)
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}
	}
}

simulated event PostNetBeginPlay()
{
	B227_SyncNum = 0;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	local WaterRing w;

	if (!B227_bHandleZoneChange)
		return;

	if (Region.Zone.bWaterZone != NewZone.bWaterZone)
	{
		if (Level.NetMode != NM_Client)
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
		}

		if (NewZone.bWaterZone)
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}
	}

	if (VSize(NewZone.ZoneVelocity) != 0)
		B227_SyncMovement();
}

function Timer()
{
	Explosion(Location+Vect(0,0,1)*16);
}

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer)
		B227_MakeGrenadeTrail(DeltaTime);
	if (Level.NetMode == NM_Client && B227_SyncNum > 0)
		B227_ClientSyncMovement();
}

function B227_SyncMovement()
{
	B227_SyncLocation = B227_ConvertToReplicatedVector(Location);
	B227_SyncVelocity = Velocity;
	++B227_SyncNum;
}

simulated function B227_ClientSyncMovement()
{
	SetLocation(B227_ConvertReplicatedVector(B227_SyncLocation));
	Velocity = B227_SyncVelocity;
	if (B227_bStop)
	{
		bBounce = false;
		SetPhysics(PHYS_None);
	}
	B227_SyncNum = 0;
}

static function B227_ReplicatedVector B227_ConvertToReplicatedVector(vector pos)
{
	local B227_ReplicatedVector Result;
	Result.X = pos.X;
	Result.Y = pos.Y;
	Result.Z = pos.Z;
	return Result;
}

static function vector B227_ConvertReplicatedVector(B227_ReplicatedVector pos)
{
	local vector Result;
	Result.X = pos.X;
	Result.Y = pos.Y;
	Result.Z = pos.Z;
	return Result;
}

simulated function B227_MakeGrenadeTrail(float DeltaTime)
{
	local BlackSmoke smoke;
	local float GrenadeTrailInterval;

	Count += DeltaTime;
	GrenadeTrailInterval = Frand() * SmokeRate + SmokeRate + NumExtraGrenades * 0.03;
	if (Count >= GrenadeTrailInterval)
	{
		if (!Region.Zone.bWaterZone)
		{
			smoke = Spawn(class'BlackSmoke');
			if (smoke != none)
				smoke.RemoteRole = ROLE_None;
		}
		Count -= GrenadeTrailInterval;
		if (Count > GrenadeTrailInterval)
			Count = GrenadeTrailInterval;
	}
}

function ProcessTouch(actor Other, vector HitLocation)
{
	if (Other != Instigator || bCanHitOwner)
		Explosion(HitLocation);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	bCanHitOwner = True;
	Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);
	B227_PlayImpactSound();
	if (Velocity.Z > 400)
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if (speed < 20 && Level.NetMode != NM_Client) 
	{
		bBounce = false;
		SetPhysics(PHYS_None);
		B227_bStop = true;
	}

	B227_SyncMovement();
}

function B227_PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc, FMax(0.5, speed/800));
}

function Explosion(vector HitLocation)
{
	local SpriteBallExplosion s;
	local B227_OSGrenadeExplosion Expl;

	BlowUp(HitLocation);
	s = Spawn(class'SpriteBallExplosion',,, HitLocation);
	s.RemoteRole = ROLE_None;

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (class'olweapons.uiweapons'.default.busedecals)
			Spawn(class'odBlastMark',,,, rot(16384,0,0));
	}

	if (Level.NetMode != NM_Standalone)
	{
		Expl = Spawn(class'B227_OSGrenadeExplosion');
		if (Expl != none)
			Expl.SetExplosionInfo(none, Location, HitLocation);
	}

	Destroy();
}

defaultproperties
{
	bNetTemporary=False
}
