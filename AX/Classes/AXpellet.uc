//=============================================================================
// AXpellet.
//=============================================================================
class AXpellet expands Projectile;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

var int NumWallHits;
var bool bCanHitInstigator, bHitWater;

/////////////////////////////////////////////////////
auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( bCanHitInstigator || (Other != Instigator) )
		{
			if ( Role == ROLE_Authority )
			{
				if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
					&& (!Instigator.IsA('Bot') || !Bot(Instigator).bNovice) )
					Other.TakeDamage(3.5 * damage, instigator,HitLocation,
						(MomentumTransfer * Normal(Velocity)), 'decapitated' );
				else
					Other.TakeDamage(damage, instigator,HitLocation,
						(MomentumTransfer * Normal(Velocity)), 'shot' );
			}
			if ( Other.bIsPawn )
				PlaySound(MiscSound, SLOT_Misc, 2.0);
			else
				PlaySound(ImpactSound, SLOT_Misc, 2.0);
			destroy();
		}
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local Splash w;

		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'Splash',,,,rot(16384,0,0));
			w.DrawScale = 0.5;
			w.RemoteRole = ROLE_None;
		}
		Velocity=0.6*Velocity;
	}

	simulated function SetRoll(vector NewVelocity)
	{
		local rotator newRot;

		newRot = rotator(NewVelocity);
		SetRotation(newRot);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		bCanHitInstigator = true;
		PlaySound(ImpactSound, SLOT_Misc, 2.0);
		LoopAnim('Still');
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Role == ROLE_Authority )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
			return;
		}
		NumWallHits++;
		SetTimer(0, False);
		MakeNoise(0.3);
		if ( NumWallHits > 1 )
			Destroy();

		if ( NumWallHits == 1 )
		{
			Spawn(class'UT_HeavyWallHitEffect',,,Location, rotator(HitNormal));




                  SetPhysics(PHYS_None);
                  Damage = 0;
                  Destroy();
			}
	}

	function SetUp()
	{
		local rotator RandRot;

		RandRot = Rotation;
		RandRot.Pitch += FRand() * 2000 - 1000;
		RandRot.Yaw += FRand() * 2000 - 1000;
		RandRot.Roll += FRand() * 2000 - 1000;
		Velocity = Vector(RandRot) * (Speed + (FRand() * 200 - 100));

		if (Instigator.HeadRegion.Zone.bWaterZone)
			bHitWater = True;
	}

	simulated function BeginState()
	{

		SetTimer(0.2, false);
		SetUp();

		if ( Level.NetMode != NM_DedicatedServer )
		{
			LoopAnim('Still');
			if ( Level.NetMode == NM_Standalone )
				SoundPitch = 400 + 50 * FRand();

		}
	}

	simulated function Timer()
	{
		bCanHitInstigator = true;
	}
}

defaultproperties
{
     speed=10000.000000
     MaxSpeed=10000.000000
     Damage=10.000000
     MomentumTransfer=15000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     Style=STY_Translucent
     Skin=Texture'AX.Icons.a5hdc'
     Mesh=LodMesh'AX.AXpellet'
     DrawScale=0.093000
     AmbientGlow=167
     bUnlit=True
     SoundRadius=12
     SoundVolume=255
     SoundPitch=200
     bBounce=True
}
