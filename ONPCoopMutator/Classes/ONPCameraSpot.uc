// ============================================================================
// CameraSpot
// Copyright 2001-2002 by Mychaeel <mychaeel@planetunreal.com>
//
// Designates a view spot for players. When this actor is triggered, sets the
// instigator's viewpoint to itself; when untriggered, sets the instigator's
// viewpoint back to him/herself.
// ============================================================================


class ONPCameraSpot expands Keypoint;


// ============================================================================
// Properties
// ============================================================================

var() int FieldOfView;
var() float TimeRotate;
var() float TimeStill;
var() string Caption;
var() Color CaptionColor;
var() Texture OverlayTexturesModulated[12];
var() Texture OverlayTexturesTranslucent[12];


// ============================================================================
// Variables
// ============================================================================

var PlayerPawn PlayerLocal;
var bool FlagActivePrev;
var float FadeCaption;

var rotator RotationStart;
var rotator RotationRateCurrent;

var KeyPoint OriginalCameraSpot;

replication
{
	reliable if (Role == ROLE_Authority)
		OriginalCameraSpot;
}

// Replacement
static function ReplaceCameraSpot(KeyPoint CameraSpot)
{
	local ONPCameraSpot ONPCameraSpot;

	ONPCameraSpot = CameraSpot.Spawn(class'ONPCameraSpot',, CameraSpot.Tag);
	if (ONPCameraSpot == none)
		return;
	ONPCameraSpot.CopyCameraSpot(CameraSpot);
	CameraSpot.Tag = '';
}

simulated function CopyCameraSpot(KeyPoint CameraSpot)
{
	local int i;

	SetLocation(CameraSpot.Location);
	SetRotation(CameraSpot.Rotation);

	FieldOfView = int(CameraSpot.GetPropertyText("FieldOfView"));
	TimeRotate = float(CameraSpot.GetPropertyText("TimeRotate"));
	TimeStill = float(CameraSpot.GetPropertyText("TimeStill"));
	Caption = CameraSpot.GetPropertyText("Caption");
	SetPropertyText("CaptionColor", CameraSpot.GetPropertyText("CaptionColor"));

	for (i = 0; i < ArrayCount(OverlayTexturesModulated); ++i)
		SetPropertyText("OverlayTexturesModulated[" $ i $ "]", CameraSpot.GetPropertyText("OverlayTexturesModulated[" $ i @ "]"));
	for (i = 0; i < ArrayCount(OverlayTexturesTranslucent); ++i)
		SetPropertyText("OverlayTexturesTranslucent[" $ i $ "]", CameraSpot.GetPropertyText("OverlayTexturesTranslucent[" $ i @ "]"));

	OriginalCameraSpot = CameraSpot;
}

simulated event PostNetBeginPlay()
{
	if (OriginalCameraSpot != none)
		CopyCameraSpot(OriginalCameraSpot);
}

// ============================================================================
// Trigger
// ============================================================================

event Trigger(Actor ActorOther, Pawn PawnInstigator) {

  if (PlayerPawn(PawnInstigator) != None)
    CameraSpotSet(PlayerPawn(PawnInstigator));
  }


// ============================================================================
// UnTrigger
// ============================================================================

event UnTrigger(Actor ActorOther, Pawn PawnInstigator) {

  if (PlayerPawn(PawnInstigator) != None)
    CameraSpotUnset(PlayerPawn(PawnInstigator));
  }
  

// ============================================================================
// Tick
// ============================================================================

simulated event Tick(float TimeDelta) {

  local bool FlagActive;

  if (PlayerLocal == None) {
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

    if (PlayerLocal == None)
      return;
    }

  FlagActive = PlayerLocal.ViewTarget == Self;

  if (FlagActive)
    CameraSpotSet(PlayerLocal);
  else if (FlagActivePrev)
    CameraSpotUnset(PlayerLocal);

  FadeCaption -= TimeDelta * 1.4;
  if (FadeCaption <= 0.3)
    FadeCaption = 1.0;

  FlagActivePrev = FlagActive;
  }


// ============================================================================
// RenderOverlays
// ============================================================================

simulated event RenderOverlays(Canvas Canvas) {

  RenderOverlayTextures(Canvas, ERenderStyle.STY_Modulated,   OverlayTexturesModulated);
  RenderOverlayTextures(Canvas, ERenderStyle.STY_Translucent, OverlayTexturesTranslucent);

  if (Len(Caption) == 0)
    return;

  Canvas.DrawColor = class'UTC_HUD'.static.B227_MultiplyColor(CaptionColor, FadeCaption);
  if (ChallengeHUD(Canvas.Viewport.Actor.MyHUD) != none)
    Canvas.Font = ChallengeHUD(Canvas.Viewport.Actor.MyHUD).MyFonts.GetSmallFont(Canvas.ClipX);
  else
    Canvas.Font = class'Botpack.FontInfo'.static.GetStaticSmallFont(Canvas.ClipX);
  Canvas.Style = ERenderStyle.STY_Translucent;
  Canvas.bCenter = true;
  Canvas.SetPos(0, Canvas.ClipY * 0.9);
  Canvas.DrawText(Caption);
  }


// ============================================================================
// RenderOverlayTextures
//
// Renders a full-screen overlay with the given textures, tiling them if more
// than one texture is given.
// ============================================================================

simulated function RenderOverlayTextures(Canvas Canvas, ERenderStyle Style, Texture OverlayTextures[12]) {

  local int IndexTexture;
  local int HeightTexture;
  local int WidthTexture;
  local int TextureX;
  local int TextureY;

  if (OverlayTextures[0] == None)
    return;

       if (OverlayTextures[11] != None) WidthTexture = (Canvas.ClipX + 3) / 4;
  else if (OverlayTextures[ 8] != None) WidthTexture = (Canvas.ClipX + 2) / 3;
  else if (OverlayTextures[ 3] != None) WidthTexture = (Canvas.ClipX + 1) / 2;
  else if (OverlayTextures[ 1] != None) WidthTexture =  Canvas.ClipX * 3/4;
  else                                  WidthTexture =  Canvas.ClipX;

  HeightTexture = WidthTexture * (Canvas.ClipY * 4) / (Canvas.ClipX * 3);

  Canvas.Style = Style;
  Canvas.DrawColor.R = 255;
  Canvas.DrawColor.G = 255;
  Canvas.DrawColor.B = 255;
  Canvas.bNoSmooth = WidthTexture < Canvas.ClipX;

  for (IndexTexture = 0; IndexTexture < ArrayCount(OverlayTextures); IndexTexture++) {
    if (OverlayTextures[IndexTexture] != None) {
      Canvas.SetPos(TextureX, TextureY);
      Canvas.DrawRect(OverlayTextures[IndexTexture], WidthTexture, HeightTexture);
      }

    TextureX += WidthTexture;

    if (TextureX >= Canvas.ClipX) {
      TextureX = 0;
      TextureY += HeightTexture;
      }

    if (TextureY >= Canvas.ClipY)
      break;
    }
  }


// ============================================================================
// CameraSpotSet
//
// Sets the local player's view point to this camera spot, hides heads-up
// display and crosshair and disables behind view.
// ============================================================================

simulated function CameraSpotSet(PlayerPawn PlayerViewer) {

  PlayerViewer.ViewTarget = Self;
  PlayerViewer.bBehindView = false;
  PlayerViewer.FovAngle = FMax(FieldOfView, (360 / Pi) * Atan(Tan(FieldOfView * Pi / 360) * Tan(PlayerViewer.MainFOV * Pi / 360)));
  PlayerViewer.DesiredFOV = PlayerViewer.FovAngle;

  if (ChallengeHUD(PlayerViewer.MyHUD) == None)
    return;

  ChallengeHUD(PlayerViewer.MyHUD).Crosshair = ChallengeHUD(PlayerViewer.MyHUD).CrosshairCount;
  ChallengeHUD(PlayerViewer.MyHUD).bHideHUD = true;
  }


// ============================================================================
// CameraSpotUnset
//
// Resets the local player's view point to him/herself and resets all other
// properties set by CameraSpotSet.
// ============================================================================

simulated function CameraSpotUnset(PlayerPawn PlayerViewer) {

  FlagActivePrev = false;

  if (PlayerViewer.ViewTarget == Self)
    PlayerViewer.ViewTarget = None;
  ///PlayerViewer.FovAngle = PlayerViewer.default.FovAngle;
  PlayerViewer.FovAngle = PlayerViewer.DefaultFOV;
  PlayerViewer.DesiredFOV = PlayerViewer.DefaultFOV;

  if (ChallengeHUD(PlayerViewer.MyHUD) == None)
    return;

  ChallengeHUD(PlayerViewer.MyHUD).Crosshair = ChallengeHUD(PlayerViewer.MyHUD).default.Crosshair;
  ChallengeHUD(PlayerViewer.MyHUD).bHideHUD  = ChallengeHUD(PlayerViewer.MyHUD).default.bHideHUD;
  }


// ============================================================================
// state RotateNone
// ============================================================================

auto simulated state() RotateNone {

  // nothing
  }


// ============================================================================
// state RotateToggle
// ============================================================================

simulated state() RotateToggle {

  // ==========================================================================
  // Tick
  // ==========================================================================

  simulated event Tick(float TimeDelta) {

    Global.Tick(TimeDelta);

    // Something is rotten in the state of this actor. I seriously have no
    // clue why this workaround is necessary to keep the engine from using a
    // multiple of the actual RotationRate to rotate this actor on clients.
    // Strange... very strange.

    SetRotation(Rotation + RotationRate * TimeDelta);
    }


  // ==========================================================================
  // State
  // ==========================================================================

  Begin:
    RotationStart = Rotation;
    RotationRateCurrent = RotationRate;

  Rotate:
    RotationRate.Yaw   = 0;
    RotationRate.Pitch = 0;
    RotationRate.Roll  = 0;
    Sleep(TimeStill);

    RotationRate = RotationRateCurrent;
    Sleep(TimeRotate);

    RotationRateCurrent.Yaw   = -RotationRateCurrent.Yaw;
    RotationRateCurrent.Pitch = -RotationRateCurrent.Pitch;
    RotationRateCurrent.Roll  = -RotationRateCurrent.Roll;

    if (RotationRateCurrent == default.RotationRate)
      SetRotation(RotationStart);
    
    goto 'Rotate';
  }


// ============================================================================
// state RotateContinuous
// ============================================================================

simulated state() RotateContinuous {

  Begin:
    SetPhysics(PHYS_Rotating);
    bFixedRotationDir = true;
  }

defaultproperties
{
	bStatic=False
	RemoteRole=ROLE_SimulatedProxy
}
