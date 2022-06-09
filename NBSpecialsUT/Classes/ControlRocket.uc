//=============================================================================
// ControlRocket.
//
// script by N.Bogenrieder (Beppo)
//
// You can control this rocket like the RazorBlade
// In addition you 'fly' with her while you control it!
//
// This thingy works similar to the upcoming
// GuidedRocket from UnrealTournament !!
//=============================================================================
class ControlRocket expands Rocket;

var PlayerPawn oInst;
//var actor oViewTarget;

// this is just a mixture of the RazorBladeAlt
// and the original Rocket class
// + YOU SEE IT FLYING
// nothing big special about it :) !!

var vector GuidedVelocity;
var rotator OldGuiderRotation, GuidedRotation;
var pawn HitPawn;
var RadarHUD rHUD;
var float TimeToCheck, TimePassed;
var bool bCanHitInst;

replication
{
    // Things the server should send to the client.
//    reliable if( Role==ROLE_Authority )
//        oInst;
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		GuidedVelocity;
}

simulated function SetRoll(vector NewVelocity)
{
	local rotator newRot;
	newRot = rotator(NewVelocity);
	newRot.Roll += 12768;
	SetRotation(newRot);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	GuidedRotation = Rotation;
	OldGuiderRotation = Rotation;
	oInst = PlayerPawn(Instigator);
	bRing = True;
}

simulated function SetViewOfPlayer()
{
	if (oInst != None)
	{
		if (oInst.ViewTarget != Self)
		{
			oInst.ViewTarget = Self;
			oInst.DesiredFOV = 110;
			oInst.bBehindView = False;

// change HUD for RADAR
			if (oInst.MyHUD.class != class'RadarHUD')
			{
				rHUD = spawn(class'RadarHUD', oInst);
				rHUD.oHUD = oInst.MyHUD;
				oInst.MyHUD = rHUD;
			}
			else
				rHUD = RadarHUD(oInst.MyHUD);
		}
	}
}

simulated function ResetViewOfPlayer()
{
	if	(	(oInst.ViewTarget == Self)
		||	(oInst.Health <= 0) )
	{
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

simulated function WarnTargets()
{
}

auto state Flying
{
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
		}
		Velocity=0.6*Velocity;
		GuidedVelocity=0.6*GuidedVelocity;
	}

	simulated function Tick(float DeltaTime)
	{
		local int DeltaYaw, DeltaPitch;
		local int YawDiff;
		local SpriteSmokePuff b;

		if (oInst != None)
		{
// Beppo - let the Rocket kill the instigator only after
// 1 second has passed!
			if (TimePassed < TimeToCheck)
				TimePassed += DeltaTime;
			else
				bCanHitInst = True;

			if (oInst != Instigator)
			{
				oInst = PlayerPawn(Instigator);
				SetViewOfPlayer();
			}
			if (Instigator.Health <= 0)
			{
				HitPawn = None;
				Explode(Location,Normal(Location));
			}

//			if ( Level.NetMode == NM_Client )
//				Velocity = GuidedVelocity;
//			else
//			{
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
//			}
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

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator || bCanHitInst) && (Rocket(Other) == none)) 
//		if (Rocket(Other) == none)
		{
			HitPawn = Pawn(Other);
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	simulated function BeginState()
	{
		SetViewOfPlayer();

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )	
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;
		PlaySound(SpawnSound, SLOT_None, 2.3);	
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
			GuidedVelocity=0.6*GuidedVelocity;
		}
		TimeToCheck = 1.0;
		TimePassed = 0.0;
		bCanHitInst = False;
	}

	simulated function BlowUp(vector HitLocation, RingExplosion r)
	{
		Super.BlowUp(HitLocation, r);
		HitPawn.Health = 0;
		HitPawn.Died( oInst, '', HitLocation );
		ResetViewOfPlayer();
	}

}

defaultproperties
{
     speed=100.000000
     MaxSpeed=480.000000
     Damage=180.000000
     LifeSpan=0.000000
     AnimSequence=None
     Mesh=LodMesh'UnrealI.perock'
     DrawScale=2.500000
}
