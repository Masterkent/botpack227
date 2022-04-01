// A Skaarj flashlight that lights a good-sized area
// Code by Sergey 'Eater' Levin, 2002

class NCSkaarjLight extends NCPickup;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

var FlashLightBeam s;
var float TimeChange;
var Vector HitNormal,HitLocation,EndTrace,StartTrace,X,Y,Z,NewHitLocation;

state Activated
{
	function endstate()
	{
		if (s!=None) s.Destroy();
		bActive = false;
	}

	function Tick( float DeltaTime )
	{
		TimeChange += DeltaTime*10;
		if (TimeChange > 1) {
			if ( s == None )
			{
				UsedUp();
				return;
			}
			Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}

		if (s == None) Return;

		if ( Pawn(Owner) == None )
		{
			s.Destroy();
			UsedUp();
			return;
		}
		if (Charge<-0) {
			s.Destroy();
			Pawn(Owner).ClientMessage(ExpireMessage);
			UsedUp();
		}

		if (Charge<400) s.LightBrightness=byte(Charge*0.6+10);

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation,HitNormal,EndTrace,Pawn(Owner).Location, True);
		s.SetLocation(HitLocation-vector(Pawn(Owner).ViewRotation)*64);
//		s.LightRadius = fmin(Vsize(HitLocation-Pawn(Owner).Location)/200,14) + 2.0;
	}

	function BeginState()
	{
		TimeChange = 0;
		Owner.PlaySound(ActivateSound);
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation,HitNormal,EndTrace,Pawn(Owner).Location+Y*17);
		s = Spawn(class'FlashLightBeam',Owner, '', HitLocation+HitNormal*40);
		s.LightHue = LightHue;
		s.LightRadius = LightRadius;
		if (Charge<400) s.LightBrightness=byte(Charge*0.6+10);
		if (s==None) GoToState('DeActivated');
	}

Begin:
}

state DeActivated
{
Begin:
	s.Destroy();
	Owner.PlaySound(DeActivateSound);
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.SkaarjLightInfo'
     bShowCharge=True
     ExpireMessage="Skaarj light power has run out"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You picked up the flashlight"
     ItemName="Flashlight"
     RespawnTime=40.000000
     PickupViewMesh=LodMesh'UnrealShare.Flashl'
     Charge=20000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealShare.Pickups.FSHLITE1'
     DeActivateSound=Sound'UnrealShare.Pickups.FSHLITE2'
     Icon=Texture'NaliChronicles.Icons.SkaarjLightIcon'
     RemoteRole=ROLE_DumbProxy
     Mesh=LodMesh'UnrealShare.Flashl'
     AmbientGlow=0
     CollisionRadius=22.000000
     CollisionHeight=4.000000
     LightBrightness=100
     LightHue=33
     LightSaturation=187
     LightRadius=7
}
