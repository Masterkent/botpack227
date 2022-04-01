// ============================================================
// olextras.TVTranslocatorTarget: bounces off collidable actors instead of just walls.
// ============================================================

class TVTranslocatorTarget expands TranslocatorTarget;

simulated function Destroyed()   //ensure that it returns
{
	if (Master != none)
	{
		Master.TTarget = None;
		Master.bTTargetOut = false;
	}
	Super.Destroyed();
}

auto state Pickup
{
 singular simulated function Touch( Actor Other )
  {
   if ( Other != Instigator ){
      if ( (Physics == PHYS_Falling) && Other.bBlockPlayers)
        HitWall(-1 * Normal(Velocity), Other);
      return;
   }
   if (role<role_authority)
     return;
   if ( Physics == PHYS_None )
   {
     PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
     Master.TTarget = None;
     Master.bTTargetOut = false;
     //-if ( Other.IsA('PlayerPawn') )
     //-  PlayerPawn(Other).ClientWeaponEvent('TouchTarget');
     destroy();
   }
  }
  event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)         //prevent disruption.....
  {
    SetPhysics(PHYS_Falling);
    Velocity = Momentum/Mass;
    Velocity.Z = FMax(Velocity.Z, 0.7 * VSize(Velocity));
    return;              //prevent it from taking damage....
   }
}

defaultproperties
{
}
