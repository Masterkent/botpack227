class PKStartMessage expands LocalMessagePlus;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var(Messages)	localized string 	StartString;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY - 2*YL;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.StartString;
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

	class'UTC_PlayerPawn'.static.B227_ClientPlayVoice(P, sound'Announcer.Prepare',, true);
}

defaultproperties
{
     StartString="PREPARE FOR BATTLE!!!"
     FontSize=1
     bIsSpecial=True
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(G=0,B=0)
     YPos=196.000000
     bCenter=True
}
