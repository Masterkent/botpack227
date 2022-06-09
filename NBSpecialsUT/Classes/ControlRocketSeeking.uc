//=============================================================================
// ControlRocketSeeking.
//
// script by N.Bogenrieder (Beppo)
//
// like the ControlRocket + if the controler presses
// Fire AND AltFire the rocket will start searching
// for a target by itself !!
//
// ( TeamMembers in TeamGames will be ignored )
//
// If you use this Rocket with a ControlRotatingMover (CRM)
// set bWait(Alt)FireRelease (in CRM) to true
// so the CRM waits for releasing the (Alt)FireButton
// use the same for the SpecialControlCannon...
//=============================================================================
class ControlRocketSeeking expands ControlRocket;

var pawn ClosestPawn;
var float ClosestDistance;
var int Count2;
var bool bMisc1, bMisc2;
var bool bCheckTeam;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Count2 = 0;
	ClosestPawn = None;
	if (Level.Game.IsA('TeamGame'))
		bCheckTeam = True;
	else
		bCheckTeam = False;
	if (oInst.Weapon.class == class'NoWeaponNoFire')
	{
		oInst.Weapon.Misc2Sound = None;
	}
}

function ResetViewOfPlayer()
{
	if	(	(oInst.ViewTarget == Self)
		||	(oInst.Health <= 0) )
	{

// reset the Crosshair
		if	(	(oInst.Weapon.class == class'NoWeaponNoFire')
			&&	(oInst.ViewTarget == Self) )
			oInst.Weapon.bOwnsCrosshair = False;

// reset the original HUD
		oInst.MyHUD = rHUD.oHUD;
		rHUD.Destroy();
		rHUD = None;

		oInst.DesiredFOV = oInst.Default.DesiredFOV;
		oInst.bBehindView = False;
		oInst.ViewTarget = None;
	}
	oInst = None;
}

function GetTarget()
{
	local pawn Victims;
	local float thisDist;

	ClosestDistance = 100000;
	ClosestPawn = None;
	Count2++;
	if (Count2==400)
	{
		Explode(Location, vect(0,0,0));
		return;
	}

	foreach VisibleCollidingActors( class'Pawn', Victims, 500.0 )
	{
// ignore TeamMembers
		if	(	(!bCheckTeam)
			||	(  Victims.PlayerReplicationInfo.Team
				!= oInst.PlayerReplicationInfo.Team )
			)
		{
			thisDist = VSize(Victims.Location - Location); 
			if ( thisDist < ClosestDistance) 
			{
				ClosestPawn = Victims;
				ClosestDistance = thisDist;
			}
		}
	}
}

auto state Flying
{
	function Tick( float DeltaTime )
	{
		local float MagnitudeVel;

		local int DeltaYaw, DeltaPitch;
		local int YawDiff;
		local SpriteSmokePuff b;

		if (oInst != None)
		{
			if (oInst != Instigator)
			{
				oInst = PlayerPawn(Instigator);
				SetViewOfPlayer();
			}
			if (oInst.Health <= 0)
			{
				HitPawn = None;
				Explode(Location,Normal(Location));
			}
			
			if ( Level.NetMode == NM_Client )
				Velocity = GuidedVelocity;
			else
			{
	// if Controler presses both Fire AND AltFire
	// start searching targets !!
				if	(	(oInst.bFire == 1)
					&&	(oInst.bAltFire == 1) )
					GetTarget();
				if (ClosestPawn != None)
				{
	// if used by a CRM or SpecialControlCannon
	// set weapons bOwnsCrosshair to TRUE for changing the Crosshair
					if	(	(oInst.Weapon.class == class'NoWeaponNoFire')
						&&	(oInst.ViewTarget == Self) )
					{
						oInst.Weapon.bOwnsCrosshair = True;
						PlaySound(oInst.Weapon.Misc1Sound, SLOT_None,oInst.SoundDampening);
						oInst.Weapon.Misc1Sound = None;
						oInst.Weapon.Misc2Sound = oInst.Weapon.default.Misc2Sound;
					}
	// warn target
					MakeNoise(oInst.SoundDampening);
					ClosestPawn.WarnTarget(oInst, Speed, vector(Rotation));	
						
					MagnitudeVel = VSize(Velocity);
					Velocity =  MagnitudeVel * Normal( Normal(ClosestPawn.Location - Location) 
								* MagnitudeVel * DeltaTime * 6 + Velocity);
					SetRotation(rotator(Velocity));
					return;
				}
				else
				{
	// reset the Crosshair
					if	(	(oInst.Weapon.class == class'NoWeaponNoFire')
						&&	(oInst.ViewTarget == Self) )
					{
						oInst.Weapon.bOwnsCrosshair = False;
						PlaySound(oInst.Weapon.Misc2Sound, SLOT_None,oInst.SoundDampening);
						oInst.Weapon.Misc2Sound = None;
						oInst.Weapon.Misc1Sound = oInst.Weapon.default.Misc1Sound;
					}
				}

				if ( (instigator.Health <= 0) || instigator.IsA('Bot') )
				{
					Disable('Tick');
					return;
				}
				else
				{
					DeltaYaw = (instigator.ViewRotation.Yaw & 65535) - (OldGuiderRotation.Yaw & 65535);
					DeltaPitch = (instigator.ViewRotation.Pitch & 65535) - (OldGuiderRotation.Pitch & 65535);
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

					Velocity += Vector(GuidedRotation) * 2000 * DeltaTime;
					speed = VSize(Velocity);
					Velocity = Velocity * FClamp(speed,400,750)/speed;

					GuidedVelocity = Velocity;
					OldGuiderRotation = instigator.ViewRotation;
				}
			}
			SetRotation(Rotator(Velocity));

			WarnTargets();

			Count += DeltaTime;
			if ( (Count>(SmokeRate+FRand()*(SmokeRate+NumExtraRockets*0.035))) && (Level.NetMode!=NM_DedicatedServer) ) 
			{
				b = Spawn(class'SpriteSmokePuff');
				b.RemoteRole = ROLE_None;
				Count=0.0;
			}
		}
		else
		{
			oInst = PlayerPawn(Instigator);
			if (oInst != None)
				SetViewOfPlayer();
		}
	}
}

defaultproperties
{
}
