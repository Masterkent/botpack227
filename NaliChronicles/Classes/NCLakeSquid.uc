// A squid that comes up and bites ya in da arse! (literally)
// Code by Sergey 'Eater' Levin, 2002

class NCLakeSquid extends Actor;

var NCPawnEnchantLake lake;
var sound strikeSound;
var NaliMage NaliOwner;
var bool bShrinking;
var bool bGrabbed;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	local vector BloodOffset;
	local vector Mo;

	BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
	BloodOffset.Z = BloodOffset.Z * 0.5;
	spawn(class'UT_BloodPuff',self,,hitLocation + BloodOffset);
	PlaySound(Sound'UnrealI.Squid.injur1sq');
}

function PostBeginPlay() {
	local float sizem;

	Super.PostBeginPlay();
	SetRotation(rot(49152,0,0));
	PlayAnim('Grab');
	bGrabbed = true;
}

function AnimEnd() {
	if (bGrabbed) {
		if (FRand() > 0.5) {
			PlayAnim('Hold');
		}
		else {
			PlayAnim('Release');
			bGrabbed = false;
		}
	}
	else {
		PlayAnim('Grab');
		bGrabbed = true;
	}
}

auto state Attack {
	function Tick(float DeltaTime) { // keep hold of target
		local vector newloc;

		newloc = location;
		newloc.z -= CollisionHeight*0.5;
		newloc.z += target.CollisionHeight*0.5;
		//if (VSize(target.location-newloc) >= 10)
		//	target.velocity = (newloc-target.location)*(VSize(target.location-newloc)*5);
		//else
		target.setlocation(newloc);
		if (!bShrinking) {
			if (DrawScale < 1.0)
				DrawScale += DeltaTime/2;
			if (DrawScale > 1.0)
				DrawScale = 1.0;
		}
		else {
			if ((DrawScale-(DeltaTime/2)) >= 0.01)
				DrawScale -= DeltaTime/2;
			else
				DrawScale = 0.01;
			if (DrawScale == 0.01) {
				lake.squiddy = none;
				destroy();
			}
		}
	}

	function Timer() {
		if (target != none && Pawn(target).health > 0) {
			target.TakeDamage(5,NaliOwner,location,vect(0,0,0),'crushed');
			if ((NaliOwner != none) && (target != NaliOwner) && (Nali(target) == none) && (NaliWarrior(target) == none) && (Pawn(target) != none))
				NaliOwner.GainExp(1,5);
		}
		setTimer(0.25,false);
	}

	function BeginState() {
		SetTimer(0.25,false);
	}

	Begin:
	sleep(9.0);
	bShrinking = true;
}

defaultproperties
{
     strikeSound=Sound'UnrealI.Squid.grab1sq'
     bNetTemporary=True
     bReplicateInstigator=True
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.Squid1'
     DrawScale=0.010000
     bGameRelevant=True
     SoundVolume=0
     CollisionRadius=13.000000
     CollisionHeight=20.000000
     bCollideWorld=True
     bProjTarget=True
     NetPriority=2.500000
}
