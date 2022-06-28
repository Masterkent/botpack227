//=============================================================================
// MovieCredits
// Created by Hugh Macdonald and Yoda.
//=============================================================================

class MovieCredits expands UMS;

var() string CreditsScript[500];		// Credits sequence script.
var() string CreditsScript2[500];
var() int CreditsSize[500];		// Size of each entry in the credits sequence.
var() texture CreditsPic[200];		// Optional pictures to insert into the credits.
var() float CreditsGap[500];		// Gap after each entry in the credit sequence.
var() int CreditsAlign[500];		// Alignment of "			    ".
var() Color CreditsColor[500];		// Color of     "			    ".
var() Color MasterColor;		// Default color for credits.
var() float ScrollingTime;		// Time, in seconds, which the credits take to scroll.
var() float CreditsOffset[500];		// Offset of each entry in the credits sequence.
var() string CreditsDivider;
var bool bRolling;

// Start the credits...
function Trigger(actor Other, pawn Instigator)
{
    local MoviePlayer M;

    bRolling = true;
    foreach AllActors(class 'MoviePlayer', M)
    {
        if(MovieHUD(M.myHUD) != NONE)
            MovieHUD(M.myHUD).StartCredits(self);
    }
}

function string GetCreditsScript (int num)
{
	return CreditsScript[num];
}

function string GetCreditsScript2 (int num)
{
	return CreditsScript2[num];
}

function color GetCreditsColor (int num)
{
	return CreditsColor[num];
}

function texture GetCreditsPic (int num)
{
	return CreditsPic[num];
}

function int GetCreditsAlign (int num)
{
	return CreditsAlign[num];
}

function float GetCreditsGap (int num)
{
	return CreditsGap[num];
}

function int GetCreditsSize (int num)
{
	return CreditsSize[num];
}

function float GetCreditsOffset (int num)
{
	return CreditsOffset[num];
}

defaultproperties
{
				MasterColor=(G=255)
				ScrollingTime=5.000000
				CreditsDivider="'"
}
