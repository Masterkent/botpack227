//=============================================================================
// INFUT_ADD_TurretWeapon.
//
// script by N.Bogenrieder (Beppo)
//=============================================================================
class INFUT_ADD_TurretWeapon expands TournamentWeapon
	abstract;

var	float	stdFOV;				// standard FOV for Infiltration
var bool	bKick;				// does the weapon kick in the moment?
var	float 	KickYaw, KickPitch;	// vars for kick-back
var INFUT_ADD_Turret B227_Turret; // the controlled turret

// disable these functions
simulated function AnimEnd() {}
simulated function bool ClientFire( float Value );
simulated function bool ClientAltFire( float Value );

function Fire(float F){}
function AltFire(float F){}

replication // for stuff that gets drawn onto client huds
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner )
		stdFOV, KickPitch, KickYaw, bKick;
}

simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_Authority)
	{
		if (B227_Turret == none ||
			B227_Turret.bDeleteMe ||
			B227_Turret.cControler == none ||
			B227_Turret.cControler.bDeleteMe ||
			B227_Turret.cControler.Health <= 0)
		{
			if (B227_Turret != none && !B227_Turret.bDeleteMe && B227_Turret.cControler == Owner)
				B227_Turret.ResetVarsAndEnd();
			if (!bDeleteMe)
				Destroy();
			return;
		}
	}
	if (Pawn(Owner) != None && Pawn(Owner).Weapon == self)
	{
		//-if (PlayerPawn(Owner) != None && PlayerPawn(Owner).DefaultFOV != stdFOV)
		//-{
		//-	PlayerPawn(Owner).SetDesiredFOV(stdFOV);
		//-	PlayerPawn(Owner).DesiredFOV = stdFOV;
		//-	PlayerPawn(Owner).DefaultFOV = stdFOV;
		//-}
		if (bKick)
		{
			if (!(Pawn(Owner).ViewRotation.Pitch > 17000 && Pawn(Owner).ViewRotation.Pitch < 48000))
				Pawn(Owner).ViewRotation.Pitch += KickPitch;
			Pawn(Owner).ViewRotation.Yaw += KickYaw;
			bKick = False;
		}
	}
}

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
}

state Active
{
	ignores animend;

	function Fire(float F){}
	function AltFire(float F){}

	function ForceFire(){}
	function ForceAltFire(){}

	function EndState()
	{
		Super.EndState();
		bForceFire = false;
		bForceAltFire = false;
	}

Begin:
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	bCanClientFire = False;
}

state Idle
{
	function AnimEnd()
	{
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);
	Disable('AnimEnd');
}

// if spawned (by CRM or else) DON'T let it be picked up !!
auto state Pickup
{
	function Touch( actor Other ) {}
}

function BringUp()
{
	if ( Owner != None && Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).EndZoom();
	bWeaponUp = false;
	GotoState('Active');
}

function TweenDown() {}
function PlaySelect() {}
function TweenToStill() {}

defaultproperties
{
     stdFOV=90.000000
     bWarnTarget=True
     bCanThrow=False
     bOwnsCrosshair=True
     bSpecialIcon=True
     AIRating=1.000000
     RefireRate=0.250000
     AltRefireRate=0.250000
     DeathMessage="%o was gunned down by %k's %w."
     AutoSwitchPriority=9
     InventoryGroup=10
     bAmbientGlow=False
     PickupMessage=""
     ItemName=""
     RespawnTime=0.000000
     bHidden=True
     bOwnerNoSee=True
     DrawType=DT_None
     AmbientGlow=0
     bIsItemGoal=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     Mass=10.000000
}
