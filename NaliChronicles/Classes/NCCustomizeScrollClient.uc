// Mostly ripped from UT
// Sergey 'Eater' Levin

class NCCustomizeScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'NCCustomizeClientWindow';

	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
