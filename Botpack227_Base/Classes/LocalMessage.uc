//
// Represents a schematic for a client localized message.
//
class LocalMessage expands Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsSpecial;										// If true, don't add to normal queue.
var bool	bIsUnique;										// If true and special, only one can be in the HUD queue at a time.
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bFadeMessage;									// If true, use fade out effect on message.
var bool	bBeep;											// If true, beep!
var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var int		Lifetime;										// # of seconds to stay in HUD message queue.

var class<LocalMessage> ChildMessage;						// In some cases, we need to refer to a child message.

// Canvas Variables
var bool	bFromBottom;									// Subtract YPos.
var color	DrawColor;										// Color to display message with.
var float	XPos, YPos;										// Coordinates to print message at.
var bool	bCenter;										// Whether or not to center the message.

// Port extensions
var name B227_MessageName;

// Hack for UTC_PlayerPawn.B227_ReceiveLocalizedMessage
var transient bool B227_bHasRelatedContext;
var transient string B227_RelatedPawnInfo_1;
var transient string B227_RelatedPawnInfo_2;
var transient class<Object> B227_RelatedClass;
var transient string B227_RelatedInfo;

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject);

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	return "";
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString)
{
	return "";
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	if (P.myHUD != none)
		class'UTC_HUD'.static.UTSF_LocalizedMessage(P.myHUD, default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (default.bBeep && P.bMessageBeep)
		P.PlayBeepSound();

	if (default.bIsConsoleMessage)
	{
		if ((P.Player != none) && (P.Player.Console != none))
		{
			if (default.B227_MessageName == '')
				class'UTC_Console'.static.UTSF_AddString(
					P.Player.Console,
					static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject));
			else
				P.Player.Console.Message(
					none,
					static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),
					default.B227_MessageName);
		}
	}
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2)
{
	return default.DrawColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return default.YPos;
}

static function int GetFontSize( int Switch );

static function string B227_GetString(optional int Switch)
{
	return "";
}

defaultproperties
{
     Lifetime=3
     DrawColor=(R=255,G=255,B=255)
}
