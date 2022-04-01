// A shield of weed and fish that lash out at any who come near
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSeashield extends NCProtectEffect;

function GiveTo(Pawn Other)
{
	Super.GiveTo(Other);
	SetPhysics(PHYS_Trailer);
	goToState('Active');
}

function vector startloc(rotator in) {
	local vector newloc;
	local rotator newrot;

	newloc = owner.location;
	newloc.z += 5+Rand(15);
	newrot.roll = in.roll - 2000 + Rand(4000);
	newrot.yaw = in.yaw - 2000 + Rand(4000);
	newloc = newloc + ((owner.collisionradius*0.25)*vector(newrot));
	return newloc;
}

state Active {
	function intercept() {
		local pawn attacker;
		local float damageScale, dist;
		local NCFlyFish fishy;
		local vector dir, newloc;

		if (owner != none) {
			foreach VisibleCollidingActors( class 'Pawn', attacker, fMax(Owner.CollisionHeight,Owner.CollisionRadius)*3, owner.location )
			{
				if( attacker != pawn(owner) && attacker.attitudeToPlayer < ATTITUDE_Ignore )
				{
					dir = attacker.Location - owner.location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;
					if (FRand() > 0.5) {
						fishy = Spawn(Class'Nalichronicles.ncflyfish',,,startloc(rotator(dir)),rotator(dir));
						fishy.NaliOwner = NaliMage(Owner);
						fishy.bNoHitInst = true;
						fishy.damage *= 2;
					}
					else {
						newloc = startloc(rotator(dir));
						Spawn(Class'NaliChronicles.ncseashieldarm',owner,,newloc,rotator(attacker.location-newloc));
					}
				}
			}
		}
	}

	Begin:
	sleep(0.2);
	intercept();
	goTo('Begin');
}

defaultproperties
{
     timeBeforeDecay=120.000000
     decayTimePerArmor=0.500000
     newHandSkin=Texture'NaliChronicles.Skins.handskinsea'
     NewSkin=Texture'NaliChronicles.Skins.NaliSeaShield'
     Charge=150
     ArmorAbsorption=100
     AbsorptionPriority=11
     Icon=Texture'NaliChronicles.Icons.WaterSeashieldBarIcon'
}
