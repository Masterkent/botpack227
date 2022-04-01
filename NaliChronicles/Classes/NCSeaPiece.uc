// Some sea related object, used by the Sea Blast projectile
// Code by Sergey 'Eater' Levin, 2001

class NCSeaPiece extends Projectile;

function PostBeginPlay()
{
	local float decision;
	local rotator newRotation;

	Super.PostBeginPlay();
	newRotation.Pitch = Rand(65536);
	newRotation.Yaw = Rand(65536);
	newRotation.Roll = 0;
	setRotation(newRotation);
	Velocity = Vector(Rotation) * (0.8 + (0.3 * FRand())) * speed;
	DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
	DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;
	DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
	decision = FRand();

	// select a random mesh here

	if (decision<0.2)
		Skin = Texture'UnrealShare.Skins.JFish23';
	else if (decision<0.4)
		Skin = Texture'UnrealShare.Skins.JFish25';
	else if (decision <0.8)
		Mesh = LodMesh'UnrealShare.SeaWeedM';
	else
		Mesh = LodMesh'Botpack.BioGelm';

	if (decision >= 0.4 && decision < 0.8)
		DrawScale = 0.4;
	if (decision >= 0.8) {
		Texture=Texture'UnrealShare.Skin.JBurst1';
     		bMeshEnviroMap=True;
	}

	if (FRand() < 0.5)
		RotationRate.Pitch = Rand(180000);
	if ( (RotationRate.Pitch == 0) || (FRand() < 0.8) )
		RotationRate.Roll = Max(0, 50000 + Rand(200000) - RotationRate.Pitch);
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		PlaySound(ImpactSound, SLOT_Interact);
		Other.TakeDamage(5,instigator,hitlocation,vector(rotation*100),'drowned');
		Destroy();
	}

	simulated function Landed(vector HitNormal)
	{
		HitWall(HitNormal, None);
	}

	function MakeSound()
	{
		PlaySound(ImpactSound, SLOT_Misc);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local vector RealHitNormal;

		MakeSound();
		SetPhysics(PHYS_None);
		GotoState('Sitting');
	}

Begin:
	SetPhysics(PHYS_Falling);
}

State Sitting
{
Begin:
	SetPhysics(PHYS_None);
	Sleep(10.0);
	Destroy();
}

defaultproperties
{
     speed=350.000000
     MaxSpeed=500.000000
     ImpactSound=Sound'UnrealI.Blob.BlobDeath'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     Mesh=LodMesh'UnrealShare.AmbientFish'
     bBounce=True
     bFixedRotationDir=True
}
