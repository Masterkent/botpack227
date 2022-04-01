// This enchantment creates storm clouds and whirwinds that kill everything beneath them
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantStorm extends NCPawnEnchant;

function PostBeginPlay() {
	Super.PostBeginPlay();
	setTimer(0.1,true);
	DrawScale = 30.0+(20*Frand());
	SetCollisionSize(DrawScale*6,DrawScale*4);
}

function Timer() {
	local int i;
	local vector newloc;
	local rotator newrot;
	local NCLightning light;
	local NCRainDrop rain;

	while (i < DrawScale/8) {
		newloc = location;
		newloc.x += (CollisionRadius)-Rand(CollisionRadius*2);
		newloc.y += (CollisionRadius)-Rand(CollisionRadius*2);
		rain = spawn(class'NCRainDrop',,,newloc);
		rain.NaliOwner = NaliMage(instigator);
		rain.damage *= 2;
		i++;
	}
	if (FRand() < 0.04) {
		newrot = rot(49152,0,0);
		newloc = location;
		newloc.x += (CollisionRadius)-Rand(CollisionRadius*2);
		newloc.y += (CollisionRadius)-Rand(CollisionRadius*2);
		light = Spawn(Class'NaliChronicles.NCLightning',,,newloc,newrot);
		light.flyTime = 20;
		light.damage = 100 + (FRand()*50);
		light.drawScale = 0.5 + (light.damage/80);
		light.NaliOwner = NaliMage(instigator);
		light.book = 2;
		light.gotoState('Flying');
		light.instigator = none;
	}
}

function PlayStartAnim() {
	local vector StartTrace, EndTrace, newloc, randloc;
	local NCSkyPoint sp;
	local bool bGotLoc;

	foreach allactors(Class'NCSkyPoint',sp) {
		if (sqrt((sp.location.x-location.x)^2 + (sp.location.y-location.y)^2) < sp.CollisionRadius) {
			StartTrace = location;
			EndTrace = location;
			EndTrace.z = sp.location.z;
			if (FastTrace(EndTrace,StartTrace)) {
				newloc = location;
				newloc.z = sp.location.z;
				if (abs(location.z - sp.location.z) > 4096 && sp.location.z > location.z) // don't go up more than 4096 units
					newloc.z = location.z + 4096;
				bGotLoc = true;
				break;
			}
		}
	}

	if (bGotLoc) {
		setLocation(newloc);
	}
	else {
		destroy();
	}
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'NaliChronicles.SFX.NCLightningSound'
     bPawnless=True
     LifeSpan=15.000000
     AmbientSound=Sound'NaliChronicles.SFX.NCRainSound'
     Mesh=LodMesh'NaliChronicles.nccloud'
     DrawScale=10.000000
     SoundRadius=160
     SoundVolume=190
     CollisionRadius=30.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
}
