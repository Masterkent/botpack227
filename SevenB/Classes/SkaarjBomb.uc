// ===============================================================
// SevenB.SkaarjBomb: Skaarj Fusion Bomb
// ===============================================================

class SkaarjBomb extends TournamentPickup;

function bool HandlePickupQuery( inventory Item )
{
  if ( Item.class==class)
    return True;
  else
    return Super.HandlePickupQuery( Item );
}
function DropInventory()
{
   Destroy();
}

function Destroyed()
{
  local Pawn Victim;
  local SkaarjBombWave DW;

  Victim = Pawn(Owner);

  if ( (Victim != None) && (Victim.Health <= 0) )
  {
     DW = Spawn(class'SkaarjBombWave', , , Victim.Location + vect(0,0,50), Victim.Rotation);
    DW.Instigator = Victim;
  }
  Super.Destroyed();
}

defaultproperties
{
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You got the Skaarj Fusion Bomb!"
     ItemName="Skaarj Fusion Bomb"
     RespawnTime=48.000000
     PickupViewMesh=LodMesh'Botpack.UDamage'
     Charge=300
     MaxDesireability=2.500000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     DeActivateSound=Sound'Botpack.Pickups.AmpOut'
     Icon=Texture'Botpack.Icons.I_UDamage'
     Physics=PHYS_Rotating
     RemoteRole=ROLE_DumbProxy
     Texture=Texture'Botpack.GoldSkin2'
     Mesh=LodMesh'Botpack.UDamage'
     bMeshEnviroMap=True
}
