// This enchantment that causes other creatures to spin about
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantWhirlwind extends NCPawnEnchant;

var float kickTime;

function PlayStartAnim() {
	LoopAnim('Spin',3);
}

function Tick(float DeltaTime) {
	local actor a;
	local vector dir, ndir;
	local vector addveloc;
	local float dist;
	local float damageScale;

	Super.Tick(DeltaTime);
	kickTime += DeltaTime;
	if (kickTime >= 0.2) {
		kickTime = 0;
		foreach VisibleCollidingActors( class 'Actor', a, 300, location ) {
			if (a != self) {
				dir = a.Location - location;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - a.CollisionRadius)/300);
				ndir = dir;
				ndir.X = dir.Y; // make sure this line is horiz. perp. to the dir
				ndir.Y = -dir.X;
				ndir.Z = -dir.Z;
				addveloc = (damageScale * 150000 * ndir)+(damageScale*100000*(-dir));
				addveloc -= (addveloc-a.velocity)*0.5;
				a.TakeDamage
				(
					damageScale * 3, Instigator,
					a.Location - 0.5 * (a.CollisionHeight + a.CollisionRadius) * dir,
					addveloc,'crushed'
				);
				if ((a != instigator) && (Nali(a) == none) && (NaliWarrior(a) == none) && (Pawn(a) != none) && (NaliMage(instigator) != none)) {
					NaliMage(instigator).GainExp(1,damageScale * 3);
				}
			}
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

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'UnrealShare.Tentacle.strike2tn'
     bPawnless=True
     Physics=PHYS_Falling
     LifeSpan=20.000000
     AmbientSound=Sound'NaliChronicles.SFX.nctwister'
     Mesh=LodMesh'NaliChronicles.twister'
     DrawScale=3.000000
     SoundRadius=64
     SoundVolume=190
     CollisionRadius=30.000000
     CollisionHeight=80.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     Mass=1.000000
}
