class UTMenuPlayerSetupClient227 extends UMenuDialogClientWindow
	config(UTGameMenu227);

var() config string PlayerTeam[2];
var() config string PlayerClass[2];
var() config string PlayerSkin[2];
var() config string PlayerFace[2];
var() config string PlayerVoice[2];

var int ControlOffset;
const ControlShift = 25;

var string CurrentTeam;
var string CurrentClass;
var string CurrentSkin;
var string CurrentFace;
var string CurrentVoice;

var class<PlayerPawn> CurrentPlayerClass;
var bool bIsTournamentPlayer;
var bool bIsSpectator;
var bool bTournament;

var string MeshName;
var bool bUseChangeNotifications;
var UTMenuPlayerMeshClient227 MeshWindow;

// Player Name
var UWindowEditControl NameEdit;

// Team Combo
var UWindowComboControl TeamCombo;

// Game Combo
var UWindowComboControl GameCombo;
var localized string GameText;
var localized string GameHelp;
var localized string GameNames[2];

// Class Combo
var UWindowComboControl ClassCombo;

// Skin Combo
var UWindowComboControl SkinCombo;

// Face Combo
var UWindowComboControl FaceCombo;

// VoicePack
var UWindowComboControl VoicePackCombo;
var localized string VoicePackText;
var localized string VoicePackHelp;

var localized string DefaultText;
var localized string ErrorTitle;
var localized string NoBotpackMessage;

var UWindowCheckbox SpectatorCheck;

var bool bGetDefaultURLIsSupported;

var string DefaultURLTeam;
var string DefaultURLClass;
var string DefaultURLSkin;
var string DefaultURLFace;
var string DefaultURLVoice;

function Created()
{
	MeshWindow = UTMenuPlayerMeshClient227(UTMenuPlayerClientWindow227(ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow);

	super.Created();

	InitPlayerURLSupport();
	CreateMenuControls();
}

function AfterCreate()
{
	super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset + 25;

	InitPlayerSetup();
}

function WindowShown()
{
	super.WindowShown();

	InitPlayerSetup();
}

function InitPlayerURLSupport()
{
	if (int(GetLevel().EngineVersion) == 227 && int(GetLevel().EngineSubVersion) <= 9)
		bGetDefaultURLIsSupported = false;
	else
		bGetDefaultURLIsSupported = DynamicLoadObject("Engine.PlayerPawn.GetDefaultURL", class'Function', true) != none;

	if (!bGetDefaultURLIsSupported)
	{
		default.DefaultURLTeam = GetLocalURLParam("Team");
		default.DefaultURLClass = GetLocalURLParam("Class");
		default.DefaultURLSkin = GetLocalURLParam("Skin");
		default.DefaultURLFace = GetLocalURLParam("Face");
		default.DefaultURLVoice = GetLocalURLParam("Voice");
	}
}

function InitPlayerSetup()
{
	bUseChangeNotifications = false;
	LoadCurrent();
	UpdateCurrentMesh();
	bUseChangeNotifications = true;
}

function CreateMenuControls()
{
	local int CenterWidth, CenterPos;
	local int i;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Player Name
	NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	NameEdit.SetText(class'UMenuPlayerSetupClient'.default.NameText);
	NameEdit.SetHelpText(class'UMenuPlayerSetupClient'.default.NameHelp);
	NameEdit.SetFont(F_Normal);
	NameEdit.SetNumericOnly(False);
	NameEdit.SetMaxLength(20);
	NameEdit.SetDelayedNotify(True);

	// Team
	ControlOffset += ControlShift;
	TeamCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TeamCombo.SetText(class'UMenuPlayerSetupClient'.default.TeamText);
	TeamCombo.SetHelpText(class'UMenuPlayerSetupClient'.default.TeamHelp);
	TeamCombo.SetFont(F_Normal);
	TeamCombo.SetEditable(False);
	TeamCombo.AddItem(class'UMenuPlayerSetupClient'.default.NoTeam, String(255));
	for (i = 0; i < 4; i++)
		TeamCombo.AddItem(class'UMenuPlayerSetupClient'.default.Teams[i], String(i));

	ControlOffset += ControlShift;
	// Game: Unreal or Unreal Tournament
	GameCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	GameCombo.SetText(GameText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetEditable(False);
	GameCombo.SetFont(F_Normal);
	for (i = 0; i < ArrayCount(GameNames); ++i)
		GameCombo.AddItem(GameNames[i], string(i));

	ControlOffset += ControlShift;
	// Load Classes
	ClassCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ClassCombo.SetText(class'UMenuPlayerSetupClient'.default.ClassText);
	ClassCombo.SetHelpText(class'UMenuPlayerSetupClient'.default.ClassHelp);
	ClassCombo.SetEditable(False);
	ClassCombo.SetFont(F_Normal);

	// Skin
	ControlOffset += ControlShift;
	SkinCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinCombo.SetText(class'UMenuPlayerSetupClient'.default.SkinText);
	SkinCombo.SetHelpText(class'UMenuPlayerSetupClient'.default.SkinHelp);
	SkinCombo.SetFont(F_Normal);
	SkinCombo.SetEditable(False);

	ControlOffset += ControlShift;
	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FaceCombo.SetText(class'UMenuPlayerSetupClient'.default.FaceText);
	FaceCombo.SetHelpText(class'UMenuPlayerSetupClient'.default.FaceHelp);
	FaceCombo.SetFont(F_Normal);
	FaceCombo.SetEditable(False);

	ControlOffset += ControlShift;
	VoicePackCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	VoicePackCombo.SetText(VoicePackText);
	VoicePackCombo.SetHelpText(VoicePackHelp);
	VoicePackCombo.SetFont(F_Normal);
	VoicePackCombo.SetEditable(False);

	ControlOffset += ControlShift;
	SpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	SpectatorCheck.SetText(class'UMenuPlayerSetupClient'.default.SpectatorText);
	SpectatorCheck.SetHelpText(class'UMenuPlayerSetupClient'.default.SpectatorHelp);
	SpectatorCheck.SetFont(F_Normal);
	SpectatorCheck.Align = TA_Left;
}

function LoadClasses()
{
	const MaxLoadedClasses = 2048;
	local int i, NumPlayerClasses, NumLoadedClasses;
	local string NextPlayer, NextDesc;
	local array<string> LoadedClasses;
	local string BaseClasses[2];

	BaseClasses[0] = "UnrealIPlayer";
	BaseClasses[1] = "Botpack.TournamentPlayer";

	NumPlayerClasses = 0;
	ClassCombo.Clear();
	ClassCombo.AddItem(DefaultText, "", 0);
	GetPlayerOwner().GetNextIntDesc(BaseClasses[int(bTournament)], 0, NextPlayer, NextDesc);
	while (NextPlayer != "" && NumLoadedClasses < MaxLoadedClasses)
	{
		if (InStr(Caps(NextPlayer), "SPECTATOR") < 0)
		{
			for (i = 0; i < NumLoadedClasses; ++i)
				if (LoadedClasses[i] ~= NextPlayer)
					break;
			if (i == NumLoadedClasses)
			{
				ClassCombo.AddItem(NextDesc, NextPlayer, 1);
				LoadedClasses[NumLoadedClasses++] = NextPlayer;
			}
		}
		GetPlayerOwner().GetNextIntDesc(BaseClasses[int(bTournament)], ++NumPlayerClasses, NextPlayer, NextDesc);
	}

	ClassCombo.Sort();
}

function FetchCurrentPlayerParams()
{
	local GameInfo Game;
	local string URLClass;

	URLClass = GetDefaultURL("Class");
	Game = GetLevel().Game;
	bIsSpectator = IsSpectatorClassName(URLClass);

	if (Len(URLClass) > 0 && !IsSpectatorClassName(URLClass))
	{
		CurrentTeam = GetDefaultURL("Team");
		CurrentClass = URLClass;
		CurrentSkin = GetDefaultURL("Skin");
		CurrentFace = GetDefaultURL("Face");
		CurrentVoice = GetDefaultURL("Voice");
	}
	else
	{
		CurrentTeam = default.PlayerTeam[int(bTournament)];
		CurrentClass = default.PlayerClass[int(bTournament)];
		CurrentSkin = default.PlayerSkin[int(bTournament)];
		CurrentFace = default.PlayerFace[int(bTournament)];
		CurrentVoice = default.PlayerVoice[int(bTournament)];
	}

	SetCurrentPlayerClassFromName(CurrentClass);

	MeshName = "";
	if (CurrentPlayerClass != none && CurrentPlayerClass.default.Mesh != none)
		MeshName = GetPlayerOwner().GetItemName(string(CurrentPlayerClass.default.Mesh));
}

function StoreURLPlayerParams()
{
	local string URLClass;
	local class<PlayerPawn> URLPlayerClass;
	local bool bIsTournamentPlayerClass;

	URLClass = GetDefaultURL("Class");
	URLPlayerClass = LoadPlayerClass(URLClass);
	bIsTournamentPlayerClass = IsTournamentPlayerClass(URLPlayerClass);
	if (URLPlayerClass != none &&
		!ClassIsChildOf(URLPlayerClass, class'Spectator') &&
		Len(default.PlayerClass[int(bIsTournamentPlayerClass)]) == 0)
	{
		default.PlayerTeam[int(bIsTournamentPlayerClass)] = GetDefaultURL("Team");
		default.PlayerClass[int(bIsTournamentPlayerClass)] = URLClass;
		default.PlayerSkin[int(bIsTournamentPlayerClass)] = GetDefaultURL("Skin");
		default.PlayerFace[int(bIsTournamentPlayerClass)] = GetDefaultURL("Face");
		default.PlayerVoice[int(bIsTournamentPlayerClass)] = GetDefaultURL("Voice");
		StaticSaveConfig();
	}
}

function FetchGamePlayerParams()
{
	CurrentTeam = default.PlayerTeam[int(bTournament)];
	CurrentClass = default.PlayerClass[int(bTournament)];
	CurrentSkin = default.PlayerSkin[int(bTournament)];
	CurrentFace = default.PlayerFace[int(bTournament)];
	CurrentVoice = default.PlayerVoice[int(bTournament)];

	SetCurrentPlayerClassFromName(CurrentClass);
	MeshName = "";
	if (CurrentPlayerClass != none && CurrentPlayerClass.default.Mesh != none)
		MeshName = GetPlayerOwner().GetItemName(string(CurrentPlayerClass.default.Mesh));
}

// Fill controls with data matching CurrentTeam, CurrentClass, etc
function UpdateModelControls()
{
	local int i;
	local bool bFacesAvailable;

	i = ClassCombo.FindItemIndex2(CurrentClass, true);

	if (i >= 0 && Len(MeshName) > 0)
	{
		ClassCombo.SetSelectedIndex(i);
		IterateSkins();
		SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(CurrentSkin, true), 0));
		if (Len(SkinCombo.GetValue2()) > 0)
		{
			SkinCombo.ShowWindow();
			IterateFaces(SkinCombo.GetValue2());
			FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(CurrentFace, true), 0));
			bFacesAvailable = Len(FaceCombo.GetValue2()) > 0;
			if (bFacesAvailable)
				FaceCombo.ShowWindow();
		}
		else
			SkinCombo.HideWindow();

		if (!bFacesAvailable)
			FaceCombo.HideWindow();

		if (bIsTournamentPlayer ||
			CurrentPlayerClass != none && GetPlayerOwner().IsA('TournamentPlayer') && Spectator(GetPlayerOwner()) == none)
		{
			VoicePackCombo.ShowWindow();
			IterateVoices();
			VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(CurrentVoice, True), 0));
		}
		else
			VoicePackCombo.HideWindow();

		TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(CurrentTeam), 0));
	}
	else
	{
		if (Len(CurrentClass) > 0)
			ClassCombo.EditBox.Value = CurrentClass;
		else
			ClassCombo.SetSelectedIndex(0);
		SkinCombo.Clear();
		FaceCombo.Clear();
		SkinCombo.HideWindow();
		FaceCombo.HideWindow();
		VoicePackCombo.HideWindow();
		TeamCombo.SetSelectedIndex(0);
	}
}

function LoadCurrent()
{
	NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);

	FetchCurrentPlayerParams();
	StoreURLPlayerParams();
	bTournament = bIsTournamentPlayer;
	LoadClasses();
	GameCombo.SetSelectedIndex(int(bTournament));
	UpdateModelControls();

	SpectatorCheck.bChecked = bIsSpectator;
}

function SaveConfigs()
{
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}

function IterateSkins()
{
	local string SkinName, SkinDesc, TestName, Temp;
	local bool bNewFormat;

	SkinCombo.Clear();

	if (ClassIsChildOf(CurrentPlayerClass, class'Spectator'))
	{
		SkinCombo.HideWindow();
		return;
	}

	SkinCombo.ShowWindow();

	bNewFormat = CurrentPlayerClass.default.bIsMultiSkinned;

	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if( SkinName == TestName )
			break;

		if( TestName == "" )
			TestName = SkinName;

		if( !bNewFormat )
		{
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if( Left(Temp, 2) != "T_" )
				SkinCombo.AddItem(Temp, SkinName);
		}
		else
		{
			// Multiskin format
			if( SkinDesc != "")
			{
				Temp = GetPlayerOwner().GetItemName(SkinName);
				if(Mid(Temp, 5, 64) == "")
					// This is a skin
					SkinCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Left(Temp, 4));
			}
		}
	}
	SkinCombo.Sort();
}

function IterateFaces(string InSkinName)
{
	local string SkinName, SkinDesc, TestName, Temp;

	FaceCombo.Clear();

	// New format only
	if (!CurrentPlayerClass.default.bIsMultiSkinned)
	{
		FaceCombo.HideWindow();
		return;
	}

	FaceCombo.ShowWindow();

	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if( SkinName == TestName )
			break;

		if( TestName == "" )
			TestName = SkinName;

		// Multiskin format
		if( SkinDesc != "")
		{
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetPlayerOwner().GetItemName(InSkinName))
				FaceCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Mid(Temp, 5));
		}
	}
	FaceCombo.Sort();
}

function IterateVoices()
{
	const MaxVoices = 1024;
	local int NumVoices;
	local string NextVoice, NextDesc;
	local string VoicepackMetaClass;

	VoicePackCombo.Clear();

	if (bIsTournamentPlayer)
		VoicePackMetaClass = GetDefaultObject(CurrentPlayerClass).GetPropertyText("VoicePackMetaClass");
	if (Len(VoicePackMetaClass) == 0)
	{
		if (CurrentPlayerClass.default.bIsFemale)
			VoicePackMetaClass = "Botpack.VoiceFemale";
		else
			VoicePackMetaClass = "Botpack.VoiceMale";
	}

	// Load the base class into memory to prevent GetNextIntDesc crashing without having the class loaded.
	if (DynamicLoadObject(VoicePackMetaClass, class'Class') == none)
		return;

	VoicePackCombo.AddItem(DefaultText, "", 0);

	GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, 0, NextVoice, NextDesc);
	while( (NextVoice != "") && (NumVoices < MaxVoices) )
	{
		VoicePackCombo.AddItem(NextDesc, NextVoice, 1);

		NumVoices++;
		GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, NumVoices, NextVoice, NextDesc);
	}

	VoicePackCombo.Sort();
}


function BeforePaint(Canvas C, float X, float Y)
{
	const EditBoxWidth = 120;

	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;
	CenterWidth += 15;

	ControlOffset = default.ControlOffset;

	NameEdit.SetSize(CenterWidth, 1);
	NameEdit.WinLeft = CenterPos;
	NameEdit.WinTop = ControlOffset;
	NameEdit.EditBoxWidth = EditBoxWidth;
	ControlOffset += ControlShift;

	TeamCombo.SetSize(CenterWidth, 1);
	TeamCombo.WinLeft = CenterPos;
	TeamCombo.WinTop = ControlOffset;
	TeamCombo.EditBoxWidth = EditBoxWidth;
	ControlOffset += ControlShift;

	GameCombo.SetSize(CenterWidth, 1);
	GameCombo.WinLeft = CenterPos;
	GameCombo.WinTop = ControlOffset;
	GameCombo.EditBoxWidth = EditBoxWidth;
	ControlOffset += ControlShift;

	ClassCombo.SetSize(CenterWidth, 1);
	ClassCombo.WinLeft = CenterPos;
	ClassCombo.WinTop = ControlOffset;
	ClassCombo.EditBoxWidth = EditBoxWidth;
	ControlOffset += ControlShift;

	SkinCombo.SetSize(CenterWidth, 1);
	SkinCombo.WinLeft = CenterPos;
	SkinCombo.WinTop = ControlOffset;
	SkinCombo.EditBoxWidth = EditBoxWidth;
	if (SkinCombo.bWindowVisible)
		ControlOffset += ControlShift;

	FaceCombo.SetSize(CenterWidth, 1);
	FaceCombo.WinLeft = CenterPos;
	FaceCombo.WinTop = ControlOffset;
	FaceCombo.EditBoxWidth = EditBoxWidth;
	if (FaceCombo.bWindowVisible)
		ControlOffset += ControlShift;

	VoicePackCombo.SetSize(CenterWidth, 1);
	VoicePackCombo.WinLeft = CenterPos;
	VoicePackCombo.WinTop = ControlOffset;
	VoicePackCombo.EditBoxWidth = EditBoxWidth;
	if (VoicePackCombo.bWindowVisible)
		ControlOffset += ControlShift;

	SpectatorCheck.SetSize(CenterWidth, 1);
	SpectatorCheck.WinLeft = CenterPos;
	SpectatorCheck.WinTop = ControlOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		if (bUseChangeNotifications)
		{
			bUseChangeNotifications = false;
			switch(C)
			{
				case NameEdit:
					NameChanged();
					break;
				case TeamCombo:
					TeamChanged();
					break;
				case GameCombo:
					GameChanged();
					break;
				case ClassCombo:
					ClassChanged();
					break;
				case SkinCombo:
					SkinChanged();
					break;
				case FaceCombo:
					FaceChanged();
					break;
				case VoicePackCombo:
					VoiceChanged();
					break;
				case SpectatorCheck:
					SpectatorChanged();
					break;
			}
			bUseChangeNotifications = true;
		}
	}
}

function NameChanged()
{
	local string N;

	N = NameEdit.GetValue();
	ReplaceText(N, " ", "_");
	NameEdit.SetValue(N);

	GetPlayerOwner().ChangeName(N);
	UpdateURL("Name", N, true);
}

function TeamChanged()
{
	ApplySelectedModel();
}

function GameChanged()
{
	bTournament = int(GameCombo.GetValue2()) > 0;

	if (bTournament && DynamicLoadObject("Botpack.TournamentPlayer", class'Class') == none)
	{
		bTournament = false;
		MessageBox(ErrorTitle, NoBotpackMessage, MB_OK, MR_OK);
		GameCombo.SetSelectedIndex(0);
		return;
	}

	LoadClasses();
	FetchGamePlayerParams();
	if (Len(CurrentClass) > 0)
	{
		UpdateModelControls();
		ApplySelectedModel();
		ApplySelectedVoice(true);
	}
	else
	{
		ClassCombo.SetSelectedIndex(0);
		ClassChanged();
	}
}

function ClassChanged()
{
	local bool bSkinsAvailable;
	local bool bFacesAvailable;

	CurrentClass = ClassCombo.GetValue2();

	// Get the class.
	SetCurrentPlayerClassFromName(CurrentClass);
	if (CurrentPlayerClass == none)
		Log("WARNING:" @ Class $ ".ClassChanged couldn't load player class" @ CurrentClass);

	// Get the meshname
	MeshName = "";
	if (CurrentPlayerClass != none && CurrentPlayerClass.default.Mesh != none)
		MeshName = GetPlayerOwner().GetItemName(string(CurrentPlayerClass.default.Mesh));
	if (Len(MeshName) > 0)
	{
		IterateSkins();
		SkinCombo.SetSelectedIndex(0);
		if (Len(SkinCombo.GetValue2()) > 0)
		{
			bSkinsAvailable = true;
			SkinCombo.ShowWindow();
			IterateFaces(SkinCombo.GetValue2());
			FaceCombo.SetSelectedIndex(0);
			bFacesAvailable = Len(FaceCombo.GetValue2()) > 0;
			if (bFacesAvailable)
				FaceCombo.ShowWindow();
		}
	}
	if (!bSkinsAvailable)
		SkinCombo.HideWindow();
	if (!bFacesAvailable)
		FaceCombo.HideWindow();

	if (Len(MeshName) == 0 && Len(CurrentClass) > 0)
	{
		MeshWindow.SetMesh(none, 1);
		VoicePackCombo.HideWindow();
		return;
	}

	ApplySelectedModel();

	if (bIsTournamentPlayer ||
		CurrentPlayerClass != none && GetPlayerOwner().IsA('TournamentPlayer') && Spectator(GetPlayerOwner()) == none)
	{
		VoicePackCombo.ShowWindow();
		IterateVoices();
		VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(GetDefaultObject(CurrentPlayerClass).GetPropertyText("VoiceType"), True), 0));
		ApplySelectedVoice(true);
	}
	else
		VoicePackCombo.HideWindow();
}

function SkinChanged()
{
	if (Len(SkinCombo.GetValue2()) > 0)
	{
		IterateFaces(SkinCombo.GetValue2());
		FaceCombo.SetSelectedIndex(0);
		ApplySelectedModel();
	}
}

function FaceChanged()
{
	if (Len(FaceCombo.GetValue2()) > 0)
		ApplySelectedModel();
}

function VoiceChanged()
{
	ApplySelectedVoice(false);
}

function SpectatorChanged()
{
	ApplySelectedModel();
}


function ApplySelectedModel()
{
	UseSelectedModel();
	ApplyCurrentModel();
	UpdateCurrentMesh();
}

function UseSelectedModel()
{
	CurrentTeam = TeamCombo.GetValue2();
	CurrentClass = ClassCombo.GetValue2();
	if (Len(CurrentClass) > 0 && SkinCombo.bWindowVisible)
		CurrentSkin = SkinCombo.GetValue2();
	else
		CurrentSkin = "";
	if (Len(CurrentClass) > 0 && FaceCombo.bWindowVisible)
		CurrentFace = FaceCombo.GetValue2();
	else
		CurrentFace = "";

	SetCurrentPlayerClassFromName(CurrentClass);
	bIsSpectator = SpectatorCheck.bChecked;
}

function ApplyCurrentModel()
{
	local int NewTeam;

	default.PlayerTeam[int(bIsTournamentPlayer)] = CurrentTeam;
	default.PlayerClass[int(bIsTournamentPlayer)] = CurrentClass;
	default.PlayerSkin[int(bIsTournamentPlayer)] = CurrentSkin;
	default.PlayerFace[int(bIsTournamentPlayer)] = CurrentFace;
	default.PlayerVoice[int(bIsTournamentPlayer)] = CurrentVoice;
	StaticSaveConfig();

	if (SpectatorCheck.bChecked)
	{
		if (bTournament)
			UpdateURL("Class", "Botpack.CHSpectator", true);
		else
			UpdateURL("Class", "UnrealShare.UnrealSpectator", true);
		UpdateURL("Skin", "", true);
		UpdateURL("Face", "", true);
		UpdateURL("Team", "", true);
	}
	else
	{
		UpdateURL("Class", CurrentClass, true);
		UpdateURL("Skin", CurrentSkin, true);
		UpdateURL("Face", CurrentFace, true);
		UpdateURL("Team", CurrentTeam, true);
	}

	NewTeam = Int(CurrentTeam);

	// if the same class as current class, change skin
	if (CurrentClass ~= string(GetPlayerOwner().Class) ||
		CurrentPlayerClass != none && CurrentPlayerClass.default.Mesh != none && CurrentPlayerClass.default.Mesh == GetPlayerOwner().Mesh)
	{
		GetPlayerOwner().ServerChangeSkin(CurrentSkin, CurrentFace, NewTeam);
	}

	if (GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam)
		GetPlayerOwner().ChangeTeam(NewTeam);
}

function UpdateCurrentMesh()
{
	if (CurrentPlayerClass != none)
	{
		if (bIsTournamentPlayer)
			MeshWindow.SetMeshString(GetDefaultObject(CurrentPlayerClass).GetPropertyText("SelectionMesh"));
		else
			MeshWindow.SetMesh(CurrentPlayerClass.default.Mesh, 35 / CurrentPlayerClass.default.CollisionHeight);
		MeshWindow.bIsTournamentPlayer = bIsTournamentPlayer;
		MeshWindow.ClearSkins();
		CurrentPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), FaceCombo.GetValue2(), Int(TeamCombo.GetValue2()));
	}
	else
		MeshWindow.SetMesh(none, 1);
}

function ApplySelectedVoice(bool bClassChanging)
{
	local class<VoicePack> VoicePackClass;
	local VoicePack V;

	if (VoicePackCombo.bWindowVisible)
		CurrentVoice = VoicePackCombo.GetValue2();
	if (CurrentVoice != "")
		VoicePackClass = class<VoicePack>(DynamicLoadObject(CurrentVoice, class'Class'));
	if (!bClassChanging && VoicePackClass != none)
	{
		V = GetPlayerOwner().Spawn(VoicePackClass, GetPlayerOwner(),, GetPlayerOwner().Location);
		V.ClientInitialize(
			GetPlayerOwner().PlayerReplicationInfo,
			GetPlayerOwner().PlayerReplicationInfo,
			'ACK',
			Rand(int(V.GetPropertyText("NumAcks"))));
	}

	UpdateURL("Voice", CurrentVoice, True);
	default.PlayerVoice[int(bIsTournamentPlayer)] = CurrentVoice;
	StaticSaveConfig();

	if (GetPlayerOwner().IsA('TournamentPlayer') &&
		(CurrentClass ~= string(GetPlayerOwner().Class) ||
			CurrentPlayerClass != none && CurrentPlayerClass.default.Mesh != none && CurrentPlayerClass.default.Mesh == GetPlayerOwner().Mesh))
	{
		GetPlayerOwner().ConsoleCommand("B227_SetVoice" @ CurrentVoice);
	}
}

function SetCurrentPlayerClass(class<PlayerPawn> PlayerClass)
{
	CurrentPlayerClass = PlayerClass;
	bIsTournamentPlayer = IsTournamentPlayerClass(PlayerClass);
}

function SetCurrentPlayerClassFromName(string ClassName)
{
	local class<PlayerPawn> PlayerClass;

	PlayerClass = LoadPlayerClass(ClassName);
	SetCurrentPlayerClass(PlayerClass);
}

static function class<PlayerPawn> LoadPlayerClass(string ClassName)
{
	if (Len(ClassName) > 0)
		return class<PlayerPawn>(DynamicLoadObject(ClassName, class'Class', true));
	return none;
}

static function bool IsSpectatorClassName(string ClassName)
{
	return class<Spectator>(LoadPlayerClass(ClassName)) != none;
}

function bool IsTournamentPlayerClass(class<PlayerPawn> PlayerClass)
{
	local class<PlayerPawn> TournamentPlayerClass;

	if (PlayerClass == none)
		return false;

	TournamentPlayerClass = class<PlayerPawn>(FindObject(class'Class', "Botpack.TournamentPlayer"));
	return
		TournamentPlayerClass != none &&
		string(TournamentPlayerClass) ~= "Botpack.TournamentPlayer" &&
		ClassIsChildOf(PlayerClass, TournamentPlayerClass);
}

function UpdateURL(string NewOption, string NewValue, bool bSaveDefault)
{
	GetPlayerOwner().UpdateURL(NewOption, NewValue, bSaveDefault);
	if (!bGetDefaultURLIsSupported)
	{
		if (NewOption ~= "Team")
			default.DefaultURLTeam = NewValue;
		else if (NewOption ~= "Class")
			default.DefaultURLClass = NewValue;
		else if (NewOption ~= "Skin")
			default.DefaultURLSkin = NewValue;
		else if (NewOption ~= "Face")
			default.DefaultURLFace = NewValue;
		else if (NewOption ~= "Voice")
			default.DefaultURLVoice = NewValue;
	}
}

function string GetDefaultURL(string Key)
{
	if (bGetDefaultURLIsSupported)
		return GetPlayerOwner().GetDefaultURL(Key);

	if (Key ~= "Team")
		return default.DefaultURLTeam;
	if (Key ~= "Class")
		return default.DefaultURLClass;
	if (Key ~= "Skin")
		return default.DefaultURLSkin;
	if (Key ~= "Face")
		return default.DefaultURLFace;
	if (Key ~= "Voice")
		return default.DefaultURLVoice;
	return "";
}

function string GetLocalURLParam(string Key)
{
	local string URL;
	local int i;

	URL = GetLevel().GetLocalURL();
	Key = "?" $ Key $ "=";

	i = InStr(Locs(URL), Locs(Key));
	if (i >= 0)
	{
		URL = Mid(URL, i + Len(Key));
		i = InStr(URL, "?");
		if (i >= 0)
			return Left(URL, i);
		return URL;
	}
	return "";
}

defaultproperties
{
	ControlOffset=25
	GameText="Game:"
	GameHelp="Select a game for determining the relevant player classes."
	GameNames(0)="Unreal"
	GameNames(1)="Unreal Tournament"
	VoicePackText="Voice:"
	VoicePackHelp="Choose a voice for your player's taunts and commands."
	DefaultText="Default"
	ErrorTitle="Error"
	NoBotpackMessage="Failed to load Botpack."
}
