//=============================================================================
// PKShotgunShell.
//=============================================================================
class PKShotgunShell extends Projectile;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var bool bHasBounced;
var int numBounces;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.1, false);
	if ( Level.bDropDetail && (Level.NetMode != NM_DedicatedServer)
		&& (Level.NetMode != NM_ListenServer) )
		LifeSpan = 1.5;
	if ( Level.bDropDetail )
		LightType = LT_None;
}

simulated function Timer()
{
	LightType = LT_None;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	if ( Level.bDropDetail )
	{
		Destroy();
		return;
	}
	if ( bHasBounced && ((numBounces > 3) || (FRand() < 0.85) || (Velocity.Z > -50)) )
		bBounce = false;
	numBounces++;
	if ( numBounces > 3 )
	{
		Destroy();
		return;
	}
	else if ( !Region.Zone.bWaterZone )
	{
		if ( numBounces == 1 )
		{
			MakeSound();
		}
	}

	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal + 0.4 * VRand());
	if ( (HitNormal Dot RealHitNormal) < 0 )
		HitNormal *= -0.5;
	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(100000);
	bHasBounced = True;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if (NewZone.bWaterZone && !Region.Zone.bWaterZone)
	{
		Velocity=0.2*Velocity;
		bHasBounced=True;
	}
}


simulated function Landed( vector HitNormal )
{
	local rotator RandRot;

	if ( Level.bDropDetail )
	{
		Destroy();
		return;
	}

	if ( !Region.Zone.bWaterZone )
	{
		if ( numBounces == 1 )
		{
			MakeSound();
		}
	}

	if ( numBounces > 3 )
	{
		Destroy();
		return;
	}

	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll = 0;
	SetRotation(RandRot);
}

function Eject(Vector Vel)
{
	Velocity = Vel;
	RandSpin(100000);
	if ( (Instigator != None) && Instigator.HeadRegion.Zone.bWaterZone )
	{
		Velocity += 0.85 * Instigator.Velocity;
		Velocity = Velocity * (0.2+FRand()*0.2);
		bHasBounced=True;
	}
}

function MakeSound()
{
	if (FRand() < 0.5)
	PlaySound(sound'PKsgshell1',,,,,0.9+0.2*FRand());
	else if (FRand() < 0.5)
	PlaySound(sound'PKsgshell2',,,,,0.9+0.2*FRand());
	else
	PlaySound(sound'PKsgshell3',,,,,0.9+0.2*FRand());
}

defaultproperties
{
     MaxSpeed=1000.000000
     bNetOptional=True
     bReplicateInstigator=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Skin=Texture'PerUnreal.Skins.PKSGShell'
     Mesh=LodMesh'PerUnreal.pkshell'
     DrawScale=2.000000
     bUnlit=True
     bCollideActors=False
     bBounce=True
     bFixedRotationDir=True
     NetPriority=1.400000
}
