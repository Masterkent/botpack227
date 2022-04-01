// ============================================================
// oldskool.oldskoolpowershield: simply the powershield hack...
// Psychic_313: unchanged
// ============================================================

class ospowershield expands osshieldbelt;
function prebeginplay(){
super(ut_shieldbelt).prebeginplay();
if (level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules)
charge=150;
}

defaultproperties
{
     PickupMessage="You got the PowerShield"
     RespawnTime=100.000000
     Charge=200
}
