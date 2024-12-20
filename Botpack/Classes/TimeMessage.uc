class TimeMessage extends CriticalEventPlus;

#exec OBJ LOAD FILE="Announcer.uax"

var localized string TimeMessage[16];
var Sound TimeSound[16];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.TimeMessage[Switch];
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

	if ( P.ViewTarget != None )
		P.ViewTarget.PlaySound(Default.TimeSound[Switch],,4.0);
	else
		P.PlaySound(Default.TimeSound[Switch],,4.0);
}

defaultproperties
{
	TimeMessage(0)="5 minutes left in the game!"
	TimeMessage(2)="3 minutes left in the game!"
	TimeMessage(3)="2 minutes left in the game!"
	TimeMessage(4)="1 minute left in the game!"
	TimeMessage(5)="30 seconds left!"
	TimeMessage(6)="10 seconds left!"
	TimeMessage(7)="9..."
	TimeMessage(8)="8..."
	TimeMessage(9)="7..."
	TimeMessage(10)="6..."
	TimeMessage(11)="5 seconds and counting..."
	TimeMessage(12)="4..."
	TimeMessage(13)="3..."
	TimeMessage(14)="2..."
	TimeMessage(15)="1..."
	TimeSound(0)=Sound'Announcer.cd5min'
	TimeSound(2)=Sound'Announcer.cd3min'
	TimeSound(4)=Sound'Announcer.cd1min'
	TimeSound(6)=Sound'Announcer.cd10'
	TimeSound(7)=Sound'Announcer.cd9'
	TimeSound(8)=Sound'Announcer.cd8'
	TimeSound(9)=Sound'Announcer.cd7'
	TimeSound(10)=Sound'Announcer.cd6'
	TimeSound(11)=Sound'Announcer.cd5'
	TimeSound(12)=Sound'Announcer.cd4'
	TimeSound(13)=Sound'Announcer.cd3'
	TimeSound(14)=Sound'Announcer.cd2'
	TimeSound(15)=Sound'Announcer.cd1'
	bBeep=False
}
