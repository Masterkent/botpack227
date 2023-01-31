//=============================================================================
// MedBox.
//=============================================================================
class MedBox extends TournamentHealth;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	PlayerViewMesh=LodMesh'Botpack.MedBox'
	PickupViewMesh=LodMesh'Botpack.MedBox'
	PickupSound=Sound'Botpack.Pickups.UTHealth'
	Mesh=LodMesh'Botpack.MedBox'
	CollisionRadius=32.000000
}
