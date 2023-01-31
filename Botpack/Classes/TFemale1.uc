//=============================================================================
// TFemale1.
//=============================================================================
class TFemale1 extends TournamentFemale;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	FaceSkin=3
	TeamSkin2=1
	DefaultSkinName="FCommandoSkins.cmdo"
	DefaultPackage="FCommandoSkins."
	SelectionMesh="Botpack.SelectionFemale1"
	SpecialMesh="Botpack.TrophyFemale1"
	MenuName="Female Commando"
	VoiceType="BotPack.VoiceFemaleOne"
	Mesh=LodMesh'Botpack.FCommando'
}
