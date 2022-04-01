// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvFlashLight : A flashlight that updates client-side
// ===============================================================

class TvFlashLight expands TvPickup;

var FlashLightBeam s;
var float TimeChange;
var () bool bUsesCharge;

/*-
simulated function PostNetBeginPlay(){ //is on client
  GotoState('ClientControl');
}*/

state Activated
{
	function endstate()
	{
		if (s != none)
			s.Destroy();
		bActive = false;
	}

	function Tick( float DeltaTime )
	{
		TimeChange += DeltaTime*10;
		if (TimeChange > 1)
		{
			if (s == none)
				return;
			if (bUsesCharge)
				Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}

		if (s == none)
		{
			GoToState('DeActivated');
			return;
		}

		if (Pawn(Owner) == none)
		{
			UsedUp();
			return;
		}
		if (bUsesCharge && Charge <= 0)
		{
			Pawn(Owner).ClientMessage(ExpireMessage);
			UsedUp();
		}

		if (bUsesCharge && Charge < 400)
			s.LightBrightness = byte(Charge * 0.6 + 10);
		else
			s.LightBrightness = s.default.LightBrightness;
	}

	event BeginState()
	{
		local Vector HitNormal, HitLocation, EndTrace;

		bActive = true;
		TimeChange = 0;
		Owner.PlaySound(ActivateSound);
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation, HitNormal, EndTrace, Owner.Location,true);
		s = Spawn(class'TvFlashLightBeam', Owner, '', HitLocation + HitNormal * 40);
		if (s == none)
		{
			GoToState('DeActivated');
			return;
		}
		s.LightHue = LightHue;
		s.LightRadius = LightRadius;
		if (bUsesCharge && Charge < 400)
			s.LightBrightness = byte(Charge * 0.6 + 10);
		else
			s.LightBrightness = s.default.LightBrightness;
	}

Begin:
}

state DeActivated
{
Begin:
	if (s != none)
		s.Destroy();
	if (Owner != none)
		Owner.PlaySound(DeActivateSound);
}

//client control: // [U227] unused
state ClientControl { //this is the state that clients (and never server) are always in.

  simulated function bool ClientActivate(){
    Super.ClientActivate();
    Tick(0.0);
    return false;
  }

  simulated function Tick(float delta){ //update beam client-side.
    local Vector HitNormal,HitLocation,EndTrace,X;
    if (!bActive){
      if (S!=none)
        S.Destroy();
      s=none;
      return;
    }
    X=vector(Pawn(Owner).ViewRotation);
    EndTrace = Owner.Location + 10000*X;
    Trace(HitLocation,HitNormal,EndTrace,Owner.Location, True);
    if (s==none){
      s = Spawn(class'FlashLightBeam',Owner, '', HitLocation-X*64);
      s.LightHue = LightHue;
      s.LightRadius = LightRadius;
    }
    else
      s.SetLocation(HitLocation-X*64);
    if (bUsesCharge&&Charge<400)
      s.LightBrightness=byte(Charge*0.6+10);
  }
}

function Destroyed()
{
  if (S!=none)
    s.Destroy();
  Super.Destroyed();
}

defaultproperties
{
     RealClass=Class'UnrealShare.Flashlight'
     bActivatable=True
     bDisplayableInv=True
     RespawnTime=40.000000
     PickupViewMesh=LodMesh'UnrealShare.Flashl'
     StatusIcon=Texture'XidiaMPack.Icons.FlashLightI'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealShare.Pickups.FSHLITE1'
     DeActivateSound=Sound'UnrealShare.Pickups.FSHLITE2'
     Icon=Texture'UnrealShare.Icons.I_Flashlight'
     Mesh=LodMesh'UnrealShare.Flashl'
     AmbientGlow=96
     CollisionRadius=22.000000
     CollisionHeight=4.000000
     LightBrightness=100
     LightHue=33
     LightSaturation=187
     LightRadius=7
}
