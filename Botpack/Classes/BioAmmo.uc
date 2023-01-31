//=============================================================================
// Sludge.
//=============================================================================
class BioAmmo extends TournamentAmmo;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_BioAmmo FILE=Textures\Hud\B227_i_BioAmmo.pcx GROUP="Icons" MIPS=OFF

auto state Init
{
Begin:
	BecomePickup();
	GoToState('Pickup');
}

defaultproperties
{
	AmmoAmount=25
	MaxAmmo=100
	UsedInWeaponSlot(3)=1
	PickupMessage="You picked up the Biosludge Ammo."
	ItemName="Biosludge Ammo"
	PickupViewMesh=LodMesh'Botpack.BioAmmoM'
	MaxDesireability=0.220000
	Physics=PHYS_Falling
	Mesh=LodMesh'Botpack.BioAmmoM'
	CollisionRadius=22.000000
	CollisionHeight=9.000000
	bCollideActors=True
	Icon=Texture'Botpack.Icons.B227_I_BioAmmo'
}
