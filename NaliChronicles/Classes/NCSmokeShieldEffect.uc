// Spell effect that causes smoke to come over the player's view
// Code by Sergey 'Eater' Levin, 2001

class NCSmokeShieldEffect extends Effects;

var float smokeCount;
var class<Effects> smokeClass[3];

auto state Follow
{
	function Tick(float DeltaTime) {
		local vector X,Y,Z;
		local vector newLoc;
		local rotator newRot;
		local int i;

		smokeCount += DeltaTime;
		if (smokeCount >= 0.2) {
			smokeCount -= 0.2;
			newRot = pawn(owner).viewrotation;
			newRot.pitch = 0;
			GetAxes(newRot,X,Y,Z);
			while (i < 8) {
				newLoc = Owner.location;
				newLoc.z += Pawn(Owner).eyeheight-10;
				newLoc += X*50;
				newLoc += -(X*(Frand()*10))+Y*(25-(Frand()*50));
				Spawn(smokeClass[int(Frand()*3)],,,newLoc);
				i++;
			}
		}
	}
}

defaultproperties
{
     smokeClass(0)=Class'UnrealShare.SpriteSmokePuff'
     smokeClass(1)=Class'UnrealShare.SmokeColumn'
     smokeClass(2)=Class'UnrealShare.BlackSmoke'
     RemoteRole=ROLE_SimulatedProxy
}
