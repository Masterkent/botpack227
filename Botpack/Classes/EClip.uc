class EClip extends Miniammo;

#exec MESH IMPORT MESH=EClipM ANIVFILE=MODELS\clips_a.3D DATAFILE=MODELS\clips_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=EClipM X=0 Y=0 Z=55
#exec MESH SEQUENCE MESH=EClipM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JEClip FILE=MODELS\clip.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=EClipM X=0.036 Y=0.036 Z=0.072
#exec MESHMAP SETTEXTURE MESHMAP=EClipM NUM=2 TEXTURE=JEClip
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
