// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// BlockShip : This class MUST be used to block ship without destroying it.
// All other blocking methods (outside of zonevelocity) will destroy the ship.
// Is like a block players.
// Note: code assumes this is a block stops a Z area.. thus it removes z component on collision.
// ============================================================

class BlockShip expands Keypoint;

simulated function Bump(actor other){
  local float speed;
  if (tvplayer(other) != none && other.IsInState('playership')){
    tvplayer(other).CheckWall=false;
    speed=vsize(other.velocity);
    other.velocity.z=0;
    other.velocity=normal(other.velocity)*speed;
  }
}

defaultproperties
{
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
     bBlockPlayers=True
}
