//=============================================================================
// Miniammo.
//=============================================================================
class MiniAmmo extends TournamentAmmo;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_MiniAmmo FILE=Textures\Hud\B227_i_MiniAmmo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=50
	MaxAmmo=199
	UsedInWeaponSlot(2)=1
	UsedInWeaponSlot(7)=1
	PickupMessage="You picked up 50 bullets."
	ItemName="Large Bullets"
	PickupViewMesh=LodMesh'Botpack.MiniAmmom'
	Mesh=LodMesh'Botpack.MiniAmmom'
	CollisionRadius=22.000000
	CollisionHeight=11.000000
	bCollideActors=True
	Icon=Texture'Botpack.Icons.B227_I_MiniAmmo'
}
