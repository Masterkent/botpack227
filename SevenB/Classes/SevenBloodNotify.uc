// ===============================================================
// SevenB.SevenBloodNotify: change blood
// ===============================================================

class SevenBloodNotify expands BloodNotify;

simulated event postbeginplay(){
  super(SpawnNotify).PostBeginPlay();
}

simulated event Actor SpawnNotification(Actor A)   //put in olbloodburst.
{
  if (a.class!=class'SevenBloodBurst'){
    a.bhidden=true; //don't want to risk destroying.
    if (level.netmode!=nm_client)
      a.remoterole=role_none; //why replicate?
    return spawn(class'Sevenbloodburst',a.owner,a.tag,a.location,a.rotation); //copy :P
  }
  return A;
}

defaultproperties
{
}
