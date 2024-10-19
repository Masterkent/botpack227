// Modified console for different menu music and menu
// Sergey 'Eater' Levin, 2002

class NCConsole extends UnrealConsole;

state UWindow
{
	event Tick( float Delta )
	{
		local Music MenuSong;

		Super.Tick( Delta );
		if (Root == None)
			return;
		if (Root.GetPlayerOwner().Song == None || Root.GetPlayerOwner().Song == Music(DynamicLoadObject("utmenu23.utmenu23", class'Music'))) {
			MenuSong = none; //Music(DynamicLoadObject("NCMenu.NCMenu", class'Music'));
			Root.GetPlayerOwner().ClientSetMusic( MenuSong, 0, 0, MTRAN_Fade );
		}
	}
}

defaultproperties
{
     RootWindow="NaliChronicles.NCRootWindow"
     ShowDesktop=True
}
