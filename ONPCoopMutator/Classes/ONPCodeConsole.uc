class ONPCodeConsole expands CodeConsole;

function PostBeginPlay() {}

function Initialize()
{
	//generate random number here.
	local codeconsole cc;
	if (mycode==-1)
	{
		Mycode = rand(1 + MaxNumber - MinNumber) + MinNumber; //generate code
		if (LinkedTag!='')
		foreach AllActors(class'codeconsole',CC,linkedTag)
			CC.MyCode = Mycode; //1 will be me, but no big deal.
	}
	SetupTrans();
}

function SetupTrans()
{
	local TranslatorEvent trans;
	local Tvtranslatorevent tvtrans;
	//message manipulation:
	local int pos;
	local string outstr, ins, code;

	Texture = none;
	digits = len(string(MaxNumber)); //count digits to test input.
	code = string(mycode);
	for (pos = len(code); pos < digits; pos++) //inserts in 0's
		code = "0" $ code;
	digits = len(code);
	if (Role < Role_Authority)
		return;
	if (translatortag != '')
	{
		foreach allactors(class'TranslatorEvent', trans, Translatortag)
		{ //insert in code in transevents.
			ins = AdjustTranslatorMessage(trans.Message); //normal message
			pos = instr(ins, "%c");
			while (pos != -1)
			{
				outstr = outstr $ left(ins, pos) $ Code;
				ins = mid(ins, pos + 2);
				pos = instr(ins, "%c");
			}
			trans.Message = outstr $ ins;
			outstr = "";
			ins = trans.AltMessage; //Alt message
			pos = instr(ins, "%c");
			while (pos != -1)
			{
				outstr = outstr $ left(ins, pos) $ Code;
				ins = mid(ins, pos + 2);
				pos = instr(ins, "%c");
			}
			trans.AltMessage = outstr $ ins;
		}

		foreach allactors(class'Tvtranslatorevent', tvtrans, Translatortag)
		{ //insert in code in transevents.
			ins = AdjustTranslatorMessage(tvtrans.Message); //normal message
			pos = instr(ins, "%c");
			while (pos != -1)
			{
				outstr = outstr $ left(ins, pos) $ Code;
				ins = mid(ins, pos + 2);
				pos = instr(ins, "%c");
			}
			tvtrans.Message = outstr $ ins;
			outstr = "";
			ins = tvtrans.AltMessage; //Alt message
			pos = instr(ins, "%c");
			while (pos != -1)
			{
				outstr = outstr $ left(ins, pos) $ Code;
				ins = mid(ins, pos + 2);
				pos = instr(ins, "%c");
			}
			tvtrans.AltMessage = outstr $ ins;
		}
	}
}

event Touch(Actor A)
{
	if (bEnabled && PlayerPawn(A) != none)
		OpenCodeConsole(PlayerPawn(A));
}

event UnTouch(Actor A)
{
	if (PlayerPawn(A) != none)
		CloseCodeConsole(PlayerPawn(A));
}

function OpenCodeConsole(PlayerPawn PP)
{
	local ONPPlayerInteraction PlayerInteraction;

	PlayerInteraction = class'ONPPlayerInteraction'.static.FindFor(PP);
	if (PlayerInteraction != none)
	{
		PlayerInteraction.OpenCodeConsole(SecurityPrompt, digits);
		if (PromptSound != none)
			PlaySound(PromptSound, SLOT_Misc);
		PP.Acceleration = vect(0,0,0);
	}
}

function CloseCodeConsole(PlayerPawn PP)
{
	local ONPPlayerInteraction PlayerInteraction;

	PlayerInteraction = class'ONPPlayerInteraction'.static.FindFor(PP);
	if (PlayerInteraction != none)
		PlayerInteraction.CloseCodeConsole();
}

function TestCodeConsoleInput(int Code, PlayerPawn EventInstigator)
{
	local name searchtag;
	local actor a;

	if (!benabled) //h4x0r
		return;
	if (Code == MyCode) // the entered code is correct
	{
		searchtag = event;

		if (EventInstigator != none)
			EventInstigator.ClientMessage(ClearenceMessage, MessageType, true);
		if (ClearenceSound != none)
			PlaySound(ClearenceSound, SLOT_Misc);
		if (DisableOnCorrect)
			benabled = false;
	}
	else
	{
		searchTag = FailureEvent;

		if (EventInstigator != none)
			EventInstigator.ClientMessage(FailureMessage, MessageType, true);
		if (FailureSound != none)
			PlaySound(FailureSound, SLOT_Misc);
	}
	if (searchtag != '')
		foreach AllActors (class'actor', a, SearchTag)
		{
			if (A != self)
				A.Trigger(Self, EventInstigator);
		}
}

function PlayCodeConsoleTypingSound()
{
	PlaySound(KeyEnterSound, SLOT_Misc);
}

function string AdjustTranslatorMessage(string Message)
{
	local int i, c;
	local string Result;

	if (Len(Message) == 0 || Asc(Message) < 65536)
		return Message;

	// fixing weird byte order on Linux version
	for (i = 0; i < Len(Message); ++i)
	{
		c = Asc(Mid(Message, i, 1)) >> 16;
		if (c < 256)
			Result $= Chr(c);
	}
	return Result;
}

defaultproperties
{
	RemoteRole=ROLE_None
}
