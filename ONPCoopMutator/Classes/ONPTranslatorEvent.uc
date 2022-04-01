class ONPTranslatorEvent expands TranslatorEvent;

function Trigger(Actor A, Pawn EventInstigator)
{
	local PlayerPawn PP;
	local Actor Targets;
	local string Temp;

	if (bTriggerAltMessage)
	{
		Temp = Message;
		Message = AltMessage;
		AltMessage = Temp;
		bHitOnce = False;
		if (A != none && !A.bDeleteMe && PlayerPawn(A) == none)
		{
			foreach AllActors(class'PlayerPawn', PP)
				Touch(PP);
		}
		else
		{
			foreach TouchingActors(class'Actor', Targets)
				if (Targets == A)
					Touch(A);
		}
	}
	else if (A != none && !A.bDeleteMe && PlayerPawn(A) == none)
	{
		foreach AllActors(class'PlayerPawn', PP)
			Touch(PP);
	}
	else
		Touch(A);
}

event Touch(Actor Other)
{
	local inventory Inv;
	local ONPPlayerInteraction PlayerInteraction;

	if (PlayerPawn(Other) == none || bHitDelay)
		return;

	if (Message=="")
		return;

	if ( ReTriggerDelay > 0 )
	{
		if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
			return;
		TriggerTime = Level.TimeSeconds;
	}

	for (Inv = Other.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Translator(Inv) != none)
		{
			PlaySound(NewMessageSound, SLOT_Misc);
			Trans = Translator(Inv);
			Trans.Hint = Hint;
			Trans.bShowHint = False;
			if (!bHitOnce)
				Trans.bNewMessage = true;
			else
				Trans.bNotNewMessage = true;

			PlayerInteraction = class'ONPPlayerInteraction'.static.FindFor(PlayerPawn(Other));
			if (PlayerInteraction == none)
				Trans.NewMessage = Message;
			else
				PlayerInteraction.SetTranslatorMessage(Trans, Message); // sends potentially long messages that cannot be replicated in usual way

			if (!bHitOnce)
				Pawn(Other).ClientMessage(M_NewMessage);
			else
				Pawn(Other).ClientMessage(M_TransMessage);
			bHitOnce = true;
			SetTimer(0.3, false);
			bHitDelay = true;
			break;
		}
}
