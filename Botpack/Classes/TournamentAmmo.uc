//=============================================================================
// TournamentAmmo.
//=============================================================================
class TournamentAmmo extends UTC_Ammo
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Pickups\AmmoPickup_4.WAV" NAME="AmmoPick" GROUP="Pickups"

defaultproperties
{
	PickupSound=Sound'Botpack.Pickups.AmmoPick'
	PickupMessageClass=Class'Botpack.PickupMessagePlus'
	bRepAnimations=False
}
