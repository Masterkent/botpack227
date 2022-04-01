//=============================================================================
// ChallengeHUD
// AX
//=============================================================================
class axHUD extends challengeHUD
	config;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

/////////this one
simulated function DrawFragCount(Canvas Canvas)
{
	local float Whiten;
	local int X,Y;

	if ( PawnOwner.PlayerReplicationInfo == None )
		return;

	Canvas.Style = Style;
	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 63.5 * Scale;
	else
		Y = Canvas.ClipY - 127.5 * Scale;
	if ( bHideAllWeapons )
		X = 0.5 * Canvas.ClipX - 256 * Scale;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawColor = HUDColor;
	Whiten = Level.TimeSeconds - ScoreTime;
	if ( Whiten < 3.0 )
	{
		if ( HudColor == GoldColor )
			Canvas.DrawColor = WhiteColor;
		else
			Canvas.DrawColor = GoldColor;
		if ( Level.bHighDetailMode )
		{
			Canvas.CurX = X - 64 * Scale;
			Canvas.CurY = Y - 32 * Scale;
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawTile(Texture'Ax.AXHUDW', 256 * Scale, 128 * Scale, 0, 128, 256.0, 128.0);
		}
		Canvas.CurX = X;
		Canvas.CurY = Y;
		Whiten = 4 * Whiten - int(4 * Whiten);
		Canvas.DrawColor = class'UTC_HUD'.static.B227_AddColor(
			Canvas.DrawColor,
			class'UTC_HUD'.static.B227_MultiplyColor(class'UTC_HUD'.static.B227_SubtractColor(HUDColor, Canvas.DrawColor), Whiten));
	}

	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 128, 128.0, 64.0);
	Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, PawnOwner.PlayerReplicationInfo.Score, X + 40 * Scale, Y + 16 * Scale);
}


simulated function DrawGameSynopsis(Canvas Canvas)
{
	local float XL, YL, YOffset;
	local string Spread;

	if ( (PawnOwner.PlayerReplicationInfo == None)
		|| PawnOwner.PlayerReplicationInfo.bIsSpectator
		|| (PlayerCount == 1) )
		return;

	Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	Canvas.DrawColor = WhiteColor;

	// Rank String
	Canvas.StrLen(RankString, XL, YL);
	if ( bHideAllWeapons )
		YOffset = Canvas.ClipY - YL*2;
	else if ( HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale )
		YOffset = Canvas.ClipY - 64*Scale - YL*2;
	else
		YOffset = Canvas.ClipY - 128*Scale - YL*2;
	Canvas.SetPos(0, YOffset);
	Canvas.DrawText(RankString, False);
	if (bTiedScore)
		Canvas.DrawColor = RedColor;
	Canvas.SetPos(XL, YOffset);
	Canvas.DrawText(" "$Rank@"/"@PlayerCount, False);
	Canvas.DrawColor = WhiteColor;

	// Spread String
	Canvas.SetPos(0, YOffset + YL);
	if (Lead > 0)
		Spread = SpreadString$" +"$Lead;
	else
		Spread = SpreadString$" "$Lead;

	Canvas.DrawText(Spread, False);
}
//////////this one

simulated function DrawWeapons(Canvas Canvas)
{
	local Weapon W, WeaponSlot[11];
	local inventory Inv;
	local int i, BaseY, BaseX, Pending, WeapX, WeapY;
	local float AmmoScale, WeaponOffset, WeapScale, WeaponX, TexX, TexY;

	BaseX = 0.5 * (Canvas.ClipX - HudScale * WeaponScale * Canvas.ClipX);
	WeapScale = WeaponScale * Scale;
	Canvas.Style = Style;
	BaseY = Canvas.ClipY - 63.5 * WeapScale;
	WeaponOffset = 0.1 * HUDScale * WeaponScale * Canvas.ClipX;

	if ( PawnOwner.Weapon != None )
	{
		W = PawnOwner.Weapon;
		if ( (Opacity > 8) || !Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Normal;
		WeaponX = BaseX + (W.InventoryGroup - 1) * WeaponOffset;
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawColor = SolidHUDColor;
		Canvas.DrawIcon(W.StatusIcon, WeapScale);
		Canvas.DrawColor = GoldColor;
		Canvas.CurX = WeaponX + 4 * WeapScale;
		Canvas.CurY = BaseY + 4 * WeapScale;
		Canvas.Style = Style;
		if ( W.InventoryGroup == 10 )
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 0, 0, 25.0, 64.0);
		else
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 25*W.InventoryGroup, 0, 25.0, 64.0);

		WeaponSlot[W.InventoryGroup] = W;
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawTile(Texture'ax.AXHUDW', 128 * WeapScale, 64 * WeapScale, 128, 64, 128, 64);
	}
	if ( Level.bHighDetailMode && (PawnOwner.PendingWeapon != None) )
	{
		Pending = PawnOwner.PendingWeapon.InventoryGroup;
		Canvas.CurX = BaseX + (Pending - 1) * WeaponOffset - 64 * WeapScale;
		Canvas.CurY = Canvas.ClipY - 96 * WeapScale;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = GoldColor;
		Canvas.DrawTile(Texture'ax.AXHUDW', 256 * WeapScale, 128 * WeapScale, 0, 128, 256.0, 128.0);
	}
	else
		Pending = 100;

	Canvas.Style = Style;
	i = 0;
	for ( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Inv.IsA('Weapon') && (Inv != PawnOwner.Weapon) )
		{
			W = Weapon(Inv);
			if ( WeaponSlot[W.InventoryGroup] == None )
				WeaponSlot[W.InventoryGroup] = W;
			else if ( (WeaponSlot[W.InventoryGroup] != PawnOwner.Weapon)
					&& ((W == PawnOwner.PendingWeapon) || (WeaponSlot[W.InventoryGroup].AutoSwitchPriority < W.AutoSwitchPriority)) )
				WeaponSlot[W.InventoryGroup] = W;
		}
		i++;
		if ( i > 100 )
			break; // can occasionally get temporary loops in netplay
	}
	W = PawnOwner.Weapon;

	// draw weapon list
	TexX = 128 * WeapScale;
	TexY = 64 * WeapScale;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] == None )
		{
			Canvas.Style = Style;
			Canvas.DrawColor = class'UTC_HUD'.static.B227_MultiplyColor(HUDColor, 0.5);
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;

			WeapX = ((i-1)%4) * 64;
			WeapY = ((i-1)/4) * 32;
			Canvas.DrawTile(Texture'ax.AXHUDW',TexX,TexY,WeapX,WeapY,64.0,32.0);
		}
		else if ( WeaponSlot[i] != W )
		{
			if ( Pending == i )
			{
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.DrawColor = SolidHUDColor;
			}
			else
			{
				Canvas.Style = Style;
				Canvas.DrawColor = class'UTC_HUD'.static.B227_MultiplyColor(HUDColor, 0.5);
			}
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;

			if (UTC_Weapon(WeaponSlot[i]) != none && UTC_Weapon(WeaponSlot[i]).bSpecialIcon )
				Canvas.DrawIcon(WeaponSlot[i].StatusIcon, WeapScale);
			else
			{
				WeapX = ((i-1)%4) * 64;
				WeapY = ((i-1)/4) * 32;
				Canvas.DrawTile(Texture'ax.AXHUDW',TexX,TexY,WeapX,WeapY,64.0,32.0);
			}
		}
	}

	//draw weapon numbers and ammo
	TexX = 0.75 * WeapScale * 25;
	TexY = 0.75 * WeapScale * 64;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] != None )
		{
			WeaponX = BaseX + (i - 1) * WeaponOffset + 4 * WeapScale;
			if ( WeaponSlot[i] != W )
			{
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 4 * WeapScale;
				Canvas.DrawColor = GoldColor;
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				else
					Canvas.Style = Style;
				if ( i == 10 )
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 0, 0, 25.0, 64.0);
				else
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 25*i, 0, 25.0, 64.0);
			}
			if ( WeaponSlot[i].AmmoType != None )
			{
				// Draw Ammo bar
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 52 * WeapScale;
				Canvas.DrawColor = BaseColor;
				AmmoScale = FClamp(88.0 * WeapScale * WeaponSlot[i].AmmoType.AmmoAmount/WeaponSlot[i].AmmoType.MaxAmmo, 0, 88);
				Canvas.DrawTile(Texture'BotPack.HudElements1', AmmoScale, 8 * WeapScale,64,64,128.0,8.0);
			}
		}
	}
}

defaultproperties
{
}
