// This enchantment sets creatures on fire, also scares them
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantBurn extends NCPawnEnchant;

var float hurttime;

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
	local vector newlocation;

	newlocation = EnchantmentTarget.location;
	newlocation.z += EnchantmentTarget.CollisionHeight;
	newlocation.x += EnchantmentTarget.CollisionRadius-(EnchantmentTarget.CollisionRadius*2*Frand());
	newlocation.y += EnchantmentTarget.CollisionRadius-(EnchantmentTarget.CollisionRadius*2*Frand());
	setLocation(newlocation);
	setRotation(EnchantmentTarget.rotation);
	hurttime += deltatime;
	if (hurttime >= 0.33) {
		hurttime -= 0.33;
		spawn(class'ut_spritesmokepuff',,,location,rotation);
		EnchantmentTarget.TakeDamage(2,instigator,location,vect(0,0,0),'burned');
		NaliMage(instigator).GainExp(3,2);
		// make monsters get scared of being "lit up" :)
		if (ScriptedPawn(EnchantmentTarget) != none && !ScriptedPawn(EnchantmentTarget).isInState('Retreating')
			&& !ScriptedPawn(EnchantmentTarget).isInState('Dying') &&
			ScriptedPawn(EnchantmentTarget).health < ScriptedPawn(EnchantmentTarget).default.health*0.4 && FRand() > 0.75)
			ScriptedPawn(EnchantmentTarget).goToState('Retreating');
	}
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     LifeSpan=10.000000
     AmbientSound=Sound'UnrealShare.Pickups.flarel1'
     Mesh=LodMesh'UnrealShare.FlameM'
     DrawScale=0.500000
     SoundRadius=24
     SoundVolume=80
}
