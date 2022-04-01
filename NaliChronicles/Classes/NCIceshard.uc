// Ice shard
// Code by Sergey 'Eater' Levin, 2001

class NCIceshard extends NCMagicProj;

var float DelayTime;

state Flying
{
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;

		if (Other != instigator && NCIceshard(Other) == none)
		{
			DealOutExp(Other);
			if ( Role == ROLE_Authority )
			{
				hitDir = Normal(Velocity);
				if ( FRand() < 0.2 )
					hitDir *= 5;
				Other.TakeDamage(damage, instigator,HitLocation,
					(MomentumTransfer * hitDir), 'shot');
			}
			Destroy();
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Super.HitWall(HitNormal, Wall);
		if (FRand()<0.3)
			PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
		else
			PlaySound(MiscSound, SLOT_Misc, 0.6,,,1.0);

		MakeNoise(0.3);
	  	SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		RemoteRole = ROLE_None;
		Mesh = mesh'Burst';
		SetRotation( RotRand() );
		PlayAnim   ( 'Explo', 0.9 );
	}

	simulated function Timer()
	{
		local bubble1 b;
		if (Level.NetMode!=NM_DedicatedServer)
		{
	 		b=spawn(class'Bubble1');
 			b.DrawScale= 0.1 + FRand()*0.2;
 			b.SetLocation(Location+FRand()*vect(2,0,0)+FRand()*Vect(0,2,0)+FRand()*Vect(0,0,2));
 			b.buoyancy = b.mass+(FRand()*0.4+0.1);
 		}
		DelayTime+=FRand()*0.1+0.1;
		SetTimer(DelayTime,False);
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			Velocity=0.7*Velocity;
			DelayTime=0.03;
			SetTimer(DelayTime,False);
		}
	}

	function BeginState()
	{
		local rotator RandRot;

		Super.BeginState();
		Velocity = Vector(Rotation) * speed;
		if( Region.zone.bWaterZone )
			Velocity=0.7*Velocity;
	}
Begin:
	LifeSpan=Default.LifeSpan;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
     speed=1600.000000
     Damage=3.000000
     MomentumTransfer=4000
     MyDamageType=shot
     ImpactSound=Sound'UnrealShare.Stinger.Ricochet'
     MiscSound=Sound'UnrealShare.Razorjack.BladeHit'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     AnimRate=1.000000
     Mesh=LodMesh'UnrealShare.TarydiumProjectile'
     DrawScale=0.500000
     AmbientGlow=215
     bUnlit=True
     bNoSmooth=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=24
     LightHue=152
     LightSaturation=32
     LightRadius=5
     LightPeriod=50
     bBounce=True
     Mass=2.000000
}
