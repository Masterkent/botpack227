// A special chunk, largely ripped from UT, but changed for me own evil needs
// Code by Sergey 'Eater' Levin, 2002

class NCChunk extends Projectile;

var	chunktrail trail;
var Texture AnimFrame[12];
var int Count;
var NaliMage NaliOwner;

	simulated function PostBeginPlay()
	{
		local rotator RandRot;
		local float decision;

		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( !Region.Zone.bWaterZone )
				Trail = Spawn(class'ChunkTrail',self);
			SetTimer(0.1, true);
		}

		decision = FRand();
		if (decision<0.25)
			Mesh = LodMesh'Botpack.ChunkM';
		else if (decision<0.5)
			Mesh = LodMesh'Botpack.Chunk2M';
		else if (decision <0.75)
			Mesh = LodMesh'Botpack.Chunk3M';
		else
			Mesh = LodMesh'Botpack.Chunk4M';

		if ( Role == ROLE_Authority )
		{
			RandRot = Rotation;
			RandRot.Pitch = 16384;
			RandRot.Pitch += FRand() * 2000 - 1000;
			RandRot.Yaw += FRand() * 2000 - 1000;
			RandRot.Roll += FRand() * 2000 - 1000;
			Velocity = Vector(RandRot) * (Speed*FRand());
			if (Region.zone.bWaterZone)
				Velocity *= 0.65;
		}
		Super.PostBeginPlay();
	}

	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		if (Chunk(Other) == None && NCPawnEnchantFlameGyser(Other) == None)
		{
			speed = VSize(Velocity);
			If ( speed > 200 )
			{
				if ( Role == ROLE_Authority ) {
					Other.TakeDamage(damage, instigator,HitLocation,
						(MomentumTransfer * Velocity/speed), MyDamageType );
					if (NaliMage(Other) == none && Nali(Other) == none && NaliWarrior(Other) == none && Pawn(Other) != none)
						NaliOwner.GainExp(3,damage);
				}
				if ( FRand() < 0.5 )
					PlaySound(Sound 'ChunkHit',, 4.0,,200);
			}
			Destroy();
		}
	}

	simulated function Timer()
	{
		Count++;
		Texture = AnimFrame[Count];
		if ( Count == 11 )
			SetTimer(0.0,false);
	}

	simulated function Landed( Vector HitNormal )
	{
		SetPhysics(PHYS_None);
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local float Rand;
		local SmallSpark s;

		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Level.NetMode != NM_Client )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
			return;
		}
		if ( Physics != PHYS_Falling )
		{
			SetPhysics(PHYS_Falling);
			if ( !Level.bDropDetail && (Level.Netmode != NM_DedicatedServer) && !Region.Zone.bWaterZone )
			{
				if ( FRand() < 0.5 )
				{
					s = Spawn(Class'SmallSpark',,,Location+HitNormal*5,rotator(HitNormal));
					s.RemoteRole = ROLE_None;
				}
				else
					Spawn(class'WallCrack',,,Location, rotator(HitNormal));
			}
		}
		Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + Velocity);   // Reflect off Wall w/damping
		SetRotation(rotator(Velocity));
		speed = VSize(Velocity);
		if ( speed > 100 )
		{
			MakeNoise(0.3);
			Rand = FRand();
			if (Rand < 0.33)	PlaySound(sound 'Hit1', SLOT_Misc,0.6,,1000);
			else if (Rand < 0.66) PlaySound(sound 'Hit3', SLOT_Misc,0.6,,1000);
			else PlaySound(sound 'Hit5', SLOT_Misc,0.6,,1000);
		}
	}

	simulated function zonechange(Zoneinfo NewZone)
	{
		if (NewZone.bWaterZone)
		{
			if ( Trail != None )
				Trail.Destroy();
			SetTimer(0.0, false);
			Texture = AnimFrame[11];
			Velocity *= 0.65;
		}
	}

defaultproperties
{
     AnimFrame(0)=Texture'Botpack.ChunkGlow.Chunk_a00'
     AnimFrame(1)=Texture'Botpack.ChunkGlow.Chunk_a01'
     AnimFrame(2)=Texture'Botpack.ChunkGlow.Chunk_a02'
     AnimFrame(3)=Texture'Botpack.ChunkGlow.Chunk_a03'
     AnimFrame(4)=Texture'Botpack.ChunkGlow.Chunk_a04'
     AnimFrame(5)=Texture'Botpack.ChunkGlow.Chunk_a05'
     AnimFrame(6)=Texture'Botpack.ChunkGlow.Chunk_a06'
     AnimFrame(7)=Texture'Botpack.ChunkGlow.Chunk_a07'
     AnimFrame(8)=Texture'Botpack.ChunkGlow.Chunk_a08'
     AnimFrame(9)=Texture'Botpack.ChunkGlow.Chunk_a09'
     AnimFrame(10)=Texture'Botpack.ChunkGlow.Chunk_a10'
     AnimFrame(11)=Texture'Botpack.ChunkGlow.Chunk_a11'
     speed=1500.000000
     MaxSpeed=2700.000000
     Damage=8.000000
     MomentumTransfer=10000
     MyDamageType=shredded
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     Texture=Texture'Botpack.ChunkGlow.Chunk_a00'
     DrawScale=0.400000
     AmbientGlow=255
     bUnlit=True
     bNoSmooth=True
     bBounce=True
}
