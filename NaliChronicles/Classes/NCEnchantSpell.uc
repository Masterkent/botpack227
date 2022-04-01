// The base of all pawn "enchantments"
// Code by Sergey 'Eater' Levin, 2001

class NCEnchantSpell extends NCSpell
	abstract;

var() float range; // how far away can things be enchanted
var() float faildamage; // damage dealt in case of failure per each second spell was held
var() class<NCEnchantEffect> EnchantEffect;
var() class<NCPawnEnchant> Enchantment;
var() float mintime;
var() bool bTargeted;
var() bool bNoExp;
var() bool bSemiTargeted;

function bool ScanForAccidents(float timeheld) { // depending on stress, this function can cause freak accidents
	local float f;
	local rotator newrotation;

	f = (stress/9) - GetMySkill()/10;
	if (FRand() < f) {
		newrotation = Pawn(Owner).viewrotation;
		newrotation.yaw += 32768;
		newrotation.pitch += 32768;
		Owner.TakeDamage(faildamage*timeheld,pawn(owner),owner.location,vect(0,0,0),'zapped');
		return false;
	}

	return true;
}

function vector GetEffectLocation() {
	local vector effectlocation, X, Y, Z;

	effectlocation = owner.location;
	GetAxes(pawn(owner).viewrotation,X,Y,Z);
	effectlocation += CalcDrawOffset();
	effectlocation += -17*Z + 40*X;

	return effectlocation;
}

function actor FindTarget() {
	local pawn possibletarg;
	local vector LookLocation;
	local vector diff, X, Y, Z;
	local pawn candidates[64];
	local float diffs[64];
	local int i;
	local pawn best;
	local float bestdiff;
	local pawn candidate;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);	// if the player is already aiming at a pawn, then that's who we'll hit
	StartTrace = GetEffectLocation();
	EndTrace = StartTrace;
	X = vector(PawnOwner.ViewRotation);
	EndTrace += (range * X);
	candidate = Pawn(PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace));
	if ((candidate != none) && (FlockPawn(candidate) == none))
		return candidate;

	GetAxes(playerpawn(owner).viewrotation,X,Y,Z);
	LookLocation = owner.location;
	LookLocation.Z += PawnOwner.eyeheight;
	foreach VisibleCollidingActors(Class'pawn', possibletarg, range, LookLocation, true) {
		if ((possibletarg != owner) && (possibletarg.health > 0) && (FlockPawn(possibletarg) == none)) { // target must be an enemy and alive
			diff = possibletarg.location - LookLocation;
			if ( ( ( (diff Dot X)/VSize(diff) ) > 0.25 ) && ( FastTrace(possibletarg.location,LookLocation) ) ) { // has to be within the inner half of the screen
				//Pawn(Owner).ClientMessage(string( (diff Dot X)/VSize(diff) ));
				candidates[i] = possibletarg;
				diffs[i] = ( (diff Dot X)/VSize(diff) );
				i++;
			}
		}
	}
	i = 0;
	best = candidates[0];
	bestdiff = diffs[0];
	if (best == none)
		return none;
	while (i < 64) {
		if ((diffs[i] > bestdiff) && (candidates[i] != none)) {
			best = candidates[i];
			bestdiff = diffs[i];
		}
		i++;
	}
	return best;
}

function actor forwardTrace(out vector outLoc) {
	local vector outNorm;
	local vector startLoc;
	local actor hitAct;
	local vector X,Y,Z;

	GetAxes(Pawn(owner).viewrotation,X,Y,Z);
	startLoc = GetEffectLocation();
	hitAct = Trace(outLoc,outNorm,startLoc+X*range,startLoc,True);
	if (hitAct == none) {
		hitAct = Level;
		outLoc = startLoc+X*range;
	}
	else {
		if (hitAct != level && bSemiTargeted)
			outLoc = hitAct.location;
	}
	return hitAct;
}

function FinishCasting(float timeheld) {
	local actor EffectTarg;
	local vector EffectLoc;
	local NCEnchantEffect EEffect;
	local NCPawnEnchant Enchant;
	local bool OtherFound;
	local NCPawnEnchant E;
	local rotator newrot;

	Super.FinishCasting(timeheld);
	if (ScanForAccidents(timeheld) && (timeheld >= mintime)) {
		if (bTargeted) {
			EffectTarg = FindTarget();
			if (EffectTarg != none) {
				EEffect = Spawn(EnchantEffect,,,GetEffectLocation(),rotator(owner.location - EffectTarg.location));
				EEffect.bHasTarg = true;
			}
			else {
				EEffect = Spawn(EnchantEffect,,,GetEffectLocation(),pawn(owner).viewrotation);
				EEffect.bHasTarg = false;
			}
			EEffect.EnchantmentTarget = EffectTarg.location;
			EEffect.EnchantmentTarget.z += EffectTarg.CollisionHeight/2;
			EEffect.StartLocation = self;
			if (pawn(EffectTarg) != none) {
				if (!bNoExp)
					NaliMage(Owner).GainExp(book,timeheld*manapersecond*15);
				timeheld *= 1 + (NaliMage(Owner).SpellSkills[book]/15);
				foreach allactors(Class'NCPawnEnchant',E) {
					if ((E.class == Enchantment) && (E.EnchantmentTarget == pawn(EffectTarg))) {
						OtherFound = true;
						E.LifeSpan += E.Default.LifeSpan*timeheld;
						E.Resupply(timeheld);
						E.MaxLifeSpan += E.Default.LifeSpan*timeheld;
					}
				}
				if (!OtherFound) {
					Enchant = Spawn(Enchantment,,,EffectTarg.location);
					Enchant.EnchantmentTarget = pawn(EffectTarg);
					Enchant.MaxLifeSpan = Enchant.LifeSpan * timeheld;
					Enchant.LifeSpan *= timeheld;
					Enchant.bTargetReceived = true;
				}
			}
		}
		else {
			EffectTarg = forwardTrace(EffectLoc);
			timeheld *= 1 + (NaliMage(Owner).SpellSkills[book]/15);
			if (!bNoExp)
				NaliMage(Owner).GainExp(book,timeheld*manapersecond*5); // smaller exp bonus for non-targeted enchantments
			if (EffectTarg.class == Enchantment) {
				newrot = rotator(owner.location - EffectTarg.location);
				newrot.pitch = 0;
				EEffect = Spawn(EnchantEffect,,,GetEffectLocation(),newrot);
				EEffect.EnchantmentTarget = EffectTarg.location;
				EEffect.StartLocation = self;
				EEffect.bHasTarg = true;
				NCPawnEnchant(EffectTarg).LifeSpan += NCPawnEnchant(EffectTarg).Default.LifeSpan*timeheld;
				NCPawnEnchant(EffectTarg).Resupply(timeheld);
				NCPawnEnchant(EffectTarg).MaxLifeSpan += NCPawnEnchant(EffectTarg).Default.LifeSpan*timeheld;
			}
			else {
				newrot = rotator(owner.location - EffectLoc);
				EEffect = Spawn(EnchantEffect,,,GetEffectLocation(),newrot); //rotator(owner.location - EffectLoc)
				EEffect.EnchantmentTarget = EffectLoc;
				EEffect.StartLocation = self;
				EEffect.bHasTarg = true;
				newrot.pitch = 0;
				Enchant = Spawn(Enchantment,,,EffectLoc,newrot);
				Enchant.MaxLifeSpan = Enchant.LifeSpan * timeheld;
				Enchant.LifeSpan *= timeheld;
				Enchant.bTargetReceived = true;
			}
		}
	}
	//Pawn(Owner).ClientMessage(EEffect);
}

defaultproperties
{
     Range=1000.000000
     faildamage=10.000000
     mintime=0.500000
     bTargeted=True
     PickupMessage="You found an enchantment spell"
}
