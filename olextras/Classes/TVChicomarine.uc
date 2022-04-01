//===============================================================================
//  [chicomarine] By Chicoverde.
// Used as a reward (difficulty 1) I (UsAaR33) would rather have hidden it from the model list, but not possible :/
//===============================================================================

class tvchicomarine extends TournamentMale;  //more or less right.. except head detach?

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

// Animation sequences. These can replace or override the implicit (exporter-defined) sequences.

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log

/*
#EXEC TEXTURE IMPORT NAME=chicomarineTex0  FILE=TEXTURES\skin0.pcx  GROUP=Skins
#EXEC TEXTURE IMPORT NAME=chicomarineTex1  FILE=TEXTURES\skin1.pcx  GROUP=Skins


#EXEC MESHMAP SETTEXTURE MESHMAP=chicomarine NUM=0 TEXTURE=chicomarineTex0
#EXEC MESHMAP SETTEXTURE MESHMAP=chicomarine NUM=1 TEXTURE=chicomarineTex1
*/
// Original material [0] is [SKIN00] SkinIndex: 0 Bitmap: skin0.jpg  Path: D:\ToolZ\3dsMax42\Scenes\STroopers\Starshipsoldier\Chicosoldier
// Original material [1] is [SKIN01] SkinIndex: 1 Bitmap: skin1.jpg  Path: D:\ToolZ\3dsMax42\Scenes\STroopers\Starshipsoldier\Chicosoldier
//notifies:

//not available stuff:

//control skin stuff here...... (prevent model use if
static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
  local string SkinItem, SkinPackage;

  if (SkinActor.Level.NetMode == NM_StandAlone && class'TVHSClient'.default.maxdif<2) //not beaten medium yet...
  {
    if (SkinActor.IsA('MeshActor'))   //not available yet :p
      SkinActor.Mesh=LodMesh'notavpanel1';
    else{
      SkinActor.Mesh=LodMesh'Soldier';
      class'tvplayer'.static.SetMultiSkin(SkinActor, "CommandoSkins.cmdo", "Blake", TeamNum);
    }
    return;
  }

  // two skins

  if ( SkinName == "" )
    SkinName = default.DefaultSkinName;
  else
  {
    SkinItem = SkinActor.GetItemName(SkinName);
    SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));

    if( SkinPackage == "" )
    {
      SkinPackage=default.DefaultPackage;
      SkinName=SkinPackage$SkinName;
    }
  }
  // Set the team elements
  if( TeamNum < 4 ){
    SetSkinElement(SkinActor, 0,SkinPackage$"T_Skin0_"$String(TeamNum), default.DefaultPackage$"T_Skin0_"$String(TeamNum));
    SetSkinElement(SkinActor, 1, SkinPackage$"T_Skin1_"$String(TeamNum), default.DefaultPackage$"T_Skin1_"$String(TeamNum));
  }
  else{
    SetSkinElement(SkinActor, 0, SkinName$"0", default.DefaultSkinName$"0");
    SetSkinElement(SkinActor, 1, SkinName$"1", default.DefaultSkinName$"1");
  }
  // Set the talktexture (if chico makes it...)  CliffyB for now.......
  if( Pawn(SkinActor) != None )
  {
/*      Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(SkinName$"Face", class'Texture'));
      if ( Pawn(SkinActor).PlayerReplicationInfo.TalkTexture == None )
        Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(default.DefaultFace, class'Texture'));
  */
    Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("UTtech2.Deco.xmetex2x1", class'Texture'));
  }
}

simulated function PlayLoudStep()
{
// 1.3 ADDED: for Challenge taunt

  if ( FootRegion.Zone.bWaterZone )
  {
    PlaySound(WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  PlaySound(LandGrunt, SLOT_Interact, 1.0, false, 1000.0, 1.0);
}

defaultproperties
{
     DefaultSkinName="chicomarineSkins.dood"
     DefaultPackage="chicomarineSkins."
     SelectionMesh="olextras.chicomarine"
     SpecialMesh="olextras.chicomarine"
     MenuName="Heavy Trooper"
     VoiceType="BotPack.VoiceMaleTwo"
     Mesh=SkeletalMesh'olextras.chicomarine'
}
