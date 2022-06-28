//=============================================================================
// Letterbox.
//=============================================================================
class Letterbox expands MovieHUD;

function DrawHUDOverlay(Canvas C)
{
	C.SetOrigin(0,0);
	C.SetPos(0,0);
	C.DrawPattern(texture'BlackTexture', C.ClipX, C.ClipY*0.2, 1);
	C.SetPos(0,C.ClipY*0.8);
	C.DrawPattern(texture'BlackTexture', C.ClipX, C.ClipY*0.2, 1);
}

defaultproperties
{
				TextColor=(R=0)
				DialogueFontSize=0
}
