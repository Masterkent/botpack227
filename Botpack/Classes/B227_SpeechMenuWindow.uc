class B227_SpeechMenuWindow expands UWindowWindow;

#exec TEXTURE IMPORT NAME=B227_OrdersTop FILE=Textures\B227_Speech\OrdersTop.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersTop2 FILE=Textures\B227_Speech\OrdersTop2.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersMid FILE=Textures\B227_Speech\Ordersmid.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersMidL FILE=Textures\B227_Speech\OrdersmidL.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersMidLR FILE=Textures\B227_Speech\OrdersmidLR.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersMidR FILE=Textures\B227_Speech\OrdersmidR.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersBtm FILE=Textures\B227_Speech\Ordersbtm.pcx GROUP=B227_Speech MIPS=OFF

#exec TEXTURE IMPORT NAME=B227_OrdersTopArrow FILE=Textures\B227_Speech\OrdersTopArow.pcx GROUP=B227_Speech MIPS=OFF
#exec TEXTURE IMPORT NAME=B227_OrdersBtmArrow FILE=Textures\B227_Speech\OrdersbtmArow.pcx GROUP=B227_Speech MIPS=OFF

#exec AUDIO IMPORT NAME=B227_SpeechWindowClick FILE=Sounds\B227_Speech\SpeechWindowClick.wav GROUP=B227_Speech

struct MenuButton
{
	var bool bDisabled;
	var bool bHighlightButton;
	var bool bLeftJustify;
	var bool bStretched;
	var bool bVisible;
	var Font MyFont;
	var int TeamID;
	var string Text;
	var color TextColor;
	var Texture Texture;
	var Texture DisabledTexture;
	var int Type;
	var float WinLeft;
	var float WinTop;
	var float WinWidth;
	var float WinHeight;
	var float XOffset;
	var Region ClippingRegion;
};

enum EMenuType
{
	MENU_Main,
	MENU_PlainChild,
	MENU_OrdersChild,
	MENU_PhysicalChild,
	MENU_TargetChild
};

struct MenuPage
{
	var float X;
	var float Y;
	var float Width;
	var float Height;

	var MenuButton TopButton;
	var MenuButton BottomButton;
	var array<MenuButton> OptionButtons;

	var int NumOptions;
	var int OptionOffset;
	var int MinOptions;

	var array<int> OtherOffset;

	var int CurrentType;
	var int Selected;
	var EMenuType MenuType;
	var int YOffset;
};

var B227_SpeechMenu B227_SpeechMenu;
var int BringToFrontCount;

var MenuPage MenuPages[3];
var int MenuPagesCount;
var B227_SpeechMiniDisplay MiniDisplay;
var int TargetTeamID;
var int SelectedOption;
var int Message;

var localized string WindowTitle;
var localized string SpeechOptions[32];
var int NumSpeechOptions;
var string TauntCommand[30];
var localized string PhysicalTaunts[30];
var string AllString;

var float MouseX, MouseY;

function Created()
{
	super.Created();
	bLeaveOnScreen = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float XWidth, YHeight, XMod, YMod, YPos;
	local int i, j;
	local int PageIndex;

	YMod = FMin(Root.WinHeight, Root.WinWidth * 3 / 4);
	if (YMod * Root.GUIScale > 1536)
		YMod = 1536 / Root.GUIScale;
	XMod = YMod * 4 / 3;

	WinWidth = Root.WinWidth;
	WinHeight = Root.WinHeight;

	XWidth = 256.0/1024.0 * XMod;
	YHeight = 32.0/768.0 * YMod;
	YPos = 196.0/768.0 * YMod;

	for (PageIndex = 0; PageIndex < MenuPagesCount; ++PageIndex)
	{
		MenuPages[PageIndex].TopButton.WinWidth = XWidth;
		MenuPages[PageIndex].TopButton.WinHeight = YHeight;
		MenuPages[PageIndex].TopButton.WinTop = YPos;
		MenuPages[PageIndex].TopButton.MyFont = GetBigFont(Root);
		MenuPages[PageIndex].TopButton.bDisabled = !(MenuPages[PageIndex].OptionOffset > 0);

		MenuPages[PageIndex].BottomButton.WinWidth = XWidth;
		MenuPages[PageIndex].BottomButton.WinHeight = YHeight;
		MenuPages[PageIndex].BottomButton.WinTop = YPos + (32.0/768.0 * YMod) * (MenuPages[PageIndex].MinOptions + 1);
		MenuPages[PageIndex].BottomButton.MyFont = GetBigFont(Root);
		MenuPages[PageIndex].BottomButton.bDisabled = !(MenuPages[PageIndex].NumOptions > MenuPages[PageIndex].MinOptions + MenuPages[PageIndex].OptionOffset);

		for (i = 0; i < MenuPages[PageIndex].OptionOffset; i++)
			MenuPages[PageIndex].OptionButtons[i].bVisible = false;
		for (i = 0; i < MenuPages[PageIndex].MinOptions; i++)
		{
			j = i + MenuPages[PageIndex].OptionOffset;
			MenuPages[PageIndex].OptionButtons[j].bVisible = true;
			MenuPages[PageIndex].OptionButtons[j].WinWidth = XWidth;
			MenuPages[PageIndex].OptionButtons[j].WinHeight = YHeight;
			MenuPages[PageIndex].OptionButtons[j].WinLeft = 0;
			MenuPages[PageIndex].OptionButtons[j].WinTop = YPos + (32.0 / 768.0 * YMod) * (i + 1);
		}
		for (i = MenuPages[PageIndex].MinOptions + MenuPages[PageIndex].OptionOffset; i < MenuPages[PageIndex].NumOptions; i++)
			MenuPages[PageIndex].OptionButtons[i].bVisible = false;
	}

	UpdateSelectedOption(X, Y);
	CheckCurrentActiveWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local float ClipX, ClipY;
	local int PageIndex, i;

	ClipX = C.ClipX;
	ClipY = C.ClipY;

	for (PageIndex = 0; PageIndex < MenuPagesCount; ++PageIndex)
	{
		DrawButton(C, PageIndex, MenuPages[PageIndex].TopButton);
		DrawButton(C, PageIndex, MenuPages[PageIndex].BottomButton);
		for (i = 0; i < MenuPages[PageIndex].MinOptions; ++i)
			DrawButton(C, PageIndex, MenuPages[PageIndex].OptionButtons[i + MenuPages[PageIndex].OptionOffset]);
	}

	C.ClipX = ClipX;
	C.ClipY = ClipY;
}

function WindowShown()
{
	SetAcceptsFocus();
	InitMainPage();

	TargetTeamID = -1;
	if (ChallengeHUD(GetPlayerOwner().MyHUD) != none)
	{
		if (( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget != None ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget.Team == GetPlayerOwner().PlayerReplicationInfo.Team ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyFadeTime > 2.0 ))
		{
			TargetTeamID = ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget.TeamID;
		}
	}
}

function CheckCurrentActiveWindow()
{
	if (Root.ActiveWindow != self)
	{
		if (BringToFrontCount < 2)
			BringToFront();
		else
			Close();
	}
	if (BringToFrontCount < 2)
		BringToFrontCount++;
}

function HideChildren(int PageIndex)
{
	MenuPagesCount = PageIndex + 1;
	if (MiniDisplay != none)
		MiniDisplay.Reset();
}

function KeyDown(int Key, float X, float Y)
{
	super.KeyDown(Key, X, Y);

	if (Key == 0xEC || Key == 0x26)      // IK_MouseWheelUp or IK_Up
		MenuScrolling(-1);
	else if (Key == 0xED || Key == 0x28) // IK_MouseWheelDown or IK_Down
		MenuScrolling(1);
	else if (Key == 0x21) // IK_PageUp
		MenuPageScrolling(-1);
	else if (Key == 0x22) // IK_PageDown
		MenuPageScrolling(1);
}

function MenuScrolling(int Direction)
{
	if (MenuPagesCount == 0)
		return;
	if (Direction < 0)
		TopButtonClicked(MenuPagesCount - 1);
	else if (Direction > 0)
		BottomButtonClicked(MenuPagesCount - 1);
}

function MenuPageScrolling(int Direction)
{
	local int PageIndex;

	PageIndex = MenuPagesCount - 1;

	if (PageIndex < 0 || MenuPages[PageIndex].NumOptions <= MenuPages[PageIndex].MinOptions)
		return;
	if (Direction < 0)
	{
		if (MenuPages[PageIndex].OptionOffset > 0)
		{
			MenuPages[PageIndex].OptionOffset =
				Max(0, MenuPages[PageIndex].OptionOffset - MenuPages[PageIndex].MinOptions);
			SetButtonTextures(PageIndex, MenuPages[PageIndex].OptionOffset, true, false);
		}
	}
	else if (Direction > 0)
	{
		if (MenuPages[PageIndex].NumOptions - MenuPages[PageIndex].OptionOffset > MenuPages[PageIndex].MinOptions)
		{
			MenuPages[PageIndex].OptionOffset =  Min(
				MenuPages[PageIndex].OptionOffset + MenuPages[PageIndex].MinOptions,
				MenuPages[PageIndex].NumOptions - MenuPages[PageIndex].MinOptions);
			SetButtonTextures(PageIndex, MenuPages[PageIndex].OptionOffset, true, false);
		}
	}
}

function LMouseDown(float X, float Y)
{
	if (HandleClick(X, Y))
		PlayClickSound();
}

function bool HandleClick(float X, float Y)
{
	local int i;
	local int PageIndex, OptionIndex;

	for (PageIndex = 0; PageIndex < MenuPagesCount; ++PageIndex)
	{
		if (CheckButtonClick(X, Y, PageIndex, MenuPages[PageIndex].TopButton))
		{
			TopButtonClicked(PageIndex);
			return true;
		}
		if (CheckButtonClick(X, Y, PageIndex, MenuPages[PageIndex].BottomButton))
		{
			BottomButtonClicked(PageIndex);
			return true;
		}
		for (i = 0; i < MenuPages[PageIndex].MinOptions; ++i)
		{
			OptionIndex = i + MenuPages[PageIndex].OptionOffset;
			if (CheckButtonClick(X, Y, PageIndex, MenuPages[PageIndex].OptionButtons[OptionIndex]))
			{
				OptionButtonClicked(PageIndex, OptionIndex);
				return true;
			}
		}
	}

	return false;
}

function TopButtonClicked(int PageIndex)
{
	if (MenuPages[PageIndex].NumOptions > MenuPages[PageIndex].MinOptions)
	{
		if (MenuPages[PageIndex].OptionOffset > 0)
		{
			MenuPages[PageIndex].OptionOffset--;
			SetButtonTextures(PageIndex, MenuPages[PageIndex].OptionOffset, true, false);
		}
	}
}

function BottomButtonClicked(int PageIndex)
{
	if (MenuPages[PageIndex].NumOptions > MenuPages[PageIndex].MinOptions)
	{
		if (MenuPages[PageIndex].NumOptions - MenuPages[PageIndex].OptionOffset > MenuPages[PageIndex].MinOptions)
		{
			MenuPages[PageIndex].OptionOffset++;
			SetButtonTextures(PageIndex, MenuPages[PageIndex].OptionOffset, true, false);
		}
	}
}

function OptionButtonClicked(int PageIndex, int OptionIndex)
{
	switch (MenuPages[PageIndex].MenuType)
	{
		case MENU_Main:
			MainPageButtonClicked(OptionIndex);
			break;
		case MENU_PlainChild:
			PlainChildPageButtonClicked(OptionIndex);
			break;
		case MENU_OrdersChild:
			OrdersChildPageButtonClicked(OptionIndex);
			break;
		case MENU_PhysicalChild:
			PhysicalChildPageButtonClicked(OptionIndex);
			break;
		case MENU_TargetChild:
			TargetChildPageButtonClicked(OptionIndex);
			break;
	}
}

function MainPageButtonClicked(int OptionIndex)
{
	if (0 <= OptionIndex && OptionIndex <= MenuPages[0].NumOptions)
	{
		SetButtonTextures(0, OptionIndex, false, true);
		HideChildren(0);
		MenuPages[0].CurrentType = OptionIndex;

		switch (OptionIndex)
		{
			case 0:
			case 1:
			case 3:
			case 4:
				InitPlainChildPage();
				break;

			case 2:
			case 6:
				InitOrdersChildPage();
				break;
			case 5:
				InitPhysicalChildPage();
				break;
		}
	}
}

function PlainChildPageButtonClicked(int OptionIndex)
{
	if (0 <= OptionIndex && OptionIndex < MenuPages[1].NumOptions)
	{
		if (MenuPages[1].CurrentType == 4)
			Root.GetPlayerOwner().Speech(MenuPages[1].CurrentType, MenuPages[1].OtherOffset[OptionIndex], 0);
		else
			Root.GetPlayerOwner().Speech(MenuPages[1].CurrentType, OptionIndex, 0);
		SetButtonTextures(1, MenuPages[1].OptionOffset, true, false);
	}
}

function OrdersChildPageButtonClicked(int OptionIndex)
{
	if (0 <= OptionIndex && OptionIndex < MenuPages[1].NumOptions)
	{
		MenuPages[1].Selected = OptionIndex;

		if (!GetPlayerOwner().GameReplicationInfo.bTeamGame)
			Root.GetPlayerOwner().Speech(2, MenuPages[1].OtherOffset[OptionIndex], 0);
		else if ((TargetTeamID >= 0) && (MenuPages[1].CurrentType == 6))
			Root.GetPlayerOwner().Speech(2, MenuPages[1].OtherOffset[OptionIndex], TargetTeamID);
		else
		{
			if (OptionIndex == 0)
				SetButtonTextures(1, 0, true, true);
			else
			{
				SetButtonTextures(1, 0, true, false);
				SetButtonTextures(1, OptionIndex, false, true, true);
			}
			HideChildren(1);
			InitTargetChildPage();
			Message = MenuPages[1].OtherOffset[OptionIndex];
		}
	}
}

function PhysicalChildPageButtonClicked(int OptionIndex)
{
	if (0 <= OptionIndex && OptionIndex < MenuPages[1].NumOptions)
		GetPlayerOwner().ConsoleCommand(TauntCommand[OptionIndex]);
}

function TargetChildPageButtonClicked(int OptionIndex)
{
	if (0 <= OptionIndex && OptionIndex < MenuPages[2].NumOptions)
	{
		if (OptionIndex == 0)
			Root.GetPlayerOwner().Speech(MenuPages[1].CurrentType, Message, -1);
		else
			Root.GetPlayerOwner().Speech(MenuPages[1].CurrentType, Message, MenuPages[2].OptionButtons[OptionIndex].TeamID);

		if (MiniDisplay != none)
			MiniDisplay.Reset();
	}
}

function PlayClickSound()
{
	GetPlayerOwner().PlaySound(sound'B227_SpeechWindowClick', SLOT_Interact);
}

function UpdateSelectedOption(float X, float Y)
{
	local int i, OptionIndex;

	if (MiniDisplay == none)
		return;

	if (MenuPagesCount == 3 && MenuPages[2].MenuType == MENU_TargetChild)
	{
		for (i = 0; i < MenuPages[2].MinOptions; ++i)
		{
			OptionIndex = i + MenuPages[2].OptionOffset;
			if (CheckButtonClick(X, Y, 2, MenuPages[2].OptionButtons[OptionIndex]))
			{
				if (OptionIndex == 0)
					MiniDisplay.Reset();
				else if (MiniDisplay.UpdateInfo(MenuPages[2].OptionButtons[OptionIndex].TeamID, MenuPages[2].OptionButtons[OptionIndex].Text))
				{
					MiniDisplay.WinLeft = WinLeft + MenuPages[2].X +
						MenuPages[2].OptionButtons[OptionIndex].WinLeft + MenuPages[2].OptionButtons[OptionIndex].WinWidth * 1.1;
					MiniDisplay.WinTop = WinTop + MenuPages[2].Y + MenuPages[2].OptionButtons[OptionIndex].WinTop;

					MiniDisplay.UpdateDisplayedInfo();

					if (!MiniDisplay.bWindowVisible)
						MiniDisplay.ShowWindow();
				}
				return;
			}
		}
	}
	MiniDisplay.Reset();
}

function MenuButton MakeDecorativeButton(float XMod, Texture Texture, Texture DisabledTexture)
{
	local MenuButton Btn;

	Btn.MyFont = GetBigFont(Root);
	Btn.TextColor.R = 255;
	Btn.TextColor.G = 255;
	Btn.TextColor.B = 255;
	Btn.XOffset = 20.0/1024.0 * XMod;
	Btn.bDisabled = true;
	Btn.bVisible = true;
	Btn.Texture = Texture;
	Btn.DisabledTexture = DisabledTexture;
	Btn.bStretched = true;

	return Btn;
}

function MenuButton MakeOptionButton(float XMod, Texture Texture, int Type)
{
	local MenuButton Btn;

	Btn.MyFont = GetBigFont(Root);
	Btn.bLeftJustify = true;
	Btn.TextColor.R = 255;
	Btn.TextColor.G = 255;
	Btn.TextColor.B = 255;
	Btn.XOffset = 20.0/1024.0 * XMod;
	Btn.bHighlightButton = true;
	Btn.Texture = Texture;
	Btn.Type = Type;
	Btn.bStretched = true;

	return Btn;
}

function bool CheckButtonClick(float X, float Y, int PageIndex, MenuButton Btn)
{
	if (!Btn.bVisible || Btn.bDisabled)
		return false;
	return IsInButtonRect(X, Y, PageIndex, Btn);
}

function bool IsInButtonRect(float X, float Y, int PageIndex, MenuButton Btn)
{
	local float WinLeft, WinTop;

	WinLeft = MenuPages[PageIndex].X + Btn.WinLeft;
	WinTop = MenuPages[PageIndex].Y + Btn.WinTop;

	return
		WinLeft <= X && X < WinLeft + Btn.WinWidth &&
		WinTop <= Y && Y < WinTop + Btn.WinHeight;
}

function InitPage(
	EMenuType MenuType,
	int PageIndex,
	int NumOptions,
	optional out float XMod,
	optional out float YMod)
{
	YMod = FMin(Root.WinHeight, Root.WinWidth * 3 / 4);
	XMod = YMod * 4 / 3;

	MenuPages[PageIndex].MenuType = MenuType;
	InitPageNumOptions(PageIndex, NumOptions);

	MenuPages[PageIndex].OptionOffset = 0;

	if (PageIndex == 0)
		MenuPages[PageIndex].TopButton = MakeDecorativeButton(XMod, Texture'B227_OrdersTop', Texture'B227_OrdersTop');
	else
		MenuPages[PageIndex].TopButton = MakeDecorativeButton(XMod, Texture'B227_OrdersTop2', Texture'B227_OrdersTop2');
	MenuPages[PageIndex].BottomButton = MakeDecorativeButton(XMod, Texture'B227_OrdersBtm', Texture'B227_OrdersBtm');

	InitOptionButtons(PageIndex, MenuPages[PageIndex].NumOptions, XMod);

	MenuPagesCount = PageIndex + 1;
}

function InitPageNumOptions(int PageIndex, int NumOptions)
{
	MenuPages[PageIndex].NumOptions = NumOptions;
	MenuPages[PageIndex].MinOptions = Min(8, NumOptions);
}

function InitOptionButtons(int PageIndex, int NumOptions, float XMod)
{
	local int i;

	for (i = 0; i < NumOptions; ++i)
		InitOrdersButton(PageIndex, i, XMod);
}

function InitOrdersButton(int PageIndex, int Index, float XMod)
{
	MenuPages[PageIndex].OptionButtons[Index] =
		MakeOptionButton(XMod, texture'B227_OrdersMid', Index);
}

function InitMainPage()
{
	local int i;

	WinTop = 0;
	WinLeft = 0;

	InitPage(MENU_Main, 0, NumSpeechOptions - 1); // the last option is unused
	MenuPages[0].TopButton.Text = WindowTitle;

	for (i = 0; i < MenuPages[0].NumOptions; ++i)
		MenuPages[0].OptionButtons[i].Text = SpeechOptions[i];
}

function InitPlainChildPage()
{
	local int i, j, n;
	local float XMod, YMod;
	local class<ChallengeVoicePack> V;
	local int NumOptions;

	if (!GetChallengeVoicePack(V))
		return;

	MenuPages[1].CurrentType = MenuPages[0].CurrentType;
	MenuPages[1].YOffset = MenuPages[1].CurrentType;

	switch (MenuPages[1].CurrentType)
	{
		case 0: // Acknowledgements
			NumOptions = V.Default.numAcks;
			break;
		case 1: // Friendly Fire
			NumOptions = V.Default.numFFires;
			break;
		case 3: // Taunts
			NumOptions = V.Default.numTaunts;
			break;
		case 4: // Other
			j = 0;
			n = ArrayCount(class'ChallengeVoicePack'.default.OtherString);
			for (i = 0; i < n; i++)
			{
				if (V.Static.GetOtherString(i) != "")
					MenuPages[1].OtherOffset[j++] = i;
			}
			NumOptions = j;
			break;
	}

	InitPage(MENU_PlainChild, 1, NumOptions, XMod, YMod);

	for (i = 0; i < NumOptions; i++)
	{
		switch (MenuPages[1].CurrentType)
		{
			case 0: // Acknowledgements
				MenuPages[1].OptionButtons[i].Text = V.Static.GetAckString(i);
				break;
			case 1: // Friendly Fire
				MenuPages[1].OptionButtons[i].Text = V.Static.GetFFireString(i);
				break;
			case 3: // Taunts
				MenuPages[1].OptionButtons[i].Text = V.Static.GetTauntString(i);
				break;
			case 4: // Other
				MenuPages[1].OptionButtons[i].Text = V.Static.GetOtherString(MenuPages[1].OtherOffset[i]);
				break;
		}
	}

	MenuPages[1].TopButton.Texture = texture'B227_OrdersTopArrow';
	MenuPages[1].TopButton.WinLeft = 0;
	MenuPages[1].BottomButton.Texture = texture'B227_OrdersBtmArrow';
	MenuPages[1].BottomButton.WinLeft = 0;

	MenuPages[1].Y = (32.0/768.0 * YMod) * MenuPages[1].CurrentType;
	MenuPages[1].X = 256.0/1024.0 * XMod;
	MenuPages[1].Width = 256.0/1024.0 * XMod;
	MenuPages[1].Height = (32.0/768.0 * YMod)*(MenuPages[1].MinOptions+2);

	SetButtonTextures(1, 0, true, false);
}

function InitOrdersChildPage()
{
	local int i, j;
	local float XMod, YMod;
	local class<ChallengeVoicePack> V;
	local int NumOptions;

	if (!GetChallengeVoicePack(V))
		return;

	MenuPages[1].CurrentType = MenuPages[0].CurrentType;
	MenuPages[1].YOffset = MenuPages[1].CurrentType;

	j = 0;
	for (i=0; i<9; i++)
	{
		if (V.Static.GetOrderString(i, GetPlayerOwner().GameReplicationInfo.GameName) != "")
			MenuPages[1].OtherOffset[j++] = i;
	}
	NumOptions = j;

	InitPage(MENU_OrdersChild, 1, NumOptions, XMod, YMod);

	for (i = 0; i < NumOptions; i++)
		MenuPages[1].OptionButtons[i].Text = V.Static.GetOrderString(MenuPages[1].OtherOffset[i], GetPlayerOwner().GameReplicationInfo.GameName);

	MenuPages[1].TopButton.Texture = texture'B227_OrdersTopArrow';
	MenuPages[1].TopButton.WinLeft = 0;
	MenuPages[1].BottomButton.Texture = texture'B227_OrdersBtmArrow';
	MenuPages[1].BottomButton.WinLeft = 0;

	MenuPages[1].Y = (32.0/768.0 * YMod) * MenuPages[1].CurrentType;
	MenuPages[1].X = 256.0/1024.0 * XMod;
	MenuPages[1].Width = 256.0/1024.0 * XMod;
	MenuPages[1].Height = (32.0/768.0 * YMod)*(MenuPages[1].MinOptions+2);

	SetButtonTextures(1, 0, true, false);
}

function InitPhysicalChildPage()
{
	local int i;
	local float XMod, YMod;
	local int NumOptions;

	MenuPages[1].CurrentType = MenuPages[0].CurrentType;
	MenuPages[1].YOffset = MenuPages[1].CurrentType;
	NumOptions = 4;

	InitPage(MENU_PhysicalChild, 1, NumOptions, XMod, YMod);

	for (i = 0; i < NumOptions; i++)
		MenuPages[1].OptionButtons[i].Text = PhysicalTaunts[i];

	MenuPages[1].TopButton.Texture = texture'B227_OrdersTopArrow';
	MenuPages[1].TopButton.WinLeft = 0;
	MenuPages[1].BottomButton.Texture = texture'B227_OrdersBtmArrow';
	MenuPages[1].BottomButton.WinLeft = 0;

	MenuPages[1].Y = (32.0/768.0 * YMod) * MenuPages[1].CurrentType;
	MenuPages[1].X = 256.0/1024.0 * XMod;
	MenuPages[1].Width = 256.0/1024.0 * XMod;
	MenuPages[1].Height = (32.0/768.0 * YMod)*(MenuPages[1].MinOptions+2);

	SetButtonTextures(1, 0, true, false);
}

function InitTargetChildPage()
{
	local float XMod, YMod;
	local PlayerReplicationInfo PRI;
	local int NumOptions;

	MenuPages[2].CurrentType = MenuPages[1].CurrentType;
	MenuPages[2].YOffset = MenuPages[1].YOffset + MenuPages[1].Selected;

	InitPage(MENU_TargetChild, 2, 0, XMod, YMod);

	NumOptions = 1;
	InitOrdersButton(2, 0, XMod);
	MenuPages[2].OptionButtons[0].Text = AllString;

	foreach GetPlayerOwner().AllActors(class'PlayerReplicationInfo', PRI)
	{
		if ( (PRI.Team == GetPlayerOwner().PlayerReplicationInfo.Team) && (PRI != GetPlayerOwner().PlayerReplicationInfo) )
		{
			InitOrdersButton(2, NumOptions, XMod);
			MenuPages[2].OptionButtons[NumOptions].Text = PRI.PlayerName;
			MenuPages[2].OptionButtons[NumOptions].TeamID = PRI.TeamID;
			NumOptions++;
		}
	}

	InitPageNumOptions(2, NumOptions);

	if (MiniDisplay == none)
	{
		MiniDisplay = B227_SpeechMiniDisplay(CreateWindow(class'B227_SpeechMiniDisplay', 100, 100, 100, 100));
		MiniDisplay.HideWindow();
	}
	MiniDisplay.WinWidth = 256.0/1024.0 * XMod;
	MiniDisplay.WinHeight = 256.0/768.0 * YMod;

	MenuPages[2].TopButton.Texture = texture'B227_OrdersTopArrow';
	MenuPages[2].TopButton.WinLeft = 0;
	MenuPages[2].BottomButton.Texture = texture'B227_OrdersBtmArrow';
	MenuPages[2].BottomButton.WinLeft = 0;

	MenuPages[2].Y = MenuPages[1].Y + (32.0/768.0 * YMod) * MenuPages[1].Selected;
	MenuPages[2].X = 512.0/1024.0 * XMod;
	MenuPages[2].Width = 256.0/1024.0 * XMod;
	MenuPages[2].Height = (32.0/768.0 * YMod)*(MenuPages[2].MinOptions+2);

	SetButtonTextures(2, 0, true, false);
}

function DrawButton(Canvas C, int PageIndex, MenuButton Btn)
{
	local float OrgX, OrgY;
	local float Wx, Hy;

	if (!Btn.bVisible)
		return;

	OrgX = C.OrgX;
	OrgY = C.OrgY;

	C.SetPos(0,0);
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.SpaceX = 0;
	C.SpaceY = 0;

	C.OrgX = C.OrgX + (MenuPages[PageIndex].X + Btn.WinLeft) * Root.GUIScale;
	C.OrgY = C.OrgY + (MenuPages[PageIndex].Y + Btn.WinTop) * Root.GUIScale;

	C.ClipX = FMin(WinWidth - (MenuPages[PageIndex].X + Btn.WinLeft), Btn.WinWidth) * Root.GUIScale;
	C.ClipY = FMin(WinHeight - (MenuPages[PageIndex].Y + Btn.WinTop), Btn.WinHeight) * Root.GUIScale;

	// Translate to child's co-ordinate system
	Btn.ClippingRegion.X = ClippingRegion.X - (MenuPages[PageIndex].X + Btn.WinLeft);
	Btn.ClippingRegion.Y = ClippingRegion.Y - (MenuPages[PageIndex].Y + Btn.WinTop);
	Btn.ClippingRegion.W = ClippingRegion.W;
	Btn.ClippingRegion.H = ClippingRegion.H;

	if (Btn.ClippingRegion.X < 0)
	{
		Btn.ClippingRegion.W += Btn.ClippingRegion.X;
		Btn.ClippingRegion.X = 0;
	}

	if (Btn.ClippingRegion.Y < 0)
	{
		Btn.ClippingRegion.H += Btn.ClippingRegion.Y;
		Btn.ClippingRegion.Y = 0;
	}

	if (Btn.ClippingRegion.W > Btn.WinWidth - Btn.ClippingRegion.X)
		Btn.ClippingRegion.W = Btn.WinWidth - Btn.ClippingRegion.X;

	if (Btn.ClippingRegion.H > Btn.WinHeight - Btn.ClippingRegion.Y)
		Btn.ClippingRegion.H = Btn.WinHeight - Btn.ClippingRegion.Y;

	SetupButtonStyle(
		C,
		PageIndex,
		Btn.WinLeft,
		Btn.WinTop,
		Btn.WinWidth,
		Btn.WinHeight,
		Btn.bHighlightButton,
		Btn.TextColor);

	if (Btn.bDisabled)
	{
		if (Btn.DisabledTexture != none)
		{
			if (Btn.bStretched)
				DrawStretchedTexture(C, 0, 0, Btn.WinWidth, Btn.WinHeight, Btn.DisabledTexture);
			else
				DrawClippedTexture(C, 0, 0, Btn.DisabledTexture);
		}
	}
	else if (Btn.Texture != None)
	{
		if (Btn.bStretched)
			DrawStretchedTexture(C, 0, 0, Btn.WinWidth, Btn.WinHeight, Btn.Texture);
		else
			DrawClippedTexture(C, 0, 0, Btn.Texture);
	}

	C.DrawColor = Btn.TextColor;
	C.Font = Btn.MyFont;
	TextSize(C, Btn.Text, Wx, Hy);
	if (Btn.bLeftJustify)
		ClipText(C, Btn.XOffset, 0, Btn.Text);
	else
		ClipText(C, (Btn.WinWidth - Wx) / 2, (Btn.WinHeight - Hy) / 2, Btn.Text);

	C.OrgX = OrgX;
	C.OrgY = OrgY;
}

function SetupButtonStyle(
	Canvas C,
	int PageIndex,
	float WinLeft,
	float WinTop,
	float WinWidth,
	float WinHeight,
	bool bHighlightButton,
	out color TextColor)
{
	local color HUDColor;

	// Set the color to that of the HUD.
	HUDColor.R = 255;
	HUDColor.G = 255;
	HUDColor.B = 255;
	if (ChallengeHUD(GetPlayerOwner().MyHUD) != none)
	{
		if (ChallengeHUD(GetPlayerOwner().MyHUD).Style != 3)
			C.Style = 2;
		else
			C.Style = 3;
		if (ChallengeHUD(GetPlayerOwner().MyHUD).bUseTeamColor)
		{
			if (GetPlayerOwner().MyHUD.IsA('ChallengeTeamHUD') && GetPlayerOwner().PlayerReplicationInfo.Team < 4)
			{
				HUDColor = ChallengeTeamHUD(GetPlayerOwner().MyHUD).TeamColor[GetPlayerOwner().PlayerReplicationInfo.Team];
			} else {
				HUDColor = ChallengeHUD(GetPlayerOwner().MyHUD).FavoriteHUDColor;
			}
		} else {
			HUDColor = ChallengeHUD(GetPlayerOwner().MyHUD).FavoriteHUDColor;
		}
		if (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity != 16)
		{
			HUDColor.R = HUDColor.R * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
			HUDColor.G = HUDColor.G * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
			HUDColor.B = HUDColor.B * (ChallengeHUD(GetPlayerOwner().MyHUD).Opacity + 0.9);
		} else {
			HUDColor.R *= 15.9;
			HUDColor.G *= 15.9;
			HUDColor.B *= 15.9;
		}
	}
	else
		C.Style = 3;
	C.DrawColor = HUDColor;
	if (MouseIsOverButton(PageIndex, WinLeft, WinTop, WinWidth, WinHeight) && bHighlightButton)
	{
		C.DrawColor.R = Clamp(C.DrawColor.R + 100, 0, 255);
		C.DrawColor.G = Clamp(C.DrawColor.G + 100, 0, 255);
		C.DrawColor.B = Clamp(C.DrawColor.B + 100, 0, 255);
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 0;
	} else {
		TextColor.R = 255;
		TextColor.G = 255;
		TextColor.B = 255;
	}
}

function SetButtonTextures(
	int PageIndex,
	int i,
	optional bool bLeft,
	optional bool bRight,
	optional bool bPreserve)
{
	local int j;

	for (j = 0; j < MenuPages[PageIndex].NumOptions; j++)
	{
		if (j == i)
		{
			if (bLeft && bRight)
				MenuPages[PageIndex].OptionButtons[j].Texture = texture'B227_OrdersMidLR';
			else if (bRight)
				MenuPages[PageIndex].OptionButtons[j].Texture = texture'B227_OrdersMidR';
			else if (bLeft)
				MenuPages[PageIndex].OptionButtons[j].Texture = texture'B227_OrdersMidL';
		}
		else if (!(bPreserve && j == 0))
			MenuPages[PageIndex].OptionButtons[j].Texture = texture'B227_OrdersMid';
	}
}

static function font GetBigFont(UWindowRootWindow Root)
{
	local float SizeX;

	SizeX = FMin(Root.WinWidth, Root.WinHeight * 4 / 3) * Root.GUIScale;

	if (class'FontInfo'.static.B227_ShouldUseTahomaFonts())
	{
		if (SizeX < 640)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma10);
		else if (SizeX < 800)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma12);
		else if (SizeX < 1024)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma16);
		else if (SizeX < 1440)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma18);
		else
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma20);
	}
	else
	{
		if (SizeX < 640)
			return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
		else if (SizeX < 800)
			return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
		else if (SizeX < 1024)
			return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
		else if (SizeX < 1440)
			return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
		else
			return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	}
}

static function font GetSmallFont(UWindowRootWindow Root)
{
	local float SizeX;

	SizeX = FMin(Root.WinWidth, Root.WinHeight * 4 / 3) * Root.GUIScale;

	if (class'FontInfo'.static.B227_ShouldUseTahomaFonts())
	{
		if (SizeX < 800)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma10);
		else if (SizeX < 1024)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma14);
		else if (SizeX < 1440)
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma16);
		else
			return class'FontInfo'.static.B227_LoadTahomaFont(class'FontInfo'.default.B227_FontName_Tahoma18);
	}
	else
	{
		if (SizeX < 800)
			return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
		else if (SizeX < 1024)
			return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
		else if (SizeX < 1440)
			return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
		else
			return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
	}
}

function bool GetChallengeVoicePack(out class<ChallengeVoicePack> V)
{
	V = class<ChallengeVoicePack>(GetPlayerOwner().PlayerReplicationInfo.VoiceType);
	if (V != none)
		return true;
	Log("B227_SpeechMenuWindow.InitPlainChildPage: no ChallengeVoicePack is available");
	return false;
}

function bool MouseIsOverButton(
	int PageIndex,
	float WinLeft,
	float WinTop,
	float WinWidth,
	float WinHeight)
{
	return
		MenuPages[PageIndex].X + WinLeft <= MouseX && MouseX < MenuPages[PageIndex].X + WinLeft + WinWidth &&
		MenuPages[PageIndex].Y + WinTop <= MouseY && MouseY < MenuPages[PageIndex].Y + WinTop + WinHeight;
}

function MouseMove(float X, float Y)
{
	super.MouseMove(X, Y);
	MouseX = X;
	MouseY = Y;
}

function Close(optional bool bByParent)
{
	super.Close(bByParent);

	B227_SpeechMenu.HideSpeech();
	MenuPagesCount = 0;
}

defaultproperties
{
	WindowTitle="Orders"
	SpeechOptions(0)="Acknowledge"
	SpeechOptions(1)="Friendly Fire"
	SpeechOptions(2)="Orders"
	SpeechOptions(3)="Taunts"
	SpeechOptions(4)="Other/Misc"
	SpeechOptions(5)="Gesture"
	SpeechOptions(6)="Order This Bot"
	NumSpeechOptions=7
	TauntCommand(0)="taunt victory1"
	TauntCommand(1)="taunt thrust"
	TauntCommand(2)="taunt taunt1"
	TauntCommand(3)="taunt wave"
	PhysicalTaunts(0)="Basic Taunt"
	PhysicalTaunts(1)="Pelvic Thrust"
	PhysicalTaunts(2)="Victory Dance"
	PhysicalTaunts(3)="Wave"
	AllString="All"
}
