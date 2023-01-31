//=============================================================================
// TMale1.
//=============================================================================
class TMale1 extends TournamentMale;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	FaceSkin=1
	TeamSkin1=2
	TeamSkin2=3
	DefaultSkinName="CommandoSkins.cmdo"
	DefaultPackage="CommandoSkins."
	LandGrunt=Sound'UnrealShare.Male.MLand3'
	JumpSound=Sound'Botpack.Male.TMJump3'
	SelectionMesh="Botpack.SelectionMale1"
	SpecialMesh="Botpack.TrophyMale1"
	MenuName="Male Commando"
	Mesh=LodMesh'Botpack.Commando'
}
