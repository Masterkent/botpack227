// ============================================================
// oldskool.OldSkoolLoadGameScrollClient: calls the actual (edited) client....
// ============================================================

class OldSkoolLoadGameScrollClient expands UWindowScrollingDialogClient;
function Created()
{
  ClientClass = class'OldSkoolLoadGameClientWindow';
  Super.Created();
}

defaultproperties
{
}
