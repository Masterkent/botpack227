// ===============================================================
// XidiaMPack.CarGrenadeAmmo: alt ammo for the car
// ===============================================================

class CarGrenadeAmmo expands TournamentAmmo;

function bool HandlePickupQuery( inventory Item )
{
  local XidiaCarRifle ca;
  if ( (class == item.class) ||
    (ClassIsChildOf(item.class, class'Ammo') && (class == Ammo(item).parentammo)) )
  {
    if (AmmoAmount==MaxAmmo) return true;
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
    if (class'UTC_Inventory'.static.B227_GetPickupMessageClass(Item) == None)
      Pawn(Owner).ClientMessage( Item.PickupMessage, 'Pickup' );
    else
      class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), class'UTC_Inventory'.static.B227_GetPickupMessageClass(Item), 0, None, None, Item.Class);
    item.PlaySound( item.PickupSound );
    if (ammoamount==0){ //check if only ammo in gun!
      ca=XidiaCarRifle(Pawn(Owner).FindInventoryType(class'XidiaCarRifle'));
      if (ca.ammotype!=self&&ca.ammotype.ammoamount<=0)
        Ca.SwapAmmo();
    }
    AddAmmo(Ammo(item).AmmoAmount);
    item.SetRespawn();
    return true;
  }
  if ( Inventory == None )
    return false;

  return Inventory.HandlePickupQuery(Item);
}

defaultproperties
{
     AmmoAmount=3
     MaxAmmo=15
     UsedInWeaponSlot(3)=1
     PickupMessage="You picked up Ca Rifle grenades."
     PickupViewMesh=LodMesh'BotPack.RocketPackMesh'
     MaxDesireability=0.300000
     Physics=PHYS_Falling
     Mesh=LodMesh'BotPack.RocketPackMesh'
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     bCollideActors=True
     Icon=Texture'Botpack.Icons.B227_I_RocketPack'
}
