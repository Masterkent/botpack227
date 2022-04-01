// by Raven
class HUDTrigger extends Triggers;

var(HUDTrigger) bool bNoHUD;
var(HUDTrigger) name CameraName;
var(HUDTrigger) sound CameraAmbientSound;
var(HUDTrigger) sound CameraStartSound;
var(HUDTrigger) bool SetCamera;
var(HUDTrigger) texture Overlay;
var name DisableTrigger;

simulated function CutSceneCamera ReturnCamera()
{
           local CutSceneCamera Cam;

           foreach AllActors(class'CutSceneCamera', Cam, CameraName)
           {
               return Cam;
               break;
           }
           return none;
}

simulated function PlayerPawn ReturnPP()
{
           local PlayerPawn PP;

           foreach AllActors(class'PlayerPawn', PP)
           {
               return PP;
               break;
           }
           return none;
}

simulated function HUDTrigger ReturnHUDTrigger()
{
           local HUDTrigger HT;

           foreach AllActors(class'HUDTrigger', HT, DisableTrigger)
           {
               return HT;
               break;
           }
           return none;
}

function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerPawn Sender;

	Sender=PlayerPawn(Other);
	if(Sender == none) return;
	if( Sender.myHUD == none ) return;
	if( KKHUD(Sender.myHUD) == none ) return;
	KKHUD(Sender.myHUD).bNoHud = bNoHUD;
	KKHUD(Sender.myHUD).Overlay = Overlay;


	if(SetCamera && ReturnCamera() != none)
	{
		ReturnCamera().CameraEndable(Sender);
		if( CameraStartSound != none )
	               ReturnCamera().PlaySound(CameraStartSound);
	        if( CameraAmbientSound != none )
		        ReturnCamera().AmbientSound = CameraAmbientSound;
		ReturnCamera().SetOwner(Sender);
		ReturnCamera().NextTrigger=ReturnHUDTrigger();

	}
	else if(!SetCamera && ReturnCamera() != none)
	{
		ReturnCamera().CameraDisable(Sender);
	}
}

defaultproperties
{
     bNoHUD=True
}
