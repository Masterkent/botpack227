//=============================================================================
// ChicomarineBot.
//=============================================================================
class ChicomarineBot extends MaleBotPlus;

function ForceMeshToExist()
{
  Spawn(class'tvChicomarine');
}
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

defaultproperties
{
     DefaultSkinName="chicomarineSkins.dood"
     DefaultPackage="chicomarineSkins."
     SelectionMesh="olextras.chicomarine"
     SpecialMesh="olextras.chicomarine"
     MenuName="Heavy Trooper"
     Mesh=SkeletalMesh'olextras.chicomarine'
}
