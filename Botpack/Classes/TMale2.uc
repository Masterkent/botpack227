//=============================================================================
// TMale2.
//=============================================================================
class TMale2 extends TournamentMale;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	FaceSkin=3
	FixedSkin=2
	TeamSkin2=1
	DefaultSkinName="SoldierSkins.blkt"
	DefaultPackage="SoldierSkins."
	LandGrunt=Sound'Botpack.MaleSounds.land10'
	CarcassType=Class'Botpack.TMale2Carcass'
	SelectionMesh="Botpack.SelectionMale2"
	SpecialMesh="Botpack.TrophyMale2"
	MenuName="Male Soldier"
	VoiceType="BotPack.VoiceMaleTwo"
	Mesh=LodMesh'Botpack.Soldier'
}
