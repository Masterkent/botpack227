class UTC_Weapon expands Weapon
	abstract
	config(Botpack);

var(WeaponAI) bool bRecommendAltSplashDamage; //if true, bot preferentially tries to use splash damage
var bool bSpecialIcon;
var() Color NameColor;	// used when drawing name on HUD
var() class<LocalMessage> PickupMessageClass;

// 0 - no scaling (U227 behavior)
// 1 - scaling PlayerViewOffset.X by FOV angle
// 2 - scaling PlayerViewOffset by FOV angle (UT436 behavior)
var() globalconfig int B227_ViewOffsetMode;
var() globalconfig bool B227_bEnableMuzzleFlash;
var() config float B227_MuzzleFlashScale;

var vector B227_FireStartTrace, B227_FireEndTrace;

auto state Pickup
{
	function Touch( actor Other )
	{
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			SpawnCopy(Pawn(Other));
			if (PickupMessageClass == none)
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Other), PickupMessageClass, 0, none, none, self.Class);
			PlaySound (PickupSound);
			if ( Level.Game.Difficulty > 1 )
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
			if ( Pawn(Other).MoveTarget == self )
				Pawn(Other).MoveTimer = -1.0;
		}
	}
}

simulated event RenderOverlays(Canvas Canvas)
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;
	local float ScreenHeight;
	local float FovScale;
	local float CustomScale;

	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
	{
		if (PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV)
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
	}

	if (  (Level.NetMode == NM_Client) && bPlayerOwner && (Hand == 2) )
	{
		bHideWeapon = true;
		return;
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) &&
		B227_bEnableMuzzleFlash && B227_MuzzleFlashScale > 0 )
	{
		if (B227_ViewOffsetMode == 2)
			ScreenHeight = Canvas.SizeY; // It's hard to calculate the correct offset for this mode anyway, so the original method is preserved for it.
		else
			ScreenHeight = Canvas.SizeX * 3 / 4;

		FovScale = 1 / Tan(FClamp(PlayerOwner.FOVAngle, 1, 179) / 360 * Pi);
		CustomScale = FClamp(B227_MuzzleFlashScale, 0, 2);
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX/640.0 * FovScale * CustomScale;
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 )
		{
			if ( Hand == 0 )
				Canvas.SetPos(
					Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO) * FovScale,
					Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + ScreenHeight * (FlashY + FlashC) * FovScale);
			else
				Canvas.SetPos(
					Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (Hand * Default.FireOffset.Y * FlashO) * FovScale,
					Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + ScreenHeight * FlashY * FovScale);

			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation(Owner.Location + B227_CalcDrawOffset(Canvas));
	NewRot = Pawn(Owner).ViewRotation;
	NewRot.Roll = B227_ViewRotationRoll(Hand);

	setRotation(newRot);
	Canvas.DrawActor(self, false);
}

function bool HandlePickupQuery(Inventory Item)
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			OldAmmo = AmmoType.AmmoAmount;
			if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0) 
				&& (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
					WeaponSet(P);
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (UTC_Weapon(Item).PickupMessageClass == none)
			P.ClientMessage(Item.PickupMessage, 'Pickup');
		else
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, UTC_Weapon(Item).PickupMessageClass, 0, none, none, Item.Class);
		Item.PlaySound(Item.PickupSound);
		Item.SetRespawn();   
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function bool ClientFire(float Value)
{
	return true;
}

function bool ClientAltFire(float Value)
{
	return true;
}

simulated function ClientWeaponEvent(name EventType);

simulated function TweenToStill();

static function UTSF_TweenToStill(Weapon this)
{
	if (UTC_Weapon(this) != none)
		UTC_Weapon(this).TweenToStill();
}

function bool SplashJump();

static function bool UTSF_SplashJump(Weapon this)
{
	if (UTC_Weapon(this) != none)
		return UTC_Weapon(this).SplashJump();
	return false;
}

// Play sound only with Role == ROLE_Authority
function B227_PlaySound(
	sound Sound,
	optional ESoundSlot Slot,
	optional float Volume,
	optional bool bNoOverride,
	optional float Radius,
	optional float Pitch)
{
	class'UTC_Actor'.static.B227_PlaySound(self, Sound, Slot, Volume, bNoOverride, Radius, Pitch);
}


function TraceFire(float Accuracy)
{
	local vector HitLocation, HitNormal, X, Y, Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	B227_FireStartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, B227_FireStartTrace, 2.75*AimError, False, False);
	B227_FireEndTrace = B227_FireStartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
			   + Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	B227_FireEndTrace += (10000 * X);
	Other = PawnOwner.TraceShot(HitLocation, HitNormal, B227_FireEndTrace, B227_FireStartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
}

simulated function vector B227_PlayerViewOffset()
{
	return PlayerViewOffset;
}

simulated function vector B227_CalcDrawOffset(Canvas Canvas)
{
	local vector DrawOffset, WeaponBob;
	local Pawn PawnOwner;
	local vector ViewOffset;

	PawnOwner = Pawn(Owner);

	switch (B227_ViewOffsetMode)
	{
		case 1:
			ViewOffset = 0.01 * B227_PlayerViewOffset();
			ViewOffset.X *= FMin(1.0, 0.75 / (Tan(FClamp(PawnOwner.FOVAngle, 1, 179) / 360 * Pi) * Canvas.SizeY / Canvas.SizeX));
			break;
		case 2:
			ViewOffset = 0.9 / PawnOwner.FOVAngle * B227_PlayerViewOffset();
			break;
		default:
			ViewOffset = 0.01 * B227_PlayerViewOffset();
	}

	DrawOffset = ViewOffset >> PawnOwner.ViewRotation;
	DrawOffset += (PawnOwner.EyeHeight * vect(0,0,1));
	WeaponBob = BobDamping * PawnOwner.WalkBob;
	WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
	DrawOffset += WeaponBob;

	return DrawOffset;
}

simulated function int B227_ViewRotationRoll(int Hand)
{
	if (Hand == 0)
		return -2 * default.Rotation.Roll;
	return default.Rotation.Roll * Hand;
}

static function bool B227_AdjustTraceResult(
	LevelInfo Level,
	out vector StartTrace,
	out vector EndTrace,
	out Actor HitActor,
	out vector HitLocation,
	out vector HitNormal,
	out int MaxWarps,
	optional out vector Dir)
{
	local WarpZoneInfo HitWarpZone;
	local float MaxTraceDist;
	local rotator R;

	if (MaxWarps <= 0)
		return false;

	Dir = Normal(EndTrace - StartTrace);

	if (HitActor != none)
		HitWarpZone = WarpZoneInfo(Level.GetLocZone(HitLocation + HitNormal).Zone);
	else
	{
		HitWarpZone = WarpZoneInfo(Level.GetLocZone(EndTrace).Zone);
		HitLocation = EndTrace;
		HitNormal = -Dir;
	}

	if (HitWarpZone == none)
		return false;
	HitWarpZone.Generate();
	if (HitWarpZone.OtherSideActor == none)
		return false;

	MaxTraceDist = VSize(EndTrace - StartTrace);
	MaxTraceDist = FMax(0, MaxTraceDist - VSize(HitLocation - StartTrace));

	--MaxWarps;
	HitLocation = B227_WarpZoneHitLocation(HitWarpZone, HitLocation, Dir);
	StartTrace = HitLocation;
	HitWarpZone.UnWarp(StartTrace, Dir, R);
	HitWarpZone.OtherSideActor.Warp(StartTrace, Dir, R);
	EndTrace = StartTrace + Dir * MaxTraceDist;
	HitActor = none;

	return true;
}

static function Actor B227_TraceShot(
	Actor Tracer,
	vector StartTrace,
	vector EndTrace,
	out vector HitLocation,
	out vector HitNormal)
{
	local Actor HitActor;
	local int i;

	if (VSize(StartTrace - EndTrace) < 1)
		return none;

	HitActor = Tracer.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	while (
		Pawn(HitActor) != none && !Pawn(HitActor).AdjustHitLocation(HitLocation, EndTrace - StartTrace) ||
		HitActor == Tracer)
	{
		StartTrace = HitLocation;
		if (VSize(StartTrace - EndTrace) < 1 || ++i >= 128)
			return none;
		HitActor = HitActor.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	}
	if (HitActor == none)
		HitLocation = EndTrace;
	return HitActor;
}

static function B227_WarpedTraceFire(
	Actor Tracer,
	vector StartTrace,
	vector EndTrace,
	int MaxWarps,
	out Actor HitActor,
	out vector HitLocation,
	out vector HitNormal,
	out vector Dir)
{
	while (B227_AdjustTraceResult(Tracer.Level, StartTrace, EndTrace, HitActor, HitLocation, HitNormal, MaxWarps))
	{
		HitActor = B227_TraceShot(Tracer, StartTrace, EndTrace, HitLocation, HitNormal);
		Dir = Normal(EndTrace - StartTrace);
	}
}

// Auxiliary
static function vector B227_WarpZoneHitLocation(WarpZoneInfo WarpZone, vector HitLocation, vector Dir)
{
	local float Dist, NextDist, MaxDist;

	MaxDist = 400;
	while ((NextDist += 100) < MaxDist && WarpZone.Level.GetLocZone(HitLocation - Dir * NextDist).Zone == WarpZone)
		Dist = NextDist;
	MaxDist = FMin(MaxDist, NextDist);
	while (MaxDist - Dist > 1)
	{
		NextDist = (Dist + MaxDist) / 2;
		if (WarpZone.Level.GetLocZone(HitLocation - Dir * NextDist).Zone == WarpZone)
			Dist = NextDist;
		else
			MaxDist = NextDist;
	}
	return HitLocation - Dir * Dist;
}

defaultproperties
{
	B227_ViewOffsetMode=1
	B227_bEnableMuzzleFlash=True
	B227_MuzzleFlashScale=1.0
}
