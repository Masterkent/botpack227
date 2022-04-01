// If you're under this one, you're DEAD
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantSkies extends NCPawnEnchant;

var float charge;

function Tick(float DeltaTime) {
	if (bTargetReceived) {
		bTargetReceived = false;
		launchLightning();
		charge=lifeSpan;
		lifeSpan=0.000000;
	}
}

function launchLightning() {
	local int i;
	local rotator newrot;
	local vector newloc, hitloc, hitnorm;
	local NCLightning light;
	local NCBlastEffect be;

	while (i < LifeSpan*15.0) {
		newrot = rot(49152,0,0);
		newrot.pitch += Rand(8000)-4000;
		newrot.yaw += Rand(65536);
		light = Spawn(Class'NaliChronicles.NCLightning',,,location,newrot);
		light.flyTime = 20;
		light.damage = 100 + (FRand()*50);
		light.drawScale = 0.5 + (light.damage/80);
		light.NaliOwner = NaliMage(instigator);
		light.book = 2;
		light.gotoState('Flying');
		light.instigator = none;
		i++;
	}
	newloc = location;
	newloc.z -= 1000000;
	Trace(hitloc,hitnorm,newloc,location,false);
	be = Spawn(Class'NCBlastEffect',,,location);
	be.numpuffs = abs(hitloc.z-location.z)/50;
	be.maxlifespan = (abs(hitloc.z-location.z)/50)*0.05+1;
	be.enchant = self;
	be.launch();
}

function blast() {
	local vector newloc, hitloc, hitnorm;
	local NCShockWave sw;

	newloc = location;
	newloc.z -= 1000000;
	Trace(hitloc,hitnorm,newloc,location,false);

	Spawn(Class'Botpack.NuclearMark',self,,hitloc, rotator(HitNorm));
	ExpHurtRadius(2000*charge,300.0*charge, 'RedeemerDeath', 100000*charge, HitLoc );
 	sw = spawn(class'NCShockWave',,,HitLoc+HitNorm*16);
	sw.NaliOwner = NaliMage(instigator);
	sw.charge = charge;

	destroy();
}

function DealOutExp(actor Other, int gain) {
	if ((Other != instigator) && (Nali(Other) == none) && (NaliWarrior(Other) == none) && (Pawn(Other) != none)) {
		NaliMage(instigator).GainExp(5,gain);
	}
}

final function ExpHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if (Pawn(Victims) != none && Pawn(victims).health > 0)
				DealOutExp(Victims,fMin(Pawn(Victims).health,damageScale * DamageAmount));
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
		}
	}
	bHurtEntry = false;
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
     LifeSpan=0.125000
     CollisionRadius=100.000000
     CollisionHeight=10.000000
}
