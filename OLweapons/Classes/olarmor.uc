// ============================================================
//  olarmor by UsAaR33.  allows UT armor rules.....
// Psychic_313: unchanged in Oldskool III OlWeapons.OlArmor
// ============================================================

class olarmor expands armor2;
function bool HandlePickupQuery( inventory Item )
{
  local inventory S;

  if ( item.class == class )
  {
    if (level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules){
    S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
    if (s==none) //try another check
    S = Pawn(Owner).FindInventoryType(class'osShieldbelt');
     if (s==none) //try another check
    S = Pawn(Owner).FindInventoryType(class'ospowershield');
    if (  S==None )
    {
      if ( Charge<Item.Charge )
        Charge = Item.Charge;
    }
    else
      Charge = Clamp(S.Default.Charge - S.Charge, Charge, Item.Charge );   }
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
    /*-if ( PickupMessageClass == None )
      Pawn(Owner).ClientMessage(PickupMessage, 'Pickup');
    else
      Pawn(Owner).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );*/
    Item.PlaySound (PickupSound,,2.0);
    Item.SetReSpawn();
    return true;
  }
  if ( Inventory == None )
    return false;

  return Inventory.HandlePickupQuery(Item);
}

function inventory SpawnCopy( pawn Other )
{
  local inventory Copy, S;

  Copy = Super(pickup).SpawnCopy(Other);
  if (level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules){
  S = Other.FindInventoryType(class'UT_Shieldbelt');
      if (s==none) //try another check
    S = Other.FindInventoryType(class'osShieldbelt');
     if (s==none) //try another check
    S = Other.FindInventoryType(class'ospowershield');
  if ( S != None )
  {
    Copy.Charge = Min(Copy.Charge, S.Default.Charge - S.Charge);
    if ( Copy.Charge <= 0 )
    {
      S.Charge -= 1;
      Copy.Charge = 1;
    }
  }  }
  return Copy;
}

defaultproperties
{
     PickupMessage="You got the Assault Vest"
     PickupViewMesh=Mesh'UnrealShare.ArmorM'
     ArmorAbsorption=90
     MaxDesireability=1.800000
     PickupSound=Sound'UnrealShare.Pickups.ArmorSnd'
     Icon=Texture'UnrealShare.Icons.I_Armor'
     Mesh=Mesh'UnrealShare.ArmorM'
}
