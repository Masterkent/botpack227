class B227_UDamageEffect expands Effects;

function Activate()
{
	bHidden = false; // enable replication across network
	LightType = LT_Steady;
}

function Deactivate()
{
	bHidden = true;
	LightType = LT_None;
}


defaultproperties
{
	bNetTemporary=False
	bHidden=True
	bCarriedItem=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_None
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=210
	LightRadius=10
	LightSaturation=0
	LightType=LT_None
}
