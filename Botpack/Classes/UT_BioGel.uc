//=============================================================================
// ut_BioGel.
//=============================================================================
class UT_BioGel extends Projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var vector SurfaceNormal;
var bool bOnGround;
var bool bCheckedSurface;
var int numBio;
var float wallTime;
var float BaseOffset;
var BioFear MyFear;


function PostBeginPlay()
{
	SetTimer(3.0, false);
	Super.PostbeginPlay();
}

function Destroyed()
{
	if ( MyFear != None )
		MyFear.Destroy();
	Super.Destroyed();
}

function Timer()
{
	local ut_GreenGelPuff f;

	f = spawn(class'ut_GreenGelPuff',,,Location + SurfaceNormal*8);
	f.numBlobs = numBio;
	if ( numBio > 0 )
		f.SurfaceNormal = SurfaceNormal;
	PlaySound (MiscSound,,3.0*DrawScale);
	if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
		Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

	HurtRadiusProj(damage * Drawscale, FMin(250, DrawScale * 75), MyDamageType, MomentumTransfer * Drawscale, Location);
	Destroy();
}

simulated function SetWall(vector HitNormal, Actor Wall)
{
	local rotator RandRot;

	SurfaceNormal = HitNormal;
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'BioMark',,,Location, rotator(SurfaceNormal));
	RandRot = rotator(HitNormal);
	RandRot.Roll += 32768;
	SetRotation(RandRot);
	if ( Mover(Wall) != None )
		SetBase(Wall);
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType )
{
	if ( damageType == MyDamageType )
		numBio = 3;
	GoToState('Exploding');
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ( Pawn(Other)!=Instigator || bOnGround)
			Global.Timer();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		SetPhysics(PHYS_None);
		MakeNoise(0.3);
		bOnGround = True;
		PlaySound(ImpactSound);
		SetWall(HitNormal, Wall);
		PlayAnim('Hit');
		GoToState('OnSurface');
	}


	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (!NewZone.bWaterZone) Return;

		if (!bOnGround)
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.1;
		}
		bOnGround = True;
		Velocity=0.1*Velocity;
	}

	function Timer()
	{
		GotoState('Exploding');
	}

	function BeginState()
	{
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
		bOnGround=False;
		PlaySound(SpawnSound);
	}
}

state Exploding
{
	ignores Touch, TakeDamage;

	function BeginState()
	{
		SetTimer(0.1+FRand()*0.2, False);
	}
}

state OnSurface
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		GotoState('Exploding');
	}

	simulated function CheckSurface()
	{
		local float DotProduct;

		DotProduct = SurfaceNormal dot vect(0,0,-1);
		If( DotProduct > 0.7 )
			PlayAnim('Drip',0.1);
		else if (DotProduct > -0.5)
			PlayAnim('Slide',0.2);
	}

	function Timer()
	{
		if ( Mover(Base) != None )
		{
			WallTime -= 0.2;
			if ( WallTime < 0.15 )
				Global.Timer();
			else if ( VSize(Location - Base.Location) > BaseOffset + 4 )
				Global.Timer();
		}
		else
			Global.Timer();
	}

	function BeginState()
	{
		wallTime = 3.8;

		MyFear = Spawn(class'BioFear');
		if ( Mover(Base) != None )
		{
			BaseOffset = VSize(Location - Base.Location);
			SetTimer(0.2, true);
		}
		else
			SetTimer(wallTime, false);
	}

	simulated function AnimEnd()
	{
		if ( !bCheckedSurface && (DrawScale > 1.0) )
			CheckSurface();

		bCheckedSurface = true;
	}
}

defaultproperties
{
	numBio=9
	speed=840.000000
	MaxSpeed=1500.000000
	Damage=20.000000
	MomentumTransfer=20000
	MyDamageType=Corroded
	ImpactSound=Sound'Botpack.BioRifle.GelHit'
	MiscSound=Sound'UnrealShare.General.Explg02'
	bNetTemporary=False
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=12.000000
	AnimSequence=Flying
	Style=STY_Translucent
	Texture=Texture'Botpack.Jgreen'
	Mesh=LodMesh'Botpack.BioGelm'
	DrawScale=2.000000
	AmbientGlow=255
	bUnlit=True
	bMeshEnviroMap=True
	CollisionRadius=2.000000
	CollisionHeight=2.000000
	bProjTarget=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=100
	LightHue=91
	LightRadius=3
	bBounce=True
	Buoyancy=170.000000
}
