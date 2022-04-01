// Nali healing fruit seeds, code from Unreal 1
// Code by Sergey 'Eater' Levin, 2001

class NCSeeds extends NCPickup;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

var vector X,Y,Z;
var NCSeeds f;
var float ShrinkTime;

state Activated  // Delete from inventory and toss in front of player.
{
	function Timer()
	{
		GoToState('Shrinking');
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		bRotatetoDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.Roll=0;
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;
		If (VSize(Velocity) < 5)
		{
			bBounce = False;
			SetPhysics(PHYS_None);
			SetTimer(0.5,False);
		}
	}
Begin:
	if (NumCopies>0)
	{
		NumCopies--;
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		f=Spawn(class, Owner, '', Pawn(Owner).Location +10*Y - 20*Z );
		f.NumCopies=-10;
		f.GoToState('Activated');
		GoToState('');
	}
	else
	{
		Disable('Touch');
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		SetPhysics(PHYS_Falling);
		Velocity = Owner.Velocity + Vector(Pawn(Owner).ViewRotation) * 250.0;
		Velocity.z += 100;
		DesiredRotation = RotRand();
		RotationRate.Yaw = 200000*FRand() - 100000;
		RotationRate.Pitch = 200000*FRand() - 100000;
		RotationRate.Roll = 200000*FRand() - 100000;
		bFixedRotationDir=True;
		SetLocation(Owner.Location+Y*10-Z*20);
		if (NumCopies>-5) {
			Pawn(Owner).NextItem();
			if (Pawn(Owner).SelectedItem == Self) Pawn(Owner).SelectedItem=None;
			Pawn(Owner).DeleteInventory(Self);
		}
		BecomePickup();
		bBounce=True;
		bCollideWorld=True;
	}
}


state Shrinking
{

	function Timer()
	{
		Spawn(class'NaliFruit',,,Location+Vect(0,0,20),Rotator(Vect(0,1,0)));
		Destroy();
	}

	function Tick(Float DeltaTime)
	{
		ShrinkTime += DeltaTime;
		DrawScale = 1.0 - fMin(ShrinkTime,0.95);
	}

Begin:
	ShrinkTime = 0;
	SetTimer(0.7,False);
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.SeedInfo'
     bCanHaveMultipleCopies=True
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got the Nali fruit seeds"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'UnrealI.Seed'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.SeedIcon'
     Mesh=LodMesh'UnrealI.Seed'
     AmbientGlow=0
     CollisionRadius=12.000000
     CollisionHeight=4.000000
     bCollideWorld=True
     bProjTarget=True
}
