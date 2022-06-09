//=============================================================================
// TriggerTeleporter.
//
// script by N.Bogenrieder (Beppo)
//
// This Teleporter can only be triggerd.
// After triggering it imediatly 'turns off'.
// To reuse you have to trigger it again!
//
//=============================================================================
class TriggerTeleporter expands Teleporter;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bEnabled = False;
}

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;

	bEnabled = True;
	if ( bEnabled ) //teleport any pawns already in my radius
	{
		for (i=0;i<4;i++)
			if ( Touching[i] != None )
				Touch(Touching[i]);
	}
	bEnabled = False;
}

defaultproperties
{
}
