class PKDeathMessagePlus extends DeathMessagePlus;

static function ClientReceive(
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == P.PlayerReplicationInfo)
	{
		// Interdict and send the child message instead.
		if (P.myHUD != none)
		{
			class'UTC_HUD'.static.UTSF_LocalizedMessage(P.myHUD, default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
			class'UTC_HUD'.static.UTSF_LocalizedMessage(P.myHUD, default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}

		if (default.bIsConsoleMessage)
			P.Player.Console.Message(none, GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject), default.B227_MessageName);

		if (TournamentPlayer(P) != none)
		{
			if (( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None ))
			{
				if ( (TournamentPlayer(P).Level.TimeSeconds - TournamentPlayer(P).LastKillTime < 3) && (Switch != 1) )
				{
					TournamentPlayer(P).MultiLevel++;
					TournamentPlayer(P).ReceiveLocalizedMessage( class'PKMultiKillMessage', TournamentPlayer(P).MultiLevel );
				}
				else
					TournamentPlayer(P).MultiLevel = 0;
				TournamentPlayer(P).LastKillTime = TournamentPlayer(P).Level.TimeSeconds;
			}
			else
				TournamentPlayer(P).MultiLevel = 0;
		}
		if ( ChallengeHUD(P.MyHUD) != None )
			ChallengeHUD(P.MyHUD).ScoreTime = P.Level.TimeSeconds;
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, class'VictimMessage', 0, RelatedPRI_1);
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
}
