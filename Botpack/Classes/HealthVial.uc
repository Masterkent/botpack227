//=============================================================================
// Vial.
//=============================================================================
class HealthVial extends TournamentHealth;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	HealingAmount=5
	bSuperHeal=True
	PickupMessage="You picked up a Health Vial +"
	ItemName="Health Vial"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'Botpack.Vial'
	PickupSound=Sound'Botpack.Pickups.UTHealth'
	Mesh=LodMesh'Botpack.Vial'
	ScaleGlow=2.000000
	CollisionRadius=14.000000
	CollisionHeight=16.000000
}
