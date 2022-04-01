// ============================================================
// oldskool.Oldskoolut_shieldbelt: Stops destroying of other armors so it can be used in SP...
// Psychic_313: unchanged
// ============================================================

class Osut_shieldbelt expands ut_shieldbelt;

function bool HandlePickupQuery( inventory Item )
{
  return Super(Pickup).HandlePickupQuery(Item);
}

function PickupFunction(Pawn Other)
{
  //-local Inventory I;

  MyEffect = Spawn(class'UT_ShieldBeltEffect', Other,,Other.Location, Other.Rotation);
  MyEffect.Mesh = Owner.Mesh;
  MyEffect.DrawScale = Owner.Drawscale;

  if ( Level.Game.bTeamGame && (Other.PlayerReplicationInfo != None) )
    TeamNum = Other.PlayerReplicationInfo.Team;
  else
    TeamNum = 3;
  SetEffectTexture();
   //hey, its still useful...sorta :D
  //-I = Pawn(Owner).FindInventoryType(class'UT_Invisibility');
  //-if ( I != None )
  //-  MyEffect.bHidden = true;

  if (Owner.bHidden || Owner.Style == STY_Translucent)
    MyEffect.bHidden = true;
}

defaultproperties
{
     Charge=100
}
