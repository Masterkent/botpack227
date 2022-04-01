class UTC_Console expands Console;

function AddString(coerce string Msg)
{
	Message(none, Msg, 'Event');
}

static function UTSF_AddString(Console this, coerce string Msg)
{
	this.Message(none, Msg, 'Event');
}

function ConnectFailure(string FailCode, string URL);
