//=============================================================================
// RifleShell.
//=============================================================================
class PKRifleShell extends PKBulletBox;

defaultproperties
{
     AmmoAmount=1
     ParentAmmo=Class'PerUnreal.PKBulletBox'
     PickupMessage="You got a rifle round."
     ItemName="Rifle Round"
     PickupViewMesh=LodMesh'UnrealI.RifleRoundM'
     PickupSound=None
     Mesh=LodMesh'UnrealI.RifleRoundM'
     CollisionHeight=15.000000
}
