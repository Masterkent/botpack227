//=============================================================================
// TranslocGlow.
//=============================================================================
class TranslocGlow extends Effects;

#exec TEXTURE IMPORT NAME=Tranglow FILE=TEXTURES\Tranglow.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowg FILE=TEXTURES\Tranglowg.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowb FILE=TEXTURES\Tranglowb.PCX GROUP="Translocator"
#exec TEXTURE IMPORT NAME=Tranglowy FILE=TEXTURES\Tranglowy.PCX GROUP="Translocator"

event BeginPlay()
{
	PrePivot = vect(0, 0, 0);
	B227_UpdatePosition();
}

simulated event Tick(float DeltaTime)
{
	B227_UpdatePosition();
}

simulated function B227_UpdatePosition()
{
	if (Owner != none)
		SetLocation(Owner.Location + (default.PrePivot >> Owner.Rotation));
}

defaultproperties
{
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Sprite
	Style=STY_Translucent
	Sprite=Texture'Botpack.Translocator.Tranglow'
	Texture=Texture'Botpack.Translocator.Tranglow'
	Skin=Texture'Botpack.Translocator.Tranglow'
	DrawScale=0.500000
	PrePivot=(Z=20.000000)
}
