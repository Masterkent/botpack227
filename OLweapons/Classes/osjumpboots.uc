// ============================================================
// OLweapons.osjumpboots: so the jumpboots appear on the HUD....
// Psychic_313: unchanged
// ============================================================

class osjumpboots expands ut_jumpboots;
function OwnerJumped()
{
  TimeCharge=0;
  if ( Charge <= 0 )
  {
    if ( Owner != None )
    {
      Owner.PlaySound(DeActivateSound);
      Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
    }
    UsedUp();
  }
  else
    Owner.PlaySound(sound'BootJmp');
  Charge -= 1;
}

function Timer()
{
  if ( !Pawn(Owner).bAutoActivate )
  {
    TimeCharge++;
    if (TimeCharge>20) OwnerJumped();
  }
}

state Activated
{
  function endstate()
  {
    Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
    Pawn(Owner).bCountJumps = False;
    bActive = false;
  }
Begin:
  Pawn(Owner).bCountJumps = True;
  Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
  Owner.PlaySound(ActivateSound);
}

defaultproperties
{
     ExpireMessage="The Jump Boots have drained"
     bAutoActivate=False
     ItemName="Jump Boots"
     PickupViewMesh=LodMesh'UnrealI.lboot'
     ActivateSound=Sound'UnrealI.Pickups.BootSnd'
     Mesh=LodMesh'UnrealI.lboot'
     CollisionHeight=7.000000
}
