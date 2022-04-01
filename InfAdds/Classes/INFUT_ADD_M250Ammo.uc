//=============================================================================
// INFUT_ADD_M250Ammo.
//=============================================================================
class INFUT_ADD_M250Ammo expands INFUT_ADD_Ammo;

#exec TEXTURE IMPORT NAME=B227_I_M250Ammo FILE=Textures\i_M250Ammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=100
     MaxAmmo=100
     Icon=Texture'InfAdds.Icons.B227_I_M250Ammo'
}
