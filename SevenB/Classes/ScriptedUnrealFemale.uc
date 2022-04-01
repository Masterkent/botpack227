// ===============================================================
// SevenB.ScriptedUnrealFemale: for unreal I female models
// ===============================================================

class ScriptedUnrealFemale extends ScriptedUnrealHuman;

function PostBeginPlay(){
  if (multiskins[0]==none)
    class'oldskool.femaleonebot'.static.SetMultiSkin(self,"","",rand(4));
  Super.PostBeginPlay();
}

defaultproperties
{
     Voice=Class'Botpack.VoiceFemaleTwo'
     drown=Sound'UnrealShare.Female.mdrown2fem'
     HitSound3=Sound'UnrealShare.Female.linjur3fem'
     HitSound4=Sound'UnrealShare.Female.hinjur4fem'
     Deaths(2)=Sound'UnrealShare.Female.death3cfem'
     Deaths(3)=Sound'UnrealShare.Female.death2afem'
     Deaths(4)=Sound'UnrealShare.Female.death4cfem'
     UWHit1=Sound'UnrealShare.Female.FUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealShare.Female.lland1fem'
     JumpSound=Sound'UnrealShare.Female.jump1fem'
     CarcassType=Class'UnrealShare.FemaleBody'
     bIsFemale=True
     HitSound1=Sound'UnrealShare.Female.linjur1fem'
     HitSound2=Sound'UnrealShare.Female.linjur2fem'
     Die=Sound'UnrealShare.Female.death1dfem'
     MenuName="Drace"
     Mesh=LodMesh'UnrealShare.Female1'
}
