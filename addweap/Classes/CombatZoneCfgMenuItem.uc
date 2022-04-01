///////////////////////////////////////////////////////
// CTFScoreCfgMenuItem
///////////////////////////////////////////////////////
class CombatZoneCfgMenuItem expands UMenuModMenuItem;

function Execute()
{
  MenuItem.Owner.Root.CreateWindow(class'COmbatZoneCfgWindow',
      10, 10, 450, 350);
}

defaultproperties
{
     MenuCaption="CombatZone Configuration"
     MenuHelp="Configure CombatZone options."
}
