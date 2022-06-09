//=============================================================================
// SpecialArrow.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class SpecialArrow expands Arrow;

// Damage grows by flown distance.
// Arrow will stay in HitTargets breast and moves around with him/her
// (Author: NB Beppo)
//=============================================================================
var vector StartLocation; // spawning location for distance check
var vector LocDiff; // Location difference between HitLoc and TargetLoc
var rotator oRot; // original rotation of the arrow
var float RotDiff_Yaw; // rotation difference of the yaw-'axis' between HitTarget and Arrow
var Pawn HitOne; // thats the fellow with an Arrow in his head
var bool IsHit; // to avoid ProcessTouch after the Arrow has hit
var int HitOneDuckMode; // 0 = not ducking, 1 = going down, 2 = standing up
var float DuckVar; // to upper or lower the arrow in duckmode; depends on collision.height of HitTarget
var float oDamage;

function DoSpecialsWithHitOne ( pawn Other )
{
// use this for further hurting or special effects
// in subclasses of course
}

function ResetHitOne ( pawn Other )
{
// use this to reset modifications if Arrow destroy...
}

function PostBeginPlay()
{
	local rotator RandRot;

	Super.PostBeginPlay();
	// used to get distance between Start- and HitLocation
	StartLocation = Location;
	// initialize (don't have to..., but)
	LocDiff = vect(0,0,0);
	oRot = rot(0,0,0);
	RotDiff_Yaw = 0;
	HitOne = None;
	IsHit = False;
	HitOneDuckMode = 0;
	DuckVar = 0;
	oDamage = Damage;
	
	Velocity = Vector(Rotation) * Speed;
	RandRot.Pitch = FRand() * 200 - 100;
	RandRot.Yaw = FRand() * 200 - 100;
	RandRot.Roll = FRand() * 200 - 100;
	Velocity = Velocity >> RandRot;
	PlaySound(SpawnSound, SLOT_Misc, 2.0);
}


simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	local float DamageModify;

	if (Arrow(Other) == none && !IsHit)
	{
		if ( Role == ROLE_Authority )
		{
// Damage depends on distance between
// Start- and HitLocation
			DamageModify = (Abs(VSize(StartLocation-HitLocation))*0.0005);
// use 'FMin' (float) ! don't use 'Min' its just for int vars
  			Damage*=FMin(1.0,DamageModify);
// minimum damage of 1
 			if	( Damage < 1 ) Damage = 1;
// hurt him/her... :)
			Other.TakeDamage(Damage, Instigator, HitLocation,
				(MomentumTransfer * Normal(Velocity)), 'shot');
// if HitTarget is a Pawn let the Arrow stay in its breast
			if ( Pawn(Other) != None)
			{
				HitOne = Pawn(Other);
				
  				LocDiff = HitLocation - HitOne.Location;
// just the z-axis is needed (for best visual results)
  				LocDiff.X = 0; LocDiff.Y = 0;
// don't bother me with Arrows over my head or under my knees
// put them just between my eyes or lower ...
  				if	( LocDiff.Z > 22 )
  					LocDiff.Z = 22;
  				if	( LocDiff.Z < -5 )
  					LocDiff.Z = -5;
  				oRot = Rotation;
  				RotDiff_Yaw = Rotation.Yaw - HitOne.Rotation.Yaw;
// special z-axis-correction if the arrows HitTarget is ducking
				if	(  ( InStr(HitOne.AnimSequence,'Duck') >= 0)
				    || ( InStr(HitOne.AnimSequence,'Bowing') >= 0)
				    || ( InStr(HitOne.AnimSequence,'Cringe') >= 0) )
				{
					HitOneDuckMode = 1;
					DuckVar = 0.42;
					LocDiff.Z += DuckVar * HitOne.CollisionHeight;
				}
			}
			else {
				HitOne = None;
			}
		}
		GotoState('HitIt');
	}
}

// HitTarget is moving ?? so does the Arrow :) !!
state HitIt
{
	function Timer()
	{
	local vector tmpVec;
	local rotator tmpRot;
		if ( HitOne != None && HitOne.Health > 0.0)
		{
// SetBase is simply bad looking...
// a floating arrow just next to targets head looks really bad!
//			SetBase(HitOne);
// so we have to do it on our own...

// arrow moves like its HitTarget do
			tmpRot = oRot;
			tmpRot.Yaw = RotDiff_Yaw + HitOne.Rotation.Yaw;
			tmpVec = HitOne.Location + LocDiff;

// special z-axis-correction if the arrows HitTarget is ducking
// set DuckMode to switch between 'going down' and 'standing up'
			if	(  ( InStr(HitOne.AnimSequence,'Duck') >= 0)
			    || ( InStr(HitOne.AnimSequence,'Bowing') >= 0)
			    || ( InStr(HitOne.AnimSequence,'Cringe') >= 0) )
			 {
				if	(  ( HitOneDuckMode == 0 )
					|| ( HitOneDuckMode == 2 ) ) {
					HitOneDuckMode = 1;
					DuckVar += 0.03;
				}
			}
			else {
				if	( HitOneDuckMode == 1 ) {
					HitOneDuckMode = 2;
					DuckVar -= 0.03;
				}
				else {
					if	(  ( HitOneDuckMode == 2 )
						&& ( DuckVar == 0.00 ) ) {
						HitOneDuckMode = 0;
					}
				}
			}
			if	( HitOneDuckmode == 1 )
			{
// move arrow down ...smoooooth
				tmpVec.Z -= DuckVar * HitOne.CollisionHeight;
				if	( DuckVar < 0.42 ) DuckVar += 0.03;
			}
			if	( HitOneDuckmode == 2 )
			{
// move arrow up ...smoooooth
				tmpVec.Z -= DuckVar * HitOne.CollisionHeight;
				if	( DuckVar > 0.00 ) DuckVar -= 0.03;
			}
			SetLocation( tmpVec );
			SetRotation( tmpRot );

// hey, want to do further hurting or special effects
// go on, make a subclass with this function included...
			DoSpecialsWithHitOne ( HitOne );
		}
		else
			GotoState('KillIt');
	}
Begin:
// stop the Arrow immediatly
	IsHit = True;
	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = 0;
	SetPhysics(PHYS_Flying);
	SetTimer(0.01,true);
}

// ok, let the Arrow fall to the ground and get rid of it
state KillIt
{
Begin:
	ResetHitOne( HitOne );
	SetPhysics(PHYS_Falling);
	Sleep(5.0);
	Destroy();
}

defaultproperties
{
}
