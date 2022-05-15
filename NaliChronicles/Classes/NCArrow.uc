// Arrow fired by Nali quadbow - parts taken from Unreal
// Code by Sergey 'Eater' Levin, 2002

class NCArrow extends Projectile;

function PostBeginPlay() {
	local rotator RandRot;

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;      // velocity
	RandRot.Pitch = FRand() * 200 - 100;
	RandRot.Yaw = FRand() * 200 - 100;
	RandRot.Roll = FRand() * 200 - 100;
	Velocity = Velocity >> RandRot;
	PlaySound(SpawnSound, SLOT_Misc, 2.0);
}

function ProcessTouch( Actor Other, Vector HitLocation ) {
	local int hitdamage;

	if (Arrow(Other) == none && Other != instigator) {
		if ( Role == ROLE_Authority )
			Other.TakeDamage(damage, instigator,HitLocation,
				(MomentumTransfer * Normal(Velocity)), 'shot');
		Destroy();
	}
}

event HitWall( vector HitNormal, actor Wall )
{
	Super.HitWall(HitNormal, Wall);
	PlaySound(ImpactSound, SLOT_Misc, 0.5);
	//mesh = mesh'Burst';
	//Skin = Texture'JArrow1';
	Spawn(Class'NaliChronicles.NCNaliArrow',,,location,rotation);
	Destroy();
	/*SetPhysics(PHYS_None);
	SetCollision(false,false,false);
	LifeSpan = 5.0;
	MakeNoise(0.3);*/
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

//simulated function AnimEnd()
//{
//	Destroy();
//}

defaultproperties
{
     speed=1500.000000
     Damage=20.000000
     MomentumTransfer=2000
     SpawnSound=Sound'UnrealShare.General.ArrowSpawn'
     ImpactSound=Sound'UnrealShare.Razorjack.BladeHit'
     RemoteRole=ROLE_SimulatedProxy
     Mesh=LodMesh'UnrealShare.ArrowM'
     bNetTemporary=False
}
