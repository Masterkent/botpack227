//=============================================================================
// BladeHopper.
//=============================================================================
class BladeHopper extends TournamentAmmo;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_BladeHopper FILE=Textures\Hud\B227_i_BladeHopper.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	AmmoAmount=25
	MaxAmmo=75
	UsedInWeaponSlot(6)=1
	PickupMessage="You picked up some Razor Blades."
	ItemName="Blade Hopper"
	PickupViewMesh=LodMesh'Botpack.BladeHopperM'
	MaxDesireability=0.220000
	Skin=Texture'Botpack.Skins.BladeHopperT'
	Mesh=LodMesh'Botpack.BladeHopperM'
	CollisionRadius=20.000000
	CollisionHeight=10.000000
	bCollideActors=True
	Icon=Texture'Botpack.Icons.B227_I_BladeHopper'
}
