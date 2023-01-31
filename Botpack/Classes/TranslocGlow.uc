//=============================================================================
// TranslocGlow.
//=============================================================================
class TranslocGlow extends Effects;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

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
