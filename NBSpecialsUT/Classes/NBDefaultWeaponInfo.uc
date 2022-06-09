//=============================================================================
// NBDefaultWeaponInfo.
//
// script by N.Bogenrieder (Beppo)
//
// YOU CAN USE THIS CLASS TO SPECIFY A DEFAULT WEAPON
// FOR YOUR MAP !!!
//
// IF YOU WANT NO WEAPON AT ALL JUST LEAVE USE
// THE NoWeaponAtAll CLASS !!
//
// IT USES THE AutoMag CLASS BY DEFAULT
//
//=============================================================================
class NBDefaultWeaponInfo expands Info;

var() class<weapon> DefaultWeapon;

replication
{
	reliable if ( Role == ROLE_Authority )
		DefaultWeapon;
	
}
function PreBeginPlay()
{
	Level.Game.DefaultWeapon = DefaultWeapon;
	Destroy();
}

defaultproperties
{
     DefaultWeapon=Class'UnrealShare.AutoMag'
     Texture=Texture'Engine.S_Weapon'
}
