//=============================================================================
// TFemale2.
//=============================================================================
class TFemale2 extends TournamentFemale;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	FaceSkin=3
	FixedSkin=2
	TeamSkin2=1
	DefaultSkinName="SGirlSkins.army"
	DefaultPackage="SGirlSkins."
	CarcassType=Class'Botpack.TFemale2Carcass'
	SelectionMesh="Botpack.SelectionFemale2"
	SpecialMesh="Botpack.TrophyFemale2"
	MenuName="Female Soldier"
	VoiceType="BotPack.VoiceFemaleTwo"
	Mesh=LodMesh'Botpack.SGirl'
}
