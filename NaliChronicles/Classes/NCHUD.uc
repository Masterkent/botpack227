// NC HUD
// Code by Sergey 'Eater' Levin
//
// Things left to do:
//
// level 16: finish
// upload updated goldbeams
// Get DarkWaver to make his cutscene skip-key compatible
//
// ************************************************
//
// General reminders:
//
// REMEMBER TO ADD AMBIENT SOUNDS AND MUSIC TO MAPS! AND SKYPOINTS!!!!!
// SKY POINTS!!!
// SKY POINTS!!!
// SKY POINTS!!!
// SKY POINTS!!!
//
// ************************************************
//
// WARNINGS:
// Rabbit pickup triggering correct event

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCHUD extends UnrealHUD;

var float spawntime;
var() int invlowend;
var() int invhighend;
var() texture BookIcons[6];
var() texture BookBarIcons[6];
var() byte BookRed[6];
var() byte BookGreen[6];
var() byte BookBlue[6];
var float spellTime;
var globalconfig float spellmTime;
var float weaponTime;
var globalconfig float weaponmTime;
var float inventoryTime;
var globalconfig float inventorymTime;
var int spellBoxMove;
var int wepBoxMove;
var int invBoxMove;
var float lastTime;
var float spellBTime;
var float invBTime;
var float wepBTime;
var globalconfig int convDelayType;

var string bigmessage;
var float bigmessagetime;
var float messagestart;
var bool showmessage;

function float modifySpeakTime(float in) {
	if (convDelayType != 3 || in <= 0)
		return in*((float(convDelayType)/2)+1);
	else
		return 3600;
}

simulated function ShowBigMessage(string S, float T) {
	messagestart = Level.TimeSeconds;
	bigmessagetime = T;
	bigmessage = S;
	showmessage = true;
}

simulated function postbeginplay() {
	super.postbeginplay();
	spawntime = level.timeseconds;
	spelltime = level.timeseconds;
	weapontime = level.timeseconds;
	inventoryTime = level.timeseconds;
}

simulated function ChangeCrosshair(int d)
{
	Crosshair = Crosshair + d;
	if ( Crosshair>6 ) Crosshair=0;
	else if ( Crosshair < 0 ) Crosshair = 6;
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
	if (Crosshair>5) Return;
	Canvas.SetPos(StartX, StartY );
	Canvas.Style = 2;
	if		(Crosshair==0) 	Canvas.DrawIcon(Texture'Crosshair1', 1.0);
	else if (Crosshair==1) 	Canvas.DrawIcon(Texture'Crosshair2', 1.0);
	else if (Crosshair==2) 	Canvas.DrawIcon(Texture'Crosshair3', 1.0);
	else if (Crosshair==3) 	Canvas.DrawIcon(Texture'Crosshair4', 1.0);
	else if (Crosshair==4) 	Canvas.DrawIcon(Texture'Crosshair5', 1.0);
	else if (Crosshair==5) 	Canvas.DrawIcon(Texture'Crosshair7', 1.0);
	Canvas.Style = 1;
}

simulated function PostRender( canvas Canvas )
{
	local int i;
	local float TempX, TempY, TempXClip, LocX;

	HUDSetup(canvas);

	// Render scripted textures for in-game effects
	if (level.timeseconds-spawntime < 3) {
		canvas.style=3;
		canvas.curX=Canvas.Clipx/2-16;
		canvas.curY=Canvas.Clipy-8;
		canvas.DrawIcon(Texture'UnrealShare.Effect55.FireEffect55',0.125);
	}

	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;

	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).PlayerReplicationInfo == None )
			return;
		if ( PlayerPawn(Owner).bShowMenu )
		{
			DisplayMenu(Canvas);
			return;
		}
		if (showmessage) {
			if ((Level.TimeSeconds - messagestart) <= bigmessagetime) {
				TempX = Canvas.ClipX;
				TempY = Canvas.ClipY;
				if (TempX < 800)
					TempXClip = Canvas.ClipX-(512*(Canvas.ClipX/800));
				else
					TempXClip = Canvas.ClipX-512;
				if (TempX < 800)
					LocX = (256*(Canvas.ClipX/800));
				else
					LocX = 256;
				Canvas.SetPos(LocX,Canvas.ClipY-128);
				Canvas.SetPos(LocX,Canvas.ClipY-128);
				Canvas.SetOrigin(LocX,Canvas.ClipY-128);
				Canvas.SetClip(TempXClip,256);
				Canvas.SetPos(0,0);
				Canvas.Font = Font'WhiteFont';
				Canvas.DrawColor.r = 128;
				Canvas.DrawColor.g = 255;
				Canvas.DrawColor.b = 128;
				Canvas.DrawText(bigmessage,false);
				HUDSetup(canvas);
				Canvas.ClipX = TempX;
				Canvas.ClipY = TempY;
			}
			else {
				showmessage = false;
			}
		}
		if ( PlayerPawn(Owner).bShowScores && NCMovie(Level.Game) == none)
		{
			if ( ( PlayerPawn(Owner).Weapon != None ) && ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair ) )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			if ( ( PlayerPawn(Owner).Weapon == None ) && ( NaliMage(Owner).SelectedSpell != None ) )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			if ( (PlayerPawn(Owner).Scoring == None) && (PlayerPawn(Owner).ScoringType != None) )
				PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, PlayerPawn(Owner));
			if ( PlayerPawn(Owner).Scoring != None )
			{
				PlayerPawn(Owner).Scoring.ShowScores(Canvas);
				return;
			}
		}
		else if (Level.LevelAction == LEVACT_None && NCMovie(Level.Game) == none)
		{
			if (PlayerPawn(Owner).Weapon != None) {
				Canvas.Font = Font'WhiteFont';
				PlayerPawn(Owner).Weapon.PostRender(Canvas);
				if ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair )
					DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			}
			else if (NaliMage(Owner).SelectedSpell != None) {
				Canvas.Font = Font'WhiteFont';
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			}
		}

		if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);

	}

	// Message of the Day / Map Info Header
	if (MOTDFadeOutTime != 0.0 && NCMovie(Level.Game) == none)
		DrawMOTD(Canvas);

	if (NCMovie(Level.Game) == none) {
		// Draw all the info
		DrawAllInfo(canvas);

		// Draw diary/logbook
		if (!DrawDiary(canvas))
			DrawLogbook(canvas);

		if (NaliMage(Owner).CurrentTalker != none)
			DrawConvString(canvas);

		if (NaliMage(Owner).ReadableEntry != "")
			DrawReadableString(canvas);

		// Display Identification Info
		DrawIdentifyInfo(Canvas, 0, Canvas.ClipY - 64.0);

		// Draw Alchemy book

		DrawAlchBook(canvas);
	}

	// Team Game Synopsis
	if ( PlayerPawn(Owner) != None && NCMovie(Level.Game) == none)
	{
		if ( (PlayerPawn(Owner).GameReplicationInfo != None) && PlayerPawn(Owner).GameReplicationInfo.bTeamGame)
			DrawTeamGameSynopsis(Canvas);
	}
}

simulated function DrawMOTD(Canvas Canvas)
{
	local GameReplicationInfo GRI;
	local float XL, YL;

	if(Owner == None) return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = true;

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, 32);
	Canvas.StrLen("TEST", XL, YL);
	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, 96 + 1*YL);
	Canvas.DrawText("Map Title: "$Level.Title, true);
	Canvas.SetPos(0.0, 96 + 2*YL);
	Canvas.DrawText("Author: "$Level.Author, true);
	Canvas.SetPos(0.0, 96 + 3*YL);
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0, 96 + 5*YL);
	Canvas.DrawText(Level.LevelEnterText, true);
	Canvas.bCenter = false;

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawReadableString(canvas canvas) {
	local float TempX,TempY, TempXClip, XLoc;

	if (((Level.TimeSeconds-NaliMage(Owner).Readablestart) >= 30.0) ||
		(VSize(NaliMage(Owner).logbookevent.location-owner.location) >
		fMax(NaliMage(Owner).logbookevent.CollisionHeight,NaliMage(Owner).logbookevent.CollisionRadius) +
            fMax(Owner.CollisionHeight,Owner.CollisionRadius))) {
		NaliMage(Owner).ReadableEntry = "";
		return;
	}
	if (Canvas.ClipX < 800)
		TempXClip = Canvas.ClipX-(512*(Canvas.ClipX/800));
	else
		TempXClip = Canvas.ClipX-512;
	if (Canvas.ClipX < 800)
		XLoc = 256*(Canvas.ClipX/800);
	else
		XLoc = 256;
	TempX = Canvas.ClipX;
	TempY = Canvas.ClipY;
	if (NaliMage(Owner).CurrentTalker != none)
		Canvas.SetOrigin(XLoc,Canvas.ClipY-96);
	else
		Canvas.SetOrigin(XLoc,Canvas.ClipY-128);
	Canvas.Font = Font'WhiteFont';
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;
	Canvas.SetClip(TempXClip,96);
	Canvas.SetPos(0,0);
	Canvas.DrawText(NaliMage(Owner).ReadableTitle$": "$NaliMage(Owner).ReadableEntry);
	HUDSetup(canvas);
	Canvas.ClipX = TempX;
	Canvas.ClipY = TempY;
}

simulated function DrawAlchBook(canvas canvas) {
	local NCAlchbook book;
	local float TempX,TempY;

	book = NCAlchbook(Pawn(Owner).FindInventoryType(Class'NCAlchbook'));
	if (book != none) {
		if (book.bCurrentlyActivated) {
			TempX = Canvas.ClipX;
			TempY = Canvas.ClipY;
			Canvas.Font = Font'WhiteFont';
			Canvas.SetPos(Canvas.ClipX/2-128,Canvas.ClipY/2-128);
			Canvas.DrawIcon(Texture'NaliChronicles.bookbg',1.0);
			Canvas.DrawColor.r = 255;
			Canvas.DrawColor.g = 0;
			Canvas.DrawColor.b = 0;
			Canvas.SetOrigin(Canvas.ClipX/2-112,Canvas.ClipY/2-112);
			Canvas.SetClip(96,224);
			Canvas.SetPos(0,0);
			Canvas.DrawText(book.entries[book.viewmode], false);
			HUDSetup(canvas);
			Canvas.ClipX = TempX;
			Canvas.ClipY = TempY;
			if (book.entries[book.viewmode+1] != "") {
				Canvas.DrawColor.r = 255;
				Canvas.DrawColor.g = 0;
				Canvas.DrawColor.b = 0;
				Canvas.Font = Font'WhiteFont';
				Canvas.SetOrigin(Canvas.ClipX/2+16,Canvas.ClipY/2-112);
				Canvas.SetClip(96,224);
				Canvas.SetPos(0,0);
				Canvas.DrawText(book.entries[book.viewmode+1], false);
				HUDSetup(canvas);
				Canvas.ClipX = TempX;
				Canvas.ClipY = TempY;
			}
			Canvas.DrawColor = Canvas.default.DrawColor;
		}
	}
}
simulated function DrawLogBook(canvas canvas) {
	local NCLogbook logbook;
	local float TempX,TempY;

	logbook = NCLogbook(Pawn(Owner).FindInventoryType(Class'NCLogbook'));
	if (logbook != none) {
		if (logbook.bCurrentlyActivated) {
			TempX = Canvas.ClipX;
			TempY = Canvas.ClipY;
			Canvas.Font = Font'WhiteFont';
			Canvas.SetPos(Canvas.ClipX/2-128,96);
			Canvas.DrawText("Entry "$(logbook.viewmode+1)$":");
			Canvas.SetPos(Canvas.ClipX/2-128,112);
			Canvas.DrawText(logbook.mapnames[logbook.viewmode]$", "$logbook.entrytitles[logbook.viewmode], false);
			Canvas.SetOrigin(Canvas.ClipX/2-128,128);
			Canvas.SetClip(256,256);
			Canvas.SetPos(0,0);
			Canvas.DrawText(logbook.entries[logbook.viewmode], false);
			HUDSetup(canvas);
			Canvas.ClipX = TempX;
			Canvas.ClipY = TempY;
		}
	}
}
simulated function bool DrawDiary(canvas canvas) {
	local NCDiary diary;
	local float TempX,TempY;

	diary = NCDiary(Pawn(Owner).FindInventoryType(Class'NCDiary'));
	if (diary != none) {
		if (diary.bCurrentlyActivated) {
			Canvas.DrawColor.r = 128;
			Canvas.DrawColor.b = 128;
			TempX = Canvas.ClipX;
			TempY = Canvas.ClipY;
			Canvas.Font = Font'WhiteFont';
			Canvas.SetPos(Canvas.ClipX/2-128,112);//Canvas.ClipY/2-128-16);
			Canvas.DrawText("Entry "$(diary.viewmode+1)$": "$diary.mapnames[diary.viewmode], false);
			Canvas.SetOrigin(Canvas.ClipX/2-128,128);//Canvas.ClipY/2-128);
			Canvas.SetClip(256,256);
			Canvas.SetPos(0,0);
			Canvas.DrawText(diary.entries[diary.viewmode], false);
			HUDSetup(canvas);
			Canvas.ClipX = TempX;
			Canvas.ClipY = TempY;
			Canvas.DrawColor.r = 255;
			Canvas.DrawColor.b = 255;
			return true;
		}
	}
	return false;
}

simulated function DrawConvString(canvas canvas) {
	local float TempX,TempY,TempXClip,LocX;

	if ((Level.TimeSeconds-NaliMage(Owner).TalkBegin) >= NaliMage(Owner).TalkLast) {
		NaliMage(Owner).CurrentTalker = none;
		return;
	}

	TempX = Canvas.ClipX;
	TempY = Canvas.ClipY;
	if (TempX < 800)
		TempXClip = Canvas.ClipX-(512*(Canvas.ClipX/800));
	else
		TempXClip = Canvas.ClipX-512;
	if (TempX < 800)
		LocX = (256*(Canvas.ClipX/800));
	else
		LocX = 256;
	Canvas.SetPos(LocX,Canvas.ClipY-128);
	Canvas.SetOrigin(LocX,Canvas.ClipY-128);
	Canvas.SetClip(TempXClip,256);
	Canvas.SetPos(0,0);
	Canvas.Font = Font'WhiteFont';
	if (NaliMage(Owner).CurrentTalker == owner) {
		Canvas.DrawColor.r = 255;
		Canvas.DrawColor.g = 255;
		Canvas.DrawColor.b = 255;
	}
	else {
		Canvas.DrawColor.r = 128;
		Canvas.DrawColor.g = 255;
		Canvas.DrawColor.b = 128;
	}
	if (Pawn(NaliMage(Owner).CurrentTalker) != none)
		Canvas.DrawText( Pawn(NaliMage(Owner).CurrentTalker).MenuName $": "$NaliMage(Owner).ConvString,false);
	else if (Inventory(NaliMage(Owner).CurrentTalker) != none)
		Canvas.DrawText(Inventory(NaliMage(Owner).CurrentTalker).ItemName$": "$NaliMage(Owner).ConvString,false);
	else if (NCCommPoint(NaliMage(Owner).CurrentTalker) != none)
		Canvas.DrawText(NCCommPoint(NaliMage(Owner).CurrentTalker).speakName$": "$NaliMage(Owner).ConvString,false);
	else
		Canvas.DrawText(NaliMage(Owner).CurrentTalker.Name$": "$NaliMage(Owner).ConvString,false);
	HUDSetup(canvas);
	Canvas.ClipX = TempX;
	Canvas.ClipY = TempY;
}

simulated function DrawInvItem(canvas canvas, int X, inventory item) {
	Canvas.SetPos(X,0);
	if (item.bActive) {
		Canvas.DrawColor.b = 0;
		Canvas.DrawColor.g = 0;
	}
	Canvas.DrawIcon(item.icon,0.5);
	Canvas.SetPos(X+2,26);
	Canvas.DrawTile(Texture'HudLine',fMin(27.0,27.0*(float(Item.Charge)/float(Item.Default.Charge))),2.0,0,0,32.0,2.0);
	if ( (Pickup(Item) != None) && Pickup(Item).bCanHaveMultipleCopies ) {
		Canvas.SetPos(X+14,20);
		if ((Pickup(Item).NumCopies+1)<100) Canvas.CurX+=6;
		if ((Pickup(Item).NumCopies+1)<10) Canvas.CurX+=6;
		Canvas.Font = Font'TinyRedFont';
		Canvas.DrawText(Pickup(Item).NumCopies+1,False);
	}
	Canvas.DrawColor.b = 255;
	Canvas.DrawColor.g = 255;
}

simulated function DrawSpellIcon(canvas canvas, int X, int Y, ncspell spell) {
	local float multer;

	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(spell.icon,0.5);
	if (!spell.bReadyToCast) {
		Canvas.DrawColor.r = 64;
		Canvas.DrawColor.b = 64;
		Canvas.SetPos(X,Y);
		if (spell.isInState('Casting')) {
			multer = (Level.TimeSeconds-spell.currtime)/spell.casttime;
			if (multer > 1)
				multer = 1;
			Canvas.DrawTile(spell.icon,
					32*multer,32,
					0,0,
					64*multer,64.0);
		}
		else {
			multer = 1-((Level.TimeSeconds-spell.currtime)/spell.recycletime)-(1-spell.percentcompleted);
			if (multer > 1)
				multer = 1;
			Canvas.DrawTile(spell.icon,
					32*multer,32,
					0,0,
					64*multer,64.0);
		}
		Canvas.DrawColor.r = 255;
		Canvas.DrawColor.b = 255;
	}
	Canvas.SetPos(X+4,Y+20);
	Canvas.Font = Font'TinyFont';
	Canvas.DrawText(int(spell.manapersecond*spell.casttime));
}

simulated function float CalcMMana(NCManaZone InZone) {
	return NaliMage(Owner).calcInManaMult(InZone.maxmana,InZone.mmaxmana,InZone.book,InZone.minskill);
}

simulated function DrawAllInfo(canvas canvas) {
	local float barmult;
	local float multer;
	local ncspell spell;
	local int spellx, spelly, spellyy;
	local int armorx, manasourcex;
	local int weaponx, weapony;
	local inventory Inv;
	local float roundhealth;
	local weapon wep[99];
	local weapon weps[99];
	local int j,i,k,l, SelectedIndex;
	local inventory invs[100];
	local inventory SelectedItem;
	local float inventx;

	Canvas.Style=2;

	spellBTime += Level.Timeseconds-lastTime;
	invBTime += Level.Timeseconds-lastTime;
	wepBTime += Level.Timeseconds-lastTime;
	lastTime = Level.TimeSeconds;

	// draw the top inventory

	if (((Pawn(Owner).SelectedItem != none) && ((NaliMage(Owner).CurrentVial != none) || (level.timeseconds-inventorytime < inventorymtime) || (inventorymtime == 0)))) {
		while (invBTime > 0.002) {
			invBTime -= 0.002;
			invBoxMove--;
		}
	}
	else {
		while (invBTime > 0.002) {
			invBTime -= 0.002;
			invBoxMove++;
		}
	}
	if (invBoxMove > 96)
		invBoxMove = 96;
	if (invBoxMove < 0)
		invBoxMove = 0;

	if (invBoxMove < 96 && Pawn(Owner).selecteditem != none) {
		SelectedItem = Pawn(Owner).SelectedItem;
		Canvas.SetPos((Canvas.ClipX/2)-64,32-invBoxMove);
		Canvas.DrawIcon(SelectedItem.icon,1.0);
		Canvas.SetPos((Canvas.ClipX/2)-60,86-invBoxMove);
		if ((NCPickup(SelectedItem) == none) || (NCPickup(SelectedItem).bShowCharge))
			Canvas.DrawTile(Texture'HudLine',fMin(54.0,54.0*(float(SelectedItem.Charge)/float(SelectedItem.Default.Charge))),4.0,0,0,32.0,2.0);
		if ( (Pickup(SelectedItem) != None) && Pickup(SelectedItem).bCanHaveMultipleCopies ) {
			Canvas.SetPos((Canvas.ClipX/2)-24,76-invBoxMove);
			if ((Pickup(SelectedItem).NumCopies+1)<100) Canvas.CurX+=6;
			if ((Pickup(SelectedItem).NumCopies+1)<10) Canvas.CurX+=6;
			Canvas.Font = Font'WhiteFont';
			Canvas.DrawText(Pickup(SelectedItem).NumCopies+1,False);
		}
		Canvas.SetPos(Canvas.ClipX/2,32-invBoxMove);
		if (NCPickup(SelectedItem) != none)
			Canvas.DrawIcon(NCPickup(SelectedItem).infotex,1.0);
		else
			Canvas.DrawIcon(Texture'NaliChronicles.InfoEmpty',1.0);
	}

	if ( (Owner.Inventory!=None) && (Pawn(owner).SelectedItem != none) ) {
		SelectedItem = Pawn(Owner).SelectedItem;
		i=0;
		for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if (NaliMage(Owner).determineUsability(Inv)) {
				invs[i] = Inv;
				if (Inv == SelectedItem)
					SelectedIndex=i;
				i++;
			}
		}
		inventx=(Canvas.ClipX/2)-128;

		if (SelectedIndex > invhighend) {
			invhighend = SelectedIndex;
			invlowend = invhighend-7;
		}
		if (SelectedIndex < invlowend) {
			invlowend = SelectedIndex;
			invhighend = invlowend+7;
		}

		j = invlowend;
		while(j<=invhighend) {
			if (invs[j] != none)
				DrawInvItem(canvas,inventx,invs[j]);
			Canvas.SetPos(inventx,0);
			if (invs[j] == SelectedItem)
				Canvas.DrawIcon(Texture'NaliChronicles.NCSelection',1.0);
			inventx+=32;
			j++;
		}
		Canvas.SetPos((Canvas.ClipX/2)+128,0);
		if (invhighend >= (i-1))
			Canvas.DrawIcon(Texture'NaliChronicles.arrowrna',1.0);
		else
			Canvas.DrawIcon(Texture'NaliChronicles.arrowr',1.0);
		Canvas.SetPos((Canvas.ClipX/2)-160,0);
		if (invlowend <= 0)
			Canvas.DrawIcon(Texture'NaliChronicles.arrowlna',1.0);
		else
			Canvas.DrawIcon(Texture'NaliChronicles.arrowl',1.0);
	}
	i=0;
	j=0;

	Canvas.SetPos((Canvas.ClipX/2)-128,0);
	Canvas.DrawIcon(Texture'NaliChronicles.InvBox',1.0);

	// draw potion mixing stuff

	if (NaliMage(Owner).CurrentVial != none) {
		Canvas.SetPos((Canvas.ClipX/2)-64,96);
		Canvas.DrawIcon(NaliMage(Owner).CurrentVial.borderIcon,1.0);
		j = 0;
		i = 0;
		while (i < 10) {
			if (NaliMage(Owner).CurrentVial.ingredientIndex[i] != none) {
				Canvas.DrawColor = NaliMage(Owner).CurrentVial.ingredientIndex[i].default.IngredientColor;
				Canvas.SetPos((Canvas.ClipX/2)-64+(getChargeRatio(j)*128),96);
				j += NaliMage(Owner).CurrentVial.ingredientAmount[i];
				Canvas.DrawTile(NaliMage(Owner).CurrentVial.filledIcon,(getChargeRatio(NaliMage(Owner).CurrentVial.ingredientAmount[i])*128),NaliMage(Owner).CurrentVial.filledIcon.VSize,Canvas.CurX-((Canvas.ClipX/2)-64),0,(getChargeRatio(NaliMage(Owner).CurrentVial.ingredientAmount[i])*128),NaliMage(Owner).CurrentVial.filledIcon.VSize);
			}
			i++;
		}
		i = 0;
		j = 0;
		Canvas.DrawColor.g = 128;
		Canvas.DrawColor.r = 128;
		Canvas.DrawColor.b = 128;
		Canvas.Style = 3;
		Canvas.SetPos((Canvas.ClipX/2)-64,96);
		Canvas.DrawIcon(NaliMage(Owner).CurrentVial.emptyIcon,1.0);
		Canvas.Style = 4;
		Canvas.SetPos((Canvas.ClipX/2)-64,96);
		Canvas.DrawIcon(NaliMage(Owner).CurrentVial.markIcon,1.0);
		Canvas.Style = 3;
		if (NaliMage(owner).CurrentVial.bBoiling) {
			Canvas.SetPos((Canvas.ClipX/2)-64,68+(NaliMage(Owner).CurrentVial.emptyIcon.VSize));
			Canvas.DrawIcon(Texture'UnrealShare.Effect55.FireEffect55',0.5);
		}
		Canvas.Style = 2;
		Canvas.DrawColor.g = 255;
		Canvas.DrawColor.r = 255;
		Canvas.DrawColor.b = 255;
	}

	// draw the weapons stuff

	Inv=none;

	if (level.timeseconds-weaponTime < weaponmtime || weaponmtime == 0) {
		while (wepBTime > 0.002) {
			wepBTime -= 0.002;
			wepBoxMove--;
		}
	}
	else {
		while (wepBTime > 0.002) {
			wepBTime -= 0.002;
			wepBoxMove++;
		}
	}
	if (wepBoxMove > 64)
		wepBoxMove = 64;
	if (wepBoxMove < 0)
		wepBoxMove = 0;

	weaponx=160;
	weapony=32-wepBoxMove;
	Canvas.Font=Font'TinyFont';

	if (wepBoxMove < 64) {
		for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if (weapon(inv) != none)
			{
				wep[j] = weapon(inv);
				j++;
			}
		}
		j = 0;
		while (k < 11) {
			i = 0;
			while ((wep[i] != none) && (i < 99)) {
				if (wep[i].InventoryGroup == k) {
					weps[j] = wep[i];
					j++;
				}
				i++;
			}
			k++;
		}
		i = 0;
		while ((weps[i] != none) && (i < 99)) {
			Canvas.SetPos(Canvas.ClipX-weaponx,Canvas.ClipY-weapony);
			Canvas.DrawIcon(weps[i].icon,0.5);
			Canvas.SetPos(Canvas.ClipX-weaponx,Canvas.ClipY-weapony);
			Canvas.DrawText(weps[i].inventorygroup,false);
			Canvas.SetPos(Canvas.ClipX-weaponx,Canvas.ClipY-weapony+24);
			if (weps[i].ammotype != none)
				Canvas.DrawText(weps[i].ammotype.ammoamount,false);
			Canvas.SetPos(Canvas.ClipX-weaponx,Canvas.ClipY-weapony);
			if (pawn(owner).weapon == weps[i])
				Canvas.DrawIcon(Texture'NaliChronicles.NCSelection',1.0);
			if (weapony==32-wepBoxMove)
				weapony=64-wepBoxMove;
			else {
				weapony=32-wepBoxMove;
				weaponx+=32;
			}
			i++;
		}
		i = 0;
	}

	if (Pawn(Owner).weapon != none) {
		Canvas.SetPos(Canvas.ClipX-64,Canvas.ClipY-64);
		Canvas.Font=Font'WhiteFont';
		if (NCWeapon(Pawn(Owner).Weapon) != none)
			Canvas.DrawIcon(NCWeapon(Pawn(Owner).Weapon).InfoTexture,1.0);
		else
			Canvas.DrawIcon(Texture'NaliChronicles.InfoEmpty',1.0);

		Canvas.SetPos(Canvas.ClipX-64,Canvas.ClipY-128);
		if (Pawn(Owner).Weapon.AmmoType != none) {
			Canvas.DrawIcon(Pawn(Owner).Weapon.AmmoType.Icon,1.0);
			Canvas.SetPos(Canvas.ClipX-64,Canvas.ClipY-128);
			Canvas.DrawText(pawn(owner).weapon.ammotype.ammoamount,false);
		}

		Canvas.SetPos(Canvas.ClipX-128,Canvas.ClipY-64);
		Canvas.DrawIcon(Pawn(Owner).weapon.icon,1.0);
		Canvas.SetPos(Canvas.ClipX-128,Canvas.ClipY-64);
		Canvas.DrawText(pawn(owner).weapon.inventorygroup,false);
	}

	// draw spell stuff

	Inv=none;

	spellx=0;
	spelly=Canvas.ClipY-64;
	//spellBTime = 0.1;
	if (level.timeseconds-spelltime >= spellmtime && spellmtime != 0) {
		while (spellBTime >= 0.002) {
			spellBTime -= 0.002;
			spellBoxMove++;
		}
	}
	else {
		while (spellBTime >= 0.002) {
			spellBTime -= 0.002;
			spellBoxMove--;
		}
	}
	if (spellBoxMove < 0)
		spellBoxMove = 0;
	if (spellBoxMove > 96)
		spellBoxMove = 96;

	if (spellBoxMove < 96) {
		spelly = Canvas.ClipY-64+spellBoxMove;
		for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == NaliMage(Owner).currentbook)) {
				DrawSpellIcon(canvas,spellX,spellY,NCSpell(Inv));
				if (NaliMage(Owner).HighlightedSpell == NCSpell(Inv)) {
					Canvas.SetPos(spellX,spellY);
					Canvas.DrawIcon(Texture'NaliChronicles.NCSelection',1.0);
				}
				spellx += 32;
				if (spellx > 160) {
					spellx = 0;
					spelly += 32;
				}
			}
		}

		Canvas.SetPos(0,Canvas.ClipY-64+spellBoxMove);
		Canvas.DrawIcon(Texture'NaliChronicles.SpellBox',1.0);

		j = 0;
		while (i < 6) {
			if (NaliMage(Owner).OpenBooks[i] == 1) {
				Canvas.SetPos((32*j),Canvas.ClipY-96+spellBoxMove);
				Canvas.DrawIcon(BookIcons[i],0.5);
				if (NaliMage(Owner).currentbook == i) {
					Canvas.SetPos((32*j),Canvas.ClipY-96+spellBoxMove);
					Canvas.DrawIcon(Texture'NaliChronicles.NCSelection',1.0);
				}
				j++;
			}
			i++;
		}
		Canvas.SetPos(0,Canvas.ClipY-96+spellBoxMove);
		Canvas.DrawIcon(Texture'NaliChronicles.BookBox',1.0);
	}
	spelly = Canvas.ClipY-160+spellBoxMove;
	spellYY = spellY;
	i = 0;
	j = 0;
	spellx = 0;
	while (i < 4) {
		if (NaliMage(Owner).QuickSpells[i] != none) {
			DrawSpellIcon(canvas,spellx,spelly,NaliMage(Owner).QuickSpells[i]);
			Canvas.SetPos(spellx,spelly);
			if (NaliMage(Owner).CurrQuickSpell == i)
				Canvas.DrawIcon(Texture'NaliChronicles.NCSelection',1.0);
		}
		spellx += 32;
		if (spellx == 64) {
			spellx = 0;
			spelly += 32;
		}
		i++;
	}
	Canvas.SetPos(0,spellYY);
	Canvas.DrawIcon(Texture'NaliChronicles.QSBox',1.0);
	if (NaliMage(Owner).SelectedSpell != none) {
		Canvas.SetPos(64,spellYY);
		Canvas.DrawIcon(NaliMage(Owner).SelectedSpell.Icon,1.0);
		Canvas.SetPos(128,spellYY);
		Canvas.DrawIcon(NaliMage(Owner).SelectedSpell.InfoTexture,1.0);
		spell = NaliMage(Owner).SelectedSpell;
		if (!spell.bReadyToCast) {
			Canvas.DrawColor.r = 64;
			Canvas.DrawColor.b = 64;
			Canvas.SetPos(64,spellYY);
			if (spell.isInState('Casting')) {
				multer = (Level.TimeSeconds-spell.currtime)/spell.casttime;
				if (multer > 1)
					multer = 1;
				Canvas.DrawTile(spell.icon,
						64*multer,64,
						0,0,
						64*multer,64.0);
			}
			else {
				multer = 1-((Level.TimeSeconds-spell.currtime)/spell.recycletime)-(1-spell.percentcompleted);
				if (multer > 1)
					multer = 1;
				Canvas.DrawTile(spell.icon,
						64*multer,64,
						0,0,
						64*multer,64.0);
			}
			Canvas.DrawColor.r = 255;
			Canvas.DrawColor.b = 255;
		}
		Canvas.Font=Font'WhiteFont';
		Canvas.SetPos(68,spellYY+52);
		Canvas.DrawText(int(NaliMage(Owner).SelectedSpell.manapersecond*NaliMage(Owner).SelectedSpell.casttime));
	}

	if (Canvas.ClipY < 576)
		barmult=0.5;
	else
		barmult=1.0;

	// draw mana meter

	Canvas.SetPos(4, (Canvas.ClipY/2) + (120*barmult) - ( (NaliMage(owner).mana/NaliMage(owner).maxmana)*(240*barmult) ) );
	Canvas.DrawColor.g = 0;
	Canvas.DrawColor.b = 255*(NaliMage(owner).mana/NaliMage(owner).maxmana);
	Canvas.DrawColor.r = 0;
	Canvas.DrawTile(Texture'HUDgreenAmmo',24,(NaliMage(owner).mana/NaliMage(owner).maxmana)*(240*barmult),0,0,24,(NaliMage(owner).mana/NaliMage(owner).maxmana)*(240*barmult));
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.b = 255;

	Canvas.SetPos(0,(Canvas.ClipY/2)-(128*barmult));
	if (barmult >= 1)
		Canvas.DrawIcon(Texture'NaliChronicles.BarFrame',1.0);
	else
		Canvas.DrawIcon(Texture'NaliChronicles.ShortBarFrame',1.0);

	Canvas.SetPos(0,(Canvas.ClipY/2)-(128*barmult)-32);
	Canvas.DrawIcon(Texture'NaliChronicles.ncMana',1.0);

	if (NaliMage(owner).mana < 100)
		Canvas.SetPos(10,(Canvas.ClipY/2)-8);
	else
		Canvas.SetPos(7,(Canvas.ClipY/2)-8);
	Canvas.Font = Font'SmallFont';
	Canvas.DrawText(int(NaliMage(owner).mana),false);

	// draw mana source list

	manasourcex=32;
	while (l < 10) {
		if ((NaliMage(Owner).ManaZones[l] != none) && ( NaliMage(Owner).CheckSkill(NaliMage(Owner).ManaZones[l].book,NaliMage(Owner).ManaZones[l].minskill) )) {
			Canvas.SetPos(manasourcex+4, (Canvas.ClipY/2) + (120*barmult) - (NaliMage(Owner).ManaZones[l].mmaxmana)*(240*barmult) );
			Canvas.DrawColor.g = float(BookGreen[NaliMage(Owner).ManaZones[l].book])*(NaliMage(Owner).ManaZones[l].mmaxmana*0.5);
			Canvas.DrawColor.r = float(BookRed[NaliMage(Owner).ManaZones[l].book])*(NaliMage(Owner).ManaZones[l].mmaxmana*0.5);
			Canvas.DrawColor.b = float(BookBlue[NaliMage(Owner).ManaZones[l].book])*(NaliMage(Owner).ManaZones[l].mmaxmana*0.5);
			Canvas.DrawTile(Texture'NaliChronicles.BarWhite',24,(NaliMage(Owner).ManaZones[l].mmaxmana)*(240*barmult),0,0,24,(NaliMage(Owner).ManaZones[l].mmaxmana)*(240*barmult));

			Canvas.SetPos(manasourcex+4, (Canvas.ClipY/2) + (120*barmult) - CalcMMana(NaliMage(Owner).ManaZones[l])*(240*barmult) );
			if (CalcMMana(NaliMage(Owner).ManaZones[l]) < 0.25) {
				Canvas.DrawColor.g = float(BookGreen[NaliMage(Owner).ManaZones[l].book])*CalcMMana(NaliMage(Owner).ManaZones[l])*4;
				Canvas.DrawColor.r = float(BookRed[NaliMage(Owner).ManaZones[l].book])*CalcMMana(NaliMage(Owner).ManaZones[l])*4;
				Canvas.DrawColor.b = float(BookBlue[NaliMage(Owner).ManaZones[l].book])*CalcMMana(NaliMage(Owner).ManaZones[l])*4;
			}
			else {
				Canvas.DrawColor.g = BookGreen[NaliMage(Owner).ManaZones[l].book];
				Canvas.DrawColor.r = BookRed[NaliMage(Owner).ManaZones[l].book];
				Canvas.DrawColor.b = BookBlue[NaliMage(Owner).ManaZones[l].book];
			}
			Canvas.DrawTile(Texture'NaliChronicles.BarWhite',24,CalcMMana(NaliMage(Owner).ManaZones[l])*(240*barmult),0,0,24,CalcMMana(NaliMage(Owner).ManaZones[l])*(240*barmult));
			Canvas.DrawColor.g = 255;
			Canvas.DrawColor.r = 255;
			Canvas.DrawColor.b = 255;

			Canvas.SetPos(manasourcex,(Canvas.ClipY/2)-(128*barmult));
			if (barmult >= 1)
				Canvas.DrawIcon(Texture'NaliChronicles.BarFrame',1.0);
			else
				Canvas.DrawIcon(Texture'NaliChronicles.ShortBarFrame',1.0);

			Canvas.SetPos(manasourcex,(Canvas.ClipY/2)-(128*barmult)-32);
			Canvas.DrawIcon(BookBarIcons[NaliMage(Owner).ManaZones[l].book],1.0);

			if (CalcMMana(NaliMage(Owner).ManaZones[l])*NaliMage(owner).maxmana < 100)
				Canvas.SetPos(manasourcex+10,(Canvas.ClipY/2)-8);
			else
				Canvas.SetPos(manasourcex+8,(Canvas.ClipY/2)-8);
			Canvas.DrawText(int(CalcMMana(NaliMage(Owner).ManaZones[l])*NaliMage(owner).maxmana),false);

			manasourcex += 32;
		}
		l++;
	}

	// draw health & armor

	if (Pawn(owner).health > 100)
		roundhealth = 100;
	else
		roundhealth = Pawn(owner).health;
	Canvas.SetPos(Canvas.ClipX-28, (Canvas.ClipY/2) + (120*barmult) - ( (roundhealth/100)*(240*barmult) ) );
	Canvas.DrawColor.g = 0;
	Canvas.DrawColor.r = 255*(roundhealth/100);
	Canvas.DrawColor.b = 0;
	Canvas.DrawTile(Texture'HUDgreenAmmo',24,(roundhealth/100)*(240*barmult),0,0,24,(roundhealth/100)*(240*barmult));
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.b = 255;

	Canvas.SetPos(Canvas.ClipX-32,(Canvas.ClipY/2)-(128*barmult));
	if (barmult >= 1)
		Canvas.DrawIcon(Texture'NaliChronicles.BarFrame',1.0);
	else
		Canvas.DrawIcon(Texture'NaliChronicles.ShortBarFrame',1.0);

	Canvas.SetPos(Canvas.ClipX-32,(Canvas.ClipY/2)-(128*barmult)-32);
	Canvas.DrawIcon(Texture'NaliChronicles.ncHealth',1.0);

	if (Pawn(owner).health < 100)
		Canvas.SetPos(Canvas.ClipX-22,(Canvas.ClipY/2)-8);
	else
		Canvas.SetPos(Canvas.ClipX-24,(Canvas.ClipY/2)-8);
	Canvas.Font = Font'SmallFont';
	Canvas.DrawText(Pawn(owner).health,false);

	armorx = 64;
	Inv=none;
	i = 0;
	j = 0;
	for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if (Inv.bIsAnArmor) {
			i++;
		}
	}
	for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if (Inv.bIsAnArmor) {
			if ((i <= 3) || (j < 2)) {
				Canvas.SetPos(Canvas.ClipX-armorx+4, (Canvas.ClipY/2) + (120*barmult) - (float(inv.charge)/float(inv.default.charge))*(240*barmult) );
				Canvas.DrawColor.g = 255*(float(inv.charge)/float(inv.default.charge));
				Canvas.DrawColor.r = 0;
				Canvas.DrawColor.b = 0;
				Canvas.DrawTile(Texture'HUDgreenAmmo',24,(float(inv.charge)/float(inv.default.charge))*(240*barmult),0,0,24,(float(inv.charge)/float(inv.default.charge))*(240*barmult));
				Canvas.DrawColor.g = 255;
				Canvas.DrawColor.r = 255;
				Canvas.DrawColor.b = 255;

				Canvas.SetPos(Canvas.ClipX-armorx,(Canvas.ClipY/2)-(128*barmult));
				if (barmult >= 1)
					Canvas.DrawIcon(Texture'NaliChronicles.BarFrame',1.0);
				else
					Canvas.DrawIcon(Texture'NaliChronicles.ShortBarFrame',1.0);

				Canvas.SetPos(Canvas.ClipX-armorx,(Canvas.ClipY/2)-(128*barmult)-32);
				Canvas.DrawIcon(Inv.Icon,1.0);

				if (Inv.Charge < 100)
					Canvas.SetPos(Canvas.ClipX-armorx+10,(Canvas.ClipY/2)-8);
				else
					Canvas.SetPos(Canvas.ClipX-armorx+8,(Canvas.ClipY/2)-8);
				Canvas.DrawText(Inv.Charge,false);

				armorx += 32;
				j++;
			}
			else {
				k = j - ((armorx-64)/32);
				Canvas.SetPos(Canvas.ClipX-armorx,((Canvas.ClipY/2)-(128*barmult)-32)+(k*32));
				Canvas.DrawIcon(Inv.Icon,1.0);
				Canvas.SetPos(Canvas.ClipX-armorx+2,((Canvas.ClipY/2)-(128*barmult)-32)+(k*32)+26);
				Canvas.DrawTile(Texture'HudLine',fMin(27.0,27.0*(float(Inv.Charge)/float(Inv.Default.Charge))),2.0,0,0,32.0,2.0);
				if (Inv.Charge > 99)
					Canvas.SetPos(Canvas.ClipX-armorx+12,((Canvas.ClipY/2)-(128*barmult)-32)+(k*32));
				else if (Inv.Charge > 9)
					Canvas.SetPos(Canvas.ClipX-armorx+16,((Canvas.ClipY/2)-(128*barmult)-32)+(k*32));
				else
					Canvas.SetPos(Canvas.ClipX-armorx+20,((Canvas.ClipY/2)-(128*barmult)-32)+(k*32));
				Canvas.DrawText(Inv.Charge,false);
				j++;
				if (k*32 >= 256*barmult) {
					armorx += 32;
					j = ((armorx-64)/32);
				}
			}
		}
	}

	// draw skills

	i = 0;
	j = 0;
	k = 0;
	l = 0;
	while (i < 6) {
		if (NaliMage(Owner).SpellSkills[i] != 0) {
			k = j;
			while (k > 1)
				k -= 2;

			if (k == 1)
				l = (j-1)/2;
			else
				l = j/2;

			Canvas.setPos(Canvas.ClipX-(64+(32*k)),32*l);
			Canvas.DrawIcon(BookIcons[i],0.5);
			Canvas.setPos(Canvas.ClipX-(32+(96*k)),32*l);
			Canvas.DrawIcon(Texture'NaliChronicles.InfoEmpty',0.5);
			Canvas.setPos(Canvas.ClipX-(20+(96*k)),(32*l)+12);
			Canvas.Font=Font'WhiteFont';
			Canvas.DrawText(NaliMage(Owner).SpellSkills[i],false);
			j++;
		}
		i++;
	}
}

simulated function float getChargeRatio(int j) {
	return float(j)/float(NaliMage(Owner).CurrentVial.default.charge);
}

simulated function DrawFragCount(Canvas Canvas, int X, int Y)
{
	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(Texture'IconSkull', 1.0);
	Canvas.CurX -= 19;
	Canvas.CurY += 23;
	if ( Pawn(Owner).PlayerReplicationInfo == None )
		return;
	Canvas.Font = Font'TinyWhiteFont';
	if (Pawn(Owner).PlayerReplicationInfo.Score<100)
		Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<10)
		Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<0)
		Canvas.CurX-=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<-9)
		Canvas.CurX-=6;
	Canvas.DrawText(int(Pawn(Owner).PlayerReplicationInfo.Score),False);

}

static function float B227_modifySpeakTime(float in)
{
	return in * (FMin(3, default.convDelayType) / 2 + 1);
}

defaultproperties
{
     invhighend=7
     BookIcons(0)=Texture'NaliChronicles.Icons.IconEarth'
     BookIcons(1)=Texture'NaliChronicles.Icons.IconWater'
     BookIcons(2)=Texture'NaliChronicles.Icons.IconWind'
     BookIcons(3)=Texture'NaliChronicles.Icons.IconFire'
     BookIcons(4)=Texture'NaliChronicles.Icons.IconHoly'
     BookIcons(5)=Texture'NaliChronicles.Icons.IconMyst'
     BookBarIcons(0)=Texture'NaliChronicles.Icons.BarEarth'
     BookBarIcons(1)=Texture'NaliChronicles.Icons.BarWater'
     BookBarIcons(2)=Texture'NaliChronicles.Icons.BarWind'
     BookBarIcons(3)=Texture'NaliChronicles.Icons.BarFire'
     BookBarIcons(4)=Texture'NaliChronicles.Icons.BarHoly'
     BookBarIcons(5)=Texture'NaliChronicles.Icons.BarMyst'
     BookRed(0)=146
     BookRed(1)=51
     BookRed(2)=115
     BookRed(3)=238
     BookRed(4)=255
     BookRed(5)=64
     BookGreen(0)=86
     BookGreen(1)=85
     BookGreen(2)=225
     BookGreen(3)=111
     BookGreen(4)=255
     BookGreen(5)=64
     BookBlue(0)=22
     BookBlue(1)=213
     BookBlue(2)=241
     BookBlue(3)=18
     BookBlue(4)=255
     BookBlue(5)=64
     HUDConfigWindowType="NaliChronicles.NCHUDConfigCW"
}
