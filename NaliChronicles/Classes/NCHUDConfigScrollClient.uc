// Mostly ripped from UT
// Sergey 'Eater' Levin

class NCHUDConfigScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'NCHUDConfigCW';
	//FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
