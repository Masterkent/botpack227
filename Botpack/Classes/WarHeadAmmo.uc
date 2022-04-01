//=============================================================================
// WarheadAmmo.
//=============================================================================
class WarheadAmmo extends TournamentAmmo;

#exec TEXTURE IMPORT NAME=B227_I_WarheadAmmo FILE=Textures\Hud\B227_i_WarheadAmmo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	MaxAmmo=2
	AmmoAmount=1
	CollisionHeight=6
	ItemName="Redeemer Rocket"
	Mesh=LodMesh'Botpack.missile'
	PickupMessage="You got a Redeemer rocket"
	PickupViewMesh=LodMesh'Botpack.missile'
	UsedInWeaponSlot(0)=1
	Icon=Texture'Botpack.Icons.B227_I_WarheadAmmo'
}
