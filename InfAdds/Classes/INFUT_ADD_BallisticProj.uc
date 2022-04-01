//=============================================================================
// INFUT_ADD_BallisticProj.
// Ballistic version of the UT_Tracer
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFUT_ADD_BallisticProj expands Projectile
	abstract;

var Pawn shooter;
var vector StartLoc;
var float MaxRange, EffectiveRange, BulletWeight, GroundHeight, MaxWall, Damage;
var int RealityFake;
var Actor LastHit;
var float LastLocX, LastLocY, LastLocZ, NewLocX, NewLocY, NewLocZ;
var class<Effects> WallHitEffectClass;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner )
		StartLoc, Shooter, LastHit, LastLocX, LastLocY, LastLocZ, NewLocX, NewLocY, NewLocZ;
}

// dropping:
// MaxRange - EffectiveRange = dropdistance for weight 0
// ie.  285 -            100 = 185 meters before hitting the ground
// StartLoc.Z - (Loc.Z of Player - half collision height of Player) = height over ground = GroundHeight

// 16 Units is equal to a foot (a foot is a little less than 1/3 a meter)
// meters * 3,28 = feet
// 96 units ~= 2 meters => 48 units = 1 meter => 157,44 feet

// a players ground speed is 400, running ~= 6,66 meters per second = 400

// ie. M16 MuzzSpeed = 853 meters per second / 6,66 * 400 = 51231
// ie. M16 MaxRange = 3.600 meters * 48 = 172800 units
// ie. M16 EffRange = 550 meters * 48 = 26400 units
// ie. M9-MP5 MuzzSpeed = 365 meters per second / 6,66 * 400 = 21921
// ie. M9-MP5 MaxRange = 285 meters * 48 = 13680 units
// ie. M9-MP5 EffRange = 100 meters * 48 = 4800 units

simulated event PostBeginPlay()
{
	LastHit = None;
	StartLoc = Location;

	Super.PostBeginPlay();

	// MaxWall = maximum wallthickness that can be shot through!
	MaxWall = BulletWeight * 9.2;
	MaxRange /= RealityFake;
	EffectiveRange /= RealityFake;
	// The hidden version Infil_UTBalisticHidden acts like InstantHit
	// this version have to be slowed down, so that the tracer is visible
	if (!bHidden) Speed = 10000;
	MaxSpeed = Speed;
	Velocity = Speed * vector(Rotation);

	if (Owner != None)
		if (Owner.Owner != None)
			if (Shooter == None && Owner.Owner.IsA('Pawn'))
				Shooter = Pawn(Owner.Owner);

	if (Shooter == None)
	{
		GroundHeight = 19.5;
	}
	else
	{
		GroundHeight = Shooter.Location.Z - StartLoc.Z;
		if (Groundheight < 0) GroundHeight *= -1;
		if (StartLoc.Z > Shooter.Location.Z)
			GroundHeight = (Shooter.CollisionHeight / 2) + GroundHeight;
		else
			GroundHeight = (Shooter.CollisionHeight / 2) - GroundHeight;
		if (Groundheight < 0) GroundHeight *= -1;
	}
}

simulated function Tick(float Deltatime)
{
	local float VDistance, Flown, MaxFly;
	local vector DVector, TmpVel;
	local rotator TmpRot;

	if ( (Velocity.X == 0 && Velocity.Y == 0 && Velocity.Z == 0) || Speed == 0 )
	{
		Destroy();
	}
	else
	{
		DVector = StartLoc - Location;
		VDistance = VSize(DVector);
		// Start falling down (all was tested with a M9 with Speed 500... so I now have to recalculate)
		if (Physics != PHYS_Falling)
		{
			if (VDistance >= EffectiveRange)
			{
				Flown = VDistance - EffectiveRange;
				MaxFly = MaxRange - EffectiveRange;
				if (Flown > MaxFly) Flown = MaxFly;
				TmpVel = Velocity;
				TmpVel.Z	-=	( (GroundHeight * (Flown * 100 / MaxFly) / 100) / (RealityFake*2/BulletWeight) )
							*	( Speed/500 );
				TmpRot = Rotation;
				TmpRot.Pitch	-=	( (GroundHeight * (Flown * 100 / MaxFly) / 100) / (RealityFake/2) )
								*	( Speed/500 );
				Velocity = TmpVel;
				SetRotation(TmpRot);
			}
			if (VDistance >= MaxRange)
			{
				SetPhysics(PHYS_Falling);
			}
		}
		ScaleGlow -= Deltatime/2;
	}
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		local Vector X,Y,Z;
		local float KickYaw, KickEffect;

		GetAxes(Rotation,X,Y,Z);
		if (Other != None && Other != self && Other != shooter && Other != Level)
		{
			// if hitting the same actor again, destroy it, cause it was not possible to go through it
			if (LastHit == Other)
			{
				Destroy();
				return;
			}
			if ( Role == ROLE_Authority )
			{
				if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
					&& (PlayerPawn(Instigator) != none || (Bot(Instigator) != none && !Bot(Instigator).bNovice)) )
				{
					Other.TakeDamage(Damage*4, shooter, HitLocation, 5000 * X, 'Decapitated');
				}
				else
					Other.TakeDamage(Damage, shooter, HitLocation, 3000 * X, 'shot');

				if (Other.IsA('Pawn'))
				{
					KickEffect = 0.4;
//					if (Owner != None)
//					{
//						if (Owner.IsA('Infil_UTWeapon'))
//							if (Infil_UTWeapon(Owner).SideKick > 0)
//								KickEffect = Infil_UTWeapon(Owner).SideKick;
//					}
					KickYaw = FRand();
					if (KickYaw > 0.5)
						Pawn(Other).ViewRotation.Yaw += BulletWeight * 100 * KickEffect;
					else
						Pawn(Other).ViewRotation.Yaw -= BulletWeight * 100 * KickEffect;
				}

				if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
					spawn(class'SpriteSmokePuff',,,HitLocation);
			}
			if (Other.IsA('Inventory'))
			{
				Destroy();
			}
			else
			{
				if ( Role == ROLE_Authority )
					TouchMe(Other, True);
			}
		}
	}

	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
				Wall.TakeDamage( Damage, shooter, Location, 3000 * Normal(Velocity), '');

			MakeNoise(1.0);
		}

		if ( Role == ROLE_Authority )
		{
			Spawn(WallHitEffectClass,self,,Location, rotator(HitNormal));
			TouchMe(Wall, False);
		}
	}

	function TouchMe( Actor Other, bool bProcessTouchFunction )
	{
		local float tmpWallDiff;
		local vector LastLoc, NewLoc;

		NetPriority = 7.0;

		// let the projectile fly further if possible
		if (!GoThroughWall(Other))
		{
			LifeSpan = 0.1;
			Destroy();
		}
		else
		{
			LastLoc.X = LastLocX;
			LastLoc.Y = LastLocY;
			LastLoc.Z = LastLocZ;
			NewLoc.X = NewLocX;
			NewLoc.Y = NewLocY;
			NewLoc.Z = NewLocZ;
			tmpWallDiff = VSize(LastLoc - NewLoc) / 2.0;
			MaxWall -= tmpWallDiff;
			tmpWallDiff /= 100.0;

			// normal Touch
			if (bProcessTouchFunction)
			{
				Damage *= 0.80;
				Velocity *= 0.98;
				LastHit = Other;
				// spawn Bloodmark at backside of pawn
//				if (Other.IsA('Pawn'))
			}
			// HitWall
			else
			{
				Damage *= 1.0 - tmpWallDiff * 2.0;
				Velocity *= 1.0 - tmpWallDiff;
				BackWall();
			}
			NetPriority = default.NetPriority;
		}
	}

	simulated function BackWall()
	{
	local vector TmpHitLocation, TmpHitNormal, LastLoc, NewLoc;
		LastLoc.X = LastLocX;
		LastLoc.Y = LastLocY;
		LastLoc.Z = LastLocZ;
		NewLoc.X = NewLocX;
		NewLoc.Y = NewLocY;
		NewLoc.Z = NewLocZ;
		// spawn a decal on the backside of the wall too
		if (Trace(TmpHitLocation,TmpHitNormal,LastLoc,NewLoc,True) != None)
			Spawn(WallHitEffectClass,self,,TmpHitLocation, rotator(TmpHitNormal));
	}

	function bool GoThroughWall(Actor Other)
	{
		local Vector X,Y,Z, LastLoc, NewLoc;
		local float tmpWall;

		Disable('Tick');
		GetAxes(Rotation,X,Y,Z);
		LastLoc = Location;

		if (Other.IsA('Pawn'))
			tmpWall = MaxWall;
		else
			tmpWall = 2.0;

		NewLoc = LastLoc + X * tmpWall;

		while (!SetLocation(NewLoc) && tmpWall <= MaxWall)
		{
			tmpWall += 2.0;
			NewLoc = LastLoc + X * tmpWall;
		}

		if (tmpWall > MaxWall)
			return False;
		else
		{
			LastLocX = LastLoc.X;
			LastLocY = LastLoc.Y;
			LastLocZ = LastLoc.Z;
			NewLocX = NewLoc.X;
			NewLocY = NewLoc.Y;
			NewLocZ = NewLoc.Z;
			Enable('Tick');
			return True;
		}
	}
}

//     RemoteRole=ROLE_Authority

defaultproperties
{
     MaxRange=5000.000000
     EffectiveRange=2400.000000
     BulletWeight=0.800000
     Damage=20.000000
     RealityFake=6
     WallHitEffectClass=Class'Botpack.UT_LightWallHitEffect'
     speed=20000.000000
     MaxSpeed=10000.000000
     MomentumTransfer=30000
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Effect1.FireEffect1u'
     Mesh=LodMesh'Botpack.MiniTrace'
     DrawScale=0.800000
     AmbientGlow=187
     Fatness=120
     bUnlit=True
     bNetTemporary=False
}
