// A portable lantern that lights a small radius around player
// Code by Sergey 'Eater' Levin, 2002

class NCLantern extends NCPickup;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

var float TimeChange;
var B227_NCLanternLight B227_Light;

state Activated
{
	function EndState()
	{
		bActive = false;
		if (B227_Light != none)
			B227_Light.Destroy();
		B227_Light = none;
	}

	function Tick( float DeltaTime )
	{
		TimeChange += DeltaTime*10;
		if (TimeChange > 1) {
			Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}

		if ( Pawn(Owner) == None )
		{
			UsedUp();
			return;
		}
		if (Charge <= 0)
		{
			Pawn(Owner).ClientMessage(ExpireMessage);
			UsedUp();
		}

		if (B227_Light != none)
		{
			if (Charge < 400)
				B227_Light.LightBrightness = byte((Charge / 400.0) * (B227_Light.default.LightBrightness - 10) + 10);
			else
				B227_Light.LightBrightness = B227_Light.default.LightBrightness;
		}
		//-setLocation(owner.location);
	}

	function BeginState()
	{
		bActive = true;
		TimeChange = 0;
		Owner.PlaySound(ActivateSound);
		//-LightType = LT_Steady;

		B227_Light = Spawn(class'B227_NCLanternLight', Owner);
		if (B227_Light != none && Charge < 400)
			B227_Light.LightBrightness = byte((Charge / 400.0) * (B227_Light.default.LightBrightness - 10) + 10);
	}

Begin:
}

state DeActivated
{
Begin:
	//-lightType = LT_None;
	Owner.PlaySound(DeActivateSound);
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.LanternInfo'
     bShowCharge=True
     ExpireMessage="The lantern oil is all gone"
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You picked up the lantern"
     ItemName="Lantern"
     RespawnTime=300.000000
     PickupViewMesh=LodMesh'UnrealShare.Lantern2M'
     PickupViewScale=0.500000
     Charge=15000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealShare.Pickups.flares1'
     DeActivateSound=Sound'UnrealShare.Pickups.flares1'
     Icon=Texture'NaliChronicles.Icons.LanternIcon'
     RemoteRole=ROLE_DumbProxy
     Mesh=LodMesh'UnrealShare.Lantern2M'
     DrawScale=0.500000
     AmbientGlow=96
     CollisionRadius=22.000000
     CollisionHeight=12.000000
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightHue=32
     LightSaturation=64
     LightRadius=20
     LightCone=128
     VolumeBrightness=64
}
