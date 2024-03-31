class UTXMenuScreenshotCW227 expands UMenuScreenshotCW;

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	if (Screenshot != None)
	{
		W = Screenshot.USize;
		H = Screenshot.VSize;

		if (WinWidth == 0 || WinHeight == 0)
			return;

		if (W > WinWidth)
		{
			Y = H * WinWidth / W;
			if (Y <= WinHeight)
			{
				W = WinWidth;
				H = Y;
			}
		}
		if (H > WinHeight)
		{
			W *= WinHeight / H;
			H = WinHeight;
		}

		X = (WinWidth - W) / 2;
		Y = (WinHeight - H) / 2;

		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		DrawStretchedTexture(C, X, Y, W, H, Screenshot);

		C.Font = Root.Fonts[F_Normal];

		if (IdealPlayerCount != "")
		{
			TextSize(C, IdealPlayerCount@PlayersText, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*2;
			ClipText(C, X, Y, IdealPlayerCount@PlayersText);
		}

		if (MapAuthor != "")
		{
			TextSize(C, MapAuthor, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*3;
			ClipText(C, X, Y, MapAuthor);
		}

		if (MapTitle != "")
		{
			TextSize(C, MapTitle, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*4;
			ClipText(C, X, Y, MapTitle);
		}
	}
}
