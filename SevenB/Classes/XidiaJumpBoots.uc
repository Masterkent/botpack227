// ===============================================================
// XidiaMPack.XidiaJumpBoots: 20 second delay... but no charge!
// ===============================================================

class XidiaJumpBoots expands ut_jumpboots;

var bool bCanJump;
var () float JumpDelay;

function PickupFunction(Pawn Other)
{
  TimeCharge = 0;
  SetTimer(0.0, false);
  bCanJump=true;
}

simulated function SetJumpZ(){ //called when jumped
  if ( !Pawn(Owner).bIsWalking )
  {
    if (bCanJump){
      Pawn(Owner).AirControl = 1.0;
      Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
      Owner.PlaySound(sound'BootJmp');
      bCanJump=false;
      SetTimer(JumpDelay,false);
    }
    else{
      ResetOwner();
      Pawn(Owner).bCountJumps = True;
    }
  }
  if (Pawn(Owner).Inventory!=none)
    Pawn(Owner).Inventory.OwnerJumped();
}

function Timer(){
  bCanJump=true;
  Owner.PlaySound(sound'BootSnd');
}

function OwnerJumped()
{
  if( Inventory != None )
    Inventory.OwnerJumped();

}

defaultproperties
{
     bCanJump=True
     JumpDelay=11.000000
     PickupMessage="You picked up the AntiGrav boots with an 11 second recharge time!"
}
