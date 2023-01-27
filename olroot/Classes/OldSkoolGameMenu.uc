// ============================================================
// oldskool.OldSkoolGameMenu: new game menu.....
// ============================================================

class OldSkoolGameMenu expands Uwindowpulldownmenu;

var UWindowPulldownMenuItem Load, Save, NewSP, NewGame, LoadGame, Botmatch, Quit, ReturnToGame;


var localized string NewSPName;      //possible future potential.....
var localized string NewSPHelp;
var localized string LoadName;
var localized string SaveName;
var localized string QuitText;
var class<mappack> packclass;
var UWindowMessageBox ConfirmQuit;

function Created()
{
	Super.Created();

	// Add menu items.
	if (DynamicLoadObject("UTMenu.UTGameMenu", class'Class') != none)
	{
		NewGame = AddMenuItem(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu NewGameName"), None);
		Botmatch = AddMenuItem(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu BotmatchName"), None);
		AddMenuItem("-", None);
		NewSP = AddMenuItem(NewSPName, None);
		Load = AddMenuItem(LoadName, None);
		Save = AddMenuItem(SaveName, None);
		AddMenuItem("-", None);
		LoadGame = AddMenuItem(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu LoadGameName"), None);
		ReturnToGame = AddMenuItem(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu ReturnToGameName"), None);
		AddMenuItem("-", None);
		Quit = AddMenuItem(class'UMenu.UMenuGameMenu'.default.QuitName, None);
	}
	else
	{
		NewSP = AddMenuItem(NewSPName, None);
		Load = AddMenuItem(LoadName, None);
		Save = AddMenuItem(SaveName, None);
		AddMenuItem("-", None);
		Botmatch = AddMenuItem(class'UMenu.UMenuGameMenu'.default.BotmatchName, None);
		AddMenuItem("-", None);
		Quit = AddMenuItem(class'UMenu.UMenuGameMenu'.default.QuitName, None);
	}
}

function ShowWindow()
{
  Super.ShowWindow();
  ReturnToGame.bDisabled = GetLevel().Game != None && GetLevel().Game.IsA('UTIntro');
  Save.bDisabled = (GetLevel().Game == None || !GetLevel().Game.IsA('SinglePlayer2')) || GetPlayerOwner().Health <= 0 ;
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
  switch(I)
  {
  case NewGame:
    GetPlayerOwner().ClientTravel( "UT-Logo-Map.unr?Game=Botpack.LadderNewGame", TRAVEL_Absolute, True );
    break;
  case LoadGame:
    GetPlayerOwner().ClientTravel( "UT-Logo-Map.unr?Game=Botpack.LadderLoadGame", TRAVEL_Absolute, True );
    break;
  case Botmatch:
    // Create botmatch dialog.
    Root.CreateWindow(class'oldskoolUTBotmatchWindow', 100, 100, 200, 200, Self, True);
    //Root.CreateWindow(class'utmenu.UTBotmatchWindow', 100, 100, 200, 200, Self, True);
    break;
  case NewSP:
    // Create new game dialog.
    Root.CreateWindow(class'olroot.OldSkoolNewGameWindow', 100, 100, 200, 200, Self, True);
    break;
  case Load:
    // Create load game dialog.
    AnalyzeLoads();
    break;
  case Save:
    // Create save game dialog.
     AnalyzeSaves();
     break;
  case Quit:
    ConfirmQuit = MessageBox(class'UMenu.UMenuGameMenu'.default.QuitTitle, QuitText, MB_YesNo, MR_No, MR_Yes);
    break;
  case ReturnToGame:
    Root.Console.CloseUWindow();
    break;
  }

  Super.ExecuteItem(I);
}

function AnalyzeSaves(){
if (class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom"&&class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="")
  packclass=Class<MapPack>(DynamicLoadObject(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType, class'Class'));
if (class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom")
    Root.CreateWindow(PackClass.default.savemenu, 100, 100, 200, 200, Self, True);
    else
    Root.CreateWindow(class'olroot.OldSkoolSaveGameWindow', 100, 100, 200, 200, Self, True);
}
function AnalyzeLoads(){
if (class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom"&&class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="")
  packclass=Class<MapPack>(DynamicLoadObject(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType, class'Class'));
if ((Getlevel().game!=none&&GetLevel().Game.Isa('SinglePlayer2'))&&(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom"))
Root.CreateWindow(PackClass.default.loadmenu, 100, 100, 200, 200, Self, True);
else
Root.CreateWindow(class'OldSkoolLoadGameWindow', 100, 100, 200, 200, Self, True);}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
  if(W == ConfirmQuit &&Result == MR_Yes)
  Root.QuitGame();
}

function Select(UWindowPulldownMenuItem I)
{
  switch(I)
  {
  case NewGame:
    UMenuMenuBar(GetMenuBar()).SetHelp(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu NewGameHelp"));
    return;
  case LoadGame:
    UMenuMenuBar(GetMenuBar()).SetHelp(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu LoadGameHelp"));
    return;
  case Botmatch:
    UMenuMenuBar(GetMenuBar()).SetHelp(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu BotmatchHelp"));
    break;
  case NewSP:
    UMenuMenuBar(GetMenuBar()).SetHelp(NewSPHelp);
    return;
  case Load:
    UMenuMenuBar(GetMenuBar()).SetHelp(class'umenu.umenugamemenu'.default.LoadHelp);
    break;
  case Save:
    UMenuMenuBar(GetMenuBar()).SetHelp(class'umenu.umenugamemenu'.default.SaveHelp);
    break;
  case Quit:
    UMenuMenuBar(GetMenuBar()).SetHelp(class'umenu.umenugamemenu'.default.QuitHelp);
    break;
  case returntogame:
    UMenuMenuBar(GetMenuBar()).SetHelp(GetLevel().ConsoleCommand("get UTMenu.UTGameMenu ReturnToGameHelp"));
    break;

  }
  Super.Select(I);
}

defaultproperties
{
     NewSPName="&New Single Player Game"
     NewSPHelp="Select to setup a new single player game."
     LoadName="&Load Single Player Game"
     SaveName="&Save Current Game"
     QuitText="Select yes to return to your puny, miserable, useless real life, if you can't handle UNREALity."
}
