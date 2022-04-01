//=============================================================================
// Vial.
//=============================================================================
class PKHealthVial extends TournamentHealth;

auto state Pickup
{
	function Touch( actor Other )
	{
		local int HealMax;
		local Pawn P;

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
			HealMax = P.default.health;
			if (bSuperHeal) HealMax = Min(199, HealMax * 2.0);
			if (P.Health < HealMax)
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, P);
				P.Health += HealingAmount;
				if (P.Health > HealMax) P.Health = HealMax;
				PlayPickupMessage(P);
				PlaySound (PickupSound,,,,,0.9+0.2*FRand());
				Other.MakeNoise(0.2);
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
     HealingAmount=5
     bSuperHeal=True
     PickupMessage="You picked up a Health Vial +"
     ItemName="Health Vial"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'Botpack.Vial'
     PickupSound=Sound'PerUnreal.Misc.PKHealthVial'
     Mesh=LodMesh'Botpack.Vial'
     ScaleGlow=2.000000
     CollisionRadius=14.000000
     CollisionHeight=16.000000
}
