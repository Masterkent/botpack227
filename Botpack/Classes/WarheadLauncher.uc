//=============================================================================
// WarHeadLauncher
//=============================================================================
class WarHeadLauncher extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var GuidedWarShell GuidedShell;
var int Scroll;
var PlayerPawn GuidingPawn;
var bool	bGuiding, bCanFire, bShowStatic;
var rotator StartRotation;

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && (Role==ROLE_Authority) )
		bGuiding, bShowStatic;
}

function SetWeaponStay()
{
	bWeaponStay = false; // redeemer never stays
}

simulated function PostRender( canvas Canvas )
{
	local int i, numReadouts, OldClipX, OldClipY;
	local float XScale;

	bOwnsCrossHair = ( bGuiding || bShowStatic );

	if ( !bGuiding )
	{
		if ( !bShowStatic )
			return;

		Canvas.Reset();
		Canvas.SetPos( 0, 0);
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'Botpack.LadrStatic.Static.Static_a00', FMax(Canvas.ClipX, Canvas.ClipY)/256.0);
		return;
	}

	Canvas.Reset();

	if (GuidedShell != none && !GuidedShell.bDeleteMe)
		GuidedShell.PostRender(Canvas);

	OldClipX = Canvas.ClipX;
	OldClipY = Canvas.ClipY;
	XScale = FMax(0.5, class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 640.0));
	Canvas.SetPos( 0.5 * OldClipX - 128 * XScale, 0.5 * OldClipY - 128 * XScale );
	if ( Level.bHighDetailMode )
		Canvas.Style = ERenderStyle.STY_Translucent;
	else
		Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawIcon(Texture'GuidedX', XScale);

	numReadouts = OldClipY/128 + 2;
	for ( i = 0; i < numReadouts; i++ )
	{
		Canvas.SetPos(1,Scroll + i * 128);
		Scroll--;
		if ( Scroll < -128 )
			Scroll = 0;
		Canvas.DrawIcon(Texture'Readout', FMax(1, XScale));
	}

	Canvas.Reset();
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P, E;
	local Bot O;

	O = Bot(Owner);
	if ( (O == None) || (AmmoType.AmmoAmount <=0) || (O.Enemy == None) )
		return -2;

	bUseAltMode = 0;
	E = O.Enemy;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.PlayerReplicationInfo != none && (P != O) && (P != E)
			&& (!Level.Game.bTeamGame || (O.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team))
			&& (VSize(E.Location - P.Location) < 650)
			&& (!Level.Game.IsA('TeamGamePlus') || TeamGamePlus(Level.Game).PriorityObjective(O) < 2)
			&& FastTrace(P.Location, E.Location) )
		{
			if ( VSize(E.Location - O.Location) > 500 )
				return 2.0;
			else
				return 1.0;
		}

	return 0.35;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return -1.0;
}

function PlayFiring()
{
	PlayAnim( 'Fire', 0.3 );
	PlaySound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
}

function setHand(float Hand)
{
	B227_SetHandedness(Hand);

	if ( Hand == 2 )
	{
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;

	PlayerViewOffset.Y = Default.PlayerViewOffset.Y;
	PlayerViewOffset.X = Default.PlayerViewOffset.X;
	PlayerViewOffset.Z = Default.PlayerViewOffset.Z;

	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

function AltFire( float Value )
{
	if ( !Owner.IsA('PlayerPawn') )
	{
		Fire(Value);
		return;
	}

	if (AmmoType.UseAmmo(1))
	{
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		PlayFiring();
		GuidedShell = GuidedWarShell(ProjectileFire(AltProjectileClass, ProjectileSpeed, bWarnTarget));
		if (GuidedShell != none)
		{
			GuidedShell.SetOwner(Owner);
			PlayerPawn(Owner).ViewTarget = GuidedShell;
			GuidedShell.Guider = PlayerPawn(Owner);
			if (Pawn(Owner).Weapon == self)
				GuidedShell.B227_GuiderWeaponClass = Class;
			ClientAltFire(0);
			GotoState('Guiding');
		}
		else
			ClientAltFire(0);
	}
}

function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		if ( Affector != None )
			Affector.FireEffect();
		// B227: FireSound is already played in PlayFiring;
		// unlike UT, B227 ensures that PlayFiring is called on network clients,
		// hence an extra call to PlaySound is not needed.
		//-PlaySound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
		return true;
	}
	return false;
}

State Guiding
{
	function Fire ( float Value )
	{
		if ( !bCanFire )
			return;
		if ( GuidedShell != None && !GuidedShell.bDeleteMe )
			GuidedShell.Explode(GuidedShell.Location,Vect(0,0,1));
		bCanClientFire = true;

		GotoState('Finishing');
	}

	function AltFire ( float Value )
	{
		Fire(Value);
	}

	function BeginState()
	{
		Scroll = 0;
		bGuiding = true;
		bCanFire = false;
		if ( Owner.IsA('PlayerPawn') )
		{
			GuidingPawn = PlayerPawn(Owner);
			StartRotation = PlayerPawn(Owner).ViewRotation;
			PlayerPawn(Owner).ClientAdjustGlow(-0.2,vect(200,0,0));
		}
	}

	function EndState()
	{
		bGuiding = false;
		if ( GuidingPawn != None )
		{
			GuidingPawn.ClientAdjustGlow(0.2,vect(-200,0,0));
			GuidingPawn.ClientSetRotation(StartRotation);
			GuidingPawn = None;
		}
	}


Begin:
	Sleep(1.0);
	bCanFire = true;
}

State Finishing
{
	ignores Fire, AltFire;

	event BeginState()
	{
		bShowStatic = true;
	}

	event EndState()
	{
		bShowStatic = false; // important if the weapon was tossed out
	}

Begin:
	Sleep(0.3);
	bShowStatic = false;
	Sleep(1.0);
	GotoState('Idle');
}

defaultproperties
{
	WeaponDescription="Classification: Thermonuclear Device\n\nPrimary Fire: Launches a huge yet slow moving missile that, upon striking a solid surface, will explode and send out a gigantic shock wave, instantly pulverizing anyone or anything within its colossal radius, including yourself.\n\nSecondary Fire: Take control of the missile and fly it anywhere.  You can press the primary fire button to explode the missile early.\n\nTechniques: Remember that while this rocket is being piloted you are a sitting duck.  If an opponent manages to hit your incoming Redeemer missile while it's in the air, the missile will explode harmlessly."
	InstFlash=-0.400000
	InstFog=(X=950.000000,Y=650.000000,Z=290.000000)
	AmmoName=Class'Botpack.WarHeadAmmo'
	ReloadCount=1
	PickupAmmoCount=1
	bWarnTarget=True
	bAltWarnTarget=True
	bSplashDamage=True
	bSpecialIcon=True
	FiringSpeed=1.000000
	FireOffset=(X=18.000000,Z=-10.000000)
	ProjectileClass=Class'Botpack.WarShell'
	AltProjectileClass=Class'Botpack.GuidedWarshell'
	shakemag=350.000000
	shaketime=0.200000
	shakevert=7.500000
	AIRating=1.000000
	RefireRate=0.250000
	AltRefireRate=0.250000
	FireSound=Sound'Botpack.Redeemer.WarheadShot'
	SelectSound=Sound'Botpack.Redeemer.WarheadPickup'
	DeathMessage="%o was vaporized by %k's %w!!"
	NameColor=(G=128,B=128)
	AutoSwitchPriority=10
	InventoryGroup=10
	PickupMessage="You got the Redeemer."
	ItemName="Redeemer"
	RespawnTime=60.000000
	PlayerViewOffset=(X=1.800000,Y=1.000000,Z=-1.890000)
	PlayerViewMesh=LodMesh'Botpack.WarHead'
	BobDamping=0.975000
	PickupViewMesh=LodMesh'Botpack.WHPick'
	ThirdPersonMesh=LodMesh'Botpack.WHHand'
	StatusIcon=Texture'Botpack.Icons.UseWarH'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseWarH'
	Mesh=LodMesh'Botpack.WHPick'
	bNoSmooth=False
	CollisionRadius=45.000000
	CollisionHeight=23.000000
}
