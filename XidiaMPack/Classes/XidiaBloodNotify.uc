// ===============================================================
// XidiaMPack.XidiaBloodNotify: whatever
// ===============================================================

class XidiaBloodNotify expands BloodNotify;

simulated event postbeginplay(){
  super(SpawnNotify).PostBeginPlay();
}

simulated event Actor SpawnNotification(Actor A)   //put in olbloodburst.
{
  a.bUnlit = false;
  if (a.class!=class'OlBloodBurst'&&class'spoldskool'.default.busedecals){
    a.bhidden=true; //don't want to risk destroying.
    if (level.netmode!=nm_client)
      a.remoterole=role_none; //why replicate?
    return spawn(class'olbloodburst',a.owner,a.tag,a.location,a.rotation); //copy :P
  }
  return A;
}

defaultproperties
{
}
