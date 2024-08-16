class B227_UMenuBotSetupBase expands UMenuBotSetupBase;

function UMenuPlayerSetupClient_Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I;

	MeshWindow = UMenuPlayerMeshClient(UMenuPlayerClientWindow(ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	NewPlayerClass = GetPlayerOwner().Class;

	// Player Name
	NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	NameEdit.SetText(NameText);
	NameEdit.SetHelpText(NameHelp);
	NameEdit.SetFont(F_Normal);
	NameEdit.SetNumericOnly(False);
	NameEdit.SetMaxLength(20);
	NameEdit.SetDelayedNotify(True);

	// Team
	ControlOffset += 25;
	TeamCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TeamCombo.SetText(TeamText);
	TeamCombo.SetHelpText(TeamHelp);
	TeamCombo.SetFont(F_Normal);
	TeamCombo.SetEditable(False);
	TeamCombo.AddItem(NoTeam, String(255));
	for (I=0; I<4; I++)
		TeamCombo.AddItem(Teams[I], String(i));

	ControlOffset += 25;
	// Load Classes
	ClassCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ClassCombo.SetText(ClassText);
	ClassCombo.SetHelpText(ClassHelp);
	ClassCombo.SetEditable(False);
	ClassCombo.SetFont(F_Normal);

	// Skin
	ControlOffset += 25;
	SkinCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinCombo.SetText(SkinText);
	SkinCombo.SetHelpText(SkinHelp);
	SkinCombo.SetFont(F_Normal);
	SkinCombo.SetEditable(False);

	ControlOffset += 25;
	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FaceCombo.SetText(FaceText);
	FaceCombo.SetHelpText(FaceHelp);
	FaceCombo.SetFont(F_Normal);
	FaceCombo.SetEditable(False);

	LoadClasses();
}

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	BotCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotCombo.SetButtons(True);
	BotCombo.SetText(BotText);
	BotCombo.SetHelpText(BotHelp);
	BotCombo.SetFont(F_Normal);
	BotCombo.SetEditable(False);
	LoadBots();
	BotCombo.SetSelectedIndex(0);
	ConfigureBot = 0;
	ControlOffset += 25;

	UMenuPlayerSetupClient_Created();
}

function AfterCreate()
{
	super(UMenuDialogClientWindow).AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset + 25;

	LoadCurrent();
	UseSelected();

	Initialized = True;
}

function WindowShown()
{
	Initialized = false;
	LoadClasses();
	LoadCurrent();
	Initialized = true;
}

function LoadClasses()
{
}

function LoadCurrent()
{
}

function SaveConfigs()
{
}

function IterateSkins()
{
	local string SkinName, SkinDesc, TestName, Temp;
	local bool bNewFormat;

	SkinCombo.Clear();

	if( ClassIsChildOf(NewPlayerClass, class'Spectator') )
	{
		SkinCombo.HideWindow();
		return;
	}
	else
		SkinCombo.ShowWindow();

	bNewFormat = NewPlayerClass.default.bIsMultiSkinned;

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
	if( !NewPlayerClass.default.bIsMultiSkinned )
	{
		FaceCombo.HideWindow();
		return;
	}
	else
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

function UMenuPlayerSetupClient_BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;

	NameEdit.SetSize(CenterWidth, 1);
	NameEdit.WinLeft = CenterPos;
	NameEdit.EditBoxWidth = 105;

	TeamCombo.SetSize(CenterWidth, 1);
	TeamCombo.WinLeft = CenterPos;
	TeamCombo.EditBoxWidth = 105;

	SkinCombo.SetSize(CenterWidth, 1);
	SkinCombo.WinLeft = CenterPos;
	SkinCombo.EditBoxWidth = 105;

	FaceCombo.SetSize(CenterWidth, 1);
	FaceCombo.WinLeft = CenterPos;
	FaceCombo.EditBoxWidth = 105;

	ClassCombo.SetSize(CenterWidth, 1);
	ClassCombo.WinLeft = CenterPos;
	ClassCombo.EditBoxWidth = 105;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = CenterPos + CenterWidth - DefaultsButton.WinWidth;

	UMenuPlayerSetupClient_BeforePaint(C, X, Y);

	BotCombo.SetSize(CenterWidth, 1);
	BotCombo.WinLeft = CenterPos;
	BotCombo.EditBoxWidth = 105;
}

function Close(optional bool bByParent)
{
	super(UMenuDialogClientWindow).Close(bByParent);
}
