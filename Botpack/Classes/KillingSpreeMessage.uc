//
// Switch is the note.
// RelatedPRI_1 is the player on the spree.
//
class KillingSpreeMessage expands CriticalEventLowPlus;

#exec OBJ LOAD FILE="Announcer.uax"

var(Messages)	localized string EndSpreeNote, EndSelfSpree, EndFemaleSpree, MultiKillString;
var(Messages)	localized string SpreeNote[10];
var(Messages)	sound SpreeSound[10];
var(Messages)	localized string EndSpreeNoteTrailer;
 
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (default.B227_bHasRelatedContext)
		return B227_GetString(Switch);

	if (RelatedPRI_2 == None)
	{
		if (RelatedPRI_1 == None)
			return "";

		if (RelatedPRI_1.PlayerName != "")
			return RelatedPRI_1.PlayerName@Default.SpreeNote[Switch];
	} 
	else
	{
		if (RelatedPRI_1 == None)
		{
			if (RelatedPRI_2.PlayerName != "")
			{
				if ( RelatedPRI_2.bIsFemale )
					return RelatedPRI_2.PlayerName@Default.EndFemaleSpree;
				else
					return RelatedPRI_2.PlayerName@Default.EndSelfSpree;
			}
		}
		else
		{
			return RelatedPRI_1.PlayerName$Default.EndSpreeNote@RelatedPRI_2.PlayerName@Default.EndSpreeNoteTrailer;
		}
	}
	return "";
}

static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (RelatedPRI_2 != None || default.B227_bHasRelatedContext)
		return;

	if (RelatedPRI_1 != P.PlayerReplicationInfo)
	{
		P.PlaySound(sound'SpreeSound',, 4.0);
		return;
	}
	class'UTC_PlayerPawn'.static.B227_ClientPlayVoice(P, default.SpreeSound[Switch],, true);

}

static function string B227_GetString(optional int Switch)
{
	return default.B227_RelatedPawnInfo_1 $ default.EndSpreeNote @ default.B227_RelatedPawnInfo_2 @ default.EndSpreeNoteTrailer;
}

defaultproperties
{
	EndSpreeNote="'s killing spree was ended by"
	EndSelfSpree="was looking good till he killed himself!"
	EndFemaleSpree="was looking good till she killed herself!"
	spreenote(0)="is on a killing spree!"
	spreenote(1)="is on a rampage!"
	spreenote(2)="is dominating!"
	spreenote(3)="is unstoppable!"
	spreenote(4)="is Godlike!"
	SpreeSound(0)=Sound'Announcer.killingspree'
	SpreeSound(1)=Sound'Announcer.rampage'
	SpreeSound(2)=Sound'Announcer.dominating'
	SpreeSound(3)=Sound'Announcer.unstoppable'
	SpreeSound(4)=Sound'Announcer.godlike'
	bBeep=False
}
