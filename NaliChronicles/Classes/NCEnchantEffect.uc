// The base of all enchantment spell effects
// Code by Sergey 'Eater' Levin, 2001

class NCEnchantEffect extends NCSpellEffect;

var class<NCLineEffect> LineClass;
var class<NCLineEffect> AltLineClass;
var NCEnchantSpell StartLocation;
var vector OriginLoc;
var vector EnchantmentTarget;
var int iFirst;
var vector LastLocation;
var rotator LastRotation;
var bool bHasTarg;
var float mult;

function PostBeginPlay() {
	Super.PostBeginPlay();
	OriginLoc = location;
}

function vector GetTargetLocation() { // to target upper body
	local vector out;

	out = EnchantmentTarget;

	return out;
}

function bool checklinefinished(int i) {
	local float dist;

	if (!bHasTarg) {
		if (i >= 10)
			return true;
	}
	else {
		dist = VSize(LastLocation - GetTargetLocation());
		if (dist <= 20)
			return true;
		if (VSize(LastLocation-OriginLoc) > VSize(GetTargetLocation()-OriginLoc)) // test to see if we're farther from origin than target
			return true;
	}

	return false;
}

function float pathag(float hyp, float leg) {
	return sqrt((hyp*hyp)-(leg*leg));
}

function SpawnLine() {
	local rotator returnrot;
	local vector returnloc;
	local bool works;
	local vector X,Y,Z;
	local float rotlimit;
	local float alttogo;
	local float Side;
	local float forward;
	local float altlimit;
	local float f;
	local playerpawn p;

	if (bHasTarg) {
		GetAxes(rotation,X,Y,Z);
		Side = sin(abs(LastRotation.yaw - rotation.yaw)/10430.2192)*VSize(LastLocation-StartLocation.GetEffectLocation());
		Forward = cos(abs(LastRotation.yaw - rotation.yaw)/10430.2192)*VSize(LastLocation-StartLocation.GetEffectLocation());
		//if (VSize(GetTargetLocation() - lastlocation) <= 80) {
		if (forward > ( 0.8*VSize(StartLocation.GetEffectLocation()-GetTargetLocation()) )) {
			returnrot = rotator(lastlocation - GetTargetLocation());
		}
		else {
			alttogo = 20 - Side; // used to be 40 - Side
			if (alttogo >= 20)
				rotlimit = 16384;
			else
				rotlimit = 10430.2192*atan(alttogo/pathag(20,alttogo));
			if (Side >= 20)
				altlimit = 16384;
			else
				altlimit = 10430.2192*atan(pathag(20,Side)/Side);
			returnrot = randomizerotation(rotlimit,forward, altlimit);
		}
	}
	else {
		returnrot = rotation;
		returnrot.yaw += Rand(16384)*mult;
		returnrot.yaw += 32768;
	}
	GetAxes(returnrot,X,Y,Z);
	returnloc = lastlocation - 10*X;
	lastlocation = lastlocation - 20*X;
	LastRotation = returnrot;
	F = FRand();
	if (F <= 0.33)
		returnrot.roll += 21845.33;
	else if (F <= 0.66)
		returnrot.roll += 43690.67;

	if (FRand() >= 0.33)
		Spawn(LineClass,,,returnloc,returnrot);
	else
		Spawn(AltLineClass,,,returnloc,returnrot);
}

function rotator randomizerotation(float limit, float forward, float altlimit) {
	local float f;
	local rotator newrot;

	newrot = rotation;
	if (forward > ( 0.5*VSize(StartLocation.GetEffectLocation()-GetTargetLocation()) ) )
		newrot.yaw -= Rand(altlimit)*mult;
	else
		newrot.yaw += Rand(limit)*mult;

	return newrot;
}

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		local int i;
		local bool bDone;

		if (iFirst == 1) { // on the second tick we get spawn all the line actors
			iFirst++;
			if (Frand() >= 0.5)
				mult = -1;
			else
				mult = 1;
			LastLocation = StartLocation.GetEffectLocation();
			LastRotation = rotation;
			while ((!bDone) && (i<400)) {
				SpawnLine();
				bDone = checklinefinished(i);
				i++;
			}
		}
		else {
			if (iFirst == 0)
				iFirst++;
		}
	}
}

defaultproperties
{
     LifeSpan=1.200000
}
