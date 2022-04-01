// Used to boil the potion, thus finishing it
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCBoiler expands NCPickup;

var travel int amountToTake;

state Activated
{
	Begin:
	Owner.PlaySound(ActivateSound);
	if ((NaliMage(Owner).CurrentVial != none) && (NaliMage(Owner).CurrentVial.charge > 0)) {
		NaliMage(Owner).CurrentVial.bBoiling = True;
		amountToTake = NaliMage(Owner).CurrentVial.charge;
		while (amountToTake >= 0) {
			sleep(0.4);
			charge -= 5;
			amountToTake -= 5;
			if (amountToTake < 0) charge -= amountToTake;
			if (charge < 0) charge = 0;
		}
		NaliMage(Owner).CurrentVial.bBoiling = False;
		NaliMage(Owner).CurrentVial.FinishBoil();
		if (charge <= 0)
			UsedUp();
		else
			Activate();
	}
	else {
		Activate();
	}
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.BoilerInfo'
     bShowCharge=True
     interGroup=True
     ExpireMessage="This potion boiler has used up its charge"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got a potion boiler"
     ItemName="Potion boiler"
     PickupViewMesh=LodMesh'NaliChronicles.Boiler'
     PickupViewScale=0.600000
     Charge=500
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'NaliChronicles.PickupSounds.Potionboil'
     Icon=Texture'NaliChronicles.Icons.Boiler'
     Style=STY_Masked
     Mesh=LodMesh'NaliChronicles.Boiler'
     DrawScale=0.600000
     AmbientGlow=0
     CollisionRadius=7.500000
     CollisionHeight=10.000000
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=24
     LightHue=32
     LightSaturation=32
     LightRadius=16
     LightPeriod=50
}
