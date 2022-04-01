//=============================================================================
// Rock.
//=============================================================================
class PKRock1 extends BigRock;

var(Sounds) sound 	RockImpact[3];

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType) {

	// If a rock is shot, it will fragment into a number of smaller
	// pieces.  The player can fragment a giant boulder which would
	// otherwise crush him/her, and escape with minor or no wounds
	// when a multitude of smaller rocks hit.

	//log ("Rock gets hit by something...");
	Velocity += Momentum/(DrawScale * 10);
	if (Physics == PHYS_None )
	{
		SetPhysics(PHYS_Falling);
		Velocity.Z += 0.4 * VSize(momentum);
	}
	SpawnChunks(4);
}

function SpawnChunks(int num)
{
	local int    NumChunks,i;
	local PKRock1   TempRock;
	local float scale;

	if ( DrawScale < 1 + FRand() )
		return;

	NumChunks = 1+Rand(num);
	scale = sqrt(0.52/NumChunks);
	if ( scale * DrawScale < 1 )
	{
		NumChunks *= scale * DrawScale;
		scale = 1/DrawScale;
	}
	speed = VSize(Velocity);
	for (i=0; i<NumChunks; i++)
	{
		TempRock = Spawn(class'PKRock1');
		if (TempRock != None )
			TempRock.InitFrag(self, scale);
	}
	InitFrag(self, 0.5);
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local int hitdamage;
		local int rnd;

		rnd = Rand(3);

		PlaySound(RockImpact[rnd],, DrawScale/8,,, 0.6+0.6 * FRand());

		if ( !Other.IsA('BigRock') && !Other.IsA('Titan') )
		{
			Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
			if ( (HitDamage > 6) && (speed > 150) )
				Other.TakeDamage(hitdamage, instigator,HitLocation,
					(35000.0 * Normal(Velocity)), 'crushed' );
		}
	}

	simulated function Landed(vector HitNormal)
	{
		HitWall(HitNormal, None);
	}

	function MakeSound()
	{
		local float soundRad;
		local int rnd;

		rnd = Rand(3);

		if ( Drawscale > 2.0 )
			soundRad = 500 * DrawScale;
		else
			soundRad = 100;

		PlaySound(RockImpact[rnd], SLOT_None, DrawScale/8,,soundRad, 0.6+0.6 * FRand());
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local vector RealHitNormal;

		if ( (Role == ROLE_Authority) && (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
		speed = VSize(velocity);
		MakeSound();
		if ( (HitNormal.Z > 0.8) && (speed < 60 - DrawScale) )
		{
			SetPhysics(PHYS_None);
			GotoState('Sitting');
		}
		else
		{
			SetPhysics(PHYS_Falling);
			RealHitNormal = HitNormal;
			if ( FRand() < 0.5 )
				RotationRate.Pitch = Max(RotationRate.Pitch, 100000);
			else
				RotationRate.Roll = Max(RotationRate.Roll, 100000);
			HitNormal = Normal(HitNormal + 0.5 * VRand());
			if ( (RealHitNormal Dot HitNormal) < 0 )
				HitNormal.Z *= -0.7;
			Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			DesiredRotation = rotator(HitNormal);
			if ( (speed > 150) && (FRand() * 30 < DrawScale) )
				SpawnChunks(4);
		}
	}

Begin:
	Sleep(5.0);
	SetPhysics(PHYS_Falling);
}

State Sitting
{
Begin:
	SetPhysics(PHYS_None);
	Sleep(DrawScale * 0.5);
	Destroy();
}

defaultproperties
{
     RockImpact(0)=Sound'PerUnreal.RockLobber.Rock1'
     RockImpact(1)=Sound'PerUnreal.RockLobber.Rock2'
     RockImpact(2)=Sound'PerUnreal.RockLobber.Rock3'
     speed=1000.000000
     MaxSpeed=2000.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
}
