// This enchantment that creates a lake with deadly creatures that bite all who pass by
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantLake extends NCPawnEnchant;

var actor targets[32];
var NCLakeSquid squiddy;
var int tc;

function PlayStartAnim() {
	LoopAnim('Swim');
	SetTimer(0.5,true);
}

/*function AnimEnd() {
	if (FRand() > 0.5)
		PlayAnim('Swim');
	else
		PlayAnim('Jump');
}*/

function Touch(actor Other) { // someone/something stepped/fell into the lake, make noise
	local int i;

	if (NCFlyFish(Other) != none) return;
	PlaySound(Sound'UnrealShare.Generic.DSplash',SLOT_Misc,2*FClamp(0.000025 * Other.Mass * (300 - 0.5 * FMax(-500, Other.Velocity.Z)), 1.0, 4.0 ));

	while (i < 32) {
		if (targets[i] == other)
			i = 255;
		i++;
	}
	if (i != 256) {
		targets[tc] = other;
		tc++;
		if (tc >= 32) tc = 0;
	}
	if ((Other.bCollideActors == true && Other.bBlockActors == true) || (Pawn(Other) != none)) {
		if (squiddy == none) {
			squiddy = Spawn(Class'NCLakeSquid',,,location);
			squiddy.target = other;
			squiddy.NaliOwner = NaliMage(instigator);
			squiddy.lake = self;
		}
	}
}

function Timer() {
	local int i;
	local vector newloc;
	local NCFlyFish ff;

	while (i < 32) {
		if (targets[i] != none) {
			newloc = targets[i].location;
			newloc.z = location.z;
			if ((VSize(newloc-location) > CollisionRadius) ||
			(Abs(targets[i].location.z - location.z) > targets[i].CollisionHeight+CollisionHeight)) {
				targets[i] = none;
			}
			else {
				// shoot the supa-fly fish :)
				newloc = location;
				newloc.x += CollisionRadius*0.8-(FRand()*(CollisionRadius*1.6));
				newloc.y += CollisionRadius*0.8-(FRand()*(CollisionRadius*1.6));
				ff = Spawn(Class'NCFlyFish',,,newloc,rotator(targets[i].location-newloc));
				ff.NaliOwner = NaliMage(instigator);
			}
		}
		i++;
	}
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     bPawnless=True
     Physics=PHYS_Falling
     LifeSpan=30.000000
     Mesh=LodMesh'NaliChronicles.lakemodel'
     DrawScale=3.000000
     CollisionRadius=40.000000
     CollisionHeight=10.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     Mass=1.000000
}
