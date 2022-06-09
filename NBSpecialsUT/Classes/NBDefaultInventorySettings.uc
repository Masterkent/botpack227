//=============================================================================
// NBDefaultInventorySettings.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class NBDefaultInventorySettings expands Info;

var() byte	DefAmbientGlow;
var() bool	DefbAmbientGlow;
var() bool	DefbFixedRotationDir;

function PreBeginPlay()
{
local Inventory I;
	foreach AllActors (class'Inventory',I)
	{
		I.AmbientGlow = DefAmbientGlow;
		I.bAmbientGlow = DefbAmbientGlow;
		I.bFixedRotationDir	= DefbFixedRotationDir;
	}
	Destroy();
}

defaultproperties
{
     Texture=Texture'Engine.S_Ammo'
}
