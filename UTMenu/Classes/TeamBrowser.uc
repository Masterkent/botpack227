class TeamBrowser extends MeshBrowser;

var ObjectiveBrowser ObjectiveWindow;

function SetTeamVars()
{
	bTeamGame = True;
	bEnemy = False;
}

function SetInitialBot(class<Bot> InitialBot)
{
	InitialBot.static.SetMultiSkin(MeshWindow.MeshActor,
		RMI.GetBotSkin(0, bTeamGame, bEnemy, GetPlayerOwner()),
		RMI.GetBotFace(0, bTeamGame, bEnemy, GetPlayerOwner()),
		RMI.GetBotTeam(0, bTeamGame, bEnemy, GetPlayerOwner())
		);
}

function SetNumNames()
{
	NumNames = MatchInfo.Default.NumAllies;
}

function Notify(UWindowWindow B, byte E)
{
	local int i;

	switch (E)
	{
		case DE_Click:
			for (i=0; i<MatchInfo.Default.NumAllies; i++)
			{
				if (B == Names[i])
				{
					if (!Names[i].bDisabled)
						NameSelected(i);
					return;
				}
			}
			switch (B)
			{
				case NextButton:
					NextPressed();
					break;
				case BackButton:
					BackPressed();
					break;
				case DescScrollup:
					DescArea.ScrollingOffset--;
					if (DescArea.ScrollingOffset < 0)
						DescArea.ScrollingOffset = 0;
					break;
				case DescScrolldown:
					DescArea.ScrollingOffset++;
					if (DescArea.ScrollingOffset > 10)
						DescArea.ScrollingOffset = 10;
					break;
				case Title1:
					TitleClicked();
					break;
			}
			break;
	}
}

function BackPressed()
{
	if (ObjectiveWindow != None)
		ObjectiveWindow.ShowWindow();
	else
		LadderWindow.ShowWindow();
	Close();
}

function NextPressed()
{
	local EnemyBrowser EB;

	HideWindow();
	EB = EnemyBrowser(Root.CreateWindow(class'EnemyBrowser', 100, 100, 200, 200, Root, True));
	EB.LadderWindow = LadderWindow;
	EB.TeamWindow = Self;
	EB.Ladder = Ladder;
	EB.Match = Match;
	EB.GameType = GameType;
	EB.Initialize();
}

function NameSelected(int i)
{
	local Class<Bot> SelectedMate;

	//-MeshWindow.bRotate = False;
	MeshWindow.FaceButton.ShowWindow();
	MeshWindow.ViewRotator = rot(0, 32768, 0);
	MeshWindow.CenterRotator = rot(0, 0, 0);

	Selected = i;

	SelectedMate = class<Bot>(DynamicLoadObject(RMI.GetBotClassName(i, True, False, GetPlayerOwner()), Class'Class'));
	MeshWindow.SetMeshString(SelectedMate.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	SelectedMate.static.SetMultiSkin(MeshWindow.MeshActor, RMI.GetBotSkin(i, True, False, GetPlayerOwner()), RMI.GetBotFace(i, True, False, GetPlayerOwner()), RMI.GetBotTeam(i, True, False, GetPlayerOwner()));

	DescArea.Clear();
	DescArea.AddText(NameString$" "$RMI.GetBotName(i, True, False, GetPlayerOwner()));
	DescArea.AddText(ClassString$" "$RMI.GetBotClassification(i, True, False, GetPlayerOwner()));
	DescArea.AddText("");
	DescArea.AddText(RMI.GetBotDesc(i, True, False, GetPlayerOwner()));
}

function StartMap(string StartMap, int Rung, string GameType)
{
	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator="
				$"?Tournament="$Rung
				$"?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName
				$"?Team=0";

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}

function Close(optional bool bByParent)
{
	RMI = None;

	Super.Close(bByParent);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	super.WindowEvent(Msg, C, X, Y, Key);

	if (Msg == WM_KeyDown)
	{
		switch (Key)
		{
			case 0x0D: // IK_Enter
				NextPressed();
				break;

			case 0x26: // IK_Up
				B227_ChangeSelected(1);
				break;

			case 0x28: // IK_Down
				B227_ChangeSelected(-1);
				break;

			case 0x21: // IK_PageUp
				Notify(DescScrollup, DE_Click);
				break;

			case 0x22: // IK_PageDown
				Notify(DescScrolldown, DE_Click);
				break;
		}
	}
}

function B227_ChangeSelected(int Offset)
{
	local int NewSelected;

	if (NumNames == 0)
		return;
	NewSelected = Clamp(Selected + Offset, 0, NumNames - 1);
	if (NewSelected != Selected && !Names[NewSelected].bDisabled)
	{
		NameSelected(NewSelected);
		GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
	}
}

defaultproperties
{
     BGName1(0)="UTMenu.CC11"
     BGName1(1)="UTMenu.CC12"
     BGName1(2)="UTMenu.CC13"
     BGName1(3)="UTMenu.CC14"
     BGName2(0)="UTMenu.CC21"
     BGName2(1)="UTMenu.CC22"
     BGName2(2)="UTMenu.CC23"
     BGName2(3)="UTMenu.CC24"
     BGName3(0)="UTMenu.CC31"
     BGName3(1)="UTMenu.CC32"
     BGName3(2)="UTMenu.CC33"
     BGName3(3)="UTMenu.CC34"
     NameString="Name:"
     ClassString="Classification:"
     TeamMesh="Botpack.DomR"
     TeamTex=Texture'Botpack.Skins.RedSkin2'
     BrowserName="Team Roster"
}
