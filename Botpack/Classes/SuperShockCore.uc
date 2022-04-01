class SuperShockCore expands ShockCore;

#exec TEXTURE IMPORT NAME=B227_SuperShockCore FILE=Textures\B227_SuperShockCore.bmp GROUP="Skins"
#exec TEXTURE IMPORT NAME=B227_I_SuperShockCore FILE=Textures\Hud\B227_i_SuperShockCore.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
	MaxAmmo=100
	PickupMessage="You picked up an enhanced Shock Core."
	ItemName="Enhanced Shock Core"
	MultiSkins(1)=Texture'Botpack.B227_SuperShockCore'
	Icon=Texture'Botpack.Icons.B227_I_SuperShockCore'
}
