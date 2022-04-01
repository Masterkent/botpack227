// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// NonBuggyViewSpot : A viewspot (by beppo) without the annoying bugs!
// ===============================================================

class NonBuggyViewSpot expands Info;


var() float ViewFOV;
var() bool bSwitchToBehindView;

var playerpawn oInst;
var float oFOV;
var bool bActive;

function SetViewOfPlayer()
{
  if (oInst.ViewTarget != Self)
  {
    oInst.ViewTarget = Self;
    oFOV = oInst.DesiredFOV;
    oInst.DesiredFOV = ViewFOV;
    oInst.bBehindView = bSwitchToBehindView;
  }
}

function ResetViewOfPlayer()
{
  if (oInst.ViewTarget == Self)
  {
    oInst.DesiredFOV = oFOV;
    oInst.bBehindView = False;
    oInst.ViewTarget = None;
  }
  oInst = None;
}

function Tick (float DeltaTime)
{
  if  (oInst == None || oInst.Health <= 0)
  {
    Disable('Tick');
    if (oInst!=none)
      oInst.ViewTarget = None;
    bActive = False;
  }
  else if (oinst.ViewTarget==none||!oInst.ViewTarget.IsA('Projectile'))
      SetViewOfPlayer();
}

function Trigger( Actor other, Pawn EventInstigator )
{
  if (!bActive && EventInstigator.IsA('PlayerPawn'))
  {
    if ( oInst != None )
    {
      ResetViewOfPlayer();
    }
    oInst = PlayerPawn(EventInstigator);
    if ( oInst != None )
    {
      Enable('Tick');
//      SetViewOfPlayer();
      bActive = True;
    }
  }
}

function UnTrigger( Actor other, Pawn EventInstigator )
{
  if (bActive)
  {
    Disable('Tick');
    ResetViewOfPlayer();
    bActive = False;
  }
}

function PostBeginPlay(){
  Disable('Tick');
}

defaultproperties
{
     ViewFOV=90.000000
     bDirectional=True
     Texture=Texture'Engine.S_Camera'
     DrawScale=0.800000
}
