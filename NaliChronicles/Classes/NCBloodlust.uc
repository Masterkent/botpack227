// Allows player to regain health, but causes bloodlust!
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCBloodlust extends Pickup;

var int count;
var bool bRushing;
var float rushStart;

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local scriptedpawn p;
	local float mindist;
	local scriptedpawn cand;
	local rotator newrot;

	foreach allactors(Class'ScriptedPawn',p) {
		if (mindist == 0 && FastTrace(p.location,owner.location)) {
			cand = p;
			mindist = VSize(p.location-owner.location);
		}
		else {
			if (VSize(p.location-owner.location) < mindist && FastTrace(p.location,owner.location)) {
				cand = p;
				mindist = VSize(p.location-owner.location);
			}
		}
	}
	if (FRand() < (float(charge)/100.0) && cand != none) {
		if (FRand() < float(charge)/100.0) { // face closest pawn
			newrot = rotator(cand.location-owner.location);
			newrot.yaw += (2000*(float(charge)/100.0))-(4000*FRand()*(float(charge)/100.0));
			newrot.pitch += (2000*(float(charge)/100.0))-(4000*FRand()*(float(charge)/100.0));
			if (newrot.pitch < 0) newrot.pitch = (16384*4)-newrot.pitch;
			if (newrot.pitch > 16384*4) newrot.pitch -= 16384*4;
			pawn(owner).viewrotation = newrot;
			if (FRand() < float(charge)/100.0) { // rush!
				PlayerPawn(Owner).aForward = 1;
				bRushing = true;
				rushStart = level.timeseconds;
			}
		}
		Pawn(Owner).bFire = 1;
		if (Pawn(Owner).weapon != none)
			Pawn(Owner).weapon.fire(0);
		Pawn(Owner).bFire = 1;
	}
	return (Damage); // doesn't absorb anything
}

function Tick(float DeltaTime) {
	if (bRushing) {
		if (level.timeseconds-rushStart > 15)
			bRushing = false;
		PlayerPawn(Owner).aForward = 1;
	}
}

function addFog() {
	PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(4,0,0));
	PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(0,-4,-4));
}

function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		Pawn(Owner).NextItem();
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	Owner.PlaySound(DeactivateSound);
	Pawn(Owner).DeleteInventory(Self);
	Destroy();
}

function Timer() {
	local rotator newrot;

	if ((Owner != none) && (charge > 0) && (Pawn(Owner).health < 100)) {
		Pawn(Owner).health += fMax(1,charge/20);
		if (Pawn(Owner).health > 100) Pawn(Owner).health = 100;
	}
	count++;
	if (count >= 3) {
		if (FRand() > (float(charge)/10000.0)) {
			ArmorAbsorbDamage(0,'',owner.location);
		}
		count = 0;
		charge -= 1;
		PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(-4,0,0));
		PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(0,4,4));
		if (charge <= 0)
			UsedUp();
	}
	SetTimer(0.4,false);
}

defaultproperties
{
     bDisplayableInv=True
     Charge=100
     bIsAnArmor=True
     AbsorptionPriority=20
     Icon=Texture'NaliChronicles.Icons.BloodlustBarIcon'
}
