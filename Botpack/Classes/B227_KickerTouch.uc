// 227i version: aux class that implements Kicker.PostTouch
class B227_KickerTouch expands Info;

var Kicker Kicker;
var Actor Other;

static function MakeInstance(Kicker Kicker, Actor Other)
{
	local B227_KickerTouch KickerTouch;

	KickerTouch = Kicker.Spawn(class'B227_KickerTouch');
	if (KickerTouch == none)
		return;
	KickerTouch.Kicker = Kicker;
	KickerTouch.Other = Other;
}

auto state KickerState
{
Begin:
	if (Kicker != none && !Kicker.bDeleteMe && Other != none && !Other.bDeleteMe)
		Kicker.B227_PostTouch(Other);
	Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_None
}
