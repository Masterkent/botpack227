class ServerInfoDOM expands ServerInfoTeam;

function DrawServerStats( canvas C, TournamentGameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;
	local TournamentGameReplicationInfo TGRI;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont(B227_ScaledFontScreenWidth(C));
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 );
	C.DrawText( ServerStatsText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(C));
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GamesHostedText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	TGRI = GRI;

	C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( TGRI.TotalGames, True);
}

function DrawGameStats( canvas C, TournamentGameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;
	local int i, NumBots;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont(B227_ScaledFontScreenWidth(C));
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 );
	C.DrawText( GameStatsText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(C));
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GameTypeText, True);

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( PlayersText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.SetPos( (C.ClipX / 8)*2, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GRI.GameName, True);

	for (i=0; i<32; i++)
		if ((GRI.PRIArray[i] != None) && (GRI.PRIArray[i].bIsABot))
			NumBots++;
	C.SetPos( (C.ClipX / 8)*2, (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( GRI.NumPlayers$"   ["$NumBots@BotText$"]", True);
}

function DrawLeaderBoard( canvas C, TournamentGameReplicationInfo GRI )
{
}

defaultproperties
{
}
