//=============================================================================
// UnrealMaleThreeBot.
//=============================================================================
class UnrealMaleThreeBot extends UnrealTournamentMaleBot;

function ForceMeshToExist()
{
	Spawn(class'UnrealMaleThreeBot');
}

defaultproperties
{
     CarcassType=Class'UnrealShare.MaleThreeCarcass'
     LandGrunt=Sound'UnrealShare.Male.MLand3'
     JumpSound=Sound'UnrealShare.Male.MJump3'
     SelectionMesh="UnrealShare.Male3"
     SpecialMesh="UnrealShare.Male3"
     MenuName="Male 3"
     Skin=Texture'UnrealShare.Skins.Dante'
     Mesh=LodMesh'UnrealShare.Male3'
}
