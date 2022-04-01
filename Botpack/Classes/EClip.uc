class EClip extends Miniammo;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_EClip FILE=Textures\Hud\B227_i_EClip.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=20
	ParentAmmo=Class'Botpack.Miniammo'
	PickupMessage="You picked up a clip."
	PickupViewMesh=LodMesh'Botpack.EClipM'
	Icon=Texture'Botpack.Icons.B227_I_EClip'
	Mesh=LodMesh'Botpack.EClipM'
	CollisionRadius=20.000000
	CollisionHeight=4.000000
}
