//=============================================================================
// Miniammo.
//=============================================================================
class MiniAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=MiniAmmom ANIVFILE=MODELS\Miniammo_a.3D DATAFILE=MODELS\Miniammo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniAmmom X=-50 Y=-40 Z=0 YAW=0
#exec MESH SEQUENCE MESH=MiniAmmom SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JM21 FILE=MODELS\miniammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=MiniAmmom X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=MiniAmmom NUM=1 TEXTURE=JM21
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
