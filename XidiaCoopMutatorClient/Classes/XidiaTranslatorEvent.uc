class XidiaTranslatorEvent expands TranslatorEvent;

function Touch(Actor Other)
{
	local inventory Inv;
	local XidiaPlayerInteraction PlayerInteraction;

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
			Trans = Translator(Inv);
			Trans.Hint = Hint;
			Trans.bShowHint = False;
			if (!bHitOnce)
				Trans.bNewMessage = true;
			else
				Trans.bNotNewMessage = true;

			PlayerInteraction = class'XidiaPlayerInteraction'.static.FindFor(PlayerPawn(Other));
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
			PlaySound(NewMessageSound, SLOT_Misc);
			Break;
		}
}
