//=============================================================================
// PKEightball.
//=============================================================================
class PKEightball extends TournamentWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var name LoadAnim[6], RotateAnim[6], FireAnim[6];
var int RocketsLoaded, ClientRocketsLoaded;
var bool bFireLoad,bTightWad, bInstantRocket, bAlwaysInstant, bClientDone, bRotated, bPendingLock;
var Actor LockedTarget, NewTarget, OldTarget;

Replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		bInstantRocket;
}

function setHand(float Hand)
{
	Super.SetHand(Hand);

	if ( Hand == 0 )
		PlayerViewOffset.Y = 0;
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("Botpack.EightML", class'Mesh'));
	else
		Mesh = mesh'EightM';
}

function BecomeItem()
{
	local TournamentPlayer TP;

	Super.BecomeItem();
	TP = TournamentPlayer(Instigator);
	bInstantRocket = bAlwaysInstant || ( (TP != None) && TP.bInstantRocket );
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	if ( AmmoType != None )
		Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 2, 10, Temp, Font'LEDFont2', C );
}

simulated event RenderOverlays( canvas Canvas )
{
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;
}

simulated function PostRender( canvas Canvas )
{
	local float Scale;

	Super.PostRender(Canvas);
	bOwnsCrossHair = bLockedOn;
	if ( bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		Scale = FMax(1.0, class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 640.0));
		Canvas.SetPos(0.5 * (Canvas.ClipX - Texture'Crosshair6'.USize * Scale), 0.5 * (Canvas.ClipY - Texture'Crosshair6'.VSize * Scale));
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'Crosshair6', Scale);
		Canvas.Style = 1;
	}
}

function PlayLoading(float rate, int num)
{
	if ( Owner == None )
		return;
	Owner.PlaySound(sound'PKloading',, 1,,, Level.TimeDilation);
	PlayAnim(LoadAnim[num],, 0.05);
}

function PlayRotating(int num)
{
	Owner.PlaySound(sound'PKbarrelmove',, 1,,, Level.TimeDilation);
	PlayAnim(RotateAnim[num],, 0.05);
}

function PlayRFiring(int num)
{
	if ( Owner.IsA('PlayerPawn') )
	{
		PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag*RocketsLoaded, ShakeVert); //shake player view
		PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
	}
	if ( Affector != None )
		Affector.FireEffect();
	if ( bFireLoad )
                {
		PlaySound(class'PKRocketMk2'.Default.SpawnSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.2*FRand());
                }
	else
	                PlaySound(sound'PKgrenade',SLOT_None,,,, Level.TimeDilation-0.2*FRand());
	if ( bFireLoad && bInstantRocket )
		PlayAnim(FireAnim[num], 0.54, 0.05);
	else
		PlayAnim(FireAnim[num], 0.6, 0.05);
}

function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if (AnimSequence == LoadAnim[0] )
		PlayAnim('Idle',0.1,0.0);
	else
		TweenAnim('Idle', 0.5);
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, Rating;
	local bool bRetreating;
	local vector EnemyDir;
	local Pawn P;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	P = Pawn(Owner);
	if ( P.Enemy == None )
		return AIRating;

	if ( (P.Base != None) && (P.Base.Velocity != vect(0,0,0))
		&& !P.CheckFutureSight(0.1) )
		return 0.1;

	EnemyDir = P.Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	Rating = AIRating;
	if ( EnemyDist < 360 )
	{
		if ( P.Weapon == self )
		{
			if ( (EnemyDist > 230) || ((P.Health < 50) && (P.Health < P.Enemy.Health - 30)) )
				return Rating;
		}
		return 0.05 + EnemyDist * 0.001;
	}
	if ( P.Enemy.IsA('StationaryPawn') )
		Rating += 0.4;
	if ( Owner.Location.Z > P.Enemy.Location.Z + 120 )
		Rating += 0.25;
	else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
		Rating -= 0.35;
	else if ( P.Enemy.Location.Z > Owner.Location.Z + 80 )
		Rating -= 0.05;
	if ( (Owner.Physics == PHYS_Falling) || Owner.Region.Zone.bWaterZone )
		bUseAltMode = 0;
	else if ( EnemyDist < -1.5 * EnemyDir.Z )
		bUseAltMode = int( FRand() < 0.5 );
	else
	{
		bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
		bUseAltMode = 0;
		if ( bRetreating && (EnemyDist < 800) && (FRand() < 0.4) )
			bUseAltMode = 1;
	}
	return Rating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 600 )
	{
		if ( EnemyDist < 300 )
			return -1.5;
		else
			return -0.7;
	}
	else
		return -0.2;
}

function Fire( float Value )
{
	local TournamentPlayer TP;

	bPointing=True;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		TP = TournamentPlayer(Instigator);
		bCanClientFire = true;
		bInstantRocket = bAlwaysInstant || ( (TP != None) && TP.bInstantRocket );
		if ( bInstantRocket )
		{
			bFireLoad = True;
			RocketsLoaded = 1;
			GotoState('');
			GotoState('FireRockets', 'Begin');
		}
		else if ( Instigator.IsA('Bot') )
		{
			if ( LockedTarget != None )
			{
				bFireLoad = True;
				RocketsLoaded = 1;
				Instigator.bFire = 0;
				bPendingLock = true;
				GotoState('');
				GotoState('FireRockets', 'Begin');
				return;
			}
			else if ( (NewTarget != None) && !NewTarget.IsA('StationaryPawn')
				&& (FRand() < 0.8)
				&& (VSize(Instigator.Location - NewTarget.Location) > 400 + 400 * (1.25 - TimerCounter) + 1300 * FRand()) )
			{
				Instigator.bFire = 0;
				bPendingLock = true;
				GotoState('Idle','PendingLock');
				return;
			}
			else if ( !Bot(Owner).bNovice
					&& (FRand() < 0.7)
					&& IsInState('Idle') && (Instigator.Enemy != None)
					&& ((Instigator.Enemy == Instigator.Target) || (Instigator.Target == None))
					&& !Instigator.Enemy.IsA('StationaryPawn')
					&& (VSize(Instigator.Location - Instigator.Enemy.Location) > 700 + 1300 * FRand())
					&& (VSize(Instigator.Location - Instigator.Enemy.Location) < 2000) )
			{
				NewTarget = CheckTarget();
				OldTarget = NewTarget;
				if ( NewTarget == Instigator.Enemy )
				{
					if ( TimerCounter > 0.6 )
						SetTimer(1.0, true);
					Instigator.bFire = 0;
					bPendingLock = true;
					GotoState('Idle','PendingLock');
					return;
				}
			}
			bPendingLock = false;
			GotoState('NormalFire');
		}
		else
			GotoState('NormalFire');
	}
}

function bool ClientFire( float Value )
{
	return false;
}

function FiringRockets()
{
	PlayRFiring(ClientRocketsLoaded - 1);
	bClientDone = true;
	Disable('Tick');
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
		GoToState('AltFiring');
}

function bool ClientAltFire( float Value )
{
	return false;
}

function Actor CheckTarget()
{
	local Actor ETarget;
	local Vector Start, X,Y,Z;
	local float bestDist, bestAim;
	local Pawn PawnOwner;
	local rotator AimRot;
	local int diff;

	PawnOwner = Pawn(Owner);
	bPointing = false;
	if ( Owner.IsA('PlayerPawn') )
	{
		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		bestAim = 0.93;
		ETarget = PawnOwner.PickTarget(bestAim, bestDist, X, Start);
	}
	else if ( PawnOwner.Enemy == None )
		return None;
	else if ( Owner.IsA('Bot') && Bot(Owner).bNovice )
		return None;
	else if ( VSize(PawnOwner.Enemy.Location - PawnOwner.Location) < 2000 )
	{
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Z * vect(0,0,1);
		AimRot = rotator(PawnOwner.Enemy.Location - Start);
		diff = abs((AimRot.Yaw & 65535) - (PawnOwner.Rotation.Yaw & 65535));
		if ( (diff > 7200) && (diff < 58335) )
			return None;
		// check if can hold lock
		if ( !bPendingLock ) //not already locked
		{
			AimRot = rotator(PawnOwner.Enemy.Location + (3 - PawnOwner.Skill) * 0.3 * PawnOwner.Enemy.Velocity - Start);
			diff = abs((AimRot.Yaw & 65535) - (PawnOwner.Rotation.Yaw & 65535));
			if ( (diff > 16000) && (diff < 49535) )
				return None;
		}

		// check line of sight
		ETarget = Trace(X,Y, PawnOwner.Enemy.Location, Start, false);
		if ( ETarget != None )
			return None;

		return PawnOwner.Enemy;
	}
	bPointing = (ETarget != None);
	Return ETarget;
}

//////////////////////////////////////////////////////
state AltFiring
{
	function Tick( float DeltaTime )
	{
		if( (pawn(Owner).bAltFire==0) || (RocketsLoaded > 5) )  // If if Fire button down, load up another
 			GoToState('FireRockets');
	}


	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);
			if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
				Pawn(Owner).bAltFire = 0;
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);
			RotateRocket();
		}
	}

	function RotateRocket()
	{
		if (AmmoType.AmmoAmount<=0)
		{
			GotoState('FireRockets');
			return;
		}
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}

	function BeginState()
	{
		Super.BeginState();
		RocketsLoaded = 1;
		bFireLoad = False;
		RotateRocket();
	}

Begin:
	bLockedOn = False;
}

///////////////////////////////////////////////////////
state NormalFire
{
	function bool SplashJump()
	{
		return true;
	}

	function Tick( float DeltaTime )
	{
		if ( (PlayerPawn(Owner) == None)
			&& ((Pawn(Owner).MoveTarget != Pawn(Owner).Target)
				|| (LockedTarget != None)
				|| (Pawn(Owner).Enemy == None)
				|| ( Mover(Owner.Base) != None )
				|| ((Owner.Physics == PHYS_Falling) && (Owner.Velocity.Z < 5))
				|| (VSize(Owner.Location - Pawn(Owner).Target.Location) < 400)
				|| !Pawn(Owner).CheckFutureSight(0.15)) )
			Pawn(Owner).bFire = 0;

		if( pawn(Owner).bFire==0 || RocketsLoaded > 5)  // If Fire button down, load up another
 			GoToState('FireRockets');
	}

	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);
			if (pawn(Owner).bAltFire!=0) bTightWad=True;
			NewTarget = CheckTarget();
			if ( Pawn(NewTarget) != None )
				Pawn(NewTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));
			if ( LockedTarget != None )
			{
				If ( NewTarget != LockedTarget )
				{
					LockedTarget = None;
					Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening,,,Level.TimeDilation-0.1);
					bLockedOn=False;
				}
				else if (LockedTarget != None)
 					Owner.PlaySound(Misc1Sound, SLOT_None, Pawn(Owner).SoundDampening,,,Level.TimeDilation-0.1);
			}
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);
			RotateRocket();
		}
	}

	function BeginState()
	{
		Super.BeginState();
		bFireLoad = True;
		RocketsLoaded = 1;
		RotateRocket();
	}

	function RotateRocket()
	{
		if ( PlayerPawn(Owner) == None )
		{
			if ( FRand() > 0.33 )
				Pawn(Owner).bFire = 0;
			if ( Pawn(Owner).bFire == 0 )
			{
	 			GoToState('FireRockets');
				return;
			}
		}
		if ( AmmoType.AmmoAmount <= 0 )
		{
			GotoState('FireRockets');
			return;
		}
		if ( AmmoType.AmmoAmount == 1 )
			Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}

Begin:
	Sleep(0.0);
}

///////////////////////////////////////////////////////
state Idle
{
	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None)
			{
				bLockedOn=True;
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));
				if ( bPendingLock )
				{
					OldTarget = NewTarget;
					Pawn(Owner).bFire = 0;
					bFireLoad = True;
					RocketsLoaded = 1;
					GotoState('FireRockets', 'Begin');
					return;
				}
			}
		}
		else if( (OldTarget != None) && (NewTarget == None) )
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
			bLockedOn = False;
		}
		else
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
		bPendingLock = false;
	}

Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	bPointing=False;
	if (AmmoType.AmmoAmount<=0)
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	PlayIdleAnim();
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
PendingLock:
	if ( bPendingLock )
		bPointing = true;
	if ( TimerRate <= 0 )
		SetTimer(1.0, true);
}


///////////////////////////////////////////////////////
state FireRockets
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function bool SplashJump()
	{
		return false;
	}

	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot, RandRot;
		local PKrocketmk2 r;
		local PKSeekingRocket s;
		local PKgrenade g;
		local float Angle, RocketRad;
		local pawn BestTarget, PawnOwner;
		local PlayerPawn PlayerOwner;
		local int DupRockets;
		local bool bMultiRockets;

		PawnOwner = Pawn(Owner);
		if ( PawnOwner == None )
			return;
		PawnOwner.PlayRecoil(FiringSpeed);
		PlayerOwner = PlayerPawn(Owner);
		Angle = 0;
		DupRockets = RocketsLoaded - 1;
		if (DupRockets < 0) DupRockets = 0;
		if ( PlayerOwner == None )
			bTightWad = ( FRand() * 4 < PawnOwner.skill );

		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

		if ( bFireLoad )
			AdjustedAim = PawnOwner.AdjustAim(ProjectileSpeed, StartLoc, AimError, True, bWarnTarget);
		else
			AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);

		if ( PlayerOwner != None )
			AdjustedAim = PawnOwner.ViewRotation;

		PlayRFiring(RocketsLoaded-1);
		Owner.MakeNoise(PawnOwner.SoundDampening);
		if ( !bFireLoad )
		{
			LockedTarget = None;
			bLockedOn = false;
		}
		else if ( LockedTarget != None )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) )
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else
			BestTarget = None;
		bPendingLock = false;
		bPointing = true;
		FireRot = AdjustedAim;
		RocketRad = 4;
		if (bTightWad || !bFireLoad) RocketRad=7;
		bMultiRockets = ( RocketsLoaded > 1 );
		While ( RocketsLoaded > 0 )
		{
			if ( bMultiRockets )
				Firelocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z - X * 4 * FRand();
			else
				FireLocation = StartLoc;
			if (bFireLoad)
			{
				if ( Angle > 0 )
				{
					if ( Angle < 3 && !bTightWad)
						FireRot.Yaw = AdjustedAim.Yaw - Angle * 600;
					else if ( Angle > 3.5 && !bTightWad)
						FireRot.Yaw = AdjustedAim.Yaw + (Angle - 3)  * 600;
					else
						FireRot.Yaw = AdjustedAim.Yaw;
				}
				if ( LockedTarget != None )
				{
					s = Spawn( class 'PKSeekingRocket',, '', FireLocation,FireRot);
					s.Seeking = LockedTarget;
					s.NumExtraRockets = DupRockets;
					if ( Angle > 0 )
						s.Velocity *= (0.9 + 0.2 * FRand());
				}
				else
				{
					r = Spawn( class'PKrocketmk2',, '', FireLocation,FireRot);
					r.NumExtraRockets = DupRockets;
					if (RocketsLoaded>4 && bTightWad) r.bRing=True;
					if ( Angle > 0 )
						r.Velocity *= (0.9 + 0.2 * FRand());
				}
			}
			else
			{
				g = Spawn( class 'PKGrenade',, '', FireLocation,AdjustedAim);
				g.NumExtraGrenades = DupRockets;
				if ( DupRockets > 0 )
				{
					RandRot.Pitch = FRand() * 1500 - 750;
					RandRot.Yaw = FRand() * 1500 - 750;
					RandRot.Roll = FRand() * 1500 - 750;
					g.Velocity = g.Velocity >> RandRot;
				}
			}

			Angle += 1.0484; //2*3.1415/6;
			RocketsLoaded--;
		}
		bTightWad=False;
		bRotated = false;
	}

	function AnimEnd()
	{
		if ( !bRotated && (AmmoType.AmmoAmount > 0) )
		{
			PlayLoading(1.5,0);
			RocketsLoaded = 1;
			bRotated = true;
			return;
		}
		LockedTarget = None;
		Finish();
	}
Begin:
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, 0.8,,, Level.TimeDilation-0.1*FRand());
}

defaultproperties
{
     LoadAnim(0)=load1
     LoadAnim(1)=Load2
     LoadAnim(2)=Load3
     LoadAnim(3)=Load4
     LoadAnim(4)=Load5
     LoadAnim(5)=Load6
     RotateAnim(0)=Rotate1
     RotateAnim(1)=Rotate2
     RotateAnim(2)=Rotate3
     RotateAnim(3)=Rotate4
     RotateAnim(4)=Rotate5
     RotateAnim(5)=Rotate3
     FireAnim(0)=Fire1
     FireAnim(1)=Fire2
     FireAnim(2)=Fire3
     FireAnim(3)=Fire4
     FireAnim(4)=Fire2
     FireAnim(5)=Fire3
     WeaponDescription="Classification: Heavy Ballistic"
     AmmoName=Class'PerUnreal.PKRocketPack'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
     ProjectileClass=Class'PerUnreal.PKRocketMk2'
     AltProjectileClass=Class'PerUnreal.PKgrenade'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.750000
     RefireRate=0.250000
     AltRefireRate=0.250000
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealShare.Eightball.Loading'
     SelectSound=Sound'UnrealShare.Eightball.Selecting'
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
     DeathMessage="%o was smacked down by %k's %w."
     NameColor=(G=0,B=0)
     AutoSwitchPriority=9
     InventoryGroup=9
     PickupMessage="You got the Rocket Launcher."
     ItemName="Rocket Launcher"
     RespawnTime=6.000000
     PlayerViewOffset=(X=2.400000,Y=-1.000000,Z=-2.200000)
     PlayerViewMesh=LodMesh'Botpack.Eightm'
     PlayerViewScale=2.000000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.Eight2Pick'
     ThirdPersonMesh=LodMesh'Botpack.EightHand'
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Icon=Texture'Botpack.Icons.Use8ball'
     Mesh=LodMesh'Botpack.Eight2Pick'
     bNoSmooth=False
     CollisionHeight=10.000000
}
