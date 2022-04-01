// ===============================================================
// SevenB.PermWoodFragments: perminent
// ===============================================================

class PermWoodFragments extends PermFragment;

simulated function CalcVelocity(vector Momentum, float ExplosionSize)
{
	Super.CalcVelocity(Momentum, ExplosionSize);
	Velocity.z += ExplosionSize/2;
}

defaultproperties
{
     Fragments(0)=LodMesh'UnrealShare.wfrag1'
     Fragments(1)=LodMesh'UnrealShare.wfrag2'
     Fragments(2)=LodMesh'UnrealShare.wfrag3'
     Fragments(3)=LodMesh'UnrealShare.wfrag4'
     Fragments(4)=LodMesh'UnrealShare.wfrag5'
     Fragments(5)=LodMesh'UnrealShare.wfrag6'
     Fragments(6)=LodMesh'UnrealShare.wfrag7'
     Fragments(7)=LodMesh'UnrealShare.wfrag8'
     Fragments(8)=LodMesh'UnrealShare.wfrag9'
     numFragmentTypes=9
     ImpactSound=Sound'UnrealShare.General.WoodHit1'
     MiscSound=Sound'UnrealShare.General.WoodHit2'
     Mesh=LodMesh'UnrealShare.wfrag2'
     CollisionRadius=12.000000
     CollisionHeight=2.000000
     Mass=5.000000
     Buoyancy=6.000000
}
