// This enchantment slows down creatures
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantSlow extends NCPawnEnchant;

var bool bPlayStarted;
var bool bOldReg;
var float OldGS, OldAS, OldWS, OldWalk;

function AnimEnd() {
	if (EnchantmentTarget.velocity == vect(0,0,0))
		PlayAnim('Still');
	else if ((EnchantmentTarget.physics == PHYS_Falling) || (EnchantmentTarget.physics == PHYS_Flying) || (EnchantmentTarget.physics == PHYS_Swimming))
		PlayAnim('Fly');
	else
		PlayAnim('Walk');
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
	local float slowdownpercent;
	local NCPawnEnchantFreeze fe;

	if (!bOldReg) {
		bOldReg = true;
		OldGS = EnchantmentTarget.GroundSpeed;
		OldAS = EnchantmentTarget.AirSpeed;
		OldWS = EnchantmentTarget.WaterSpeed;
		if (ScriptedPawn(EnchantmentTarget) != none)
			OldWalk = ScriptedPawn(EnchantmentTarget).WalkingSpeed;
		foreach allactors(Class'NCPawnEnchantFreeze',fe) {
			if (fe.EnchantmentTarget == EnchantmentTarget)
				fe.sle = self;
		}
	}
	DrawScale = EnchantmentTarget.CollisionRadius/10;
	newlocation = EnchantmentTarget.location;
	newlocation.Z -= EnchantmentTarget.CollisionHeight*0.9;
	if (LifeSpan < FadeTime)
		slowdownpercent = 1.0;
	else {
		slowdownpercent = 0.6;
		slowdownpercent -= (LifeSpan/Default.LifeSpan)/10;
		if (slowdownpercent < 0.3)
			slowdownpercent = 0.3;
	}
	EnchantmentTarget.GroundSpeed = OldGS*slowdownpercent;
	EnchantmentTarget.AirSpeed = OldAS*slowdownpercent;
	EnchantmentTarget.WaterSpeed = OldWS*slowdownpercent;
	if (ScriptedPawn(EnchantmentTarget) != none)
		ScriptedPawn(EnchantmentTarget).WalkingSpeed = OldWalk*slowdownpercent;

	setLocation(newlocation);
	setRotation(EnchantmentTarget.rotation);
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'UnrealShare.Tentacle.strike2tn'
     LifeSpan=40.000000
     Mesh=LodMesh'NaliChronicles.sloweffect'
}
