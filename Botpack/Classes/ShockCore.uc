//=============================================================================
// Shock Core
//=============================================================================
class ShockCore extends TournamentAmmo;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_ShockCore FILE=Textures\Hud\B227_i_ShockCore.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=10
	MaxAmmo=50
	UsedInWeaponSlot(4)=1
	PickupMessage="You picked up a Shock Core."
	ItemName="Shock Core"
	PickupViewMesh=LodMesh'Botpack.ShockCoreM'
	Physics=PHYS_Falling
	Mesh=LodMesh'Botpack.ShockCoreM'
	SoundRadius=26
	SoundVolume=37
	SoundPitch=73
	CollisionRadius=14.000000
	CollisionHeight=20.000000
	bCollideActors=True
	Icon=Texture'Botpack.Icons.B227_I_ShockCore'
}
