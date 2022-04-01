//=============================================================================
// TMale2Bot.
//=============================================================================
class ADTMale2Bot extends CombatMaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'ADTMale2');
}

defaultproperties
{
     CarcassType=Class'Botpack.TMale2Carcass'
     FaceSkin=3
     FixedSkin=2
     TeamSkin2=1
     DefaultSkinName="SoldierSkins.blkt"
     DefaultPackage="SoldierSkins."
     GroundSpeed=360.000000
     Health=150
     SelectionMesh="Botpack.SelectionMale2"
     MenuName="Male Soldier"
     Mesh=LodMesh'Botpack.Soldier'
}
