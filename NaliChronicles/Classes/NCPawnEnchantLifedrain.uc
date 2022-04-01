// This enchantment drains health from target and gives it to player
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantLifedrain extends NCPawnEnchant;

function PostBeginPlay() {
	Super.PostBeginPlay();
	setTimer(1.5,true);
}

function Timer() {
	local int oldh;
	local int ah;
	local NCLifeProj lp;
	local vector newloc;

	if (EnchantmentTarget != none) {
		oldh = EnchantmentTarget.health;
		EnchantmentTarget.TakeDamage(15,instigator,location,vect(0,0,0),'burned');
		ah = oldh-EnchantmentTarget.health;
		NaliMage(instigator).GainExp(5,15);
		if (ah > 0) {
			newloc = instigator.location;
			newloc.z += instigator.CollisionHeight/2;
			lp = Spawn(Class'NCLifeProj',,,location,rotator(newloc-location));
			lp.damage = ah;
			lp.NaliOwner = NaliMage(instigator);
		}
	}
}

function CalculateFade() {
	if (((MaxLifeSpan-LifeSpan) >= FadeTime) && (LifeSpan >= FadeTime)) {
		Style=STY_Translucent;
		ScaleGlow = 1.0;
	}
	else {
		Style=STY_Translucent;
		if ((MaxLifeSpan-LifeSpan) >= FadeTime)
			ScaleGlow = LifeSpan/FadeTime;
		else
			ScaleGlow = FadeTime/(MaxLifeSpan-LifeSpan);
	}
}

function FollowTarget(float DeltaTime) {
	setLocation(EnchantmentTarget.location);
	//setRotation(EnchantmentTarget.rotation);
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'NaliChronicles.SFX.ldrains'
     Physics=PHYS_Rotating
     LifeSpan=8.000000
     AmbientSound=Sound'NaliChronicles.SFX.ldrainl'
     Texture=Texture'NaliChronicles.Skins.skull_a00'
     Mesh=LodMesh'NaliChronicles.CloudFrame'
     DrawScale=0.200000
     bUnlit=True
     bParticles=True
     SoundRadius=64
     SoundVolume=190
     bFixedRotationDir=True
     RotationRate=(Yaw=20000)
     DesiredRotation=(Yaw=30000)
}
