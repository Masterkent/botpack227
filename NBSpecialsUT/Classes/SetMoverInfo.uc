//=============================================================================
// SetMoverInfo.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class SetMoverInfo expands Info;

function PostBeginPlay()
{
local mover m;
	Super.PostBeginPlay();
// if KeyNum != 0 the function 'BeginPlay' moves 
// movers to its initial location (KeyNum) but it
// doesn't set up all needed vars correctly...
	foreach AllActors (class'Mover', m)
		if(m.KeyNum != 0)
			m.InterpolateTo(m.KeyNum,0.01);
// this fixes it!
	Destroy();
}

defaultproperties
{
     Texture=Texture'Engine.S_Corpse'
}
