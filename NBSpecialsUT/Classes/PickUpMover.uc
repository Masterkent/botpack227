//=============================================================================
// PickUpMover.
//
// script by N.Bogenrieder (Beppo)
//
// If you don't have a mesh for your Inventory class,
// or if you just want to 'build' one for it inside UnrealEd...
// use this class...
// In addition:
// up to TEN (10) Inventory objects with only one touch possible!
//
// Set Keyframe 0 (base) to its normal/visible location
// set Keyframe 1 to its invisible location to hide it after
// 'picking it up'...
//
// The BumpType is used for determine if a 'toucher' is valid!
//
// If no RespawnTime is set up it uses the default.RespawnTime
// of the first Inventory object [0] in the list.
//=============================================================================
class PickUpMover expands Mover;

var() class<Inventory> UseInventory[10];
var() float RespawnTime;
var() float zAxisCorForBotInvSpot;
var() float BotDesireability;

var float TimePassed, TimeToCheck;
var bool bActive;
var vector oLoc;
var BotInventorySpot BIS;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	oLoc = Location;
	bActive = True;
	MoveTime = 0;
	TimeToCheck = RespawnTime;
	if(RespawnTime == 0)
		TimeToCheck = UseInventory[0].default.RespawnTime;

	if(BotDesireability == 0)
		BotDesireability = UseInventory[0].default.MaxDesireability;
		
	BIS = spawn(class'BotInventorySpot',,,oLoc+vect(0,0,1)*zAxisCorForBotInvSpot,Rotation);
	BIS.oMaxDesireability = BotDesireability;
}

function GetInv()
{	
local inventory inv;
local int i;

	for (i=0; i<10; i++)
		if(Useinventory[i] != None)
		{
			inv = spawn(UseInventory[i],,,oLoc,Rotation);
			inv.RespawnTime = 0;
		}
}

final function bool IsValid( actor TT )
{
	switch( BumpType )
	{
		case BT_PlayerBump:
			return TT.bIsPawn && Pawn(TT)!=None && Pawn(TT).bIsPlayer;
		case BT_PawnBump:
			return TT.bIsPawn && Pawn(TT)!=None && ( Pawn(TT).Intelligence > BRAINS_None );
		case BT_AnyBump:
			return true;
	}
}

state() PickUp
{
ignores Trigger, UnTrigger;

	function Touch (actor Other)
	{
		if (bActive)
		{
			if (IsValid(Other))
			{
				bActive = False;
				TimePassed = 0;
				Enable( 'Tick' );
				DoOpen();
				GetInv();
				BIS.TurnOFF();
			}
		}
	}

	function Tick( float DeltaTime )
	{
		if(!bActive)
		{
			TimePassed += DeltaTime;
			if (TimePassed > TimeToCheck)
			{
				Disable('Tick');
				bActive = True;
				spawn(class'Respawn',,,oLoc + vect(0,0,1)*8);
				DoClose();
				BIS.TurnON();
			}
		}
	}

Begin:
	bActive = True;
	Disable( 'Tick' );
	BIS.TurnON();
}

defaultproperties
{
     MoverEncroachType=ME_IgnoreWhenEncroach
     MoverGlideType=MV_MoveByTime
     BumpType=BT_PawnBump
     MoveTime=0.000000
     InitialState=Pickup
     bBlockActors=False
     bBlockPlayers=False
}
