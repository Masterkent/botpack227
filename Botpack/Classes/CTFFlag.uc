//=============================================================================
// CTFFlag.
//=============================================================================
class CTFFlag extends Decoration;

#exec MESH IMPORT MESH=pflag ANIVFILE=MODELS\pflag_a.3d DATAFILE=MODELS\pflag_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=pflag X=400 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=pflag SEQ=All   STARTFRAME=0 NUMFRAMES=133
#exec MESH SEQUENCE MESH=pflag SEQ=pflag STARTFRAME=0 NUMFRAMES=133

#exec TEXTURE IMPORT NAME=JpflagB FILE=MODELS\N-Flag-B.PCX GROUP=Skins FLAGS=2 // twosided
#exec TEXTURE IMPORT NAME=JpflagR FILE=MODELS\N-Flag-R.PCX GROUP=Skins FLAGS=2 // twosided

#exec MESHMAP NEW   MESHMAP=pflag MESH=pflag
#exec MESHMAP SCALE MESHMAP=pflag X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=pflag NUM=0 TEXTURE=JpflagB

var byte	 	 Team;      	
var bool bHome;
var bool bKnownLocation; //for bot AI
var bool bHeld;
var Pawn		Holder;
var FlagBase	HomeBase;

var B227_CTFFlagEffect B227_Effect;

replication
{
	reliable if ( Role == ROLE_Authority )
		Team, bHome, bHeld;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('pflag');
}

function Actor Position()
{
	if ( bHeld )
		return Holder;

	return self;
}

event FellOutOfWorld()
{
	SendHome();
}

function SendHome()
{
	local Pawn aPawn;

	B227_DisableHolderLighting();

	if ( Holder != None )
	{
		//-Holder.AmbientGlow = Holder.Default.AmbientGlow;
		Holder.PlayerReplicationInfo.HasFlag = None;
		if ( Holder.Inventory != None )
			Holder.Inventory.SetOwnerDisplay();
		Holder = None;
	}
	GotoState('Home');
	SetPhysics(PHYS_None);
	bCollideWorld = false;
	SetLocation(HomeBase.Location);
	SetRotation(HomeBase.Rotation);
	SetBase(None);
	SetCollision(true,false,false);
	For (aPawn = Level.PawnList; aPawn!=None; aPawn=aPawn.nextPawn )
		if ( aPawn.MoveTarget == self )
			aPawn.MoveTimer = -1.0;
}

function Landed(vector HitNormall)
{
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
}

function Drop(vector newVel)
{
	local Pawn OldHolder;
	local vector X,Y,Z;
	local bool bHolderPainZone;

	BroadcastLocalizedMessage( class'CTFMessage', 2, Holder.PlayerReplicationInfo, None, CTFGame(Level.Game).Teams[Team] );
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("flag_dropped", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("flag_dropped", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));
	Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	If (Region.Zone.bWaterZone)
		Velocity *= 0.5;
	OldHolder = Holder;
	Holder.PlayerReplicationInfo.HasFlag = None;
	//-Holder.AmbientGlow = Holder.Default.AmbientGlow;
	B227_DisableHolderLighting();
	bHolderPainZone = (Holder.Region.Zone.bPainZone && (Holder.Region.Zone.DamagePerSec > 0));
	bHolderPainZone = bHolderPainZone || (Holder.FootRegion.Zone.bPainZone && (Holder.FootRegion.Zone.DamagePerSec > 0));
	if ( Holder.Inventory != None )
		Holder.Inventory.SetOwnerDisplay();
	Holder = None;

	GetAxes(OldHolder.Rotation, X,Y,Z);
	SetRotation(rotator(-1 * X));
	bCollideWorld = true;
	SetCollisionSize(0.5 * Default.CollisionRadius, CollisionHeight);
 	if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5)) 
		&& !SetLocation(OldHolder.Location) )
	{
		SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		if ( !SetLocation(OldHolder.Location) )
		{
			SendHome();
			return;
		}
	}

	SetPhysics(PHYS_Falling);
	SetBase(None);
	SetCollision(true, false, false);
	GotoState('Dropped');
	if ( bHolderPainZone )
		Timer();
}

function SetHolderLighting()
{
	//-Holder.AmbientGlow = 254; // [B227] excluded
	LightType = LT_None;

	if (B227_Effect != none && !B227_Effect.bDeleteMe)
		B227_Effect.SetOwner(Holder);
	else
	{
		B227_Effect = Spawn(class'B227_CTFFlagEffect', Holder);
		if (B227_Effect != none)
			B227_Effect.Init(self);
	}
}

state Dropped
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		if ( Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
			timer();
	}

	singular function ZoneChange( ZoneInfo NewZone )
	{
		Super.ZoneChange(NewZone);
		if ( NewZone.bPainZone && (NewZone.DamagePerSec > 0) )
			timer();
	}

	function Timer()
	{
		SendHome();
		BroadcastLocalizedMessage( class'CTFMessage', 3, None, None, CTFGame(Level.Game).Teams[Team] );
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("flag_returned_timeout", CTFGame(Level.Game).Teams[Team].TeamIndex);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("flag_returned_timeout", CTFGame(Level.Game).Teams[Team].TeamIndex);
	}

	function Touch(Actor Other)
	{
		local Pawn aPawn;

		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& !aPawn.IsInState('FeigningDeath') )
		{
			aPawn.MoveTimer = -1;
			if ( aPawn.PlayerReplicationInfo.Team == Team )
			{
				// returned flag
				CTFGame(Level.Game).ScoreFlag(aPawn, self);
				SendHome();
				return;
			}
			else
			{
				Holder = aPawn;
				Holder.PlayerReplicationInfo.HasFlag = self;
				SetHolderLighting();
				if ( Holder.IsA('Bot') )
				{
					Bot(Holder).AlternatePath = None;
					Bot(Holder).SendTeamMessage(None, 'OTHER', 2, 10);
				}
				else if (TournamentPlayer(Holder) != none && TournamentPlayer(Holder).bAutoTaunt)
					TournamentPlayer(Holder).SendTeamMessage(None, 'OTHER', 2, 10);
			}
			BroadcastLocalizedMessage( class'CTFMessage', 4, Holder.PlayerReplicationInfo, None, CTFGame(Level.Game).Teams[Team] );
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
			GotoState('Held');
		}
	}

	function BeginState()
	{
		LightEffect = LE_NonIncidence;
		SetTimer(25.0, false);
		bCollideWorld = true;
		bKnownLocation = false;
		bHidden = false;
	}

	function EndState()
	{
		bHidden = true;
	}

Begin:
	if ( Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
		timer();

}

state Held
{
	event FellOutOfWorld()
	{
	}

	function Timer()
	{
		if ( Holder == None )
			SendHome();
	}

	function BeginState()
	{
		bHeld = true;
		bCollideWorld = false;
		bKnownLocation = false;
		HomeBase.PlayAlarm();
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		SetTimer(10.0, true);
	}

	function EndState()
	{
		bHeld = false;
	}
}

auto state Home
{
	function Timer()
	{
		if ( HomeBase != none && CTFGame(Level.Game) != none && VSize(Location - HomeBase.Location) > 10 )
		{
			SendHome();
			BroadcastLocalizedMessage(class'CTFMessage', 5, None, None, CTFGame(Level.Game).Teams[Team]);
		}
	}

	function Touch(Actor Other)
	{
		local CTFFlag aFlag;
		local Pawn aPawn;
		local NavigationPoint N;
		local float totalweight, selection, PartialWeight;
		local Bot B;

		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0) )
		{
			// check if scored capture
			if ( aPawn.PlayerReplicationInfo.Team == Team )
			{
				if ( aPawn.PlayerReplicationInfo.HasFlag != None )
				{
					//Score!
					aFlag = CTFFlag(aPawn.PlayerReplicationInfo.HasFlag);
					CTFGame(Level.Game).ScoreFlag(aPawn, aFlag);
					aFlag.SendHome();
				}
			}
			else
			{
				Holder = aPawn;
				Holder.MoveTimer = -1;
				Holder.PlayerReplicationInfo.HasFlag = self;
				Holder.MakeNoise(2.0);
				SetHolderLighting();
				B = Bot(Holder);
				if ( B != None )
				{
					B.AlternatePath = None;
					if ( FRand() < 0.5 )
					{
						for (N = Level.NavigationPointList; N != none; N = N.nextNavigationPoint)
							if (AlternatePath(N) != none && (AlternatePath(N).team == Holder.PlayerReplicationInfo.team || B227_bTwoWay(N)))
							{
								if (AlternatePath(N).team != Holder.PlayerReplicationInfo.team)
									TotalWeight += 4000;
								TotalWeight += AlternatePath(N).SelectionWeight;
							}
						selection = TotalWeight * FRand();
						for (N = Level.NavigationPointList; N != none; N = N.nextNavigationPoint)
							if (AlternatePath(N) != none && (AlternatePath(N).team == Holder.PlayerReplicationInfo.team || B227_bTwoWay(N)))
							{
								B.AlternatePath = AlternatePath(N);
								if (AlternatePath(N).team != Holder.PlayerReplicationInfo.team)
								{
									PartialWeight += 4000;
								}
								PartialWeight += AlternatePath(N).SelectionWeight;
								if ( PartialWeight > selection )
									break;
							}
					}
					B.SendTeamMessage(None, 'OTHER', 2, 10);
				}
				else if (TournamentPlayer(Holder) != none && TournamentPlayer(Holder).bAutoTaunt )
					TournamentPlayer(Holder).SendTeamMessage(none, 'OTHER', 2, 10);

				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogSpecialEvent("flag_taken", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogSpecialEvent("flag_taken", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
				BroadcastLocalizedMessage( class'CTFMessage', 6, Holder.PlayerReplicationInfo, None, CTFGame(Level.Game).Teams[Team] );
				GotoState('Held');
			}
		}
	}

	function BeginState()
	{
		bHome = true;
		bCollideWorld = false;
		bKnownLocation = true;
		if ( HomeBase != None ) // will be none when flag is created
		{
			HomeBase.bHidden = false;
			HomeBase.AmbientSound = None;
		}
		SetTimer(1.0, true);
		SetCollisionSize(Default.CollisionRadius, Default.CollisionHeight);
	}

	function EndState()
	{
		bHome = false;
		HomeBase.bHidden = true;
		SetTimer(0.0, false);
	}
}

function BroadcastLocalizedMessage(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	class'UTC_Actor'.static.UTSF_BroadcastLocalizedMessage(self, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

// Auxiliary
function bool B227_bTwoWay(NavigationPoint A)
{
	return bool(A.GetPropertyText("bTwoWay"));
}

function B227_DisableHolderLighting()
{
	LightType = LT_Steady;
	if (B227_Effect != none)
	{
		B227_Effect.Destroy();
		B227_Effect = none;
	}
}

defaultproperties
{
	bHome=True
	bStatic=False
	bHidden=True
	bAlwaysRelevant=True
	bStasis=False
	DrawType=DT_Mesh
	Style=STY_Masked
	Skin=Texture'Botpack.Skins.JpflagB'
	Mesh=LodMesh'Botpack.pflag'
	DrawScale=0.600000
	PrePivot=(X=2.000000)
	bUnlit=True
	CollisionRadius=48.000000
	CollisionHeight=30.000000
	bCollideActors=True
	bCollideWorld=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=170
	LightRadius=6
	bFixedRotationDir=True
	Mass=30.000000
	Buoyancy=20.000000
	RotationRate=(Pitch=30000,Roll=30000)
	NetPriority=3.000000
}
