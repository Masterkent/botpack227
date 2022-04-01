class ONPTranslatorBook expands TranslatorBook;

var TranslatorEvent TransEvent;

function PostBeginPlay() {} // empty overrider

function Initialize()
{
	TransEvent = Spawn(class'TranslatorEvent',, Tag);
	TransEvent.SetBase(self);
	TransEvent.Message = Message;
	TransEvent.AltMessage = AltMessage;
	TransEvent.NewMessageSound = NewMessageSound;
	TransEvent.btriggerAltMessage = bTriggerAltMessage;
	TransEvent.ReTriggerDelay = RetriggerDelay;
	if (M_NewMessage != default.M_NewMessage)
		TransEvent.M_NewMessage = M_newmessage;
	if (M_Transmessage != default.M_Transmessage)
		TransEvent.M_Transmessage = M_Transmessage;
}

function Destroyed()
{
	TransEvent.Destroy();
	Super(Decoration).Destroyed();
}
