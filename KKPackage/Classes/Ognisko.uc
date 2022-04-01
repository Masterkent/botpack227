class Ognisko extends Decoration;

#exec OBJ LOAD FILE="..\Textures\KKSkins.utx"

#exec OBJ LOAD FILE="KKPackageResources.u" PACKAGE=KKPackage

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=Mesh'KKPackage.Ognisko'
}
