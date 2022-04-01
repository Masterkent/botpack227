// A worm that attacks an enchantment's target
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCEarthworm extends Actor;

var() int charge;
var NCPawnEnchantWorms enchantment;
var() int health;
var pawn Target;
var vector Offset;
var NaliMage NaliOwner;

function PostBeginPlay() {
	Super.PostBeginPlay();
	PlayAnim('Grow');
}

function AnimEnd() {
	SetCollisionSize(5*DrawScale,8*DrawScale); // change this
	GotoState('Ready');
}

function Tick(float DeltaTime) {
	local vector X,Y,Z;
	local rotator newrot;

	GetAxes(enchantment.rotation,X,Y,Z);
	setLocation(enchantment.location + X*Offset.X + Y*Offset.Y + Z*Offset.Z);
	newrot = enchantment.rotation;
	newrot.yaw = rotator(location-enchantment.location).yaw;
	setRotation(newrot);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	local vector BloodOffset;
	local vector Mo;

	health -= Damage;
	BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
	BloodOffset.Z = BloodOffset.Z * 0.5;
	if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') ) {
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
	}
	else
		spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
	if (health <= 0) {
		health = 0;
		GotoState('Dying');
	}
}

state Dying {
	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local vector BloodOffset;
		local vector Mo;

		BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
		BloodOffset.Z = BloodOffset.Z * 0.5;
		if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') ) {
			Mo = Momentum;
			if ( Mo.Z > 0 )
				Mo.Z *= 0.5;
			spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
		}
		else
			spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
	}

	function AnimEnd() {
		SetCollisionSize(0,0);
		enchantment.loseWorm(self);
	}

	Begin:
	PlayAnim('Death');
}

state Ready {
	function AnimEnd() { }
	Begin:
	if (charge <= 0) {
		GotoState('Dying');
	}
	else {
		if (FRand() > (0.6+(charge/200))) {
			PlayAnim('Still');
			FinishAnim();
			Goto('Begin');
		}
		else {
			if (FRand() > 0.4) {
				PlayAnim('LightAttack');
				sleep(0.4);
				Target.TakeDamage(3*DrawScale,instigator,location,vect(0,0,0),'shredded');
				NaliOwner.GainExp(0,3*DrawScale);
				charge -= 1;
				FinishAnim();
				Goto('Begin');
			}
			else {
				PlayAnim('HeavyAttack');
				sleep(0.8);
				Target.TakeDamage(6*DrawScale,instigator,location,vect(0,0,0),'shredded');
				NaliOwner.GainExp(0,6*DrawScale);
				charge -= 2;
				FinishAnim();
				Goto('Begin');
			}
		}
	}
}

defaultproperties
{
     Charge=10
     Health=20
     bNetTemporary=True
     bReplicateInstigator=True
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'NaliChronicles.earthworm'
     bGameRelevant=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bProjTarget=True
     NetPriority=2.500000
}
