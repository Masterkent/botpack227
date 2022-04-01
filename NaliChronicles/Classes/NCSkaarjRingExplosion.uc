// Effect for Skaarj cannon
// by Sergey 'Eater' Levin, 2002

class NCSkaarjRingExplosion extends RingExplosion4;

simulated function Timer()
{
	local RingExplosion4 r;

	//log(self$" timer "$Level.TimeSeconds$" role "$Role$" Location "$Location$" rot "$Rotation$" numpuffs "$numpuffs);

	//log("self lifespan "$lifespan);

	if (NumPuffs>0)
	{
		r = Spawn(class'NCSkaarjRingExplosion',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
		r.DrawScale = DrawScale;
	}
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim  ( 'Explo', 0.35, 0.0 );
		SetTimer(0.06, false);
	}
}

defaultproperties
{
     Mesh=LodMesh'Botpack.UTsRingex'
     DrawScale=0.500000
     AmbientGlow=255
}
