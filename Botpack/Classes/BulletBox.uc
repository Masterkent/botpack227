//=============================================================================
// BulletBox.
//=============================================================================
class BulletBox extends TournamentAmmo;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_BulletBox FILE=Textures\Hud\B227_i_BulletBox.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=10
	MaxAmmo=50
	UsedInWeaponSlot(0)=1
	PickupMessage="You got a box of rifle rounds."
	ItemName="Box of Rifle Rounds"
	PickupViewMesh=LodMesh'Botpack.BulletBoxM'
	MaxDesireability=0.240000
	Icon=Texture'Botpack.Icons.B227_I_BulletBox'
	Physics=PHYS_Falling
	Skin=Texture'Botpack.Skins.BulletBoxT'
	Mesh=LodMesh'Botpack.BulletBoxM'
	CollisionRadius=15.000000
	CollisionHeight=10.000000
	bCollideActors=True
}
