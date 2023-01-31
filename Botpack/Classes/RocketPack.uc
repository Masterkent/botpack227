//=============================================================================
// RocketPack.
//=============================================================================
class RocketPack extends TournamentAmmo;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_RocketPack FILE=Textures\Hud\B227_i_RocketPack.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=12
	MaxAmmo=48
	UsedInWeaponSlot(9)=1
	PickupMessage="You picked up a rocket pack."
	PickupViewMesh=LodMesh'Botpack.RocketPackMesh'
	MaxDesireability=0.300000
	Physics=PHYS_Falling
	Mesh=LodMesh'Botpack.RocketPackMesh'
	CollisionRadius=27.000000
	CollisionHeight=12.000000
	bCollideActors=True
	Icon=Texture'Botpack.Icons.B227_I_RocketPack'
}
