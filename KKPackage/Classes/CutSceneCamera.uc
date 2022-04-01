// by Raven
class CutSceneCamera extends Keypoint;

var HUDTrigger NextTrigger;

simulated function CameraDisable(PlayerPawn Sender)
{
    if( Sender == none ) return;
    if( Sender.ViewTarget == Self ) Sender.ViewTarget = None;
    if( AmbientSound != none ) AmbientSound=none;
}

simulated function CameraEndable(PlayerPawn Sender)
{
    if( Sender == none ) return;
    if( Sender.ViewTarget == none ) Sender.ViewTarget = self;
}

function InterpolateEnd(actor Other)
{
	CameraDisable(PlayerPawn(Owner));
	if( PlayerPawn(Owner).myHUD == none ) return;
	if( KKHUD(PlayerPawn(Owner).myHUD) == none ) return;
	KKHUD(PlayerPawn(Owner).myHUD).bNoHud = false;
	KKHUD(PlayerPawn(Owner).myHUD).Overlay = none;
}

defaultproperties
{
     bStatic=False
     bDirectional=True
}
