// ===============================================================
// XidiaMPack.Minion: Doesn't take damage.  Triggering kills it instantly...
// ===============================================================

class Minion expands StoneTitan;

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
            Vector momentum, name damageType);

function Trigger( actor Other, pawn EventInstigator )
{
  if (Other==self || Health <=0)
    return;
  Died (EventInstigator, 'LeaderDeath', location);
}

defaultproperties
{
}
