//=============================================================================
// PKBulletBox.
//=============================================================================
class PKBulletBox extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=60
     UsedInWeaponSlot(0)=1
     PickupMessage="You got a box of rifle rounds."
     ItemName="Box of Rifle Rounds"
     PickupViewMesh=LodMesh'Botpack.BulletBoxM'
     MaxDesireability=0.240000
     PickupSound=Sound'PerUnreal.Sniper.PKsniperammo'
     Icon=Texture'Botpack.Icons.B227_I_BulletBox'
     Physics=PHYS_Falling
     Skin=Texture'Botpack.Skins.BulletBoxT'
     Mesh=LodMesh'Botpack.BulletBoxM'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
