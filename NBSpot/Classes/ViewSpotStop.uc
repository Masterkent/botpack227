//=============================================================================
// ViewSpotStop.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class ViewSpotStop expands Info;

var() float ViewFOV;
var() bool bSwitchToBehindView, bStopPlayer;

var playerpawn oInst;
var float oFOV;
var bool bActive;

var float shaketimer; // player uses this for shaking view
var int shakemag;	// max magnitude in degrees of shaking
var float shakevert; // max vertical shake magnitude
var float maxshake;
var float verttimer;

var name B227_LastPlayerState;

function StopPlayer(Pawn pPawn)
{
	if (pPawn.Physics != PHYS_None)
	{
		pPawn.Velocity = Vect(0,0,0);
		pPawn.SetPhysics(PHYS_Falling);
		B227_LastPlayerState = pPawn.GetStateName();
		pPawn.GotoState('');
	}
}

function SetViewOfPlayer()
{
	if (oInst.ViewTarget != Self)
	{
		if (oInst.ViewTarget != none)
			oInst.EndZoom();
		oInst.ViewTarget = Self;
		oFOV = oInst.DesiredFOV;
		oInst.DesiredFOV = B227_ScaleFOV(ViewFOV, oInst.MainFOV);
		oInst.bBehindView = bSwitchToBehindView;
		if (bStopPlayer)
			StopPlayer(oInst);
	}
}

function ResetViewOfPlayer()
{
	if (oInst.ViewTarget == Self)
	{
		oInst.DesiredFOV = oFOV;
		oInst.bBehindView = False;
		oInst.ViewTarget = None;
		if (bStopPlayer)
			oInst.GotoState(B227_LastPlayerState);
	}
	oInst = None;
}

auto state ViewSpot
{
	event Tick(float DeltaTime)
	{
		if (oInst == none ||
			oInst.Health <= 0 ||
			oInst.bHidden)
		{
			Disable('Tick');
			if (oInst != none)
				oInst.ViewTarget = None;
			bActive = False;
		}
		else
			if (Projectile(oInst.ViewTarget) == none)
				SetViewOfPlayer();
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (!bActive && PlayerPawn(Other) != none)
		{
			if (oInst != none)
				ResetViewOfPlayer();
			oInst = PlayerPawn(other);
			Enable('Tick');
			//SetViewOfPlayer();
			bActive = True;
		}
	}

	function UnTrigger( Actor other, Pawn EventInstigator )
	{
		if (bActive && oInst == Other)
		{
			Disable('Tick');
			if (OInst != none)
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

static function float B227_ScaleFOV(float FOV, float MainFOV)
{
	return Atan(Tan(FClamp(FOV, 1, 179) * Pi / 360) * Tan(FClamp(MainFOV, 90, 179) * Pi / 360)) * 360 / Pi;
}

defaultproperties
{
				ViewFOV=90.000000
				bStopPlayer=True
				bDirectional=True
				Texture=Texture'Engine.S_Camera'
				DrawScale=0.800000
}
