class XidiaSkaarjVoice extends VoiceMaleTwo;

function Timer()
{
	local name MessageType;

	if ( bDelayedResponse )
	{
		bDelayedResponse = false;
		if ( Owner.IsA('PlayerPawn') )
		{
			if ( PlayerPawn(Owner).GameReplicationInfo.bTeamGame
				 && (PlayerPawn(Owner).PlayerReplicationInfo.Team == DelayedSender.Team) )
				MessageType = 'TeamSay';
			else
				MessageType = 'Say';
			PlayerPawn(Owner).TeamMessage(DelayedSender, DelayedResponse, MessageType);
		}
	}
	if ( Phrase[PhraseNum] != None )
	{
		if ( Owner.IsA('PlayerPawn') && !PlayerPawn(Owner).bNoVoices
			&& (Level.TimeSeconds - class'UTC_PlayerPawn'.static.B227_LastPlaySound(PlayerPawn(Owner)) > 2)  )
		{
			if ( (PlayerPawn(Owner).ViewTarget != None) && !PlayerPawn(Owner).ViewTarget.IsA('Carcass') )
			{
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0,,,0.7);
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Misc, 16.0,,,0.7);
			}
			else
			{
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0,,,0.7);
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Misc, 16.0,,,0.7);
			}
		}
		if ( PhraseTime[PhraseNum] == 0 )
			Destroy();
		else
		{
			SetTimer(PhraseTime[PhraseNum], false);
			PhraseNum++;
		}
	}
	else
		Destroy();
}

defaultproperties
{
	TauntSound(0)=Sound'UnrealShare.Skaarj.chalnge1s'
	TauntSound(1)=Sound'UnrealShare.Skaarj.chalnge3s'
	TauntSound(2)=Sound'UnrealShare.Skaarj.roam11s'
	TauntString(0)="$#%#!"
	TauntString(1)="%&$##!"
	TauntString(2)="*@#&$!"
}
