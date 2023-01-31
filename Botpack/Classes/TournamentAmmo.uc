//=============================================================================
// TournamentAmmo.
//=============================================================================
class TournamentAmmo extends UTC_Ammo
	abstract;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	PickupSound=Sound'Botpack.Pickups.AmmoPick'
	PickupMessageClass=Class'Botpack.PickupMessagePlus'
	bRepAnimations=False
}
