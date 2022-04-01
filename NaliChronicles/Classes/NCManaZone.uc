// Slowly supplies the player with mana
// Code by Sergey 'Eater' Levin, 2001

class NCManaZone extends Triggers;

var() bool bInitiallyActive;
var NaliMage users[64];
var actor TriggerActor;
var actor TriggerActor2;
var() int book;
var() float mmaxmana; // with highest skill points, a value from 0 to 1 (will be multiplied by max mana)
var() float maxmana; // a value from 0 to 1 (will be multiplied by max mana)
var() float manapersecond; // mana given per second
var() int minskill;

function PostBeginPlay()
{
	if ( !bInitiallyActive )
		FindTriggerActor();
	Super.PostBeginPlay();
	SetTimer(0.2,true);
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( Counter(A) != None )
				return; //FIXME - handle counters
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

function Actor SpecialHandling(Pawn Other)
{
	local int i;

	if ( !Other.bIsPlayer )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None)
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		for (i=0;i<4;i++)
			if (Touching[i] == Other)
				Touch(Other);
		return self;
	}

	return self;
}

// when trigger gets turned on, check its touch list

function CheckTouchList()
{
	local int i;

	for (i=0;i<4;i++)
		if ( Touching[i] != None )
			Touch(Touching[i]);
}

//=============================================================================
// Trigger states.

// Trigger is always active.
state() NormalTrigger
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
		if ( bInitiallyActive )
			CheckTouchList();
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		if ( !bWasActive )
			CheckTouchList();
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
	}
}

//=============================================================================
// Trigger logic.

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant( actor Other )
{
	if( !bInitiallyActive )
		return false;
	return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
}
//
// Called when something touches the trigger.
//
function Touch( actor Other )
{
	local int i;
	local actor A;
	local bool notclear;

	if( (IsRelevant( Other )) && (NaliMage(Other) != none) )
	{
		while (i<64) {
			if (users[i] == NaliMage(other))
				notclear = true;
			i++;
		}
		if (notclear)
			return;
		i = 0;
		while (i<64) {
			if (users[i] == none) {
				users[i] = NaliMage(Other);
				i = 255;
			}
			i++;
		}
		i = 0;
		while (i<10) {
			if (NaliMage(Other).ManaZones[i] == none || NaliMage(Other).ManaZones[i] == self) {
				NaliMage(Other).ManaZones[i] = self;
				i = 255;
			}
			i++;
		}
		//Pawn(Other).ClientMessage("You've entered a mana zone of doom");
	}
}

function Timer()
{
	local int i;

	while (i<64) {
		if (users[i] != none) {
			users[i].GiveMana(manapersecond*0.2,maxmana,mmaxmana,book,minskill);
		}
		i++;
	}
}

//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	local int i;
	local bool pawnfound;

	if( (IsRelevant( Other )) && (NaliMage(Other) != none) )
	{
		while (i<64) {
			if (users[i] == NaliMage(Other)) {
				users[i] = none;
				pawnfound = true;
			}
			i++;
		}
		if (!pawnfound)
			return;
		i = 0;
		while (i<10) {
			if (NaliMage(Other).ManaZones[i] == self)
				NaliMage(Other).ManaZones[i] = none;
			i++;
		}
		//NaliMage(Other).ClientMessage("You are now leaving a mana zone");
	}
}

defaultproperties
{
     bInitiallyActive=True
     mmaxmana=0.650000
     maxmana=0.250000
     manapersecond=5.000000
     InitialState=NormalTrigger
     Texture=Texture'Engine.S_Trigger'
}
