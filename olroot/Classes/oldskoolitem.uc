// ============================================================
// olroot.oldskoolitem: allows for quick uninstall/installing of oldskool.
// ============================================================

class oldskoolitem expands UMenuModMenuItem;
function Setup()
{
if (class'WindowConsole'.default.rootwindow~="olroot.oldskoolrootwindow"){
MenuCaption="Disable &OldSkool Amp'd";
MenuHelp="Why on earth would you do this? :P";  }
}
function execute(){
local processmessage rec;
if (menuitem.owner.root.isa('oldskoolrootwindow')){
rec=processmessage(menuitem.owner.root.createwindow(class'processmessage', 100, 100, 100, 100));
rec.setupbox(self, "Confirm disable","Are you sure you wish to disable OldSkool Amp'd's menus?  Note that to uninstall OldSkool you will need to use setup.exe (but why do that?)", MB_YesNo, MR_No, MR_None, false);}
else{
class'olroot.oldskoolrootwindow'.default.savedroot=menuitem.owner.root.console.rootwindow;  //backup root.
class'olroot.oldskoolrootwindow'.static.staticsaveconfig();
menuitem.owner.root.console.rootwindow="olroot.oldskoolrootwindow";   //update root.
menuitem.owner.root.console.default.rootwindow="olroot.oldskoolrootwindow";
menuitem.owner.root.console.saveconfig();
menuitem.owner.root.console.resetuwindow(); //this pretty much unlinks everything and will restart uwindow system with the olroot's.
}
}

defaultproperties
{
     MenuCaption="Enable &OldSkool Amp'd"
     MenuHelp="Click to finish the installation of OldSkool Amp'd and activate the menus!"
}
