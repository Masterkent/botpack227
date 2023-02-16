class UTMenuOptionsMenu227 expands UMenuOptionsMenu;

var UWindowPulldownMenuItem UTPreferences;

var localized string UTPreferencesName;
var localized string UTPreferencesHelp;

function Created()
{
	Super(UWindowPulldownMenu).Created();

	Preferences = AddMenuItem(PreferencesName, none);
	Player = AddMenuItem(PlayerMenuName, none);
	Prioritize = AddMenuItem(PrioritizeName, none);
	AdvPreferences = AddMenuItem(AdvancedOptionsName, none);

	AddMenuItem("-", none);

	UTPreferences = AddMenuItem(UTPreferencesName, none);

	AddMenuItem("-", none);

	Desktop = AddMenuItem(DesktopName, none);
	Desktop.bChecked = Root.Console.ShowDesktop;
}

function ShowUTPreferences()
{
	Root.CreateWindow(Class'UTMenuOptionsWindow227', 100, 100, 200, 200, self, true);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
		case UTPreferences:
			ShowUTPreferences();
			break;

		default:
			super.ExecuteItem(I);
			return;
	}

	super(UWindowPulldownMenu).ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
		case UTPreferences:
			UMenuMenuBar(GetMenuBar()).SetHelp(UTPreferencesHelp);
			break;

		default:
			super.Select(I);
			return;
	}

	super(UWindowPulldownMenu).Select(I);
}

defaultproperties
{
	UTPreferencesName="&Tournament Preferences"
	UTPreferencesHelp="Change your settings for Unreal Tournament."
	PlayerWindowClass=Class'UTMenuPlayerWindow227'
}
