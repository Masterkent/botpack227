//=============================================================================
// UnrealFemaleTwoBot.
//=============================================================================
class UnrealFemaleTwoBot extends UnrealTournamentFemaleBot;

function ForceMeshToExist()
{
	Spawn(class'UnrealFemaleTwo');
}

defaultproperties
{
     CarcassType=Class'UnrealI.FemaleTwoCarcass'
     SelectionMesh="UnrealI.Female2"
     SpecialMesh="UnrealI.Female2"
     MenuName="Female 2"
     Skin=Texture'UnrealShare.Skins.Sonya'
     Mesh=LodMesh'UnrealI.Female2'
}
