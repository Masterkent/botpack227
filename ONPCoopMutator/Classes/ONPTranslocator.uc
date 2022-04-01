class ONPTranslocator expands TVTranslocator;

function bool AllowTranslocation(Pawn P, vector Dest)
{
	local bool Result;
	local ONPLocationTest Test;

	Test = Spawn(class'ONPLocationTest');
	if (Test == none)
		return false;
	Result = Test.IsClearLocationFor(Dest, P);
	Test.Destroy();

	return Result;
}

function bool MovePawnTo(Pawn P, vector Pos)
{
	local bool Result;
	local bool bPawnBlockActors, bPawnBlockPlayers;

	bPawnBlockActors = P.bBlockActors;
	bPawnBlockPlayers = P.bBlockPlayers;
	P.SetCollision(P.bCollideActors, false, false);

	Result = P.SetLocation(Pos);
	P.SetCollision(P.bCollideActors, bPawnBlockActors, bPawnBlockPlayers);

	return Result;
}

function Fire(float Value)
{
	if (bBotMoveFire)
		return;
	if (TTarget == None)
	{
		if (Level.TimeSeconds - 0.5 > FireDelay)
		{
			bPointing=True;
			if (PlayerPawn(Owner) != None)
			{
				if (InstFlash != 0.0)
					PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);
				PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
			}
			if (Affector != None)
				Affector.FireEffect();
			PlayFiring();
			Pawn(Owner).PlayRecoil(FiringSpeed);
			ThrowTarget();
			FireDelay = Level.TimeSeconds + 0.1;
		}
	}
	else if (TTarget.SpawnTime < Level.TimeSeconds - 0.8)
	{
		if (TTarget.Disrupted())
		{
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Misc, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Interact, 4.0);
		}
		else
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
		FireDelay = Level.TimeSeconds;
	}

	GotoState('NormalFire');
}

function Translocate()
{
	local vector Dest, Start;
	local Bot B;
	local Pawn P;

	bBotMoveFire = false;
	PlayAnim('Thrown', 1.2,0.1);
	Dest = TTarget.Location;
	if (TTarget.Physics == PHYS_None)
		Dest += vect(0,0,40);

	if (Pawn(Owner) == none)
		return;

	if (TTarget.Disrupted())
	{
		SpawnEffect(Start, Dest);
		Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);
		Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Misc, 4.0);
		Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Interact, 4.0);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = none;
		return;
	}

	Start = Pawn(Owner).Location;
	TTarget.SetCollision(false,false,false);
	if (AllowTranslocation(Pawn(Owner), Dest) && MovePawnTo(Pawn(Owner), Dest))
	{
		if (!Owner.Region.Zone.bWaterZone)
			Owner.SetPhysics(PHYS_Falling);

		if ( !FastTrace(Pawn(Owner).Location, TTarget.Location) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			MovePawnTo(Pawn(Owner), Start);
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		}	
		else 
		{ 
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Owner.Velocity.X = 0;
			Owner.Velocity.Y = 0;
			B = Bot(Owner);
			if ( B != None )
			{
				if ( TTarget.DesiredTarget.IsA('NavigationPoint') )
					B.MoveTarget = TTarget.DesiredTarget;
				B.bJumpOffPawn = true;
				if ( !Owner.Region.Zone.bWaterZone )
					B.SetFall();
			}
			else
			{
				// bots must re-acquire this player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Enemy == Owner) && P.IsA('Bot') )
						Bot(P).LastAcquireTime = Level.TimeSeconds;
			}

			Level.Game.PlayTeleportEffect(Owner, true, true);
			SpawnEffect(Start, Dest);
		}
	} 
	else 
	{
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	}

	if (TTarget != None)
	{
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
	}
	bPointing=True;
}

defaultproperties
{
	bTravel=False
}
