// This enchantment creates a large meteor shower
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantMeteorshower extends NCPawnEnchant;

function PostBeginPlay() {
	Super.PostBeginPlay();
	setTimer(0.2,true);
}

function Timer() {
	local vector newloc;
	local rotator newrot;
	local NCMeteor meteor;

	newrot = rotation;
	newrot.pitch = 49152-Rand(4000);
	newrot.roll += 8000-Rand(4000);
	newrot.yaw += 8000-Rand(4000);
	newloc = location;
	newloc.x += (CollisionRadius)-Rand(CollisionRadius*2);
	newloc.y += (CollisionRadius)-Rand(CollisionRadius*2);
	meteor = Spawn(Class'NaliChronicles.NCMeteor',,,newloc,newrot);
	meteor.damage = 200 + (FRand()*100);
	meteor.speed /= 3;
	meteor.drawScale += meteor.damage/360;
	meteor.NaliOwner = NaliMage(instigator);
	meteor.book = 3;
	meteor.gotoState('Flying');
	meteor.bKillInst = true;
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
     bPawnless=True
     LifeSpan=7.000000
     CollisionRadius=100.000000
     CollisionHeight=10.000000
}
