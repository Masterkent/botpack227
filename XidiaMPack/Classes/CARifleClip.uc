//=============================================================================
// CARifleClip.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================

class CARifleClip expands TournamentAmmo;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack
#exec TEXTURE IMPORT NAME=CARAmmoI FILE=Textures\CARAmmoI.pcx GROUP="Icons" MIPS=OFF

//#exec TEXTURE IMPORT NAME=JCARammo1 FILE=MODELS\CARIFLE\ammo01.PCX GROUP=Skins FLAGS=2 // Material #7

// Caseless ammo for Combat Assault Rifle
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
     AmmoAmount=50
     MaxAmmo=400
     UsedInWeaponSlot(3)=1
     PickupMessage="You got a 50 bullet CAR clip."
     PickupViewMesh=LodMesh'XidiaMPack.CARammo'
     PickupViewScale=3.500000
     MaxDesireability=0.240000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Mesh=LodMesh'XidiaMPack.CARammo'
     DrawScale=2.500000
     CollisionRadius=15.000000
     CollisionHeight=20.000000
     bCollideActors=True
     Icon=Texture'XidiaMPack.Icons.CARAmmoI'
}
