class B227_CTFFlagEffect expands Effects;

function Init(CTFFlag Flag)
{
	LightHue = Flag.LightHue;
	LightSaturation = Flag.LightSaturation;
}

defaultproperties
{
	bNetTemporary=False
	bHidden=False
	bCarriedItem=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_None
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightRadius=6
	LightSaturation=0
	LightType=LT_Steady
}
