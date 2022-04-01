// ===============================================================
// SevenB.PermFragment: permanent fragments!
// ===============================================================

class PermFragment extends Fragment;

state Dying   //a misnomer as it will not die now, but whatever
{
  function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation,
              Vector momentum, name damageType)    //allow players to destroy it
  {
    Destroy();
  }

  simulated function timer();

  simulated function BeginState()
  {
    SetTimer(0,false);
		SetCollision(true, false, false);
  }
}

defaultproperties
{
     LifeSpan=0.000000
}
