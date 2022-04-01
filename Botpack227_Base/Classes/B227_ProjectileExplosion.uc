class B227_ProjectileExplosion expands Info;

// Replicated built-in vectors hold inexact values, float values are replicated precisely
struct ReplicatedVector
{
	var float X, Y, Z;
};

var private class<B227_Projectile> ProjClass;
var private ReplicatedVector ProjLocation;
var private ReplicatedVector HitLocation;
var private int EncodedHitNormal;
var private rotator Direction; // does not need precise replication

replication
{
	reliable if (Role == ROLE_Authority)
		ProjClass,
		ProjLocation,
		HitLocation,
		EncodedHitNormal,
		Direction;
}

function SetExplosionInfo(
	class<B227_Projectile> ProjClass,
	optional vector ProjLocation,
	optional vector HitLocation,
	optional vector HitNormal,
	optional rotator Direction)
{
	self.ProjClass = ProjClass;
	self.ProjLocation = ConvertToReplicatedVector(ProjLocation);
	self.HitLocation = ConvertToReplicatedVector(HitLocation);
	self.EncodedHitNormal = EncodeNormalVector(HitNormal);
	self.Direction = Direction;

	LifeSpan = FMax(0.1, Level.TimeDilation);
}

// This function is called only on network client
simulated function Explosion()
{
	if (ProjClass == none || Level.NetMode != NM_Client)
		return;

	ProjClass.static.B227_Explode(
		self,
		GetProjLocation(),
		GetHitLocation(),
		GetHitNormal(),
		Direction);

	ProjClass = none;
}

simulated event PostNetBeginPlay()
{
	if (Level.NetMode != NM_Client)
		return;

	Explosion();
	Destroy();
}

simulated function vector GetProjLocation()
{
	return ConvertReplicatedVector(ProjLocation);
}

simulated function vector GetHitLocation()
{
	return ConvertReplicatedVector(HitLocation);
}

simulated function vector GetHitNormal()
{
	return DecodeNormalVector(EncodedHitNormal);
}

static function ReplicatedVector ConvertToReplicatedVector(vector pos)
{
	local ReplicatedVector result;
	result.X = pos.X;
	result.Y = pos.Y;
	result.Z = pos.Z;
	return result;
}

static function vector ConvertReplicatedVector(ReplicatedVector pos)
{
	local vector result;
	result.X = pos.X;
	result.Y = pos.Y;
	result.Z = pos.Z;
	return result;
}

static function int EncodeNormalVector(vector NormalVect)
{
	local rotator R;

	if (VSize(NormalVect) == 0)
		return 0;

	R = rotator(NormalVect);
	if (R.Yaw < 0)
		R.Yaw += 65536;
	if (R.Pitch < 0)
		R.Pitch += 65536;

	return ((R.Yaw >> 1) << 1) + ((R.Pitch >> 1) << 16) + 1;
}

static function vector DecodeNormalVector(int EncodedNormalVect)
{
	local rotator R;

	if (EncodedNormalVect == 0)
		return vect(0, 0, 0);

	R.Yaw = EncodedNormalVect & (65536 - 2);
	R.Pitch = (EncodedNormalVect >> 16) << 1;

	return vector(R);
}

defaultproperties
{
	bAlwaysRelevant=True
	bCarriedItem=True
	bNetTemporary=True
	LifeSpan=1
	RemoteRole=ROLE_SimulatedProxy
}
