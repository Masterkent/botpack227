// ============================================================
// OLweapons.OSAmplifier: so it works with pulse gun and shock rifle... (and the tourney compatible weapons)
// Psychic_313: unchanged
// ============================================================

class OSAmplifier expands Amplifier;
                        //botcode from tournament pickup...
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
event TravelPostAccept()  //UsAaR33: post is better.
{
  local inventory w;

  Super.TravelPostAccept();
  w = Pawn(Owner).FindInventoryType(class'OSshockrifle');
  if ( w != None )
    OSshockrifle(w).Amp = self;
  w = Pawn(Owner).FindInventoryType(class'OSpulsegun');
  if ( w != None )
    OSpulsegun(w).Amp = self;
  w = Pawn(Owner).FindInventoryType(class'OLASMD');
  if ( w != None )
    OLASMD(w).Amp = self;
  w = Pawn(Owner).FindInventoryType(class'OLdpistol');
  if ( w != None )
    OLdpistol(w).Amp = self;
}
event travelpreaccept(){
super(pickup).travelpreaccept();
}
function inventory SpawnCopy( pawn Other )
{
  local inventory Copy;
  local Inventory I;

  Copy = Super.SpawnCopy(Other);
  I = Other.FindInventoryType(class'OSshockrifle');
  if ( OSshockrifle(I) != None )
    OSshockrifle(I).amp = Amplifier(Copy);

  I = Other.FindInventoryType(class'OSpulsegun');
  if ( OSpulsegun(I) != None )
    OSpulsegun(I).amp = Amplifier(Copy);

  I = Other.FindInventoryType(class'OLASMD');
  if ( OLASMD(I) != None )
    OLASMD(I).amp = Amplifier(Copy);

  I = Other.FindInventoryType(class'OLdpistol');
  if ( OLdpistol(I) != None )
    OLdpistol(I).amp = Amplifier(Copy);

  return Copy;
}

function UsedUp()
{
  local Inventory I;

  I = Pawn(Owner).FindInventoryType(class'OSshockrifle');
  if (OSshockrifle(I) != None )
    OSshockrifle(I).amp = None;

  I = Pawn(Owner).FindInventoryType(class'OSpulsegun');
  if ( OSpulsegun(I) != None )
    OSpulsegun(I).amp = None;

  I = Pawn(Owner).FindInventoryType(class'OLASMD');
  if ( OLASMD(I) != None )
    OLASMD(I).amp = None;

  I = Pawn(Owner).FindInventoryType(class'OLdpistol');
  if ( OLdpistol(I) != None )
    OLdpistol(I).amp = None;

  Super.UsedUp();
}

defaultproperties
{
     ItemName="Amplifier"
}
