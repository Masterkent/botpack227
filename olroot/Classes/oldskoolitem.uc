// ============================================================
// olroot.oldskoolitem: allows for quick uninstall/installing of oldskool.
// ============================================================

class oldskoolitem expands UMenuModMenuItem;

function Setup()
{
	if (class'oldskoolRootwindow'.static.B227_IsEnabled(self))
	{
		MenuCaption = "Disable &OldSkool Amp'd";
		MenuHelp = "Disable the OldSkool menu";
	}
}
function execute()
{
	local processmessage rec;

	if (oldskoolrootwindow(menuitem.owner.root) != none)
	{
		rec = processmessage(menuitem.owner.root.createwindow(class'processmessage', 100, 100, 100, 100));
		rec.setupbox(
			self,
			"Confirm disable",
			"Are you sure you wish to disable OldSkool Amp'd's menus?  Note that to uninstall OldSkool you will need to remove its files.",
			MB_YesNo,
			MR_No,
			MR_None,
			false);
	}
	else
	{
		class'olroot.oldskoolrootwindow'.default.savedroot = menuitem.owner.root.console.rootwindow;  //backup root.
		class'olroot.oldskoolrootwindow'.static.staticsaveconfig();
		menuitem.owner.root.console.rootwindow = "olroot.oldskoolrootwindow";   //update root.
		menuitem.owner.root.console.default.rootwindow = "olroot.oldskoolrootwindow";
		menuitem.owner.root.console.saveconfig();
		menuitem.owner.root.console.resetuwindow(); //this pretty much unlinks everything and will restart uwindow system with the olroot's.
		MenuItem.Owner.Root.Console.LaunchUWindow();
	}
}

defaultproperties
{
     MenuCaption="Enable &OldSkool Amp'd"
     MenuHelp="Click to finish the installation of OldSkool Amp'd and activate the menus!"
}
