// This enchantment that creates a sanctuary the player can enter for safety
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantSanctuary extends NCPawnEnchant;

var NCSanctuaryPillar pillars[6];
var bool bOccupied;
var NaliMage occupant;

function PlayStartAnim() {
	local vector X, Y, Z;

	GetAxes(rotation,X,Y,Z);
	pillars[0] = Spawn(Class'NCSanctuaryPillar',self,,location - 55*Z,rotation);
	pillars[0].SetCollisionSize(30,0);
	pillars[1] = Spawn(Class'NCSanctuaryPillar',self,,location + (40*X),rotation);
	pillars[1].SetCollisionSize(2,55);
	pillars[2] = Spawn(Class'NCSanctuaryPillar',self,,location + (40*Y),rotation);
	pillars[2].SetCollisionSize(2,55);
	pillars[3] = Spawn(Class'NCSanctuaryPillar',self,,location + (-40*X),rotation);
	pillars[3].SetCollisionSize(2,55);
	pillars[4] = Spawn(Class'NCSanctuaryPillar',self,,location + (-40*Y),rotation);
	pillars[4].SetCollisionSize(2,55);
	pillars[5] = Spawn(Class'NCSanctuaryPillar',self,,location + 70*Z,rotation);
	pillars[5].SetCollisionSize(40,7);
}

function destroyed() {
	local int i;

	while (i < 6) {
		if (pillars[i] != none)
			pillars[i].destroy();
		i++;
	}
	if (occupant != none)
		occupant.bDisarmed = false;
}

function Touch(actor Other) {
	if (NaliMage(Other) != none) {
		NaliMage(Other).ClientMessage("Now entering the protection of the sanctuary.",'Pickup');
		NaliMage(Other).bDisarmed = true;
		occupant = NaliMage(Other);
		SetCollisionSize(120,55); // get big enough to prevent Skaarj from attacking
		bOccupied = true;
	}
	if (Projectile(Other) != none && bOccupied)
		Projectile(Other).HitWall(Normal(other.location-location),self);
}

function Untouch(actor Other) {
	if (bOccupied && NaliMage(Other) != none) {
		NaliMage(Other).ClientMessage("Now leaving the protection of the sanctuary.",'Pickup');
		NaliMage(Other).bDisarmed = false;
		occupant = none;
		SetCollisionSize(40,55);
		bOccupied = false;
	}
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     bPawnless=True
     Physics=PHYS_Falling
     LifeSpan=120.000000
     Mesh=LodMesh'NaliChronicles.sanctuary'
     DrawScale=4.000000
     CollisionRadius=40.000000
     CollisionHeight=55.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     Mass=1.000000
}
