//=============================================================================
// Pammo.
//=============================================================================
class PAmmo extends TournamentAmmo;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_PAmmo FILE=Textures\Hud\B227_i_PAmmo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=25
	MaxAmmo=199
	UsedInWeaponSlot(5)=1
	PickupMessage="You picked up a Pulse Cell."
	ItemName="Pulse Cell"
	PickupViewMesh=LodMesh'Botpack.PAmmo'
	Mesh=LodMesh'Botpack.PAmmo'
	CollisionRadius=20.000000
	CollisionHeight=12.000000
	Icon=Texture'Botpack.Icons.B227_I_PAmmo'
}
