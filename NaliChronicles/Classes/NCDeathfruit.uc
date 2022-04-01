// The fruit of death - plants more death fruit plants
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDeathfruit extends NCMagicProj;

state Flying
{
	function BeginState() {
		Super.PostBeginPlay();
		Velocity = Vector(Rotation) * speed;
		Velocity.z += 120;
		DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
		DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
		if ( (RotationRate.Pitch == 0) || (FRand() < 0.8) )
			RotationRate.Roll = Max(0, 50000 + Rand(200000) - RotationRate.Pitch);
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local int hitdamage;

		if ( Other == instigator )
			return;
		if ( !Other.IsA('NCDeathfruit') && other != instigator )
		{
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	simulated function Landed(vector HitNormal)
	{
		HitWall(HitNormal, None);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BioMark',,,Location, rotator(HitNormal));
		Explode(location,HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local ut_GreenGelPuff f;
		local int i;
		local int seedPower;
		local NCDeathfruitseed seed;
		local NCBioGel gel;
		local int slimePower;
		local rotator RandRot;

		PlaySound(ImpactSound, SLOT_Interact, DrawScale);
		while (i < DrawScale*3) {
			f = spawn(class'ut_GreenGelPuff',,,RVect(Location + HitNormal*8,DrawScale*20));
			f.DrawScale = 2;
			i++;
		}
		i = 0;
		seedPower = Damage*0.3;
		slimePower = Damage*0.2;
		Damage -= (seedPower+slimePower);
		while (seedPower >= 10) {
			seedPower -= 10;
			seed = spawn(class'NCDeathfruitSeed',,,location+5*Hitnormal); // spawn some seed
			seed.NaliOwner = NaliOwner;
		}
		while (slimePower >= 20) {
			slimePower -= 20;
			RandRot.Pitch = FRand() * 8192 + 8192;
			RandRot.Yaw = FRand() * (16384*4);
			RandRot.Roll = FRand() * (16384*4);
			gel = spawn(class'NCBioGel',,,location+10*Hitnormal,RandRot);
			gel.NaliOwner = NaliOwner;
		}
		Damage += seedPower;
		ExpHurtRadius(Damage,Damage*0.75, 'slimed', MomentumTransfer, HitLocation );
		destroy();
	}

	function vector RVect(vector inVect, float offSet) {
		if (FRand() > 0.5)
			inVect.X += FRand()*offSet;
		else
			inVect.X -= FRand()*offSet;
		if (FRand() > 0.5)
			inVect.Y += FRand()*offSet;
		else
			inVect.Y -= FRand()*offSet;
		if (FRand() > 0.5)
			inVect.X += FRand()*offSet;
		else
			inVect.X -= FRand()*offSet;
		return inVect;
	}

Begin:
	LifeSpan=Default.LifeSpan;
	SetCollisionSize(10*DrawScale,10*DrawScale);
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
     speed=850.000000
     MaxSpeed=1000.000000
     ImpactSound=Sound'Botpack.BioRifle.GelHit'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     Style=STY_Masked
     Mesh=LodMesh'NaliChronicles.deathfruitproj'
     DrawScale=0.250000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bBounce=True
     bFixedRotationDir=True
}
