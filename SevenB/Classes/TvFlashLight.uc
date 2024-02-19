// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvFlashLight : A flashlight that updates client-side
// NOTE: ALSO USES SPECIAL FLASHLIGHT FEATURES WRITTEN BE SOME OTHER GUY (TM)
// Also makesnoise!
// ===============================================================

class TvFlashLight expands TvPickup;

var TvFlashLightBeam s;
var float TimeChange;
var () bool bUsesCharge;
//var SBFlashDecal r, r2;
//var vector lastloc;

/*-
simulated function PostNetBeginPlay(){ //is on client
  GotoState('ClientControl');
}*/

state Activated
{
  function endstate()
  {
    if (s!=None) s.Destroy();
    bActive = false;
  }

  function Tick( float DeltaTime )
  {
    //-local Vector HitNormal,HitLocation,EndTrace,X, newloc;
    TimeChange += DeltaTime*10;
    if (TimeChange > 1) {
      if ( s == None )
      {
        UsedUp();
        return;
      }
      if (bUsesCharge)
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
    if (bUsesCharge&&Charge<=0) {
      s.Destroy();
      Pawn(Owner).ClientMessage(ExpireMessage);
      UsedUp();
    }

    if (bUsesCharge && Charge < 400)
      s.LightBrightness = byte(Charge*0.6+10);
    else if (s.default.B227_bLowBrightness && !bUsesCharge)
      s.LightBrightness = 212;
    else
      s.LightBrightness = s.default.LightBrightness;

    //-X=vector(Pawn(Owner).ViewRotation);
    //-EndTrace = Owner.Location + 10000* X;
    //-Trace(HitLocation,HitNormal,EndTrace,Owner.Location+vect(0,0,1)*pawn(owner).baseeyeheight, True);
    //-s.SetLocation(HitLocation-X*64);
 //   s.SetRotation(HitNormal);
    //-s.LightRadius = fmin(Vsize(HitLocation-Pawn(Owner).Location)/200,14)+4.0;
    //-s.DecalPos = HitLocation + HitNormal*9;
    //newloc=HitLocation+HitNormal*9;
    //two decals for some reason?
 /*   if (r==none||r.bDeleteMe)
        r = Spawn(class'SBFlashDecal',,, lastloc, Rotator(HitNormal));
	else if (lastloc!=newloc){
        r.DetachDecal();
        r.SetLocation(lastloc);
        r.SetRotation(Rotator(HitNormal));
        r.AttachDecal(100,vect(0,0,1));
    }
	if (r2==none||r2.bDeleteMe)
        r2 = Spawn(class'SBFlashDecal',,, lastloc, Rotator(HitNormal));
	else if (lastloc!=newloc){
        r2.DetachDecal();
        r2.SetLocation(lastloc);
        r2.SetRotation(Rotator(HitNormal));
        r2.AttachDecal(100, vect(0,0,1));
    }
    lastloc=newloc;*/
  }

  function BeginState()
  {
    local Vector HitNormal,HitLocation,EndTrace;
    bActive = true;
    TimeChange = 0;
    Owner.PlaySound(ActivateSound);
    EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
    Trace(HitLocation,HitNormal,EndTrace,Owner.Location+vect(0,0,1)*pawn(owner).baseeyeheight,true);
    //-s = Spawn(class'TvFlashLightBeam',Owner, '', HitLocation+HitNormal*40);
    s = Spawn(class'TvFlashLightBeam',Owner, '', HitLocation+HitNormal * 64);
    s.bHideMe = (Owner.Isa('playerpawn')&&ViewPort(PlayerPawn(Owner).player)==none);
    s.DecalPos = HitLocation + HitNormal*9;
 //   s.LightHue = LightHue;
//    s.LightRadius = LightRadius;
    if (bUsesCharge&&Charge<400) s.LightBrightness=byte(Charge*0.6+10);
 //   r = Spawn(class'SBFlashDecal',,, HitLocation+HitNormal*9, Rotator(HitNormal));
 //   r2 = Spawn(class'SBFlashDecal',,, HitLocation+HitNormal*9, Rotator(HitNormal));
 //   lastloc=HitLocation+HitNormal*9;
    if (s==None) GoToState('DeActivated');
  }

Begin:
}

state DeActivated
{
Begin:
  if (s!=none)
    s.Destroy();
/*  if(r != none)
	r.Destroy();
  if(r2 != none)
	r2.Destroy();*/
  Owner.PlaySound(DeActivateSound);
}

//client control: // [U227] unused
state ClientControl { //this is the state that clients (and never server) are always in.

  simulated function bool ClientActivate(){
    Super.ClientActivate();
    if (!bActive)
      Owner.PlaySound(DeActivateSound);
    else
      Owner.PlaySound(ActivateSound);
    Tick(0.0);
    return false;
  }

  simulated function Tick(float delta){ //update beam client-side.
    local Vector HitNormal,HitLocation,EndTrace,X;
    ///local vector newloc;
    if (!bActive){
      if (S!=none)
        S.Destroy();
   /*   if(r != none)
    	r.Destroy();
      if(r2 != none)
	   r2.Destroy();*/
      s=none;
/*      r=none;
      r2=none;*/
      return;
    }
    X=vector(Pawn(Owner).ViewRotation);
    EndTrace = Owner.Location + 10000*X;
    Trace(HitLocation,HitNormal,EndTrace,Owner.Location+vect(0,0,1)*pawn(owner).baseeyeheight, True);
    if (s==none){
      s = Spawn(class'TVFlashLightBeam',Owner, '', HitLocation-X*64);
    }
    else
      s.SetLocation(HitLocation-X*64);
    s.LightRadius = fmin(Vsize(HitLocation-Pawn(Owner).Location)/200,14)+4.0;
    s.DecalPos = HitLocation + HitNormal*9;
    //two decals for some reason?
/*    if (r==none||r.bDeleteMe){
        r = Spawn(class'SBFlashDecal',,,newloc, Rotator(HitNormal));
    }
	else if (lastloc!=newloc){
        r.DetachDecal();
        r.SetLocation(newloc);
        r.SetRotation(rotator(HitNormal));
        r.AttachDecal(100, vect(0,0,1));
    }
	if (r2==none||r2.bDeleteMe)
        r2 = Spawn(class'SBFlashDecal',,, newloc, Rotator(HitNormal));
	else if (lastloc!=newloc){
        r2.DetachDecal();
        r2.SetLocation(newloc);
        r2.SetRotation(rotator(HitNormal));
        r2.AttachDecal(100, vect(0,0,1));
    }
    lastloc=newloc;*/
    if (bUsesCharge&&Charge<400)
      s.LightBrightness=byte(Charge*0.6+10);
  }
}

simulated function Destroyed(){
  if (S!=none)
    s.Destroy();
/*  if(r != none)
	r.Destroy();
  if(r2 != none)
	r2.Destroy();*/
  Super.Destroyed();
}

defaultproperties
{
     RealClass=Class'UnrealShare.Flashlight'
     bActivatable=True
     bDisplayableInv=True
     RespawnTime=40.000000
     PickupViewMesh=LodMesh'UnrealShare.Flashl'
     StatusIcon=Texture'SevenB.Icons.FlashLightI'
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
