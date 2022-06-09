//=============================================================================
// ViewSpot.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class ViewSpot expands Info;

var() float ViewFOV;
var() bool bSwitchToBehindView;

var playerpawn oInst;
var float oFOV;
var bool bActive;

var float shaketimer; // player uses this for shaking view
var int shakemag;	// max magnitude in degrees of shaking
var float shakevert; // max vertical shake magnitude
var float maxshake;
var float verttimer;

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

auto state ViewSpot
{

function Tick (float DeltaTime)
{
	if (oInst == none)
		return;
	if (oInst.Health <= 0 || oInst.bHidden)
	{
		Disable('Tick');
		oInst.ViewTarget = None;
		bActive = False;
	}
	else
		if (Projectile(oInst.ViewTarget) == none)
			SetViewOfPlayer();
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	if (!bActive && PlayerPawn(Other) != none)
	{
		if (oInst != None)
			ResetViewOfPlayer();
		oInst = PlayerPawn(Other);
		if (oInst != None)
		{
			Enable('Tick');
//			SetViewOfPlayer();
			bActive = True;
		}
	}
}

function UnTrigger( Actor Other, Pawn EventInstigator )
{
	if (bActive && oInst == Other)
	{
		Disable('Tick');
		ResetViewOfPlayer();
		bActive = False;
	}
}

Begin:
	Disable('Tick');
	oInst = None;
	bActive = False;
}

function ClientShake(vector shake)
{
	if ( (shakemag < shake.X) || (shaketimer <= 0.01 * shake.Y) )
	{
		shakemag = shake.X;
		shaketimer = 0.01 * shake.Y;
		maxshake = 0.01 * shake.Z;
		verttimer = 0;
		ShakeVert = -1.1 * maxshake;
	}
}

function ShakeView( float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	shake.X = RollMag;
	shake.Y = 100 * shaketime;
	shake.Z = 100 * vertmag;
	ClientShake(shake);
}

defaultproperties
{
     ViewFOV=90.000000
     bDirectional=True
     Texture=Texture'Engine.S_Camera'
     DrawScale=0.800000
}
