// Just a dummy collision cylinder
// Code by Sergey 'Eater' Levin, 2002

class NCSanctuaryPillar extends Actor;

var vector offSet;

function PostBeginPlay() {
	offSet = location-owner.location;
}

function Tick(float DeltaTime) {
	setLocation(owner.location+offSet);
}

defaultproperties
{
     DrawType=DT_None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
