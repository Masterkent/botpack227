//=============================================================================
// MovieSound: Will play a sound that follows a specific pawn, denoted by Pawn
// and MoviePawn
//=============================================================================
class MovieSound extends UMSTriggers;

//-----------------------------------------------------------------------------
// Variables.

var bool bMovieSound;
var bool bMoviePawn;
var Pawn PawnName;
var bool bPlayingMovieSound;
var float ElapsedSoundLength;
var() float Volume;
var() sound Sound;
var() string Pawn;
var() float Radius;
var float SoundLength;

//-----------------------------------------------------------------------------
// Functions.

function Trigger( actor Other, pawn EventInstigator )
{
    PlaySound(Sound,,Volume,,Radius);
    bPlayingMovieSound=true;
    ElapsedSoundLength=0;
}

function PostBeginPlay()
{
    PawnName = FindPawn(Pawn);
    if(PawnName!=NONE)
    {
        bMoviePawn=true;
    }
    SoundLength=GetSoundDuration(Sound);
}

function Pawn FindPawn(string PawnName)
{
    local Pawn P;

    foreach AllActors(class'Pawn', P)
        if (PawnName ~= string(P.Tag) || PawnName ~= string(P.Name))
               return P;
    //If there is no matching pawn, return none.
    return NONE;
}

function Tick(float DeltaTime)
{
    if (bPlayingMovieSound == true && bMoviePawn == true)
    {
        SetLocation(PawnName.Location);
        ElapsedSoundLength+=DeltaTime;
        if (ElapsedSoundLength >= SoundLength)
        {
            bPlayingMovieSound=false;
        }
    }
}

defaultproperties
{
				Volume=255.000000
				Radius=400.000000
				Texture=Texture'Engine.S_SpecialEvent'
}
