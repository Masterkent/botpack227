// A trigger that triggers the big fancy message
// Code by Sergey 'Eater' Levin, 2001

class NCMovieMessage extends Triggers;

var() string MyMessage;
var() float MyTime;

function Trigger( actor Other, pawn EventInstigator )
{
	local NCHUD HUD;

	foreach allactors(Class'NCHUD',HUD) {
		HUD.ShowBigMessage(MyMessage,MyTime);
	}
}

defaultproperties
{
     MyTime=6.500000
     Texture=Texture'Engine.S_SpecialEvent'
}
