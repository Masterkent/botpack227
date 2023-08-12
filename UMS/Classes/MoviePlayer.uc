//=============================================================================
// MoviePlayer.
//=============================================================================
class MoviePlayer expands PlayerPawn;

//Used for fading
var bool bFade, bFadingOut;
var float DesiredFadeTime;
var float CurrentFadeTime, TimeChange;
var vector FadeColor, BlackColour, ColourChange;
var float FadeScale;

//First, we make sure that the MoviePlayer can't do anything
//I'm not sure how much of this code really needs to be here, but I
//am just going to leave well enough alone since it works

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.bIsSpectator = true;
}

event FootZoneChange(ZoneInfo newFootZone)
{
}
	
event HeadZoneChange(ZoneInfo newHeadZone)
{
}

exec function Walk()
{	
}

exec function BehindView( Bool B )
{
}

function ChangeTeam( int N )
{
}

exec function Taunt( name Sequence )
{
}

exec function CallForHelp()
{
}

exec function ThrowWeapon()
{
}

exec function Suicide()
{
}

exec function Fly()
{
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
}

function ClientReStart()
{
}

function PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'dropped', Location);
}

exec function Grab()
{
}

// Send a message to all players.
exec function Say( string S )
{
}

//=============================================================================
// functions.

exec function RestartLevel()
{
}

// This pawn was possessed by a player.
function Possess()
{
	DefaultFOV = FClamp(MainFOV, 90, 170);
	DesiredFOV = DefaultFOV;
}

function PostBeginPlay()
{
    if (Level.LevelEnterText != "" )
        ClientMessage(Level.LevelEnterText);
    bIsPlayer = true;
    FlashScale = vect(1,1,1);
    if ( Level.NetMode != NM_Client )
        ScoringType = Level.Game.ScoreboardType;
    BlackColour.X = 0;
    BlackColour.Y = 0;
    BlackColour.Z = 0;
}

//=============================================================================
// Inventory-related input notifications.

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
}

exec function NextItem()
{
}

exec function PrevItem()
{
}

exec function Fire( optional float F )
{
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
}

//=================================================================================

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
}

//Were we add in a tick function, used to make sure the FOV of the
//MoviePlayer is updated as whatever camera it is wathcing zooms.
event PlayerTick(float DeltaTime)
{
    local MovieCamera M;

    M = MovieCamera(ViewTarget);

	//If ViewTarget is a MovieCamera, update FOV
    if(M != NONE)
    {
        //Adjust FOV to FOV of camera
        DesiredFOV = B227_ScaleFOV(M.CurrentFOV);
	}

	//Do fade
	if(bFade)
	{
        CurrentFadeTime += DeltaTime;
        if(bFadingOut)
        {
            ConstantGlowScale = -(CurrentFadeTime / DesiredFadeTime);
            ConstantGlowFog = FadeColor * (CurrentFadeTime / DesiredFadeTime);
        }
        else
        {
            ConstantGlowScale = (CurrentFadeTime / DesiredFadeTime) - 1;
            ConstantGlowFog = FadeColor * (1 - (CurrentFadeTime / DesiredFadeTime));
        }
	}

	ViewFlash(DeltaTime);
	ViewShake(DeltaTime);
}

function FadeView(float TheTime, vector TheColor, bool bFadeOut)
{
    DesiredFadeTime = TheTime;
    FadeColor = TheColor;
    CurrentFadeTime = 0;
    bFadingOut = bFadeOut;
    if(bFadingOut)
    {
        ConstantGlowFog = BlackColour;
        ConstantGlowScale = 0;
    }
    else
    {
        ConstantGlowFog = FadeColor;
        ConstantGlowScale = -1;
    }
    bFade = true;
}

auto state WatchingTheMovie
{
	ignores all;
	
	Begin:
		Sleep(100);
		Goto'Begin';
}

function float B227_ScaleFOV(float FOV)
{
	local float FOVScale;

	if (Player.Console == none)
		return FOV;

	FOVScale = FMin(
		Tan(FClamp(DefaultFOV, 90, 179) * Pi / 360),
		FMax(1.0, 0.75 * Player.Console.FrameX / FMax(1.0, Player.Console.FrameY)));

	return Atan(FOVScale * Tan(FClamp(FOV, 1, 179) * Pi / 360)) * 360 / Pi;
}

defaultproperties
{
	AnimSequence="None"
}
