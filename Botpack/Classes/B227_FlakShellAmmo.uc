class B227_FlakShellAmmo expands FlakAmmo;

defaultproperties
{
	AmmoAmount=1
	ParentAmmo=Class'Botpack.FlakAmmo'
	PickupMessage="You got a flak shell."
	PickupMessageClass=None
	ItemName="Flak Shell"
	PickupViewMesh=LodMesh'Botpack.flakslugm'
	Mesh=LodMesh'Botpack.flakslugm'
	CollisionRadius=10.000000
	CollisionHeight=8.000000
	PrePivot=(X=0,Y=0,Z=-3)
}
