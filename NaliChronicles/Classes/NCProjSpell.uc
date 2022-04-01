// The base of all projectile-spawning spells
// Code by Sergey 'Eater' Levin, 2001

class NCProjSpell extends NCSpell
	abstract;

var() class<NCMagicProj> Proj;
var() float damagepersecond;
var() float sizepersecond;
var() float mintime;
var NCMagicProj MyProj[20];
var() int numProjectiles;
var() float inaccuracy;

function ScanForAccidents(float timeheld) { // depending on stress, this function can cause freak accidents
	local float f;
	local vector effectlocation, X, Y, Z;
	local rotator newrotation;
	local int i;

	f = (stress/9) - GetMySkill()/10;
	if (FRand() < f) {
		while (i < numProjectiles) {
			if (MyProj[i] != none) {
				MyProj[i].Destroy();
				MyProj[i] = none;
			}
			i++;
		}
		i = 0;
		Owner.TakeDamage(30*timeheld,pawn(owner),owner.location,vect(0,0,0),'zapped');
		PlaySound(FailSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
		effectlocation = owner.location;
		GetAxes(pawn(owner).viewrotation,X,Y,Z);
		effectlocation += CalcDrawOffset();
		effectlocation += -17*Z + 40*X;
		Spawn(Class'NaliChronicles.NCFailEffect',,,effectlocation,pawn(owner).viewrotation);
	}

	f = (stress/6) - GetMySkill()/10;
	if (FRand() < f) {
		newrotation = Pawn(Owner).viewrotation;
		newrotation.yaw += 32768;
		newrotation.pitch += 32768;
		while (i < numProjectiles) {
			if (MyProj[i] != none) {
				Owner.TakeDamage(MyProj[i].Damage*0.5,pawn(owner),MyProj[i].location,vector(newrotation*MyProj[i].MomentumTransfer),MyProj[i].MyDamageType);
				MyProj[i].SetRotation(addstressrot());
				MyProj[i].SetLocation(getprojloc(i));
				MyProj[i].DoneCasting();
				MyProj[i].Explode(MyProj[i].location,MyProj[i].location);
				MyProj[i] = none;
			}
			i++;
		}
		i = 0;
		return;
	}
}

function FinishCasting(float timeheld) {
	local int i;

	Super.FinishCasting(timeheld);
	ScanForAccidents(timeheld);
	while (i < 20) {
		if (MyProj[i] != none) {
			MyProj[i].SetRotation(addstressrot());
			MyProj[i].SetLocation(getprojloc(i));
			MyProj[i].DoneCasting();
			if (NaliMage(Owner) != none) {
				MyProj[i].NaliOwner = NaliMage(Owner);
				MyProj[i].book = book;
			}
			MyProj[i] = none;
		}
		i++;
	}
}

function rotator AddStressRot() {
	local rotator newrot;

	newrot = Pawn(Owner).ViewRotation;

	if (FRand() < 0.5)
		newrot.pitch += (Rand(2048/GetMySkill())*stress)+Rand(inaccuracy);
	else
		newrot.pitch -= Rand(2048/GetMySkill())*stress+Rand(inaccuracy);
	if (FRand() < 0.5)
		newrot.yaw += Rand(2048/GetMySkill())*stress+Rand(inaccuracy);
	else
		newrot.yaw -= Rand(2048/GetMySkill())*stress+Rand(inaccuracy);

	return newrot;
}

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -8.5*Z + 20*X;

	return newloc;
}

state Casting {
	function Timer() {
		local int i;

		Super.Timer();
		if ((Level.TimeSeconds-currtime) >= mintime) {
			while (i < numProjectiles) {
				if (MyProj[i] == none) {
					MyProj[i] = Spawn(Proj,,,getprojloc(i),pawn(owner).viewrotation);
				}
				else {
					//Pawn(Owner).ClientMessage(stress);
					MyProj[i].DrawScale += (sizepersecond*0.1)*( GetMySkill()*( 1-(stress/GetMySkill()) ) );
					MyProj[i].Damage += (damagepersecond*0.1)*( GetMySkill()*( 1-(stress/GetMySkill()) ) );
				}
				i++;
			}
		}
	}

	function Tick(float DeltaTime) {
		local int i;

		Super.Tick(DeltaTime);
		while (i < numProjectiles) {
			if (MyProj[i] != none) {
				MyProj[i].SetLocation(getprojloc(i));
				MyProj[i].SetRotation(Pawn(Owner).viewrotation);
			}
			i++;
		}
	}
}

defaultproperties
{
     damagepersecond=10.000000
     sizepersecond=0.020000
     mintime=0.500000
     numProjectiles=1
     PickupMessage="You found a projectile pell"
}
