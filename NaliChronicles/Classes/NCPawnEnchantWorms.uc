// This enchantment that makes worms attack a creature
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantWorms extends NCPawnEnchant;

var bool bPlayStarted;
var NCEarthworm Worms[5];
var bool bWormsInited;

function loseWorm(NCEarthworm wormToLose) {

}

function Destroyed() {
	local int i;

	while (i < 5) {
		if (Worms[i] != none)
			Worms[i].destroy();
		i++;
	}
	Super.Destroyed();
}

function AnimEnd() {
	local int i, j, k;
	local vector X, Y, Z;

	if (!bWormsInited) {
		bWormsInited = True;
		GetAxes(rotation,x,y,z);
		i = 0;
		while (i < 4) {
			Worms[i] = Spawn(Class'NaliChronicles.NCEarthworm');
			if (i == 1 || i == 2)
				j = 1;
			else
				j = 0;
			if (i > 1)
				k = 1;
			else
				k = 0;
			Worms[i].Offset.X = EnchantmentTarget.CollisionRadius*0.8 + 1.6*(EnchantmentTarget.CollisionRadius * -j);
			Worms[i].Offset.Y = EnchantmentTarget.CollisionRadius*0.8 + 1.6*(EnchantmentTarget.CollisionRadius * -k);
			Worms[i].Offset.Z = 10*DrawScale;
			Worms[i].DrawScale = EnchantmentTarget.CollisionRadius/10;
			Worms[i].enchantment = self;
			Worms[i].Target = EnchantmentTarget;
			Worms[i].NaliOwner = NaliMage(instigator);
			i++;
		}
	}
	if (EnchantmentTarget.velocity == vect(0,0,0))
		PlayAnim('Still');
	else if ((EnchantmentTarget.physics == PHYS_Falling) || (EnchantmentTarget.physics == PHYS_Flying) || (EnchantmentTarget.physics == PHYS_Swimming))
		PlayAnim('Fly');
	else
		PlayAnim('Walk');
}

function Resupply(float timeheld) {
	local int i;
	local float time;

	time = timeheld;
	while (i < 4) {
		if (time >= 1) { // restore a worm
			if ((Worms[i].health <= 0) || (Worms[i].charge <= 0)) {
				Worms[i].health = 20;
				Worms[i].charge = 10;
				Worms[i].GotoState('');
				Worms[i].PlayAnim('Grow');
				time -= 1;
			}
		}
		i++;
	}
	i = 0;
	while (i < 4) {
		if (time >= 0) { // restore a worm
			if (Worms[i].charge < 10) {
				if (time >= (10-Worms[i].charge)/10) {
					Worms[i].charge = 10;
					time -= (10-Worms[i].charge)/10;
				}
				else {
					Worms[i].charge += time*10;
					time = 0;
				}
			}
			if (Worms[i].health < 20) {
				if (time >= (20-Worms[i].health)/20) {
					Worms[i].health = 10;
					time -= (20-Worms[i].health)/20;
				}
				else {
					Worms[i].health += time*20;
					time = 0;
				}
			}
		}
		i++;
	}
}

function CalculateFade() {
	if (((MaxLifeSpan-LifeSpan) >= FadeTime) && (LifeSpan >= FadeTime)) {
		if (!bPlayStarted) {
			bPlayStarted = true;
			PlayAnim('Grow');
		}
		Style=STY_Normal;
	}
	else {
		Style=STY_Translucent;
		if ((MaxLifeSpan-LifeSpan) >= FadeTime) {
			ScaleGlow = LifeSpan/FadeTime;
		}
		else {
			ScaleGlow = FadeTime/(MaxLifeSpan-LifeSpan);
		}
	}
}

function FollowTarget(float DeltaTime) {
	local vector newlocation;

	DrawScale = EnchantmentTarget.CollisionRadius/10;
	newlocation = EnchantmentTarget.location;
	newlocation.Z -= EnchantmentTarget.CollisionHeight*0.9;

	setLocation(newlocation);
	setRotation(EnchantmentTarget.rotation);
}

function Tick(float DeltaTime) {
	local int i;

	while (i < 4) {
		if (Worms[i] != none) {
			Worms[i].Style = Style;
			Worms[i].ScaleGlow = ScaleGlow;
		}
		i++;
	}
	Super.Tick(DeltaTime);
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'UnrealShare.Tentacle.strike2tn'
     LifeSpan=10.000000
     Mesh=LodMesh'NaliChronicles.mudeffect'
}
