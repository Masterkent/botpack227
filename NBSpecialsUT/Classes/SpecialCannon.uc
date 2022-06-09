//=============================================================================
// SpecialCannon.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class SpecialCannon expands Decoration;

// Author: Norbert Bogenrieder (Beppo)
// The normal Cannon can only shoot on non 'living' Actors such as movers.
// This Cannon tracks the actor who activates it until he has reached the
// deactivate-health or the deactivate-distance and when he's matching the
// target type specified!
// In addition it can be used as an automated cannon that finds and destroyes
// its targets !!!
// Added variables:
// DeactivateHealth = deactivate cannon if targets health drops under this entry
// TargetType       = activate only if target matches this type
// TargetTypeClass  = if TT_Class is selected check if this class matches targets class
// + ... (all in SpecialCannon)
//=============================================================================

var(Cannon) float DeactivateDistance;	// How far away Instigator must be to deactivate Cannon
var(Cannon) float SampleTime; 			// How often we sample Instigator's location
var(Cannon) int   TrackingRate;			// How fast Cannon tracks Instigator
var(Cannon) float Drop;					// How far down to drop spawning of projectile
var(Cannon) float Health;
var(Cannon) sound FireSound;
var(Cannon) sound ActivateSound;
var(Cannon) sound ExplodeSound;

//special parameters
var(SpecialCannon) int  DeactivateTargetHealth;	// min health of target to deactivate
var(SpecialCannon) bool bDeactivateOutOfSight; // deactivate if target is out of sight
var(SpecialCannon) bool bAutomatic;	// search for next target within the deactivate distance
var(SpecialCannon) int  MaxAutoTargets; // max number of targets that the cannon can shoot in auto-mode
var(SpecialCannon) bool bActivateIfDamaged; // activate cannon if damaged
var(SpecialCannon) enum ETargetType	// select a specific type of target
{
	TT_Player,	// Target is player proximity.
	TT_Pawn,	// Target is any pawn's proximity
	TT_Class,	// Target is actor of that class only
	TT_Any,     // Target is any actor in proximity.
} TargetType, DamagedByTargetType;
var(SpecialCannon) class<actor> TargetTypeClass; // if target_class than this is it for Trigger
var(SpecialCannon) class<actor> DamagedByTypeClass; // if target_class than this is it for Damage
var(SpecialCannon) localized string ActivateMessage; // if activated send this message to all players
var(SpecialCannon) localized string DeActivateMessage; // if deactivated send this message to all players
var(SpecialCannon) localized string AutoActivateMessage; // if activated in auto-mode send this message to all players
var(SpecialCannon) localized string ActivateIfDamagedMessage; // if activated by damage ...
var(SpecialCannon) bool bIgnoreInstigator;
var(SpecialCannon) bool bIgnoreDamageInstigator;
var(SpecialCannon) bool bInitiallyActive;
var(SpecialEvents) name	EventIfDestroyed;	// event if destroyed
var(SpecialCannon) enum EProjectileType	// select a specific type of projectile
{
	Proj_Default,	// use default projectile
	Proj_Class,		// use projectile of ProjectileClass
} ProjectileType;
var(SpecialCannon) class<projectile> ProjectileClass; // use this projectile if Proj_Class
var(SpecialCannon) bool bIgnoreInstigatorTeam;
var(SpecialCannon) bool bIgnoreDamageInstigatorTeam;
var(SpecialCannon) bool bDontTrackInstigatorsIfIgnore;
var(SpecialCannon) localized string InitiallyIgnoreTeam;
var(SpecialCannon) float ReActivateTime;
var(SpecialCannon) float ReActivateHealth;
var(SpecialProjectile) float PDamage;
var(SpecialProjectile) float PMaxSpeed;
var(SpecialProjectile) int PMomentumTransfer;
var(SpecialProjectile) float PSpeed;
var(SpecialEvents) name	DeactivateTag;
var(SpecialCannon) float FireRate; // ReloadTime for Fire
var(SpecialCannon) bool bDontPlayActivateAnim;
var(SpecialCannon) int ReactivateMode;

var(SpecialInstantHit) bool bInstantHit;
var(SpecialInstantHit) float InstantHitDamage;
var(SpecialInstantHit) class<effects> FireEffect;
var(SpecialInstantHit) class<effects> WallHitEffect;
var(SpecialInstantHit) class<effects> PawnHitEffect;
var(SpecialInstantHit) class<effects> OtherHitEffect;
var(SpecialInstantHit) float InstantHitAccuracy;

var name tTag;

var localized string ActMessage; // the ActivateMessage or AutoActivateMessage
var bool bAutoRun;	// is cannon in auto-mode
var int  cAutoTarget;	// current target number
var int  cTempTarget;
var bool bDeactivateNow;
var float oHealth;
var float TimePassed, TimeToCheck;
var rotator ReactivateRotation;
//end of special parameters

var actor cTarget, oInstigator, dInstigator; //current target and original, damage instigator
var bool bShoot;
var int ShotsFired;
var actor a;
var name oAnim;

function PostBeginPlay()
{
	tTag = Tag;
	ReactivateRotation = Rotation;
	oAnim = AnimSequence;
	Super.PostBeginPlay();
}

function Shoot() {}   // To resolve error 'virtual function 'shoot' not found'

function InitSpecials()
{
	cAutoTarget = 0;
	bDeactivateNow = False;
	if (DeactivateTargetHealth<0) DeactivateTargetHealth = 0;
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	Instigator = InstigatedBy;
	if (Health<0) Return;
	if ( Instigator != None )
		MakeNoise(1.0);
	Health -= NDamage;
	if	(Health <0) {
		PlaySound(ExplodeSound, SLOT_None,5.0);
		spawn(class'SpriteBallExplosion',,,Location - vect(0,0,1)*Drop,rot(16384,0,0));
		if	( ReActivateTime > 0 && ReActivateHealth > 0 )
		{
			TriggerIfDestroyed(instigatedBy);
			GotoState ('Reactivate');
		}
		else
		{
			skinnedFrag(class'Fragment1',texture'JCannon1', Momentum,1.0,17);
			Destroy();
			TriggerIfDestroyed(instigatedBy);
		}
	}
	else {
		// if damaged by choosen class fire at this actor
		if ( bActivateIfDamaged ) {
			a 			= Instigator;
			dInstigator = Instigator;
			if ( !bAutoRun ) InitSpecials();
			if ( IsDamageTarget(a) )
			{
				cTarget = a;
				ActMessage = ActivateIfDamagedMessage;
				if ( ActMessage != "" )
				{
					// send message to instigator if its a player
					if ( Pawn(a)!=None && Pawn(a).bIsPlayer )
						a.Instigator.ClientMessage( ActMessage );
						// send message to all other players within double DeactivateDistance from cannon
				    foreach RadiusActors( class 'Actor', A, DeactivateDistance*2, Location)
					{
						if (  ( Pawn(A)!=None && Pawn(A).bIsPlayer )
						   && ( A != Instigator ) )
							A.Instigator.ClientMessage( ActMessage );
					}
				}
  				GotoState( 'ActivateCannon');
		  	}
		}
	}
}

final function bool IsTarget( actor TT )
{
	// only shootable actors are valid
	if	(TT==None || !TT.bProjTarget)
		return false;

	switch( TargetType )
	{
		case TT_Player:
			return TT.bIsPawn && Pawn(TT)!=None && Pawn(TT).bIsPlayer;
		case TT_Pawn:
			return TT.bIsPawn && Pawn(TT)!=None && ( Pawn(TT).Intelligence > BRAINS_None );
		case TT_Class:
			return ClassIsChildOf(TT.Class, TargetTypeClass);
		case TT_Any:
			return true;
	}
}

final function bool IsDamageTarget( actor TT )
{
	// only shootable actors are valid
	if (TT==None || !TT.bProjTarget)
		return False;
	switch( DamagedByTargetType )
	{
		case TT_Player:
			return Pawn(TT)!=None && Pawn(TT).bIsPlayer;
		case TT_Pawn:
			return Pawn(TT)!=None && ( Pawn(TT).Intelligence > BRAINS_None );
		case TT_Class:
			return ClassIsChildOf(TT.Class, DamagedByTypeClass);
		case TT_Any:
			return true;
	}
}

intrinsic(514) final function bool LineOfSightTo(actor Other);

function Trigger( actor Other, pawn EventInstigator )
{
	if ( !bAutoRun )
	{
		InitSpecials();
		cTarget     = Other;
		oInstigator = Other;
		Instigator  = EventInstigator;
		if ( IsTarget(cTarget) || bAutomatic )
		{
			if ( bAutomatic )
				ActMessage = AutoActivateMessage;
			else
				ActMessage = ActivateMessage;

			if ( ActMessage != "" )
			{
				// send message to instigator if its a player
				if ( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
					Other.Instigator.ClientMessage( ActMessage );

				// send message to all other players within double DeactivateDistance from cannon
			    foreach RadiusActors( class 'Actor', A, DeactivateDistance*2, Location)
   				{
					if (  ( Pawn(A)!=None && Pawn(A).bIsPlayer )
					   && ( A != Other ) )
						A.Instigator.ClientMessage( ActMessage );
				}
			}
	  		GotoState( 'ActivateCannon');
	  	}
	}
}

function TriggerIfDestroyed(pawn DestroyedBy)
{
	local actor A;

	if ( EventIfDestroyed != '' )
		foreach allactors(class'Actor', A, EventIfDestroyed)
			A.Trigger(self, DestroyedBy);
}

final function bool IsInstigatorOrTeam(actor Other)
{
	if	(	(bIgnoreInstigator && Other == oInstigator)
		||	(bIgnoreDamageInstigator && Other == dInstigator)
		)
		return true;
	else
	{
		if	( Level.Game.IsA('TeamGame') )
		{
			if	( oInstigator != None && bIgnoreInstigatorTeam )
			{
				if	( Pawn(oInstigator).PlayerReplicationInfo.TeamName
					==		Pawn(Other).PlayerReplicationInfo.TeamName)
					return true;
				else
					return false;
			}
			else
			{
				if	( dInstigator != None && bIgnoreDamageInstigatorTeam )
				{
					if	( Pawn(dInstigator).PlayerReplicationInfo.TeamName
						==		Pawn(Other).PlayerReplicationInfo.TeamName)
						return true;
					else
						return false;
				}
				else
				{
					if	( bInitiallyActive )
					{
						if	( InitiallyIgnoreTeam
							== Pawn(Other).PlayerReplicationInfo.TeamName)
							return true;
						else
							return false;
					}
					//	place further team-if-structs here
					else
						return false;
				}
			}
		}
		else
			return false;
	}
}

function ActTimer ()
{
	// search next target thats in the LineOfSightTo
	// cause else near targets could not be found if a
	// target in the distance is hiding
	cTempTarget = cAutoTarget;
   	foreach RadiusActors( class 'Actor', A, DeactivateDistance, Location)
   	{
		cTarget = None;
		if	( IsTarget(A) )
		{
			if	( LineOfSightTo(A) )
			{
				//	for Team-testing
				//	ActMessage = Pawn(A).PlayerReplicationInfo.TeamName;
				//	dInstigator.Instigator.ClientMessage( ActMessage );

				if	(	(	bDontTrackInstigatorsIfIgnore
						&&	!IsInstigatorOrTeam(A) )
					||	!bDontTrackInstigatorsIfIgnore
					)
				{
					// set the target only if its valid
					cTarget = A;
					cAutoTarget++;
					GotoState( 'ActivateCannon');
           			break;
           		}
           	}
		}
   	}
   	// if no target is found deactivate
   	if ( cTempTarget == cAutoTarget )
   	{
   		cTarget = None;
   		bDeactivateNow = True;
   	}
}

function CheckMaxTargets ()
{
	// search targets until cannon is destroyed
	// if negativ amount of MaxAutoTargets
	if ( MaxAutoTargets < 0 )
	{
		cAutoTarget    = MaxAutoTargets-1;
		bDeactivateNow = False;
	}
}

function DoDeactivate ()
{
	InitSpecials();
	oInstigator = None;
	dInstigator = None;

   	bAutoRun = False;
	SetTimer(0.0,False);
	if (!bDontPlayActivateAnim) TweenAnim('Activate',3.0);
	else TweenAnim(oAnim,1.0);
	if ( DeActivateMessage != "" )
	{
		// send message to all players within double DeactivateDistance from cannon
	    foreach RadiusActors( class 'Actor', A, DeactivateDistance*2, Location)
		{
			if ( Pawn(A)!=None && Pawn(A).bIsPlayer )
				A.Instigator.ClientMessage( DeActivateMessage );
		}
	}
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local rotator AdjustedAim;

	GetAxes(Rotation,X,Y,Z);
	StartTrace = Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop;
	AdjustedAim = DesiredRotation;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X);
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if (Other == Level)
	{
		if (WallHitEffect != None)
			Spawn(WallHitEffect,,, HitLocation+HitNormal*9, Rotator(HitNormal));
	}
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
	{
		if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
		{
			if (OtherHitEffect != None)
				spawn(OtherHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
		}
		else
		{
			if (PawnHitEffect != None)
				spawn(PawnHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
		}
//		if ( Other.IsA('ScriptedPawn') && (FRand() < 0.2) )
//			Pawn(Other).WarnTarget(Pawn(cControler), 500, X);
		rndDam = InstantHitDamage + Rand(6);
		if ( FRand() < 0.2 )
			X *= 2;
		Other.TakeDamage(rndDam, None, HitLocation, rndDam*500.0*X, 'shot');
	}
}

// initially Active ?
auto state Active
{
	function Timer()
	{
		ActTimer();
    }

Begin:
	if ( bInitiallyActive )
	{
		InitSpecials();
		oInstigator = None;
		dInstigator = None;

		CheckMaxTargets();

    	if ( bAutomatic && cAutoTarget<MaxAutoTargets && !bDeactivateNow)
	    {
    		bAutoRun = True;
    		SetTimer(0.05,True);
		}
	}
}

state ReActivate
{
ignores Trigger, TakeDamage;

	function Timer()
	{
		if (bShoot)
		{
			bShoot = False;
			Health = ReActivateHealth;
			PlayAnim('Angle2', 0.25);
			PlaySound(ActivateSound, SLOT_None, 2.0);
			if (ReactivateMode == 0)
				GotoState ('ActivateCannon');
			else
				GotoState('');
		}
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		if (TimePassed > TimeToCheck) {
			bShoot = True;
			Disable('Tick');
		}
	}

Begin:
	bRotateToDesired = True;
	DesiredRotation = ReactivateRotation;
	TweenAnim('Angle0', 0.25);
	TimePassed = 0.0;
	TimeToCheck = ReactivateTime;
	bShoot = False;
	Enable('Tick');
	SetTimer(0.2,True);
}

state ActivateCannon
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (Tag == DeactivateTag)
		{
			Tag = tTag;
			GotoState('DeactivateTagged');
		}
	}

	function Timer()
	{
        if	( bDeactivateOutOfSight && !LineOfSightTo(cTarget) )
        	GoToState('Deactivate');
		if	( VSize(cTarget.Location - Location) > DeactivateDistance )
			GoToState('Deactivate');
		if	( Pawn(cTarget)!=None && Pawn(cTarget).Health<DeactivateTargetHealth + 1 )
			GoToState('Deactivate');
		if	( cTarget==None || !cTarget.bProjTarget )
			GoToState('Deactivate');
		if	( IsInstigatorOrTeam(cTarget) )
			GoToState('Deactivate');

		DesiredRotation = rotator(cTarget.Location - Location + Vect(0,0,1)*Drop);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		if (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 1000
			&& DesiredRotation.Pitch < 1000 && bShoot)	Shoot();
		else if (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 64535
			&& DesiredRotation.Pitch < 1000 && bShoot)	Shoot();
		else {
			if (DesiredRotation.Pitch < -6000 ) TweenAnim('Angle4', 0.25);
			else if (DesiredRotation.Pitch < -4000 ) TweenAnim('Angle3', 0.25);
			else if (DesiredRotation.Pitch < -2000 ) TweenAnim('Angle2', 0.25);
			else if (DesiredRotation.Pitch < -500 ) TweenAnim('Angle1', 0.25);
			else TweenAnim('Angle0', 0.25);
//			bShoot=True;
		}
		bRotateToDesired = True;
		SetTimer(SampleTime,True);
	}

	function Shoot()
	{
		// to avoid Instigator getting killpoints if Cannon
		// destroys Target - Instigator set to None.
		local pawn TempInstigator;
		local Projectile PProj;
		TempInstigator = Instigator;
		Instigator = None;

		if (DesiredRotation.Pitch < -10000) Return;
		PlaySound(FireSound, SLOT_None,5.0);
		if (DesiredRotation.Pitch < -6000 ) PlayAnim('FAngle4',5.0);
		else if (DesiredRotation.Pitch < -4000 ) PlayAnim('FAngle3',5.0);
		else if (DesiredRotation.Pitch < -2000 ) PlayAnim('FAngle2',5.0);
		else if (DesiredRotation.Pitch < -500 ) PlayAnim('FAngle1',5.0);
		else PlayAnim('FAngle0',5.0);

		if(bInstantHit)
		{
			TraceFire(InstantHitAccuracy);
			if (FireEffect != None)
				Spawn (FireEffect,,,Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop,DesiredRotation);
		}
		else
		{
			switch( ProjectileType )
			{
				case Proj_Default:
					PProj = Spawn (class'CannonBolt',,,Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop,DesiredRotation);
					break;
				case Proj_Class:
					if ( ProjectileClass != None )
						PProj = Spawn (ProjectileClass,,,Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop,DesiredRotation);
					else
						PProj = Spawn (class'CannonBolt',,,Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop,DesiredRotation);
					break;
			}
			if	(PSpeed > 0)
				PProj.Speed = PSpeed;
			if	(PDamage > 0)
				PProj.Damage = PDamage;
			if	(PMaxSpeed > 0)
				PProj.MaxSpeed = PMaxSpeed;
			if	(PMomentumTransfer > 0)
				PProj.MomentumTransfer = PMomentumTransfer;
			if	(PSpeed > 0)
				PProj.Speed = PSpeed;
		}

		// set Instigator back to saved one
		Instigator = TempInstigator;

		TimeToCheck = FireRate;
		TimePassed = 0;
		bShoot = False;
		Enable('Tick');

		SetTimer(0.05,True);
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		if (TimePassed > TimeToCheck) {
			bShoot = True;
			Disable('Tick');
		}
	}

Begin:
	if ( !bAutoRun )
	{
		if (!bDontPlayActivateAnim) PlayAnim('Activate',0.5);
		PlaySound(ActivateSound, SLOT_None, 2.0);
		if (!bDontPlayActivateAnim) FinishAnim();
	}

	if	(	( Tag != DeactivateTag )
		&&	( DeactivateTag != '' ) )	Tag = DeactivateTag;

	Disable('Tick');
	bShoot = True;

	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
}

state DeActivate
{
	function Timer()
	{
    	ActTimer();
    }

Begin:
	CheckMaxTargets();
    if ( bAutomatic && cAutoTarget<MaxAutoTargets && !bDeactivateNow)
    {
    	bAutoRun = True;
    	SetTimer(0.05,True);
	}
	else
	{
		DoDeactivate();
	}
	if (Event!='')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Pawn(cTarget) );
}

state DeActivateTagged
{
Begin:
	DoDeactivate();
	if (Event!='')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Pawn(cTarget) );
	if (bInitiallyActive)
		GotoState('');
}

defaultproperties
{
     DeactivateDistance=2000.000000
     SampleTime=0.200000
     TrackingRate=20000
     Drop=60.000000
     Health=100.000000
     FireSound=Sound'UnrealI.Cannon.CannonShot'
     ActivateSound=Sound'UnrealI.Cannon.CannonActivate'
     ExplodeSound=Sound'UnrealI.Cannon.CannonExplode'
     bDeactivateOutOfSight=True
     bAutomatic=True
     MaxAutoTargets=-1
     bActivateIfDamaged=True
     TargetType=TT_Pawn
     DamagedByTargetType=TT_Any
     ActivateMessage="Cannon activated !"
     DeActivateMessage="Cannon deactivated !"
     AutoActivateMessage="Automatic cannon activated !"
     ActivateIfDamagedMessage="Cannon targets threat !"
     FireRate=0.500000
     bDontPlayActivateAnim=True
     InstantHitDamage=8.000000
     FireEffect=Class'UnrealShare.BlackSmoke'
     WallHitEffect=Class'UnrealShare.LightWallHitEffect'
     OtherHitEffect=Class'UnrealShare.SpriteSmokePuff'
     InstantHitAccuracy=0.400000
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.CannonM'
     CollisionRadius=44.000000
     CollisionHeight=44.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     RotationRate=(Yaw=50000)
}
