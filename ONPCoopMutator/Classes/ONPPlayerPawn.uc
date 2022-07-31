class ONPPlayerPawn expands tvplayer;

var float FlightStartTime;
var Teleporter ReachedExit;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	RemoveClientDeathSounds();
}

event Touch(Actor A)
{
	local Teleporter Telep;

	super.Touch(A);

	Telep = Teleporter(A);
	if (ReachedExit == none && Telep != none && Telep.bEnabled && (InStr(Telep.URL, "/") > 0 || InStr(Telep.URL, "#") > 0))
		ReachedExit = Telep;
}

simulated function RemoveClientDeathSounds()
{
	local int i;
	if (Level.NetMode == NM_Client)
	{
		for (i = 0; i < ArrayCount(Deaths); ++i)
			Deaths[i] = none;
	}
}

function ViewNextPlayer()
{
	ViewClass(class'Pawn', true);
	while (ViewTarget != none
			&& (Pawn(ViewTarget).PlayerReplicationInfo == none || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator))
		ViewClass(class'Pawn', true);

	if (ViewTarget != None)
		ClientMessage(ViewingFrom $ Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
	else
		ClientMessage(ViewingFrom $ OwnCamera, 'Event', true);
}

function ship() {}

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, StartClimbing,
	FootZoneChange, HeadZoneChange, ZoneChange, NextItem, PrevItem, ActivateItem,
	Taunt, CallForHelp, SwitchWeapon, ThrowWeapon, Grab;

	function Fire(optional float F)
	{
		if (ReachedExit == none)
			super.Fire(F);
		else
			ViewNextPlayer();
	}
	
	function AltFire(optional float F)
	{
		if (ReachedExit == none)
			super.AltFire(F);
		else if (ViewTarget != none)
			ViewSelf();
		else
			ReachedExit.Touch(self);
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0;
		aStrafe  = 0;
		aLookup *= 0.24;
		aTurn   *= 0.24;
		aUp		 = 0;
	
		Acceleration = vect(0,0,0);  
		UpdateRotation(DeltaTime, 1);

		if (Role < ROLE_Authority)
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		SetMesh();
		if (UTC_PlayerReplicationInfo(PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(PlayerReplicationInfo).bWaitingPlayer = false;
		SetCollision(true,true,true);
		SetPropertyText("bIsAmbientCreature", "false");
	}

	function BeginState()
	{
		Mesh = None;
		if (UTC_PlayerReplicationInfo(PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(PlayerReplicationInfo).bWaitingPlayer = true;
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		SetPropertyText("bIsAmbientCreature", "true");
		Weapon = none;
	}
}

state PlayerWalking
{
	simulated function EndState()
	{
		super.EndState();
		PrePivot.Z = 0;
	}
}

state PlayerSpectating
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, StartClimbing,
	FootZoneChange, HeadZoneChange, ZoneChange, NextItem, PrevItem, ActivateItem,
	Taunt, CallForHelp, SwitchWeapon, ThrowWeapon, Grab;

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		if (UTC_PlayerReplicationInfo(PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(PlayerReplicationInfo).bWaitingPlayer = false;
		SetMesh();
		SetCollision(true,true,true);
		SetPropertyText("bIsAmbientCreature", "false");
	}

	function BeginState()
	{
		PlayerReplicationInfo.bIsSpectator = true;
		if (UTC_PlayerReplicationInfo(PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(PlayerReplicationInfo).bWaitingPlayer = true;
		Mesh = None;
		SetCollision(false,false,false);
		EyeHeight = Default.BaseEyeHeight;
		SetPhysics(PHYS_None);
		SetPropertyText("bIsAmbientCreature", "true");
	}
}

state PlayerShip
{
ignores SeePlayer, HearNoise;

	function BeginState()
	{
		local Effects E;

		EyeHeight = BaseEyeHeight;
		if (Shadow != none)
			Shadow.Destroy();
		Shadow = none;
		Health = Max(100, Health);
		SetPhysics(PHYS_Flying);
		Weapon = none;
		bCanFly = true;
		Mesh = mesh'shuttle';
		foreach ChildActors(class'Effects', E)
		{
			E.bHidden = true;
			E.DrawType = DT_None;
			E.SetTimer(0.0, false);
		}
		MultiSkins[0] = Texture(DynamicLoadObject("GenIn.gship1", class'Texture'));
		MultiSkins[1] = FireTexture(DynamicLoadObject("xfx.chinese", class'FireTexture'));
		AmbientSound = Sound'botpack.Redeemer.WarFly';
		bBehindView = true;
		SetCollisionSize(78, 32);
		OldVelocity = vect(0,0,0);
		bFlipped = false;
		SoundRadius = 100;
		SoundVolume = 255;
		CheckWall = false;
		Enable('HitWall');

		Mass = 1000;
		FlightStartTime = Level.TimeSeconds;

		if (Level.NetMode != NM_Client)
		{
			if (B227_PlayerShipEffects != none)
				B227_PlayerShipEffects.Destroy();
			B227_PlayerShipEffects = Spawn(class'B227_PlayerShipEffects', self);
		}
	}
	
	function EndState()
	{
		super.EndState();
		Mass = default.Mass;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)  
	{
		const InitialAccelerationTime = 0.5;
		local vector expected, x, y, z;
		local rotator newrot;
		local int oldroll;
		local float SmoothRoll;

		Weapon = None;
		if (PlayerMod == 1)
		{
			Velocity = vect(0,0,0);
			return;
		}
		if (OldVelocity != Velocity && OldVelocity != vect(0,0,0))
			Velocity = Oldvelocity;
		Acceleration = NewAccel;
		if (Level.TimeSeconds - FlightStartTime < InitialAccelerationTime)
			Acceleration = vector(ViewRotation);
		if (!CheckWall)
			Acceleration.Z = Min(0, Acceleration.Z);
		Acceleration = Normal(Acceleration);
		if (Role < ROLE_Authority)
			AirSpeed = RealSpeed;
		if (Level.TimeSeconds - FlightStartTime < InitialAccelerationTime || VSize(Velocity) == 0)
		{
			Velocity = Acceleration * AirSpeed;
			OldVelocity = Velocity;
		}
		else
			Velocity = normal(Velocity + Acceleration * 4000 * DeltaTime) * Airspeed;
		if (Level.NetMode!=nm_standalone)
			Deltatime *= 2;
		expected = Location + Velocity * DeltaTime;
		CheckWall = true;
		Move(Velocity * DeltaTime);
		if (CheckWall && expected != Location && Role == ROLE_Authority && !Region.Zone.IsA('WarpZoneInfo') && !bWarping)
		{
			HitWall(Location, none);
			return;
		}
		else if (!CheckWall && Velocity.Z == 0)
			Move(Normal(Velocity) * VSize(expected - Location));
		NewRot = Rotator(Velocity);
		Acceleration = vect(0,0,0);
		// Roll based on acceleration
		GetAxes(NewRot, X,Y,Z);
		//ripped from guided warhead:
		OldRoll = Rotation.Roll & 65535;
		NewRot.Roll = 10430 * aTan(AirSpeed * class'tvvehicle'.static.normalizeangle(NewRot.Yaw - Rotation.Yaw) / (-10430 * DeltaTime * Region.Zone.ZoneGravity.Z));

		//smoothly change rotation
		if (NewRot.Roll > 32768)
		{
			if (OldRoll < 32768)
				OldRoll += 65536;
		}
		else if (OldRoll > 32768)
			OldRoll -= 65536;
		SmoothRoll = FMin(1.2, 6.0 * deltaTime);
		NewRot.Roll= (NewRot.Roll * SmoothRoll + OldRoll * (1 - SmoothRoll)) * Abs(Cos(NewRot.Pitch/10430));  //cos is a hack because of gimble lock
		SetRotation(NewRot);
		OldVelocity = Velocity;
	}

	function Bump(Actor A)
	{
		local int HitDamage;
		local vector HitMomentum;

		if (!A.bIsPawn && !A.IsA('Decoration'))
			return;
		HitDamage = Mass * VSize(Velocity) / 1000;
		HitMomentum = Velocity * Mass;
		A.TakeDamage(HitDamage, self, A.Location, HitMomentum, 'Crushed');

		Died(self, 'Crushed', Location);
	}
	function HitWall(vector HitLocation, Actor A)
	{
		Died(self, 'Crushed', HitLocation);
	}
}

defaultproperties
{
	BreathAgain=Sound'BotPack.MaleSounds.gasp02'
	Deaths(0)=Sound'BotPack.MaleSounds.deathc1'
	Deaths(1)=Sound'BotPack.MaleSounds.deathc51'
	Deaths(2)=Sound'BotPack.MaleSounds.deathc3'
	Deaths(3)=Sound'BotPack.MaleSounds.deathc4'
	Deaths(4)=Sound'BotPack.MaleSounds.deathc53'
	Deaths(5)=Sound'BotPack.MaleSounds.deathc53'
	Die=Sound'BotPack.MaleSounds.deathc1'
	Drown=Sound'BotPack.MaleSounds.drownM02'
	FootStep1=Sound'BotPack.FemaleSounds.stone02';
	FootStep2=Sound'BotPack.FemaleSounds.stone04';
	FootStep3=Sound'BotPack.FemaleSounds.stone05';
	GaspSound=Sound'BotPack.MaleSounds.hgasp1';
	HitSound1=Sound'BotPack.MaleSounds.injurL2';
	HitSound2=Sound'BotPack.MaleSounds.injurL04';
	HitSound3=Sound'BotPack.MaleSounds.injurM04';
	HitSound4=Sound'BotPack.MaleSounds.injurH5';
	JumpSound=Sound'BotPack.MaleSounds.jump1';
	JumpSounds(0)=Sound'BotPack.MaleSounds.jump1';
	JumpSounds(1)=Sound'BotPack.MaleSounds.jump1';
	JumpSounds(2)=Sound'BotPack.MaleSounds.jump1';
	Land=Sound'UnrealShare.Generic.Land1';
	LandGrunt=Sound'BotPack.MaleSounds.land01';
	UWHit1=Sound'BotPack.MaleSounds.UWinjur41';
	UWHit2=Sound'BotPack.MaleSounds.UWinjur42';
	WaterStep=Sound'UnrealShare.Generic.LSplash';
}
