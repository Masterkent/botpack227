// The seed of a death fruit plant that creates more plants
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDeathfruitSeed extends Projectile;

var NaliMage NaliOwner;

auto state Flying
{
	function BeginState() {
		local rotator newrot;

		Super.PostBeginPlay();
		newrot.pitch = 0;
		newrot.yaw = rotation.yaw;
		setRotation(newrot);
		Velocity = Vector(RRand()) * speed;
		Velocity.z += 100+Rand(600);
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
	}

	function rotator RRand() {
		local rotator rr;
		rr.pitch = Rand(16384);
		rr.yaw = Rand(16384*4);
		rr.roll = Rand(16384*4);
		return rr;
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local int hitdamage;

		if ( Other == instigator )
			return;
		PlaySound(ImpactSound, SLOT_Interact, DrawScale/10);

		if ( !Other.IsA('NCDeathfruitSeed') && !Other.IsA('NCBioGel') && !Other.IsA('NCDeathfruit') && other != instigator )
		{
			Other.TakeDamage(damage,instigator,HitLocation,vect(0,0,0),'slimed');
			spawn(class'ut_GreenGelPuff',,,Location);
			//destroy();
		}
	}

	simulated function Landed(vector HitNormal)
	{
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BioMark',,,Location, rotator(HitNormal));
		Explode(location,HitNormal);
		PlaySound(ImpactSound, SLOT_Interact, DrawScale);
	}
	// always bounce
	function HitWall(vector HitNormal, actor wall) {
		local vector RealHitNormal;

		if (Rotator(HitNormal).Pitch > (16384-4096) && Rotator(HitNormal).Pitch < (16384+4096)) {
			Landed(HitNormal);
			return;
		}
		SetPhysics(PHYS_Falling);
		RealHitNormal = HitNormal;
		HitNormal = Normal(HitNormal + 0.5 * VRand());
		if ( (RealHitNormal Dot HitNormal) < 0 )
			HitNormal.Z *= -0.7;
		Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BioMark',,,Location, rotator(HitNormal));
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local ut_GreenGelPuff f;
		local NCDeathfruitVine dfv;
		local rotator newrot;
		local vector newloc;

		PlaySound(ImpactSound,SLOT_Interact);
		f = spawn(class'ut_GreenGelPuff',,,location);
		HurtRadius(Damage,Damage*0.75, 'slimed', 1000, HitLocation );
		newrot.pitch = rotation.pitch;
		newloc = location;
		newloc.z += 10;
		dfv = spawn(class'NCDeathfruitVine',,,newloc,newrot);
		dfv.NaliOwner = NaliOwner;
		destroy();
	}

Begin:
	LifeSpan=Default.LifeSpan;
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
     speed=250.000000
     MaxSpeed=1000.000000
     Damage=10.000000
     ImpactSound=Sound'Botpack.BioRifle.GelHit'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     Mesh=LodMesh'NaliChronicles.deathfruitseed'
     DrawScale=0.750000
     CollisionRadius=3.000000
     CollisionHeight=3.000000
     bBounce=True
     bFixedRotationDir=True
}
