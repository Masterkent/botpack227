// A vial of crack!
// Code by Sergey 'Eater' Levin, 2001

// leaf - 35%, fruit - 50%, power - 15%
// .30, .16, -.015, .485, .035, -.015

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpeedVial extends NCPotion;

state Activated
{
	function Timer()
	{
		if (Pawn(Owner) != none) {
			if ((Pawn(Owner).groundspeed >= 480) && (Pawn(Owner).WaterSpeed >= 300) && (Pawn(Owner).AirSpeed >= 600)) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;

				if (Pawn(Owner).groundspeed <= 633.6) Pawn(Owner).GroundSpeed += 6.4;
				else if (Pawn(Owner).groundspeed < 640) Pawn(Owner).GroundSpeed = 480;

				if (Pawn(Owner).WaterSpeed <= 396) Pawn(Owner).WaterSpeed += 4;
				else if (Pawn(Owner).WaterSpeed < 400) Pawn(Owner).WaterSpeed = 300;

				if (Pawn(Owner).AirSpeed <= 792) Pawn(Owner).AirSpeed += 8;
				else if (Pawn(Owner).AirSpeed < 800) Pawn(Owner).AirSpeed = 600;
			}
		}
		if (Charge<=0) {
			UsedUp();
			GotoState('DeActivated');
		}
	}
}

defaultproperties
{
     powershigh(0)=0.320000
     powershigh(1)=0.620000
     powershigh(2)=0.120000
     powershigh(3)=0.700000
     powershigh(4)=0.200000
     powershigh(5)=0.133333
     powerslow(0)=-0.160000
     powerslow(1)=0.020000
     powerslow(2)=-0.150000
     powerslow(3)=0.300000
     powerslow(4)=-0.160000
     powerslow(5)=-0.200000
     infotex=Texture'NaliChronicles.Icons.SpeedVialInfo'
     PickupMessage="You got a speed potion vial"
     ItemName="speed potion vial"
     Icon=Texture'NaliChronicles.Icons.SpeedVial'
     Skin=Texture'NaliChronicles.Skins.Jspeedvial'
}
