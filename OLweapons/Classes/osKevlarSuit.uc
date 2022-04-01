// ============================================================
// oskevlarsuit.  allows new rulez to work.
// Psychic_313: unchanged
// ============================================================

class osKevlarSuit expands KevlarSuit;
function BecomeItem()
{
  local Bot B;
  local Pawn P;

  Super.BecomeItem();

  if ( Instigator.IsA('Bot') || Level.Game.bTeamGame || !Level.Game.IsA('DeathMatchPlus')
    || DeathMatchPlus(Level.Game).bNoviceMode
    || (DeathMatchPlus(Level.Game).NumBots > 4) )
    return;

  // let high skill bots hear pickup if close enough
  for ( P=Level.PawnList; P!=None; P=P.NextPawn )
  {
    B = Bot(p);
    if ( (B != None)
      && (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
    {
      B.HearPickup(Instigator);
      return;
    }
  }
}
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

  Copy = Super.SpawnCopy(Other);
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
  } }
  return Copy;
}

defaultproperties
{
}
