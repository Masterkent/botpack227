class ONPTranslatorEvent expands TranslatorEvent;

var bool bHadBroadcast;

function Trigger(Actor A, Pawn EventInstigator)
{
	local PlayerPawn PP;
	local string Temp;

	if (bHitDelay || ReTriggerDelay > 0 && Level.TimeSeconds - TriggerTime < ReTriggerDelay)
		return;

	if (bTriggerAltMessage)
	{
		Temp = Message;
		Message = AltMessage;
		AltMessage = Temp;
		bHitOnce = False;
		foreach TouchingActors(class'PlayerPawn', PP)
		{
			bHitDelay = false;
			TriggerTime = 0;
			Touch(PP);
		}
	}
	else if (!bHadBroadcast && A != none && !A.bDeleteMe && PlayerPawn(A) == none)
	{
		foreach AllActors(class'PlayerPawn', PP)
		{
			bHadBroadcast = true;
			bHitDelay = false;
			TriggerTime = 0;
			Touch(PP);
		}
	}
	else
		Touch(EventInstigator);
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
