class NCGameOptionsScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'NCGameOptionsClientWindow';
	FixedAreaClass = None;//class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
