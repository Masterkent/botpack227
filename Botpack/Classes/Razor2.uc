//=============================================================================
// Razor2
// A human modified RazorBlade
//=============================================================================
class Razor2 extends B227_SyncedProjectile;

#exec MESH IMPORT MESH=razorblade ANIVFILE=MODELS\razorblade_a.3D DATAFILE=MODELS\razorblade_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=razorblade X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=razorblade SEQ=All    STARTFRAME=0   NUMFRAMES=30
#exec MESH SEQUENCE MESH=razorblade SEQ=Spin  STARTFRAME=0   NUMFRAMES=29
#exec MESHMAP SCALE MESHMAP=razorblade X=0.09 Y=0.09 Z=0.18
#exec TEXTURE IMPORT NAME=RazTrail FILE=MODELS\raztrail.PCX GROUP="Skins"
#exec TEXTURE IMPORT NAME=RazSkin FILE=MODELS\razorskin.PCX GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=razorblade NUM=1 TEXTURE=RazSkin
#exec MESHMAP SETTEXTURE MESHMAP=razorblade NUM=2 TEXTURE=RazTrail

var int NumWallHits;
var bool bCanHitInstigator, bHitWater;

var int B227_NumWallHits;
var vector B227_WallHitLocation;
var rotator B227_WallHitRotation;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_NumWallHits,
		B227_WallHitLocation,
		B227_WallHitRotation;
}

/////////////////////////////////////////////////////
auto state Flying
{
	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if (bCanHitInstigator || Other != Instigator) 
		{
			if (Other.bIsPawn &&
				HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight &&
				(Bot(Instigator) == none || !Bot(Instigator).bNovice))
			{
				Other.TakeDamage(3.5 * Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), 'decapitated');
			}
			else
				Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), 'shredded');

			if ( Other.bIsPawn )
				PlaySound(MiscSound, SLOT_Misc, 2.0);
			else
				PlaySound(ImpactSound, SLOT_Misc, 2.0);
			Destroy();
		}
	}

	simulated event ZoneChange( Zoneinfo NewZone )
	{
		local Splash w;

		if (Region.Zone.bWaterZone != NewZone.bWaterZone)
		{
			if (Level.NetMode != NM_Client)
			{
				w = Spawn(class'Splash',,,,rot(16384,0,0));
				w.DrawScale = 0.5;
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

	simulated function SetRoll(vector NewVelocity) 
	{
		local rotator newRot;

		newRot = rotator(NewVelocity);
		SetRotation(newRot);
	}

	simulated event HitWall(vector HitNormal, Actor Wall)
	{
		local vector Vel2D, Norm2D;

		bCanHitInstigator = true;
		B227_PlayImpactSound();
		LoopAnim('Spin',1.0);

		if (Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_Client)
			Spawn(class'WallCrack',,, Location, rotator(HitNormal));

		if (Role == ROLE_Authority)
		{
			if (Mover(Wall) != none && Mover(Wall).bDamageTriggered)
			{
				Wall.TakeDamage(Damage, Instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				Destroy();
				return;
			}
			NumWallHits++;
			SetTimer(0, False);
			MakeNoise(0.3);
			if (NumWallHits > 6)
			{
				Destroy();
				return;
			}
			B227_NumWallHits = NumWallHits;
			B227_WallHitLocation = Location;
			B227_WallHitRotation = rotator(HitNormal);
		}

		if ( NumWallHits == 1 ) 
		{
			Vel2D = Velocity;
			Vel2D.Z = 0;
			Norm2D = HitNormal;
			Norm2D.Z = 0;
			Norm2D = Normal(Norm2D);
			Vel2D = Normal(Vel2D);
			if ( (Vel2D Dot Norm2D) < -0.999 )
			{
				HitNormal = Normal(HitNormal + 0.6 * Vel2D);
				Norm2D = HitNormal;
				Norm2D.Z = 0;
				Norm2D = Normal(Norm2D);
				if ( (Vel2D Dot Norm2D) < -0.999 )
				{
					if ( Rand(1) == 0 )
						HitNormal = HitNormal + vect(0.05,0,0);
					else
						HitNormal = HitNormal - vect(0.05,0,0);
					if ( Rand(1) == 0 )
						HitNormal = HitNormal + vect(0,0.05,0);
					else
						HitNormal = HitNormal - vect(0,0.05,0);
					HitNormal = Normal(HitNormal);
				}
			}
		}
		Velocity -= 2 * (Velocity dot HitNormal) * HitNormal;
		SetRoll(Velocity);

		B227_SyncMovement();
	}

	function SetUp()
	{
		local vector X;

		X = vector(Rotation);
		Velocity = Speed * X;     // Impart ONLY forward vel
		if (Region.Zone.bWaterZone)
			bHitWater = True;
	}

	simulated function BeginState()
	{

		SetTimer(0.2, false);
		SetUp();

		if ( Level.NetMode != NM_DedicatedServer )
		{
			LoopAnim('Spin',1.0);
			if ( Level.NetMode == NM_Standalone )
				SoundPitch = 200 + 50 * FRand();
		}
	}

	simulated function Timer()
	{
		bCanHitInstigator = true;
	}

	simulated event Tick(float DeltaTime)
	{
		if (Level.NetMode == NM_Client)
		{
			B227_ClientSyncMovement();
			if (VSize(Velocity) > 0)
				SetRotation(rotator(Velocity));

			if (B227_NumWallHits > 0)
			{
				Spawn(class'WallCrack',,, B227_WallHitLocation, B227_WallHitRotation);
				B227_NumWallHits = 0;
			}
		}
	}
}

function B227_PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc, 2.0);
}

defaultproperties
{
	speed=1300.000000
	MaxSpeed=1200.000000
	Damage=30.000000
	MomentumTransfer=15000
	SpawnSound=Sound'UnrealI.Razorjack.StartBlade'
	ImpactSound=Sound'UnrealI.Razorjack.BladeHit'
	MiscSound=Sound'UnrealI.Razorjack.BladeThunk'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	AnimSequence=spin
	AmbientSound=Sound'UnrealI.Razorjack.RazorHum'
	Mesh=LodMesh'Botpack.RazorBlade'
	AmbientGlow=167
	bUnlit=True
	SoundRadius=12
	SoundVolume=255
	SoundPitch=200
	bBounce=True
}
