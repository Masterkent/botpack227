// A vine that grows out of the ground and eats/slows down pawns
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDeathfruitVine extends Actor;

var sound boomSound;
var sound growSound;
var sound peckSound;
var sound dieSound;
var sound strikeSound;
var sound crushSound;
var bool bDeathPlayed;
var NaliMage NaliOwner;
var() int lifeForce;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	local vector BloodOffset;
	local vector Mo;

	lifeForce -= Damage;
	BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
	BloodOffset.Z = BloodOffset.Z * 0.5;
	spawn(class'GreenBloodPuff',self,,hitLocation + BloodOffset);
	if (lifeForce <= 0) {
		lifeForce = 0;
		GotoState('Dying');
	}
}

function PostBeginPlay() {
	local float sizem;

	Super.PostBeginPlay();
	sizem = 0.9 + (Frand()*0.75);
	drawscale *= sizem;
	setCollisionSize(collisionradius*sizem,collisionheight*sizem);
}

function vector randvect() {
	local vector newv;

	newv.x = FRand()*30-15;
	newv.y = FRand()*30-15;
	newv.z = 0;
	return newv;
}

auto state Grow {
	Begin:
	sleep(1.0); // sleep for a second
	PlaySound(growSound);
	PlayAnim('Grow');
	sleep(0.5);
	SetCollision(true,false,false);
	FinishAnim();
	goToState('Ready');
}

state Dying {
	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local vector BloodOffset;
		local vector Mo;

		BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
		BloodOffset.Z = BloodOffset.Z * 0.5;
		spawn(class'GreenBloodPuff',self,,hitLocation + BloodOffset);
	}

	function AnimEnd() {
		local GreenBloodPuff gbp;

		if (bDeathPlayed) {
			gbp = spawn(class'GreenBloodPuff',self,,location+randvect());
			gbp.drawScale *= 3;
			PlaySound(boomSound);
			destroy();
		}
	}

	Begin:
	PlaySound(dieSound);
	SetCollision(false,false,false);
	PlayAnim('Death');
	bDeathPlayed = true;
}

state Ready {

	function BeginState() {
		target = none;
		setTimer(0.5,false);
		AnimEnd();
	}

	function AnimEnd() {
		if (FRand() > 0.5)
			PlayAnim('Sway1',FRand()*0.5+0.75);
		else
			PlayAnim('Sway2',FRand()*0.5+0.75);
	}

	function Timer() {
		lifeForce--;
		if (lifeForce <= 0)
			goToState('Dying');
		setTimer(0.5,false);
	}

	function Touch(actor other) {
		if (pawn(other) != none) {
			target = other;
			if (FRand() > 0.45)
				GoToState('SmallAttack');
			else
				GoToState('crushAttack');
		}
	}
}

function actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace) {
	local vector realHit;
	local actor Other;
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True,vect(10,10,10));
	if ( Pawn(Other) != None )
	{
		realHit = HitLocation;
		if ( !Pawn(Other).AdjustHitLocation(HitLocation, EndTrace - StartTrace) )
			Other = Pawn(Other).TraceShot(HitLocation,HitNormal,EndTrace,realHit);
	}
	return Other;
}

function TraceFire() {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	PlaySound(peckSound);
	lifeForce -= 8; // 8 life force per peck
	GetAxes(rotation,X,Y,Z);
	StartTrace = location + (5*drawscale) * Z;
	EndTrace = StartTrace + (5*drawscale) * X - (10*drawscale) * Z;
	Other = TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	if (other != none && other != self) {
		other.TakeDamage(4*drawscale,NaliOwner,location,vect(0,0,0),'shredded');
		if (NaliOwner != none && other != NaliOwner && Nali(other) == none && NaliWarrior(Other) == none && Pawn(Other) != none)
			NaliOwner.GainExp(0,4*drawscale);
	}
}

state SmallAttack {
	function Tick(float DeltaTime) {
		local rotator newrot;

		newrot = rotator(target.location-location);
		newrot.pitch = 0;
		setRotation(newrot);
	}

	Begin:
	PlayAnim('Peck');
	PlaySound(strikeSound);
	sleep(0.25);
	TraceFire();
	if (checkClose())
		goToState('crushAttack');
	sleep(0.05);
	TraceFire();
	if (checkClose())
		goToState('crushAttack');
	FinishAnim();
	goToState('Ready');
}

function bool checkClose() {
	local vector newloc;

	newloc = location;
	newloc.z -= CollisionHeight*0.5;
	newloc.z += target.CollisionHeight*0.5;
	//NaliOwner.ClientMessage(VSize(target.location-newloc));
	if (VSize(target.location-newloc) <= CollisionRadius*1.25)
		return true;
	else
		return false;
}

state crushAttack {
	function Tick(float DeltaTime) { // keep hold of target
		local vector newloc;

		newloc = location;
		newloc.z -= CollisionHeight*0.5;
		newloc.z += target.CollisionHeight*0.5;
		if (VSize(target.location-newloc) >= 5)
			target.velocity = (newloc-target.location)*30;
		else
			target.setlocation(newloc);
	}

	function Timer() {
		target.TakeDamage(4*drawscale,NaliOwner,location,vect(0,0,0),'crushed');
		if (NaliOwner != none && target != NaliOwner && Nali(target) == none)
			NaliOwner.GainExp(0,4*drawscale);
		setTimer(0.25,false);
	}

	Begin:
	PlaySound(crushSound);
	setTimer(0.25,false);
	PlayAnim('Curl');
	FinishAnim();
	if (Frand() > 0.3)
		goToState('Ready');
	else
		goToState('crushAttack');
}

defaultproperties
{
     boomSound=Sound'Botpack.BioRifle.GelHit'
     growSound=Sound'UnrealShare.Tentacle.TentSpawn'
     peckSound=Sound'UnrealShare.Tentacle.TentImpact'
     dieSound=Sound'UnrealShare.Manta.land1mt'
     strikeSound=Sound'UnrealShare.Tentacle.strike2tn'
     crushSound=Sound'NaliChronicles.PickupSounds.leafsound'
     lifeForce=400
     bNetTemporary=True
     bReplicateInstigator=True
     Physics=PHYS_Falling
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'NaliChronicles.deathfruitvine'
     DrawScale=3.750000
     bGameRelevant=True
     SoundVolume=0
     CollisionRadius=13.000000
     CollisionHeight=35.000000
     bCollideWorld=True
     bProjTarget=True
     NetPriority=2.500000
}
