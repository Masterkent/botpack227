//=============================================================================
// Shock Core
//=============================================================================
class PKShockCore extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(4)=1
     PickupMessage="You picked up a Shock Core."
     ItemName="Shock Core"
     PickupViewMesh=LodMesh'Botpack.ShockCoreM'
     PickupSound=Sound'PerUnreal.ShockRifle.PKshockammo'
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
