// Root window
// Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCRootWindow extends UMenuRootWindow;

function Paint(Canvas C, float MouseX, float MouseY)
{
	local int XOffset, YOffset;
	local float W, H;

	if(Console.bNoDrawWorld)
	{
		DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MenuBlack');

		if (Console.bBlackOut)
			return;

		W = WinWidth / 3;
		//H = W;

		//if(H > WinHeight / 2)
		//{
		H = WinHeight / 2;
		//	W = H;
		//}

		XOffset = (WinWidth - (3 * (W-1))) / 2;
		YOffset = (WinHeight - (2 * (H-1))) / 2;

		C.bNoSmooth = False;

		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'NCBg12');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'NCBg11');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'NCBg10');

		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'NCBg22');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'NCBg21');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'NCBg20');
		C.bNoSmooth = True;
	}
}

defaultproperties
{
}
