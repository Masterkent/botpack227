//=============================================================================
// BotInventorySpot.
//
// script by N.Bogenrieder (Beppo)
//
// This item is used by:
// the inventory spawner (Effects.InvSpawner)
// ...
// to get Bots using it !!
// DON'T place this Inventory inside your levels!!
//=============================================================================
class BotInventorySpot expands Inventory;

var float oMaxDesireability;

function PostBeginPlay()
{
	oMaxDesireability = MaxDesireability;
}

event float BotDesireability( pawn Bot )
{
	return MaxDesireability;
}

function TurnOFF()
{
	MaxDesireability = -1.0;
// used for debugging
	texture = Texture'Engine.S_Corpse';
	GotoState( 'Pickup' );
}
function TurnON()
{
	MaxDesireability = oMaxDesireability;
// used for debugging
	texture = Texture'Engine.S_Inventory';
	GotoState( 'Pickup' );
}

auto state Pickup
{
	function Touch( actor Other ){ }
Begin:
}

defaultproperties
{
     bRotatingPickup=False
     MaxDesireability=1.000000
     bAlwaysRelevant=True
     DrawType=DT_None
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bCollideActors=False
}
