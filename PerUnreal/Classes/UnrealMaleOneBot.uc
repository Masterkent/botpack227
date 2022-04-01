//=============================================================================
// UnrealMaleOneBot.
//=============================================================================
class UnrealMaleOneBot extends UnrealTournamentMaleBot;

function ForceMeshToExist()
{
	Spawn(class'UnrealMaleOne');
}

defaultproperties
{
     CarcassType=Class'UnrealI.MaleOneCarcass'
     SelectionMesh="UnrealI.Male1"
     SpecialMesh="UnrealI.Male1"
     MenuName="Male 1"
     Skin=Texture'UnrealShare.Skins.Kurgan'
     Mesh=LodMesh'UnrealI.Male1'
}
