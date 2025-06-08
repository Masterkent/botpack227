//=============================================================================
// ControlPoint.
//=============================================================================
class ControlPoint extends NavigationPoint;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var TeamInfo ControllingTeam;
var Pawn Controller;
var() Name RedEvent;
var() Name BlueEvent;
var() Name GreenEvent;
var() Name GoldEvent;
var() bool bSelfDisplayed;
var() localized String PointName;
var() Sound ControlSound;
var   int ScoreTime;
var   bool bScoreReady;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		ControllingTeam, PointName;
}

function PostBeginPlay()
{
	if ( !Level.Game.IsA('Domination') )
		return;
	else
	{
		Super.PostBeginPlay();
		bHidden = !bSelfDisplayed;
	}

	// Log the event.
	if (Level.Game.LocalLog != None)
	{
		Level.Game.LocalLog.LogSpecialEvent("controlpoint_created", PointName);
	}
	if (Level.Game.WorldLog != None)
	{
		Level.Game.WorldLog.LogSpecialEvent("controlpoint_created", PointName);
	}
}

function string GetHumanName()
{
	return PointName;
}

function Touch(Actor Other)
{
	if (!Other.bIsPawn ||
		Pawn(Other).PlayerReplicationInfo == none ||
		Pawn(Other).Health <= 0 ||
		Domination(Level.Game) == none)
	{
		return;
	}

	Controller = Pawn(Other);
	if ( Bot(Controller) != none && (Controller.MoveTarget == self) )
		Controller.MoveTimer = -1.0; // stop moving toward this
	UpdateStatus();
}

function UpdateStatus()
{
	local Actor A;
	local Name E;
	local TeamInfo NewTeam;
	local TeamGamePlus T;
	local Bot B, B2;
	local Pawn P;
	local bool bNeedDefense, bTempDefense;

	T = TeamGamePlus(Level.Game);
	if ( Controller == None )
		NewTeam = None;
	else
		NewTeam = T.GetTeam(Controller.PlayerReplicationInfo.Team);

	if ( NewTeam == ControllingTeam )
		return;

	ControllingTeam = NewTeam;
	if ( ControllingTeam != None )
	{
		// Log the event.
		if (Level.Game.LocalLog != None)
		{
			Level.Game.LocalLog.LogSpecialEvent("controlpoint_capture", PointName, Controller.PlayerReplicationInfo.PlayerID);
		}
		if (Level.Game.WorldLog != None)
		{
			Level.Game.WorldLog.LogSpecialEvent("controlpoint_capture", PointName, Controller.PlayerReplicationInfo.PlayerID);
		}
		PlaySound(ControlSound, SLOT_None, 12.0);
		class'UTC_Actor'.static.UTSF_BroadcastLocalizedMessage(self, class'ControlPointMessage', Controller.PlayerReplicationInfo.Team, None, None, self);
		B = Bot(Controller);
		if ( B != None )
		{
			bNeedDefense = false;
			bTempDefense = false;
			B.SendTeamMessage(None, 'OTHER', 11, 15);
			if ( (B.Orders != 'Follow') && (B.Orders != 'Hold') )
			{
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( P.PlayerReplicationInfo != none && (P.PlayerReplicationInfo.Team == ControllingTeam.TeamIndex) )
					{
						bNeedDefense = true; // only defend if at least one other player on team
						B2 = Bot(P);
						if ( B2 == None )
							bTempDefense = true;
						else if ( ((B2.OrderObject == self) && (B2.Orders == 'Defend'))
								|| ((B2.OrderObject == B) && (B2.Orders == 'Follow')) )
						{
							bNeedDefense = false;
							break;
						}
					}
				if ( bNeedDefense )
				{
					if ( bTempDefense || (FRand() < 0.35) )
					{
						B.SetOrders('Freelance', None);
						B.Orders = 'Defend';
					}
					else
					{
						B.SetOrders('Defend', None);
						BotReplicationInfo(B.PlayerReplicationInfo).OrderObject = self;
					}
					B.OrderObject = self;
				}
			}
		}
		else if (TournamentPlayer(Controller) != none)
		{
			if (TournamentPlayer(Controller).bAutoTaunt)
				TournamentPlayer(Controller).SendTeamMessage(None, 'OTHER', 11, 15);
			if ( DeathMatchPlus(Level.Game).bRatedGame
					&& (Controller == DeathMatchPlus(Level.Game).RatedPlayer) )
				DeathMatchPlus(Level.Game).bFulfilledSpecial = true;
		}
	}
	if ( bSelfDisplayed )
		bHidden = false;

	if ( ControllingTeam == None )
	{
		bScoreReady = false;
		E = '';
		if ( bSelfDisplayed )
		{
			DrawScale=0.4;
			Mesh = mesh'DomN';
			Texture=texture'JDomN0';
			LightHue=0;
			LightSaturation=255;
		}
	}
	else
	{
		ScoreTime = 2;
		SetTimer(1.0, true);
		if ( bSelfDisplayed )
		{
			LightBrightness=255;
			LightSaturation=0;
		}
		if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Red )
		{
			E = RedEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.4;
				Mesh = mesh'DomR';
				Texture = texture'RedSkin2';
				LightHue=0;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Blue )
		{
			E = BlueEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.4;
				Mesh = mesh'DomB';
				Texture = texture'BlueSkin2';
				LightHue=170;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Green )
		{
			E = GreenEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=1.0;
				Mesh=mesh'UDamage';
				Texture=Texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen'; //FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield';
				LightHue=85;
			}
		}
		else if ( Controller.PlayerReplicationInfo.Team == T.TEAM_Gold )
		{
			E = GoldEvent;
			if ( bSelfDisplayed )
			{
				DrawScale=0.7;
				Mesh=mesh'MercSymbol';
				Texture=texture'GoldSkin2';
				LightHue=35;
			}
		}
	}
	if ( E != '' )
		foreach AllActors(class'Actor', A, E )
		 Trigger(self, Controller);
}

function Timer()
{
	ScoreTime--;
	if (ScoreTime > 0)
		bScoreReady = false;
	else
	{
		ScoreTime = 0;
		bScoreReady = true;
		SetTimer(0.0, false);
	}
}

defaultproperties
{
	bSelfDisplayed=True
	PointName="Position"
	ControlSound=Sound'Botpack.Domination.ControlSound'
	bStatic=False
	bNoDelete=True
	bAlwaysRelevant=True
	Physics=PHYS_Rotating
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Texture=Texture'Botpack.Skins.JDomN0'
	Mesh=LodMesh'Botpack.DomN'
	DrawScale=0.400000
	AmbientGlow=255
	bUnlit=True
	bMeshEnviroMap=True
	SoundRadius=64
	SoundVolume=255
	bCollideActors=True
	LightType=LT_SubtlePulse
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=170
	LightSaturation=255
	LightRadius=7
	bFixedRotationDir=True
	RotationRate=(Yaw=5000)
	DesiredRotation=(Yaw=30000)
}
