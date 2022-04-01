//=============================================================================
// TFemale1Bot.
//=============================================================================
class ADTFemale1Bot extends CombatFemaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'TFemale1');
}

defaultproperties
{
     FaceSkin=3
     TeamSkin2=1
     DefaultSkinName="FCommandoSkins.cmdo"
     DefaultPackage="FCommandoSkins."
     GroundSpeed=430.000000
     JumpZ=400.000000
     Health=80
     SelectionMesh="Botpack.SelectionFemale1"
     MenuName="Female Commando"
     VoiceType="BotPack.VoiceFemaleOne"
     Mesh=LodMesh'Botpack.FCommando'
}
