// ===============================================================
// SevenB.Rations: nothing more than a portable health boost
// ===============================================================

class Rations extends Pickup;
var () int HealingAmount;

function Activate()   // Delete from inventory and give player health
{
	local int HealMax;
	local Pawn P;

    P = Pawn(owner);
	HealMax = P.default.health;
	if (P.Health >= HealMax){
       Pawn(Owner).ClientMessage("You are not hungry right now");
       return;
    }
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));
	P.Health += HealingAmount;
	if (P.Health > HealMax) P.Health = HealMax;
    Owner.PlaySound(class'Health'.default.PickupSound);
	Pawn(Owner).ClientMessage("Consumed the Rations +"@HealingAmount);
	if (NumCopies>0)
  	{
    	NumCopies--;
    }
    else
  	{
		Pawn(Owner).NextItem();
      	if (Pawn(Owner).SelectedItem == Self)
		  Pawn(Owner).SelectedItem=None;
      	Pawn(Owner).DeleteInventory(Self);
    }
}

defaultproperties
{
     HealingAmount=50
     bCanHaveMultipleCopies=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You got some Rations"
     RespawnTime=30.000000
     PlayerViewMesh=LodMesh'UnrealShare.HealthM'
     PickupViewMesh=LodMesh'UnrealShare.HealthM'
     PickupSound=Sound'UnrealShare.Pickups.Health2'
     Icon=Texture'UnrealI.Icons.I_Seed'
     Mesh=LodMesh'UnrealShare.HealthM'
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     bCollideWorld=True
     bProjTarget=True
}
