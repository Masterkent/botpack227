//=============================================================================
// starterbolt.
//=============================================================================
class StarterBolt extends PBolt;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float OldError, NewError, StartError, AimError; //used for bot aiming
var rotator AimRotation;
var float AnimTime;

var vector B227_Location;
var int B227_Pitch, B227_Yaw, B227_Roll;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		AimError, NewError, AimRotation;

	reliable if (Role == ROLE_Authority)
		B227_Location, B227_Pitch, B227_Yaw, B227_Roll;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( instigator == None )
		return;
	if ( Instigator.IsA('Bot') && Bot(Instigator).bNovice )
		aimerror = 2200 + (3 - instigator.skill) * 300;
	else
		aimerror = 1000 + (3 - instigator.skill) * 400;

	if ( FRand() < 0.5 )
		aimerror *= -1;
}

simulated event Tick(float DeltaTime)
{
	B227_BoltTick(
		self,
		DeltaTime,
		OldError,
		NewError,
		StartError,
		AimError,
		AimRotation,
		AnimTime,
		B227_Location,
		B227_Rotation(),
		class'PulseGun'.default.B227_bAdjustNPCAccuracy);
}

// Auxiliary

// May be used in modified starter bolt classes that are not derived from this class
static function B227_BoltTick(
	PBolt Proj,
	float DeltaTime,
	out float OldError,
	out float NewError,
	out float StartError,
	float AimError,
	out rotator AimRotation,
	out float AnimTime,
	vector NewLocation,
	rotator NewRotation,
	bool bAdjustNPCAccuracy)
{
	local vector X, Y, Z, DrawOffset;

	AnimTime += DeltaTime;
	if ( AnimTime > 0.05 )
	{
		AnimTime -= 0.05;
		Proj.SpriteFrame++;
		if ( Proj.SpriteFrame == ArrayCount(Proj.SpriteAnim) )
			Proj.SpriteFrame = 0;
		Proj.Skin = Proj.SpriteAnim[Proj.SpriteFrame];
	}

	// orient with respect to instigator
	if (!Proj.B227_bGuidedByWeapon && Proj.Instigator != none)
	{
		if (Proj.Level.NetMode == NM_Client &&
			(PlayerPawn(Proj.Instigator) == none || PlayerPawn(Proj.Instigator).Player == none))
		{
			Proj.SetRotation(AimRotation); 
			Proj.Instigator.ViewRotation = AimRotation;
			DrawOffset = ((0.01 * class'PulseGun'.Default.PlayerViewOffset) >> Proj.Rotation);
			DrawOffset += (Proj.Instigator.EyeHeight * vect(0,0,1));
		}
		else 
		{
			if (PlayerPawn(Proj.Instigator) == none)
				B227_SetInstigatorRotation(
					Proj,
					DeltaTime,
					OldError,
					NewError,
					StartError,
					AimError,
					AimRotation,
					bAdjustNPCAccuracy);
			else
			{
				AimRotation = Proj.Instigator.ViewRotation;
				Proj.SetRotation(AimRotation);
			}
			DrawOffset = Proj.Instigator.Weapon.CalcDrawOffset();
		}
		GetAxes(Proj.Instigator.ViewRotation,X,Y,Z);

		if (Proj.bCenter)
		{
			Proj.FireOffset.Z = Proj.default.FireOffset.Z * 1.5;
			Proj.FireOffset.Y = 0;
		}
		else 
		{
			Proj.FireOffset.Z = Proj.default.FireOffset.Z;
			if (Proj.bRight)
				Proj.FireOffset.Y = Proj.default.FireOffset.Y;
			else
				Proj.FireOffset.Y = -1 * Proj.default.FireOffset.Y;
		}
		Proj.SetLocation(Proj.Instigator.Location + DrawOffset + Proj.FireOffset.X * X + Proj.FireOffset.Y * Y + Proj.FireOffset.Z * Z);
	}
	else if (Proj.B227_bGuidedByWeapon)
	{
		if (Proj.Level.NetMode == NM_Client)
		{
			if (Proj.Instigator != none && PulseGun(Proj.Instigator.Weapon) != none && Proj.Instigator.Weapon.bNetOwner)
				PulseGun(Proj.Instigator.Weapon).B227_GuidePlasmaBeam(Proj);
			else
			{
				Proj.SetLocation(NewLocation);
				Proj.SetRotation(NewRotation);
			}
		}
		else if (Proj.Instigator != none && PulseGun(Proj.Instigator.Weapon) != none)
		{
			PulseGun(Proj.Instigator.Weapon).B227_GuidePlasmaBeam(Proj);
			if (PlayerPawn(Proj.Instigator) == none)
				B227_SetInstigatorRotation(
					Proj,
					DeltaTime,
					OldError,
					NewError,
					StartError,
					AimError,
					AimRotation,
					bAdjustNPCAccuracy);
		}

		GetAxes(Proj.Rotation, X, Y, Z);
	}
	else
		GetAxes(Proj.Rotation, X, Y, Z);

	if (Proj.Level.NetMode != NM_DedicatedServer &&
		class'PulseGun'.static.B227_ShouldModifyPlasmaLighting())
	{
		Proj.LightEffect = LE_None;
		Proj.LightBrightness = Proj.default.LightBrightness / 5;
		Proj.LightRadius = Clamp(FMax(15, Proj.default.LightRadius) * FMin(2, Sqrt(Proj.B227_DamageMult)), 15, 255);
	}
	Proj.CheckBeam(X, DeltaTime);
}

static function B227_SetInstigatorRotation(
	PBolt Proj,
	float DeltaTime,
	out float OldError,
	out float NewError,
	out float StartError,
	float AimError,
	out rotator AimRotation,
	bool bAdjustNPCAccuracy)
{
	local Bot MyBot;
	local vector AimSpot, AimStart, X, Y, Z;
	local float dAdjust;
	local int YawErr;

	if ( Proj.Instigator.Target == None )
		Proj.Instigator.Target = Proj.Instigator.Enemy;
	if ( Proj.Instigator.Target != none && Proj.Instigator.Target == Proj.Instigator.Enemy )
	{
		MyBot = Bot(Proj.Instigator);
		if (MyBot != none && MyBot.bNovice)
			dAdjust = DeltaTime * (4 + Proj.Instigator.Skill) * 0.075;
		else
			dAdjust = DeltaTime * (4 + Proj.Instigator.Skill) * 0.12;
		if ( OldError > NewError )
			OldError = FMax(OldError - dAdjust, NewError);
		else
			OldError = FMin(OldError + dAdjust, NewError);

		if ( OldError == NewError )
			NewError = FRand() - 0.5;
		if ( StartError > 0 )
			StartError -= DeltaTime;
		else if (MyBot != none && MyBot.bNovice && (Proj.Level.TimeSeconds - MyBot.LastPainTime < 0.2))
			StartError = MyBot.LastPainTime;
		else if (bAdjustNPCAccuracy &&
			Bots(Proj.Instigator) != none &&
			Bots(Proj.Instigator).Skill < 2 &&
			Proj.Level.TimeSeconds - Bots(Proj.Instigator).LastPainTime < 0.2)
		{
			StartError = Bots(Proj.Instigator).LastPainTime;
		}
		else if (bAdjustNPCAccuracy &&
			ScriptedPawn(Proj.Instigator) != none &&
			ScriptedPawn(Proj.Instigator).Skill < 2 &&
			Proj.Level.TimeSeconds - ScriptedPawn(Proj.Instigator).LastPainTime < 0.2)
		{
			StartError = ScriptedPawn(Proj.Instigator).LastPainTime;
		}
		else
			StartError = 0;
		AimSpot = 1.25 * Proj.Instigator.Target.Velocity + 0.75 * Proj.Instigator.Velocity;
		if ( Abs(AimSpot.Z) < 120 )
			AimSpot.Z *= 0.25;
		else
			AimSpot.Z *= 0.5;
		if ( Proj.Instigator.Target.Physics == PHYS_Falling )
			AimSpot = Proj.Instigator.Target.Location - 0.0007 * AimError * OldError * AimSpot;
		else
			AimSpot = Proj.Instigator.Target.Location - 0.0005 * AimError * OldError * AimSpot;
		if ( (Proj.Instigator.Physics == PHYS_Falling) && (Proj.Instigator.Velocity.Z > 0) )
			AimSpot = AimSpot - 0.0003 * AimError * OldError * AimSpot;

		/// Was: AimStart = Instigator.Location + FireOffset.X * X + FireOffset.Y * Y + (1.2 * FireOffset.Z - 2) * Z;
		///      [where X, Y, Z are null vectors]
		AimStart = Proj.Instigator.Location;
		if (MyBot == none)
		{
			GetAxes(Proj.Instigator.ViewRotation, X, Y, Z);
			AimStart += Proj.FireOffset.X * X + Proj.FireOffset.Y * Y + Proj.FireOffset.Z * Z;
		}

		if ( Proj.FastTrace(AimSpot - vect(0,0,10), AimStart) )
			AimSpot	= AimSpot - vect(0,0,10);
		///GetAxes(Instigator.Rotation,X,Y,Z); // had no effect (X, Y, Z were overridden by subsequent call to GetAxes)
		AimRotation = Rotator(AimSpot - AimStart);
		AimRotation.Yaw = AimRotation.Yaw + (OldError + StartError) * 0.75 * aimerror;
		YawErr = (AimRotation.Yaw - (Proj.Instigator.Rotation.Yaw & 65535)) & 65535;
		if ( (YawErr > 3000) && (YawErr < 62535) )
		{
			if ( YawErr < 32768 )
				AimRotation.Yaw = Proj.Instigator.Rotation.Yaw + 3000;
			else
				AimRotation.Yaw = Proj.Instigator.Rotation.Yaw - 3000;
		}
	}
	else if ( Proj.Instigator.Target != None )
		AimRotation = Rotator(Proj.Instigator.Target.Location - Proj.Instigator.Location);
	else
		AimRotation = Proj.Instigator.ViewRotation;
	Proj.Instigator.ViewRotation = AimRotation;
	Proj.SetRotation(AimRotation);
}

simulated function rotator B227_Rotation()
{
	return B227_Pitch * rot(1, 0, 0) + B227_Yaw * rot(0, 1, 0) + B227_Roll * rot(0, 0, 1);
}

function B227_SetBeamRepMovement(vector Pos, rotator Dir)
{
	B227_Location = Pos;
	B227_Pitch = Dir.Pitch;
	B227_Yaw = Dir.Yaw;
	B227_Roll = Dir.Roll;
}

defaultproperties
{
	StartError=0.500000
	SpriteAnim(0)=Texture'Botpack.Skins.sbolt0'
	SpriteAnim(1)=Texture'Botpack.Skins.sbolt1'
	SpriteAnim(2)=Texture'Botpack.Skins.sbolt2'
	SpriteAnim(3)=Texture'Botpack.Skins.sbolt3'
	SpriteAnim(4)=Texture'Botpack.Skins.sbolt4'
	RemoteRole=ROLE_SimulatedProxy
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=83
	LightSaturation=50
	LightRadius=5
	bAlwaysRelevant=True
}
