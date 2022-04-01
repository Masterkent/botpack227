// ===============================================================
// SevenB.PermGlassFragments: perminent
// ===============================================================

class PermGlassFragments extends PermFragment;

simulated function CalcVelocity(vector Momentum, float ExplosionSizes)
{
	Velocity = (FRand()+0.6+0.4)*VRand() * Momentum * 0.0001;
}

defaultproperties
{
     Fragments(0)=LodMesh'UnrealShare.Glass1'
     Fragments(1)=LodMesh'UnrealShare.Glass2'
     Fragments(2)=LodMesh'UnrealShare.Glass3'
     Fragments(3)=LodMesh'UnrealShare.Glass4'
     Fragments(4)=LodMesh'UnrealShare.Glass5'
     Fragments(5)=LodMesh'UnrealShare.Glass6'
     Fragments(6)=LodMesh'UnrealShare.Glass7'
     Fragments(7)=LodMesh'UnrealShare.Glass8'
     Fragments(8)=LodMesh'UnrealShare.Glass9'
     Fragments(9)=LodMesh'UnrealShare.Glass10'
     Fragments(10)=LodMesh'UnrealShare.Glass11'
     numFragmentTypes=11
     ImpactSound=Sound'UnrealShare.General.GlassTink1'
     MiscSound=Sound'UnrealShare.General.GlassTink2'
     Mesh=LodMesh'UnrealShare.Glass1'
     CollisionRadius=10.000000
     CollisionHeight=2.000000
}
