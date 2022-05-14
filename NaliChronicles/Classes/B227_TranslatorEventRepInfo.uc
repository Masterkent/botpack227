class B227_TranslatorEventRepInfo expands Info;

replication
{
	reliable if (Role == ROLE_Authority)
		SendTranslatorMessagePart;
}

static function SendTranslatorMessageTo(Translator Translator, string Message)
{
	local B227_TranslatorEventRepInfo TransRep;

	if (PlayerPawn(Translator.Owner) != none && Len(Message) > 0)
		TransRep = Translator.Owner.Spawn(class'B227_TranslatorEventRepInfo', Translator.Owner);
	if (TransRep != none)
		TransRep.SendTranslatorMessage(Translator, Message);
}

function SendTranslatorMessage(Translator Translator, string Message)
{
	const MaxPartLen = 128;
	local bool bAppend;

	while (Len(Message) > MaxPartLen)
	{
		SendTranslatorMessagePart(Translator, Left(Message, MaxPartLen), bAppend);
		Message = Mid(Message, MaxPartLen);
		bAppend = true;
	}
	SendTranslatorMessagePart(Translator, Message, bAppend);
}

simulated function SendTranslatorMessagePart(Translator Translator, string Message, bool bAppend)
{
	if (Translator == none || Len(Message) == 0)
		return;

	if (bAppend)
		Translator.NewMessage $= Message;
	else
		Translator.NewMessage = Message;

	if (Translator.TranslatorScale < 3)
		Translator.TranslatorScale = 3;
}

defaultproperties
{
	LifeSpan=2
	RemoteRole=ROLE_SimulatedProxy
}
