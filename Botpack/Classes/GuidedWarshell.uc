//=============================================================================
// GuidedWarShell.
//=============================================================================
class GuidedWarShell extends WarShell;

var Pawn Guider;
var rotator OldGuiderRotation, GuidedRotation;
var float CurrentTimeStamp, LastUpdateTime,ClientBuffer,ServerUpdate;
var bool bUpdatePosition;
var bool bDestroyed;

var SavedMove SavedMoves;
var SavedMove FreeMoves;

var vector RealLocation, RealVelocity;

var float B227_CurrentTimestamp; // Doesn't change when the game is paused (in contrast to Level.TimeSeconds)
var float B227_CurrentServerTimestamp;
var vector B227_Velocity; // Actual velocity; the value is preserved when setting PHYS_None (in contrast to Velocity)
var vector B227_LastLocation;
var vector B227_LastVelocity;

replication
{
	// Things the server should send to the client.
	unreliable if ( Role==ROLE_Authority )
		ClientAdjustPosition, bDestroyed;
	unreliable if ( Role==ROLE_Authority && bNetOwner && bNetInitial )
		GuidedRotation, OldGuiderRotation;
	unreliable if ( Role==ROLE_Authority && !bNetOwner )
		RealLocation, RealVelocity;
	unreliable if ( Role < ROLE_Authority )
		ServerMove;

	reliable if (Role == ROLE_Authority && bNetOwner)
		B227_CurrentServerTimestamp;

	reliable if (Role == ROLE_Authority && bNetOwner && bNetInitial)
		B227_Velocity;
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if (Role == ROLE_Authority &&
		PlayerPawn(Owner) != none &&
		Viewport(PlayerPawn(Owner).Player) == none &&
		B227_CurrentTimestamp - ServerUpdate > 4)
	{
		Explode(Location,Vect(0,0,1));
		return;
	}

	if (Level.NetMode != NM_DedicatedServer && (Trail == none || Trail.bDeleteMe))
	{
		Trail = Spawn(class'RedeemerTrail', self);
		if (Trail != none)
			Trail.LifeSpan = 0;
	}

	CannonTimer += SmokeRate;
	if ( CannonTimer > 0.6 )
	{
		WarnCannons();
		CannonTimer -= 0.6;
	}

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			SmokeRate = 0.07;
		else
			SmokeRate = 0.02; 
	}
	else 
	{
		SmokeRate = 0.15;
	}
	b = Spawn(class'ut_SpriteSmokePuff');
	if (b != none)
		b.RemoteRole = ROLE_None;
	SetTimer(SmokeRate, false);
}


simulated function Destroyed()
{
	local WarheadLauncher W;

	//-bDestroyed = true;
	if (Role == ROLE_Authority && PlayerPawn(Guider) != none)
		PlayerPawn(Guider).ViewTarget = None;

	While ( FreeMoves != None )
	{
		FreeMoves.Destroy();
		FreeMoves = FreeMoves.NextMove;
	}

	While ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}

	if ( (Guider != None) && (Level.NetMode != NM_Client) )
	{
		W = WarheadLauncher(Guider.Weapon);
		if ( W != None )
		{
			W.GuidedShell = None;
			W.GotoState('Finishing');
		}
	}
	Super.Destroyed();
}

simulated function Tick(float DeltaTime)
{
	local int DeltaYaw, DeltaPitch;
	local int YawDiff;
	local SavedMove NewMove;

	if (Role == ROLE_Authority && B227_LostGuider())
	{
		Explode(Location,Vect(0,0,1));
		return;
	}

	B227_CurrentTimestamp += DeltaTime;

	if ( Level.NetMode == NM_Client )
	{
		B227_AdjustCurrentClientTimestamp(DeltaTime);

		if ( (PlayerPawn(Owner) != None) && (ViewPort(PlayerPawn(Owner).Player) != None) )
		{
			SetPhysics(PHYS_None);
			Guider = Pawn(Owner);
			if (WarheadLauncher(Guider.Weapon) != none)
				WarheadLauncher(Guider.Weapon).GuidedShell = self;
		}
		else
		{
			SetPhysics(default.Physics);
			if ( RealLocation != vect(0,0,0) )
			{
				SetLocation(RealLocation);
				RealLocation = vect(0,0,0);
			}
			if ( RealVelocity != vect(0,0,0) )
			{
				B227_Velocity = RealVelocity;
				SetRotation(rotator(B227_Velocity));
				RealVelocity = vect(0,0,0);
			}
			return;
		}
	}
	else if (
		(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer) &&
		(PlayerPawn(Owner) == none || ViewPort(PlayerPawn(Owner).Player) == none))
	{
		B227_CurrentServerTimestamp = B227_CurrentTimestamp;
		MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
		return;
	}

	// if server updated client position, client needs to replay moves after the update
	if ( bUpdatePosition )
		ClientUpdatePosition();

	if (Guider != none)
	{
		DeltaYaw = (Guider.ViewRotation.Yaw & 65535) - (OldGuiderRotation.Yaw & 65535);
		DeltaPitch = (Guider.ViewRotation.Pitch & 65535) - (OldGuiderRotation.Pitch & 65535);
	}
	if ( DeltaPitch < -32768 )
		DeltaPitch += 65536;
	else if ( DeltaPitch > 32768 )
		DeltaPitch -= 65536;
	if ( DeltaYaw < -32768 )
		DeltaYaw += 65536;
	else if ( DeltaYaw > 32768 )
		DeltaYaw -= 65536;

	YawDiff = (Rotation.Yaw & 65535) - (GuidedRotation.Yaw & 65535) - DeltaYaw;
	if ( DeltaYaw < 0 )
	{
		if ( ((YawDiff > 0) && (YawDiff < 16384)) || (YawDiff < -49152) )
			GuidedRotation.Yaw += DeltaYaw;
	}
	else if ( ((YawDiff < 0) && (YawDiff > -16384)) || (YawDiff > 49152) )
		GuidedRotation.Yaw += DeltaYaw;

	GuidedRotation.Pitch += DeltaPitch;
	if (Guider != none)
		OldGuiderRotation = Guider.ViewRotation;
	if ( Role == ROLE_SimulatedProxy )
	{
		// Send the move to the server
		// skip move if too soon
		if ( ClientBuffer < 0 )
		{
			ClientBuffer += DeltaTime;
			MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
			return;
		}
		else if (PlayerPawn(Owner) != none)
			ClientBuffer = ClientBuffer + DeltaTime - 80.0 / FMax(5000, PlayerPawn(Owner).NetSpeed);
		else
			ClientBuffer = ClientBuffer + DeltaTime;

		// I'm  a client, so I'll save my moves in case I need to replay them
		// Get a SavedMove actor to store the movement in.
		if ( SavedMoves == None )
		{
			SavedMoves = GetFreeMove();
			NewMove = SavedMoves;
		}
		else
		{
			NewMove = SavedMoves;
			while ( NewMove.NextMove != None )
				NewMove = NewMove.NextMove;
			NewMove.NextMove = GetFreeMove();
			NewMove = NewMove.NextMove;
		}

		NewMove.TimeStamp = B227_CurrentTimestamp;
		NewMove.Delta = DeltaTime;
		NewMove.Velocity = B227_Velocity;
		NewMove.SetRotation(GuidedRotation);

		MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
		ServerMove(B227_CurrentTimestamp, Location, NewMove.Rotation.Pitch, NewMove.Rotation.Yaw);
		return;
	}
	MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
}

// Server sends ClientAdjustPosition to the client to adjust the warhead position on the client side when the error
// is excessive
simulated function ClientAdjustPosition
(
	float TimeStamp, 
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ
)
{
	local vector NewLocation;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	B227_Velocity.X = NewVelX;
	B227_Velocity.Y = NewVelY;
	B227_Velocity.Z = NewVelZ;

	SetLocation(NewLocation);

	bUpdatePosition = true;
}

// Client calls this to replay moves after getting its position updated by the server
simulated function ClientUpdatePosition()
{
	local SavedMove CurrentMove;

	bUpdatePosition = false;
	CurrentMove = SavedMoves;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			MoveRocket(CurrentMove.Delta, CurrentMove.Velocity, CurrentMove.Rotation);
			CurrentMove = CurrentMove.NextMove;
		}
	}
}

// server moves the rocket based on clients input, and compares the resultant location to the client's view of the location
function ServerMove(float TimeStamp, vector ClientLoc, int Pitch, int Yaw)
{
	local float ClientErr, DeltaTime;
	local vector LocDiff;

	if ( CurrentTimeStamp >= TimeStamp || TimeStamp > B227_CurrentTimestamp + 0.3 )
		return;

	if ( CurrentTimeStamp > 0 )
		DeltaTime = TimeStamp - CurrentTimeStamp;
	CurrentTimeStamp = TimeStamp;

	if (TimeStamp >= B227_CurrentTimestamp - 1)
	{
		GuidedRotation.Pitch = Pitch;
		GuidedRotation.Yaw = Yaw;
	}

	if (DeltaTime > 0)
	{
		SetLocation(B227_LastLocation);
		B227_Velocity = B227_LastVelocity;
		MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
	}

	if ( B227_CurrentTimestamp - LastUpdateTime > 0.3 || ServerUpdate == 0)
	{
		ClientErr = 10000;
	}
	else if ( B227_CurrentTimestamp - LastUpdateTime > 0.07 )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		LastUpdateTime = B227_CurrentTimestamp;
		ClientAdjustPosition(TimeStamp, Location.X, Location.Y, Location.Z, B227_Velocity.X, B227_Velocity.Y, B227_Velocity.Z);
	}

	ServerUpdate = B227_CurrentTimestamp;
	B227_LastLocation = Location;
	B227_LastVelocity = B227_Velocity;

	DeltaTime = B227_CurrentTimestamp - TimeStamp;
	if (DeltaTime > 0)
		MoveRocket(DeltaTime, B227_Velocity, GuidedRotation);
}

simulated function MoveRocket(float DeltaTime, vector CurrentVelocity, rotator GuideRotation )
{
	local int OldRoll, RollMag;
	local rotator NewRot;
	local float SmoothRoll;
	local vector OldVelocity, X,Y,Z;

	if (Role == ROLE_Authority && B227_LostGuider())
	{
		Explode(Location,Vect(0,0,1));
		return;
	}

	OldRoll = Rotation.Roll & 65535;
	OldVelocity = CurrentVelocity;
	Velocity = CurrentVelocity + Vector(GuideRotation) * 1500 * DeltaTime;
	Velocity = Normal(Velocity) * 550;
	NewRot = Rotator(Velocity);

	// Roll Warhead based on acceleration
	GetAxes(NewRot, X,Y,Z);
	RollMag = int(10 * (Y Dot (Velocity - OldVelocity))/DeltaTime);
	if ( RollMag > 0 ) 
		NewRot.Roll = Min(12000, RollMag); 
	else
		NewRot.Roll = Max(53535, 65536 + RollMag);

	//smoothly change rotation
	if (NewRot.Roll > 32768)
	{
		if (OldRoll < 32768)
			OldRoll += 65536;
	}
	else if (OldRoll > 32768)
		OldRoll -= 65536;

	SmoothRoll = FMin(1.0, 5.0 * deltaTime);
	NewRot.Roll = NewRot.Roll * SmoothRoll + OldRoll * (1 - SmoothRoll);
	SetRotation(NewRot);

	B227_Velocity = Velocity;

	if (Level.NetMode != NM_Standalone)
	{
		if (Level.NetMode != NM_ListenServer ||
			PlayerPawn(Owner) == none ||
			(PlayerPawn(Owner).Player != none && ViewPort(PlayerPawn(Owner).Player) == none))
		{
			SetPhysics(default.Physics);
			AutonomousPhysics(DeltaTime);
			B227_Velocity = Velocity;
			SetPhysics(PHYS_None);
			Velocity = B227_Velocity; // for AI
		}
	}

	if ( Role == ROLE_Authority )
	{
		RealLocation = Location;
		RealVelocity = B227_Velocity;
	}
}

simulated function PostRender( canvas Canvas )
{
	local float Dist;
	local Pawn P;
	local int XPos, YPos;
	local Vector X,Y,Z, Dir;
	local float Scale, FovScale;

	if (PlayerPawn(Owner) == none || PlayerPawn(Owner).bBehindView)
		return;

	GetAxes(Rotation, X,Y,Z);
	if (Canvas.ClipY < 768)
		Canvas.Font = Font'TinyRedFont';
	else
	{
		Canvas.Font = Font'WhiteFont';
		Canvas.DrawColor = MakeColor(255, 0, 0);
	}

	if ( Level.bHighDetailMode )
		Canvas.Style = ERenderStyle.STY_Translucent;
	else
		Canvas.Style = ERenderStyle.STY_Normal;

	FovScale = 1 / Tan(FClamp(PlayerPawn(Owner).DesiredFOV, 1, 170) / 360 * Pi);

	foreach VisibleCollidingActors(class'Pawn', P, 2000,, true)
	{
		Dir = P.Location - Location;
		Dist = VSize(Dir);
		if ( ((Dir / Dist) Dot X) > 0.7 * FovScale)
		{
			Dir = Dir / (Dir Dot X);
			XPos = 0.5 * (Canvas.SizeX + Canvas.SizeX * (Dir Dot Y) * FovScale);
			YPos = 0.5 * (Canvas.SizeY - Canvas.SizeX * (Dir Dot Z) * FovScale);

			Scale = FMax(1.0, class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 640.0));

			Canvas.SetPos(XPos - 0.5 * Texture'Crosshair6'.USize * Scale, YPos - 0.5 * Texture'Crosshair6'.VSize * Scale);
			Canvas.DrawIcon(texture'CrossHair6', Scale);
			Canvas.SetPos(Xpos - 12, YPos + Texture'Crosshair6'.VSize * Scale);
			Canvas.DrawText(int(Dist), true);
		}
	}

	Canvas.Reset();
}

simulated function SavedMove GetFreeMove()
{
	local SavedMove s;

	if ( FreeMoves == None )
		return Spawn(class'SavedMove');
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}
}

auto state Flying
{
	function BeginState()
	{
		ServerUpdate = 0;
		GuidedRotation = Rotation;
		OldGuiderRotation = Rotation;
		Velocity = speed*vector(Rotation);
		Acceleration = vect(0,0,0);

		B227_Velocity = Velocity;
		B227_LastLocation = Location;
		B227_LastVelocity = Velocity;

		// NOTE: Role_AutonomousProxy doesn't allow calls to Tick on dedicated servers.
		//       Tick is used for forming actual timestamps and checking the guider.
		if ( (Level.NetMode != NM_Standalone) && (Role == ROLE_Authority) )
			RemoteRole = ROLE_SimulatedProxy;

		if (PlayerPawn(Instigator) != none)
			PlayerPawn(Instigator).bBehindView = false;
	}
}

simulated event PostNetBeginPlay()
{
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).bBehindView = false;
}

function bool B227_LostGuider()
{
	return
		Guider == none ||
		Guider.bDeleteMe ||
		Guider.Health <= 0 ||
		(PlayerPawn(Guider) != none && PlayerPawn(Guider).ViewTarget != self) ||
		Guider.IsInState('FeigningDeath');
}

simulated function B227_AdjustCurrentClientTimestamp(out float DeltaTime)
{
	local float Diff;
	local float Delta;

	if (B227_CurrentServerTimestamp == 0)
		return;

	Diff = B227_CurrentServerTimestamp - B227_CurrentTimestamp;

	if (Diff > 0)
		Delta = Diff;
	else if (Diff < -0.3)
		Delta = FMax(Diff, -DeltaTime / 2);
	else
		return;

	B227_CurrentServerTimestamp = 0;
	B227_CurrentTimestamp += Delta;
	DeltaTime += Delta;
}

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
	NetPriority=3.000000
}
