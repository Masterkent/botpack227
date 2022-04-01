//=============================================================================
// UnrealMaleTwoBot.
//=============================================================================
class UnrealMaleTwoBot extends UnrealTournamentMaleBot;

function ForceMeshToExist()
{
	Spawn(class'UnrealMaleTwo');
}

defaultproperties
{
     CarcassType=Class'UnrealI.MaleTwoCarcass'
     LandGrunt=Sound'UnrealI.Male.MLand2'
     JumpSound=Sound'UnrealI.Male.MJump2'
     SelectionMesh="UnrealI.Male2"
     SpecialMesh="UnrealI.Male2"
     MenuName="Male 2"
     Skin=Texture'UnrealShare.Skins.Ash'
     Mesh=LodMesh'UnrealI.Male2'
}
