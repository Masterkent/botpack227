//=============================================================================
// BigRocket.
//=============================================================================
class BigRocket expands Decoration;

var() float RocketVelocity;
var() float DestroyAfter;

function Trigger( actor Other, pawn EventInstigator )
{
	SetPHysics(PHYS_Projectile);
	Velocity = vector(Rotation)*RocketVelocity;
	Acceleration = Velocity;

	PlayAnim('Ignite', 0.5);
	SetTimer(DestroyAfter,False);
}


function Timer()
{
	Destroy();
}

defaultproperties
{
     RocketVelocity=500.000000
     DestroyAfter=15.000000
     bStatic=False
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.srocket'
     DrawScale=2.000000
     CollisionRadius=40.000000
}
