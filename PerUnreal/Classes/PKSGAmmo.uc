//=============================================================================
// PKSGAmmo.
//=============================================================================
class PKSGAmmo extends TournamentAmmo;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     PickupMessage="You picked up a box of shells."
     ItemName="Shells"
     PickupViewMesh=LodMesh'Botpack.BulletBoxM'
     PickupSound=Sound'PerUnreal.Sniper.PKsniperammo'
     Icon=Texture'UnrealShare.Icons.I_ClipAmmo'
     Skin=Texture'PerUnreal.Skins.ShellBox'
     CollisionRadius=20.000000
     CollisionHeight=4.000000
     bCollideActors=True
}
