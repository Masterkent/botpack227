// This enchantment creates a rain cloud that damages the target
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantRaincloud extends NCPawnEnchant;

function PostBeginPlay() {
	Super.PostBeginPlay();
	setTimer(0.1,true);
}

function Timer() {
	local int i;
	local vector newloc;
	local rotator newrot;
	local NCLightning light;
	local NCRainDrop rain;

	while (i < 2) {
		newloc = location;
		newloc.x += 30-Rand(60);
		newloc.y += 30-Rand(60);
		rain = spawn(class'NCRainDrop',,,newloc);
		rain.NaliOwner = NaliMage(instigator);
		i++;
	}
	if (FRand() < 0.02) {
		newrot = rot(49152,0,0);
		newloc = location;
		newloc.x += 30-Rand(60);
		newloc.y += 30-Rand(60);
		light = Spawn(Class'NaliChronicles.NCLightning',,,newloc,newrot);
		light.bGuiding = true;
		light.damage = 10 + (FRand()*10);
		light.drawScale = 0.5 + ((light.damage-2)/21);
		light.NaliOwner = NaliMage(instigator);
		light.book = 2;
		light.gotoState('Flying');
		light.Target = EnchantmentTarget;
	}
}

function FollowTarget(float DeltaTime) {
	local vector newlocation;

	newlocation = EnchantmentTarget.location;
	newlocation.Z += EnchantmentTarget.CollisionHeight+25;

	setLocation(newlocation);
	setRotation(EnchantmentTarget.rotation);
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'NaliChronicles.SFX.NCLightningSound'
     LifeSpan=4.000000
     AmbientSound=Sound'NaliChronicles.SFX.NCRainSound'
     Mesh=LodMesh'NaliChronicles.nccloud'
     DrawScale=5.000000
     SoundRadius=64
     SoundVolume=190
}
