//=============================================================================
// UnrealFemaleOneBot.
//=============================================================================
class UnrealFemaleOneBot extends UnrealTournamentFemaleBot;

function ForceMeshToExist()
{
	Spawn(class'UnrealFemaleOne');
}

defaultproperties
{
     CarcassType=Class'UnrealShare.FemaleOneCarcass'
     SelectionMesh="UnrealShare.Female1"
     SpecialMesh="UnrealShare.Female1"
     MenuName="Female 1"
     Skin=Texture'UnrealShare.Skins.gina'
     Mesh=LodMesh'UnrealShare.Female1'
}
