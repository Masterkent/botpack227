class UT_SkaarjPlayer extends UT_UnrealIPlayer;

#exec OBJ LOAD FILE="multimesh.u"

simulated function WalkStep()
{
	local sound step;
	local float decision;

	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't preform this on dedicated servers.

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
}

simulated function RunStep()
{
	local sound step;
	local float decision;

	if ( (Level.Game != None) && (Level.Game.Difficulty > 1) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't preform this on dedicated servers.

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

//-----------------------------------------------------------------------------
// Animation functions

function PlayDodge(eDodgeDir DodgeMove)
{
	Velocity.Z = 210;
	if (bUpdating)
		return;

	if ( DodgeMove == DODGE_Left )
		PlayAnim('LeftDodge', 1.35, 0.06);
	else if ( DodgeMove == DODGE_Right )
		PlayAnim('RightDodge', 1.35, 0.06);
	else if ( DodgeMove == DODGE_Forward )
		PlayAnim('Lunge', 1.2, 0.06);
	else
		PlayDuck();
}

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayAnim('Turn', 0.3, 0.3);
}

function TweenToWalking(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		TweenAnim('Walk', tweentime);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
		TweenAnim('WalkFire', tweentime);
	else
		TweenAnim('Walk', tweentime);
}

function TweenToRunning(float tweentime)
{
	local vector X, Y, Z, Dir;
	local float StrafeAnimRate;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X, Y, Z);
	Dir = Normal(Acceleration);

	StrafeAnimRate = 2.5 * 0.6;

	if (bIsWalking)
		TweenToWalking(0.1);
	else if (Weapon == none || !Weapon.bPointing)
	{
		if (Dir Dot X < 0.75 && Dir != vect(0,0,0))
		{
			// strafing or backing up
			if (Dir Dot X < -0.75)
				PlayAnim('Jog', 1, tweentime);
			else if (Dir Dot Y > 0)
				PlayAnim('StrafeLeft', StrafeAnimRate, tweentime);
			else
				PlayAnim('StrafeRight', StrafeAnimRate, tweentime);
		}
		else
			PlayAnim('Jog', 1, tweentime);
	}
	else
	{
		if (Dir Dot X < 0.75 && Dir != vect(0,0,0))
		{
			// strafing or backing up
			if (Dir Dot X < -0.75)
				PlayAnim('JogFire', 1, tweentime);
			else if (Dir Dot Y > 0)
				PlayAnim('StrafeLeftFr', StrafeAnimRate, tweentime);
			else
				PlayAnim('StrafeRightFr', StrafeAnimRate, tweentime);
		}
		else
			PlayAnim('JogFire', 1, tweentime);
	}
}

function PlayWalking()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk',1.1);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
		LoopAnim('WalkFire',1.1);
	else
		LoopAnim('Walk',1.1);
}

function PlayRunning()
{
	local vector X, Y, Z, Dir;
	local float StrafeAnimRate;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X, Y, Z);
	Dir = Normal(Acceleration);

	StrafeAnimRate = 2.5 * 0.6 * 1.1;

	if (Weapon == none || !Weapon.bPointing)
	{
		if (Dir Dot X < 0.75 && Dir != vect(0,0,0))
		{
			// strafing or backing up
			if (Dir Dot X < -0.75)
				LoopAnim('Jog', 1.1);
			else if (Dir Dot Y > 0)
			{
				if (AnimSequence == 'StrafeLeft' || AnimSequence == 'StrafeLeftFr')
					LoopAnim('StrafeLeft', StrafeAnimRate,, 1.0);
				else
					LoopAnim('StrafeLeft', StrafeAnimRate, 0.1, 1.0);
			}
			else
			{
				if (AnimSequence == 'StrafeRight' || AnimSequence == 'StrafeRightFr')
					LoopAnim('StrafeRight', StrafeAnimRate,, 1.0);
				else
					LoopAnim('StrafeRight', StrafeAnimRate, 0.1, 1.0);
			}
		}
		else
			LoopAnim('Jog', 1.1);
	}
	else
	{
		if (Dir Dot X < 0.75 && Dir != vect(0,0,0))
		{
			// strafing or backing up
			if (Dir Dot X < -0.75)
				LoopAnim('JogFire', 1.1);
			else if (Dir Dot Y > 0)
			{
				if (AnimSequence == 'StrafeLeft' || AnimSequence == 'StrafeLeftFr')
					LoopAnim('StrafeLeftFr', StrafeAnimRate,, 1.0);
				else
					LoopAnim('StrafeLeftFr', StrafeAnimRate, 0.1, 1.0);
			}
			else
			{
				if (AnimSequence == 'StrafeRight' || AnimSequence == 'StrafeRightFr')
					LoopAnim('StrafeRightFr', StrafeAnimRate,, 1.0);
				else
					LoopAnim('StrafeRightFr', StrafeAnimRate, 0.1, 1.0);
			}
		}
		else
			LoopAnim('JogFire', 1.1);
	}
}

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	PlayAnim('Getup', 0.7, 0.1);
}

function PlayFeignDeath()
{
	BaseEyeHeight = 0;
	PlayAnim('Death2',0.7);
}

function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local Carcass carc;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( FRand() < 0.15 )
	{
		PlayAnim('Death',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.7) )
	{
		PlayAnim('Death2', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight) )
	{
		DamageType = 'Decapitated';
		carc = Spawn(class'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Mesh = mesh'SkaarjHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Death5',0.7,0.1);
		return;
	}


	if ( FRand() < 0.15)
	{
		PlayAnim('Death3', 0.7, 0.1);
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	if (Abs(dotp) > 0.71) //then hit in front or back
		PlayAnim('Death3', 0.7, 0.1);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayAnim('Death', 0.7, 0.1);
		else
			PlayAnim('Death4', 0.7, 0.1);
	}
}

//FIXME - add death first frames as alternate takehit anims!!!

function PlayGutHit(float tweentime)
{
	if ( AnimSequence == 'GutHit' )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
	if ( AnimSequence == 'HeadHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( AnimSequence == 'LeftHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( AnimSequence == 'RightHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		B227_PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( Level.FootprintManager!=None )
		B227_PlayLandingNoise(Self, 1, impactVel);
	else if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		B227_PlayOwnedSound(Land, SLOT_Interact, FClamp(4.5 * impactVel,0.5,6), false, 1000, 1.0);

	if ( (GetAnimGroup(AnimSequence) == 'Dodge') && IsAnimating() )
		return;
	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
		TweenAnim('Land', 0.12);
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			AnimEnd();
		else
			TweenAnim('Land', 0.12);
	}
}

function PlayInAir()
{
	BaseEyeHeight =  Default.BaseEyeHeight;
	TweenAnim('InAir', 0.4);
}

function PlayDuck()
{
	BaseEyeHeight = 0;
	TweenAnim('Duck', 0.25);
}

function PlayCrawling()
{
	BaseEyeHeight = 0;
	LoopAnim('DuckWalk');
}

function TweenToWaiting(float tweentime)
{
	if (bIsTyping && AnimSequence == 'gunfix' || IsAnimating() && (AnimSequence == 'Shield' || AnimSequence == 'Fighter'))
		return;

	if ( IsInState('PlayerSwimming') || Physics==PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		TweenAnim('Swim', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		TweenAnim('Firing', tweentime);
	}
}

function PlayWaiting()
{
	local name newAnim;

	if ( Mesh == None )
		return;

	if (bIsTyping)
	{
		PlayChatting();
		return;
	}

	if ( IsInState('PlayerSwimming') || (Physics==PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		LoopAnim('Swim');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon != None) && Weapon.bPointing )
			TweenAnim('Firing', 0.3);
		else
		{
			if ( FRand() < 0.2 )
				newAnim = 'Breath';
			else
				newAnim = 'Breath2';

			if ( AnimSequence == newAnim )
				LoopAnim(newAnim, 0.3 + 0.7 * FRand());
			else
				PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
		}
	}
}

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if (AnimSequence == 'Jog')
		AnimSequence = 'JogFire';
	else if (AnimSequence == 'Walk')
		AnimSequence = 'WalkFire';
	else if ( AnimSequence == 'InAir' )
		TweenAnim('JogFire', 0.03);
	else if ( (GetAnimGroup(AnimSequence) != 'Attack')
			  && (GetAnimGroup(AnimSequence) != 'MovingAttack')
			  && (GetAnimGroup(AnimSequence) != 'Dodge')
			  && (AnimSequence != 'Swim') )
		TweenAnim('Firing', 0.02);
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	LoopAnim('Swim');
}

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	TweenAnim('Swim',tweentime);
}

function SwimAnimUpdate(bool bNotForward)
{
	if ( !bAnimTransition && !IsGestureAnim(AnimSequence) && (AnimSequence != 'Swim') )
		TweenToSwimming(0.1);
}

exec function Taunt(name Sequence)
{
	if (bool(Acceleration) || bIsCrouching)
		return;

	if (HasAnim(Sequence) && GetAnimGroup(Sequence) == 'Gesture')
		super.Taunt(Sequence);
	else if (Sequence == 'Victory1' || Sequence == 'Wave')
	{
		ServerTaunt(Sequence);
		PlayAnim('Shield', 0.6, 0.1);
	}
	else if (Sequence == 'Thrust')
	{
		ServerTaunt(Sequence);
		PlayAnim('Fighter', 0.8, 0.1);
	}
}

function ServerTaunt(name Sequence)
{
	if (bool(Acceleration) || bIsCrouching)
		return;

	if (HasAnim(Sequence) && GetAnimGroup(Sequence) == 'Gesture')
		super.ServerTaunt(Sequence);
	else if (Sequence == 'Victory1' || Sequence == 'Wave')
		PlayAnim('Shield', 0.6, 0.1);
	else if (Sequence == 'Thrust')
		PlayAnim('Fighter', 0.8, 0.1);
}

function PlayChatting()
{
	if (Mesh != none)
		LoopAnim('gunfix', 0.7, 0.25);
}

function bool IsGestureAnim(name Sequence)
{
	return
		GetAnimGroup(Sequence) == 'Gesture' ||
		Sequence == 'Shield' ||
		Sequence == 'Fighter' ||
		Sequence == 'gunfix';
}

state PlayerWalking
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		super.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);

		if (Physics == PHYS_Walking &&
			!bIsCrouching &&
			(!bAnimTransition || AnimFrame > 0) &&
			bool(Acceleration) &&
			IsGestureAnim(AnimSequence))
		{
			bAnimTransition = true;
			TweenToRunning(0.1);
		}
	}
}



function MultimeshPackageRef()
{
	local Object Obj;
	Obj = class'multimesh.SkaarjVoice'; // Makes a reference to multimesh.u
}

defaultproperties
{
	bIsHuman=False
	Footstep1=Sound'UnrealShare.Cow.walkC'
	Footstep2=Sound'UnrealShare.Cow.walkC'
	Footstep3=Sound'UnrealShare.Cow.walkC'
	UWHit1=Sound'SKPInjur4'
	UWHit2=Sound'SKPInjur4'
	Die=Sound'SKPDeath1'
	Die2=Sound'SKPDeath2'
	Die3=Sound'SKPDeath3'
	Die4=Sound'SKPDeath3'
	HitSound1=Sound'SKPInjur1'
	HitSound2=Sound'SKPInjur2'
	HitSound3=Sound'SKPInjur3'
	HitSound4=Sound'SKPInjur4'
	GaspSound=Sound'SKPGasp1'
	JumpSound=Sound'SKPJump1'
	Drown=Sound'SKPDrown1'
	breathagain=Sound'SKPGasp1'
	LandGrunt=Sound'Land1SK'
	CarcassType=Class'TrooperCarcass'
	bSinglePlayer=False
	JumpZ=360.00
	BaseEyeHeight=24.75
	EyeHeight=24.75
	Health=130
	MenuName="Skaarj"
	Skin=Texture'sktrooper1'
	Mesh=LodMesh'sktrooper'
	CollisionRadius=32.00
	CollisionHeight=42.00
	Mass=120.00
	Buoyancy=118.80
	VoiceType="MultiMesh.SkaarjVoice"
}