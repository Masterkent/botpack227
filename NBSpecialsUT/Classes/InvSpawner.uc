//=============================================================================
// InvSpawner.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class InvSpawner expands Effects;

var() class <inventory> InventoryItem;
var() float ReactivateTime;
var() localized string ReactivateMessage;
var() name TurnOnOffEvent;
var() byte	InvAmbientGlow;
var() bool	InvbAmbientGlow;
var() bool	InvbFixedRotationDir;
var() rotator InvRotation;
var() float zAxisCorrection;
var() ePhysics InvPhysics;
var() bool bUseSpawnEffect;

var bool bUseit;
var localized string ReMessage;
var int TimeLeft;
var float TimePassed, TimeToCheck;
var inventory inv;
var pawn oInst;
var actor tAct;
var BotInventorySpot BSpot;

function PostBeginPlay()
{
	if (zAxisCorrection == 0)
	{
// just get a z_axis_correction for the spawning position
		inv = Spawn(InventoryItem,,,Location);
		zAxisCorrection = inv.default.CollisionHeight / 2;
		inv.RespawnTime = 0.0; //don't respawn
		inv.Destroy();
	}
	inv = None;
}

// Spawn a BotInventorySpot to get Bots to move here !
function CallBots()
{
	BSpot = Spawn(class'BotInventorySpot',,,Location + vect(0,0,1)*zAxisCorrection);
}

// If a bot is already touching the activating trigger(s)
// give this trigger a TOUCH...
function CheckTriggers()
{
local trigger T;
	foreach allactors(class 'Trigger', T)
		if ( T.Event == Tag)
			T.CheckTouchList();
}

auto state Waiting
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (bUseIt)
		{
			BSpot.Destroy();

			oInst = EventInstigator;
			if (TurnOnOffEvent != '')
				foreach allactors(class'Actor', tAct, TurnOnOffEvent)
					tAct.Trigger(self, EventInstigator);
			GotoState('Reactivate');
		}
	}
Begin:
	bUseIt = True;
	CallBots();
	CheckTriggers();
}

state Reactivate
{
	function Trigger ( actor Other, pawn EventInstigator )
	{
		if ( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
			Other.Instigator.ClientMessage( ReMessage );
	}

	function Timer()
	{
		if (bUseIt)
		{
			if (TurnOnOffEvent != '')
				foreach allactors(class'Actor', tAct, TurnOnOffEvent)
					tAct.Trigger(self, oInst);
			GotoState('Waiting');
		}
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		TimeLeft = TimeToCheck - TimePassed;
		if (ReactivateMessage != "")
			ReMessage = ReactivateMessage $ " " $ string(TimeLeft) $ " seconds!";
		if (TimePassed > TimeToCheck) {
			bUseIt = True;
			Disable('Tick');
		}
	}

Begin:
	bUseIt = False;
	inv = Spawn(InventoryItem,,,Location + vect(0,0,1)*zAxisCorrection);
	inv.bHidden = True;
	inv.RespawnTime = 0.0; //don't respawn
	inv.SetPhysics(InvPhysics);
	inv.AmbientGlow = InvAmbientGlow;
	inv.bAmbientGlow = InvbAmbientGlow;
	inv.bFixedRotationDir = InvbFixedRotationDir;
	inv.SetRotation(InvRotation);
	if (bUseSpawnEffect)
		Spawn(class'Respawn',,,Location + vect(0,0,1)*zAxisCorrection);
	inv.bHidden = False;

	TimePassed = 0.0;
	TimeToCheck = ReactivateTime;
	TimeLeft = ReactivateTime;
	Enable('Tick');
	SetTimer(0.03,True);
}

defaultproperties
{
     InventoryItem=Class'UnrealShare.Health'
     ReactivateTime=20.000000
     ReActivateMessage="Item available in"
     bUseSpawnEffect=True
     bHidden=True
     DrawType=DT_Sprite
     Texture=Texture'Engine.S_Inventory'
}
