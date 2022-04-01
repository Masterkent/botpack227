//=============================================================================
// UnrealHUD
// Parent class of heads up display
//=============================================================================
class KKHUD extends UnrealHUD;

var bool bNoHUD;
var texture Overlay;
var float FadeInType;
var bool bShouldFadeOut;
var bool bForceOverlay;

simulated function RenderOverlay( canvas Canvas )
{
	if( Overlay != none )
	{
		if( !bShouldFadeOut )
		{
			if( FadeInType < 1 )
				FadeInType+=0.005;
			else if( FadeInType >= 1 )
				FadeInType=1;
		}
		else
		{
			if( FadeInType > 0 )
				FadeInType-=0.005;
			else if( FadeInType <= 0 )
			{
				FadeInType=0;
				Overlay=none;
				return;
			}
		}
		Canvas.DrawColor.r = byte(255*FadeInType);
		Canvas.DrawColor.g = byte(255*FadeInType);
		Canvas.DrawColor.b = byte(255*FadeInType);
		Canvas.SetPos(0, 0);
		Canvas.Style = ERenderStyle.STY_Translucent;
      		Canvas.DrawRect(Overlay, Canvas.ClipX, Canvas.ClipY);
	}
	else
	{
		//BroadCastMessage("chuj");
		bForceOverlay=false;
		bShouldFadeOut=false;
		bNoHUD=false;
        }
}

simulated function PostRender( canvas Canvas )
{
	HUDSetup(canvas);

	if( bNoHUD )
	{
		RenderOverlay(Canvas);
		return;
	}
	if( bForceOverlay )
		RenderOverlay(Canvas);

	Super.PostRender(Canvas);
}

defaultproperties
{
}
