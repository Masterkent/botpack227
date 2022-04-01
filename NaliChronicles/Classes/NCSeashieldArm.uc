// An arm that comes off the sea shield
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSeashieldArm extends Actor;

var sound peckSound;
var sound strikeSound;
var bool bAttacked;
var vector offSet;

function PostBeginPlay() {
	Super.PostBeginPlay();
	Timer();
	offSet = location-owner.location;
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
	local NaliMage NaliOwner;

	NaliOwner = NaliMage(Owner);
	PlaySound(peckSound);
	GetAxes(rotation,X,Y,Z);
	StartTrace = location;
	EndTrace = StartTrace + 80 * X;
	Other = TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	if (other != none && other != self) {
		other.TakeDamage(15,NaliOwner,location,vect(0,0,0),'shredded');
		if (NaliOwner != none && other != NaliOwner && Nali(other) == none && NaliWarrior(other) == none)
			NaliOwner.GainExp(1,15);
	}
}

function Timer() {
	if (!bAttacked) {
		PlayAnim('Peck');
		PlaySound(strikeSound);
		bAttacked=true;
		setTimer(0.5,false);
	}
	else {
		TraceFire();
            PlaySound(peckSound);
		destroy();
	}
}

function Tick(float DeltaTime) {
	setLocation(owner.location+offSet);
}

defaultproperties
{
     peckSound=Sound'UnrealShare.Tentacle.TentImpact'
     strikeSound=Sound'UnrealShare.Tentacle.strike2tn'
     bNetTemporary=True
     bReplicateInstigator=True
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'NaliChronicles.seashieldarm'
     bGameRelevant=True
}
