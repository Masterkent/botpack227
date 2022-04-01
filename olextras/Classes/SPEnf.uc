// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SPEnf.  Simply an enforcer travel hack, which will allow the doubles to be set up properitly.
// ============================================================

class SPEnf expands enforcer;

var travel bool HasTwoEnf;

function bool HandlePickupQuery(Inventory Item)
{
	local bool Result;

	Result = super.HandlePickupQuery(Item);
	HasTwoEnf = B227_bDoubleEnforcer;
	return Result;
}

function DropFrom(vector StartLocation)
{
	super.DropFrom(StartLocation);
	HasTwoEnf = false;
}

event TravelPostAccept()
{
	if (HasTwoEnf)
		B227_bDoubleEnforcer = true;
	else
		HasTwoEnf = B227_bDoubleEnforcer;
	super.TravelPostAccept();
}

/*-
function SetSwitchPriority(pawn Other)   //allows use of ENF properties
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'enforcer' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'enforcer';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }

    // also set double switch priority

    for ( i=0; i<20; i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'doubleenforcer' )
      {
        DoubleSwitchPriority = i;
        return;
      }
  }
}

//copies vars over so can detect travel much better :P
function bool HandlePickupQuery( inventory Item )
{
  local Pawn P;
  local Inventory Copy;

  if ( (Item.class == class) && (SlaveEnforcer == None) )
  {
    P = Pawn(Owner);
    // spawn a double
    Copy = Spawn(class, P);
    Copy.BecomeItem();
    ItemName = DoubleName;
    SlaveEnforcer = Enforcer(Copy);
    SetTwoHands();
    AIRating = 0.4;
    HasTwoEnf=true;     //IMPORTANT: TWO ENF TRAVEL VAR.
    SlaveEnforcer.SetUpSlave( Pawn(Owner).Weapon == self );
    SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
    SetTwoHands();
    P.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, Self.Class );
    Item.PlaySound(Item.PickupSound);
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
    Item.SetRespawn();
    return true;
  }
  return Super.HandlePickupQuery(Item);
}
function DropFrom(vector StartLocation)
{
super.dropfrom(startlocation);
HasTwoEnf=false; //set back var.
}
event TravelPostAccept() //this allows the slave enf to be spawned
{
local Pawn P;
super.TravelPostAccept();
P = Pawn(Owner);
if (!hastwoenf||P==none)
return;
//spawn a slave
SlaveEnforcer = Spawn(class, P);
    SlaveEnforcer.BecomeItem();
    ItemName = DoubleName;
    SetTwoHands();
    AIRating = 0.4;
    SPENF(SlaveEnforcer).SetUpSlaveNoAm( P.Weapon == self );
    SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
    SetTwoHands();
}
*/
function SetUpSlaveNoAM(bool bBringUp) //set up slave w/out adding ammo.  from traveling.
{
  bIsSlave = true;
  ItemName = DoubleName;
  AmbientGlow = 0;
  if ( bBringUp )
    BringUp();
  else
    GotoState('Idle2');
}

defaultproperties
{
}
