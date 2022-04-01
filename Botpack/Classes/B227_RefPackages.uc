class B227_RefPackages expands Info
	abstract;

#exec OBJ LOAD FILE="BossSkins.utx"
#exec OBJ LOAD FILE="CommandoSkins.utx"
#exec OBJ LOAD FILE="FCommandoSkins.utx"
#exec OBJ LOAD FILE="LadderFonts.utx"
#exec OBJ LOAD FILE="SGirlSkins.utx"
#exec OBJ LOAD FILE="SoldierSkins.utx"

event BeginPlay()
{
	local Texture Tex;
	local Font Font;

	Tex = Texture'BossSkins.boss1';
	Tex = Texture'CommandoSkins.cmdo1';
	Tex = Texture'FCommandoSkins.cmdo1';
	Tex = Texture'SGirlSkins.Army1';
	Tex = Texture'SoldierSkins.Blkt1';
	Font = Font'LadderFonts.UTLadder30';
}
