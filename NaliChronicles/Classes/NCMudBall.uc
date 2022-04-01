// Mud ball
// Code by Sergey 'Eater' Levin, 2001

class NCMudBall extends NCMagicProj;

var bool bCanHitOwner;
var bool bCS;
var vector SurfaceNormal;

state Stuck {
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType ) {
		Explode(Location,Vector(Rotation));
	}

	function Explode(vector Hitlocation, vector Hitnormal) {
		local actor s;

		//HurtRadius(damage,220, MyDamageType, MomentumTransfer, Hitlocation);
		PlaySound (ImpactSound);
		s = Spawn(Class'NCMudSmoke',,,location);
		s.DrawScale = DrawScale/7.5;
		Destroy();
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		DealOutExp(Other);
		Explode(HitLocation,vector(rotation));
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
	}

	simulated function AnimEnd()
	{
		local float DotProduct;

		if (!bCS) {
			DotProduct = SurfaceNormal dot vect(0,0,-1);
			If( DotProduct > 0.7 )
				PlayAnim('Drip',0.1);
			else if (DotProduct > -0.5)
				PlayAnim('Slide',0.2);
			bCS = true;
		}
	}
	Begin:
	sleep(3.0);
	Explode(Location,Vector(Rotation));
}

state Flying
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType ) {
		Explode(Location,Vector(Rotation));
	}

	function Explode(vector Hitlocation, vector Hitnormal) {
		local actor s;

		PlaySound (ImpactSound);
		s = Spawn(Class'NCMudSmoke',,,location);
		s.DrawScale = DrawScale/7.5;
		Destroy();
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if (NCMudBall(Other) != none) return;
		if ((Pawn(Other)!=Instigator) || (bCanHitOwner)) {
			DealOutExp(Other);
			Other.TakeDamage(damage,instigator,hitlocation,vector(rotation*MomentumTransfer),MyDamageType);
			Explode(HitLocation,vector(rotation));
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local vector TraceNorm, TraceLoc, Extent;
		local actor HitActor;
		local rotator RandRot;

		SurfaceNormal = HitNormal;
		RandRot = rotator(HitNormal);
		RandRot.Roll += 32768;
		SetRotation(RandRot);
		if ( Mover(Wall) != None )
			SetBase(Wall);
		PlaySound(ImpactSound);
		SurfaceNormal = HitNormal;
		PlayAnim('Hit');
		GotoState('Stuck');
	}


	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (!NewZone.bWaterZone) Return;

		w = Spawn(class'WaterRing',,,,rot(16384,0,0));
		w.DrawScale = 0.1;
		bCS = true;
		Velocity=0.1*Velocity;
		GotoState('Stuck');
	}

	function BeginState()
	{
		Super.BeginState();
		if ( Role == ROLE_Authority )
		{
			Velocity = Vector(Rotation) * Speed;
			Velocity.z += 120;
			if( Region.zone.bWaterZone )
				Velocity=Velocity*0.7;
		}
		if ( Level.NetMode != NM_DedicatedServer )
			RandSpin(100000);
		LoopAnim('Flying',0.4);
		PlaySound(SpawnSound);
	}

	Begin:
	LifeSpan=Default.LifeSpan;
	sleep(1.0);
	bCanHitOwner=true;
	sleep(3.0);
	//HurtRadius(damage,220, MyDamageType, MomentumTransfer, Location);
	Explode(Location,Vector(Rotation));
}

defaultproperties
{
     speed=840.000000
     MaxSpeed=1500.000000
     Damage=2.000000
     MomentumTransfer=20000
     MyDamageType=Crushed
     ImpactSound=Sound'Botpack.BioRifle.GelHit'
     MiscSound=Sound'UnrealShare.General.Explg02'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=12.000000
     AnimSequence=Flying
     Texture=Texture'Botpack.ChunkGlow.Chunk_a07'
     Mesh=LodMesh'Botpack.BioGelm'
     bMeshEnviroMap=True
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bProjTarget=True
     bBounce=True
     Buoyancy=170.000000
}
