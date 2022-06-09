//=============================================================================
// AlarmSpot.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class AlarmSpot expands Info;

var() localized string AlarmMessage;
var() enum EAlarmingActors
{
	AA_PlayerProximity,
	AA_PawnProximity,
	AA_ClassProximity,
	AA_AnyProximity,
} AlarmingActors;
var() class<actor> AlarmingClass;
var() sound AlarmSound;

var playerpawn oInst;
var bool bActive;

function bool IsRelevant( actor Other )
{
	if (PlayerPawn(Other) == oInst)
		return false;

	switch( AlarmingActors )
	{
		case AA_PlayerProximity:
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
		case AA_PawnProximity:
			return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None );
		case AA_ClassProximity:
			return ClassIsChildOf(Other.Class, AlarmingClass);
		case AA_AnyProximity:
			return true;
	}
}

auto state AlarmSpot
{

function Touch( actor Other )
{
	if (IsRelevant(Other))
	{
		oInst.Instigator.ClientMessage( AlarmMessage );
		if (AlarmSound != None)
		{
			if (oInst.ViewTarget == None)
				oInst.PlaySound(AlarmSound,Slot_None);
			else
				oInst.ViewTarget.PlaySound(AlarmSound,Slot_None);
		}
	}
}

function Trigger( Actor other, Pawn EventInstigator )
{
	if (!bActive && Other.IsA('PlayerPawn'))
	{
		oInst = PlayerPawn(other);
		if ( oInst != None )
		{
			Enable('Touch');
			bActive = True;
		}
	}
}

function UnTrigger( Actor other, Pawn EventInstigator )
{
	if (bActive && oInst == Other)
	{
		Disable('Touch');
		oInst = None;
		bActive = False;
	}
}

Begin:
	Disable('Touch');
	oInst = None;
	bActive = False;
}

defaultproperties
{
     AlarmMessage="Enemy in vicinity !!!"
     AlarmingActors=AA_PawnProximity
     AlarmSound=Sound'UnrealShare.Pickups.TransA3'
     Texture=Texture'Engine.S_Corpse'
     CollisionRadius=64.000000
     bCollideActors=True
}
