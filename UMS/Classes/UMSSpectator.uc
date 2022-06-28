//=============================================================================
//
// UMSSpectator.uc
//
// by Hugh Macdonald
//
//=============================================================================

class UMSSpectator expands CHSpectator;

var pawn CurrentPlayerCam;
var bool bFollowingFlag;
var Pawn FlagHolder;

var enum UMSSpectView
{
	UMSV_StaticCam,
	UMSV_ChaseCam,
	UMSV_OwnCam
} ViewType;

function Pawn FindFlagHolder()
{
	local pawn P;
	local int ThisPlayer;
	
	for ( P=Level.PawnList; ThisPlayer <= 100; P=P.NextPawn )
	{
		if(P == NONE)
			break;
		
		ThisPlayer++;
		
		if(P.PlayerReplicationInfo.HasFlag != NONE)
		{
			return P;
		}
	}
	return NONE;
}

function ChangeUMSView()
{
	if(ViewType == UMSV_StaticCam)
	{
		if(bFollowingFlag)
		{
			CurrentPlayerCam = FindFlagHolder();
		}
		
		if(CurrentPlayerCam != None)
		{
			if(CurrentPlayerCam.IsA('Bot'))
			{
				ViewTarget = UMSBotReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera;
				DesiredFOV = UMSBotReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera.CurrentFOV;
				if(ViewTarget.IsA('MPMovieCamera'))
				{
					if(MPMovieCamera(ViewTarget).bTrackingMP || MPMovieCamera(ViewTarget).bMovingMP)
					{
						MPMovieCamera(ViewTarget).CurrentPawn = CurrentPlayerCam;
					}
				}
				bChaseCam = false;
				bBehindView = false;
			}
			else if(CurrentPlayerCam.IsA('PlayerPawn') && !CurrentPlayerCam.IsA('Spectator'))
			{
				ViewTarget = UMSPlayerReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera;
				DesiredFOV = UMSPlayerReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera.CurrentFOV;
				if(ViewTarget.IsA('MPMovieCamera'))
				{
					if(MPMovieCamera(ViewTarget).bTrackingMP || MPMovieCamera(ViewTarget).bMovingMP)
					{
						MPMovieCamera(ViewTarget).CurrentPawn = CurrentPlayerCam;
					}
				}
				bChaseCam = false;
				bBehindView = false;
			}
		}
	}
}

exec function ViewPlayerNum(optional int num)
{
	local int ThisPlayer;
	local pawn P;
	
	ThisPlayer = 0;

	for ( P=Level.PawnList; ThisPlayer <= num; P=P.NextPawn )
	{
		if(P == NONE)
			break;
		
		ThisPlayer++;
		
		CurrentPlayerCam = P;
		ChangeUMSView();
	}
	
	
	/*log(self$": ViewPlayerNum has been called");
	super.ViewPlayerNum(num);
	
	CurrentPlayerCam = Pawn(ViewTarget);
	if(CurrentPlayerCam.IsA('Bot'))
		{
			ViewTarget = UMSBotReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera;
			if(ViewTarget.IsA('MPMovieCamera'))
			{
				if(MPMovieCamera(ViewTarget).bTrackingMP || MPMovieCamera(ViewTarget).bMovingMP)
				{
					MPMovieCamera(ViewTarget).CurrentPawn = CurrentPlayerCam;
				}
			}
			bChaseCam = false;
			bBehindView = false;
		}
	else if(CurrentPlayerCam.IsA('PlayerPawn') && !CurrentPlayerCam.IsA('Spectator'))
		{
			ViewTarget = UMSPlayerReplicationInfo(CurrentPlayerCam.PlayerReplicationInfo).CurrentCamera;
			if(ViewTarget.IsA('MPMovieCamera'))
			{
				if(MPMovieCamera(ViewTarget).bTrackingMP || MPMovieCamera(ViewTarget).bMovingMP)
				{
					MPMovieCamera(ViewTarget).CurrentPawn = CurrentPlayerCam;
				}
			}
			bChaseCam = false;
			bBehindView = false;
		}
	*/
	/*
	if ( !PlayerReplicationInfo.bIsSpectator && !Level.Game.bTeamGame )
		return;
	if ( num >= 0 )
	{
		log("Num is >= 0");
		
		P = Pawn(ViewTarget);
		if ( (P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.TeamID == num) )
		{
			ViewTarget = None;
			bBehindView = false;
			return;
		}
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
				&& !P.PlayerReplicationInfo.bIsSpectator
				&& (P.PlayerReplicationInfo.TeamID == num) )
			{
				if ( P != self)
				{
					CurrentPlayerCam = P;
					if(UMSPlayerReplicationInfo(P.PlayerReplicationInfo) != None)
					{
						ViewTarget = UMSPlayerReplicationInfo(P.PlayerReplicationInfo).CurrentCamera;
						log("Changing the spectator's view to watch "$P.PlayerReplicationInfo.PlayerName$" from this camera: "$UMSPlayerReplicationInfo(P.PlayerReplicationInfo).CurrentCamera);
					}
					if(UMSBotReplicationInfo(P.PlayerReplicationInfo) != None)
					{
						ViewTarget = UMSBotReplicationInfo(P.PlayerReplicationInfo).CurrentCamera;
						log("Changing the spectator's view to watch "$P.PlayerReplicationInfo.PlayerName$" from this camera: "$UMSBotReplicationInfo(P.PlayerReplicationInfo).CurrentCamera);
					}
					bBehindView = false;
				}
				return;
			}
		return;
	}
	if ( Role == ROLE_Authority )
	{
		ViewClass(class'Pawn', true);
		While ( (ViewTarget != None) 
				&& (!Pawn(ViewTarget).bIsPlayer || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator) )
			ViewClass(class'Pawn', true);

		if ( ViewTarget != None )
			ClientMessage(ViewingFrom@Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
	*/
}

exec function AltFire( optional float F)
{
	log(self$": AltFire() has been called");
	
	if(ViewType == UMSV_StaticCam)
	{
		ViewType = UMSV_ChaseCam;
		ViewTarget = CurrentPlayerCam;
		bChaseCam = true;
		bBehindView = true;
	}
	else if(ViewType == UMSV_ChaseCam)
	{
		ViewType = UMSV_OwnCam;
		ViewTarget = None;
		bBehindView = false;
		bChaseCam = false;
		ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
	else if(ViewType == UMSV_OwnCam)
	{
		ViewType = UMSV_StaticCam;
	}
}

exec function Fire( optional float F )
{
	local Pawn P;
	local bool bUseNext;
	local bool bHasChanged;
	
	log(self$": Fire() has been called");
	bUseNext = false;
	
	if(ViewType == UMSV_OwnCam)
		ViewType = UMSV_StaticCam;

	if(!bFollowingFlag)
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			If(!P.IsA('Spectator'))
			{
				log(Self$": bFollowingFlag is false, and currently checking"@P);
				if(bUseNext)
				{
					CurrentPlayerCam = P;
					bUseNext = false;
					bHasChanged = true;
					break;
				}
				if(P == CurrentPlayerCam)
				{
					bUseNext = true;
				}
			}
		}
		if ( P != None )
			ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event', true);

	}
	
	if(!bHasChanged && !bFollowingFlag)
	{
		log(Self$": bHasChanged and bFollowingFlag are both false");
		bFollowingFlag = true;
		CurrentPlayerCam = FindFlagHolder();
		ClientMessage(ViewingFrom@"the flag", 'Event', true);
	}
	else if (bFollowingFlag)
	{
		log(Self$": bFollowingFlag is true");
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			If(!P.IsA('Spectator'))
			{
					bFollowingFlag=false;
					CurrentPlayerCam = P;
					bHasChanged = true;
					break;
			}
		}
		if ( P != None )
			ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event', true);


	}
	

	ChangeUMSView();
	//if ( (Role == ROLE_Authority) && (Level.Game == None || !Level.Game.IsA('Intro')) )
	//{
	//	ViewPlayerNum(-1);
	//}
	
}

defaultproperties
{
}
