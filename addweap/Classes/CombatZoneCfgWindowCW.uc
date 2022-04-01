///////////////////////////////////////////////////////
// CTFScoreCfgWindow
///////////////////////////////////////////////////////
class CombatZoneCfgWindowCW extends UMenuDialogClientWindow;


var UWindowSmallCloseButton CloseButton;
var UMenuPageControl Pages;
var int HOffset;
var string DMUTPages[4];
var string TabNames[4];




function Created()
{
	local int i,j,k,y;
	local string Entry,description;
	local int CenterWidth, CenterPos;

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-48, WinHeight-19, 48, 16));

	CreatePages();

	Super.Created();

}

function CreatePages()
{
	local int	i, W, H;
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, 1, 1));

	W=(CombatZoneCfgWindow(GetParent(class'addweap.CombatZoneCfgWindow')).WinWidth)-4;
	H=(CombatZoneCfgWindow(GetParent(class'addweap.CombatZoneCfgWindow')).WinHeight)-41;
	Pages.SetSize(W, H);

	//Pages.SetMultiLine(True);

	for(i=0; i<4; i++) {
		if (DMUTPages[i]!="") {
			PageClass = class<UWindowPageWindow>(DynamicLoadObject(DMUTPages[i], class'Class'));
			if(PageClass != None)
				Pages.AddPage(TabNames[i], PageClass);
		} else {
			break;
		}
	}
}

defaultproperties
{
     DMUTPages(0)="addweap.CombatZoneWeaponCfgWindow"
     DMUTPages(1)="addweap.CombatZoneWeaponCfgWindow"
     DMUTPages(2)="addweap.CombatZoneWeaponCfgWindow"
     TabNames(0)="Weapons"
     TabNames(1)="Settings"
     TabNames(2)="Classes"
}
