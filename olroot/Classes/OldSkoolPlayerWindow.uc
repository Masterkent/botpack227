// ============================================================
// oldskool.OldSkoolPlayerWindow: the window that pops up to fix up animations....
// ============================================================

class OldSkoolPlayerWindow expands UMenuPlayerWindow;

function BeginPlay()
{
  Super.BeginPlay();

  ClientClass = class'OldSkoolPlayerClientWindow';
}

defaultproperties
{
}
