//=============================================================================
// TMale1Bot.
//=============================================================================
class ADTMale1Bot extends CombatMaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'ADTMale1');
}

defaultproperties
{
     LandGrunt=Sound'UnrealShare.Male.MLand3'
     JumpSound=Sound'Botpack.Male.TMJump3'
     FaceSkin=1
     TeamSkin1=2
     TeamSkin2=3
     DefaultSkinName="CommandoSkins.cmdo"
     DefaultPackage="CommandoSkins."
     GroundSpeed=360.000000
     Health=150
     SelectionMesh="Botpack.SelectionMale1"
     MenuName="Male Commando"
     VoiceType="BotPack.VoiceMaleOne"
     Mesh=LodMesh'Botpack.Commando'
}
