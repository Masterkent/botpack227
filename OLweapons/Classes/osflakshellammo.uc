// ============================================================
// olweapons.osflakshellammo: to stop cheats...  thankz to UTPT for mesh extraction....
// Psychic_313: unchanged
// ============================================================

class osflakshellammo expands flakammo;
//mesh stuff
#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

defaultproperties
{
     AmmoAmount=1
     ParentAmmo=Class'botpack.FlakAmmo'
     PickupMessage="You got a flak shell."
     PickupViewMesh=LodMesh'OLweapons.FlakSlugAm'
     Mesh=LodMesh'OLweapons.FlakSlugAm'
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
