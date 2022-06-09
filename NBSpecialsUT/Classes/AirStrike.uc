//=============================================================================
// AirStrike.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class AirStrike expands Effects;

var() sound PlayAlarmSound;
var() float a_AlarmTime;	//10.0
var() float b_LookTime;		//3.0
var() float c_ByeByeTime;	//1.8
var() float d_BombingTime;	//4.0
var() localized string ActivateMessage; // if activated send this message to Instigator
var() float e_EndAlarmTime;	//4.0
var() sound PlayEndAlarmSound;
var() float f_ReactivateTime;	//30.0
var() localized string ReActivateMessage; // if activated during Reactivation
var() float BombingRate; //0.2

var(AirStrikeSpecial) enum ESpecial
{
	a_AlarmTime_a,
	b_LookTime_b,
	c_ByeByeTime_c,
	d_BombingTime_d,
	x_dont_use_it_x,
} StartEventAfter, EndEventAfter;
var(AirStrikeSpecial) name SpecialEvent;

var float TimePassed, TimeToCheck;
var pawn pPawn;
var float fBoom;
var bool bFoundTarget, bFoundASP;
var AirStrikePoint ASP;
var actor A;
var vector oLocation;
var localized string ReMessage;
var int TimeLeft;

function LookAnim (pawn Other)
{
	if 	(  (Other.IsA('Human'))
		|| (Other.IsA('HumanBot')))
		Other.LoopAnim('LookL',0.7,0.2);
	else if (  (Other.IsA('SkaarjPlayer'))
			|| (Other.IsA('SkaarjPlayerBot'))
			|| (Other.IsA('SkaarjTrooper'))
			|| (Other.IsA('SkaarjWarrior')))
		Other.LoopAnim('Looking',0.7,0.2);
	else if (  (Other.IsA('Nali'))
			|| (Other.IsA('NaliPlayer')))
		Other.LoopAnim('Pray',0.7,0.2);
	else if (Other.IsA('Krall'))
		Other.LoopAnim('Look',0.7,0.2);
	else if (Other.IsA('Mercenary'))
		Other.LoopAnim('NeckCrak',0.7,0.2);
	else if (Other.IsA('Brute'))
		Other.LoopAnim('StillLook',0.7,0.2);
	else if (Other.IsA('Titan'))
		Other.LoopAnim('TSnif001',0.5,0.2);
	else if (Other.IsA('Warlord'))
		Other.LoopAnim('Point',0.5,0.2);
}

function ByeByeAnim (pawn Other)
{
	if 	(  (Other.IsA('Human'))
		|| (Other.IsA('HumanBot')))
		Other.PlayAnim('WaveL',0.5,0.2);
	else if (  (Other.IsA('SkaarjPlayer'))
			|| (Other.IsA('SkaarjPlayerBot'))
			|| (Other.IsA('SkaarjTrooper')))
		Other.PlayAnim('ShldTest',0.5,0.2);
	else if (Other.IsA('SkaarjWarrior'))
		Other.PlayAnim('hairflip',0.5,0.2);
	else if (  (Other.IsA('Nali'))
			|| (Other.IsA('NaliPlayer')))
		Other.PlayAnim('Cringe',0.5,0.2);
	else if (  (Other.IsA('Krall'))
			|| (Other.IsA('Warlord')))
		Other.PlayAnim('Laugh',0.5,0.2);
	else if (Other.IsA('Mercenary'))
		Other.PlayAnim('CHARGEUP',0.5,0.2);
	else if (Other.IsA('Brute'))
		Other.PlayAnim('Sleep',0.5,0.2);
	else if (Other.IsA('Titan'))
		Other.PlayAnim('TChest',0.5,0.2);
}

function bool StopPlayer ( pawn pPawn )
{
	if ( pPawn.Physics != PHYS_None )
	{
		PlayerPawn(pPawn).bBehindview = True;
		PlayerPawn(pPawn).bPressedJump = False;
		pPawn.Velocity = Vect(0,0,0);
		pPawn.SetPhysics(PHYS_Falling);
		pPawn.GotoState('');
		return True;
	}
	return False;
}

function StartSpecialEvent( actor pP)
{
local actor a;
	if (pP == None || SpecialEvent == '')
		return;
	foreach allactors (class'Actor', a, SpecialEvent)
		a.Trigger(pP, Pawn(pP));
}

function EndSpecialEvent( actor pP)
{
local actor a;
	if (pP == None || SpecialEvent == '')
		return;
	foreach allactors (class'Actor', a, SpecialEvent)
		a.UnTrigger(pP, Pawn(pP));
}

auto state Waiting
{
	function Trigger ( actor Other, pawn EventInstigator )
	{
		bFoundTarget = False;
		bFoundASP    = False;
		oLocation = Location;

		if ( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
			Other.Instigator.ClientMessage( ActivateMessage );

		foreach allactors (class'AirStrikePoint',ASP)
		{
			if ( ASP.Tag == Self.Tag )
			{
				bFoundASP = True;
				SetLocation(ASP.Location);
				foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
				{
					if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
					{
						bFoundTarget = True;
						// 1st go into the Behindview-mode
						PlayerPawn(pPawn).bBehindview = True;
					}
				}
				// and sound the alarm
				ASP.AmbientSound = PlayAlarmSound;
			}
		}
		if (bFoundASP)
		{
			GotoState('BoomBoom');
		}
	}
Begin:
}

state BoomBoom
{
	function Trigger ( actor Other, pawn EventInstigator ) {}

	function Timer()
	{
		local SpriteBallExplosion f;
		local vector xyz, tmpvec;
		local int posneg;

		if (fBoom > 1.0)
		{
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					SetLocation(ASP.Location);
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							StopPlayer(pPawn);
							if (SpecialEvent == '')
							{
								PlayerPawn(pPawn).ViewRotation.Pitch = 56000;
								PlayerPawn(pPawn).ViewRotation.Yaw += 1000;
							}
						}
					}
				}
			}
		}

		// 2nd let Pawns stop moving, cut players control,
		// play Look-Around-Anim, and stop playing the alarm sound
		if (fBoom == 1.0) {
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					ASP.AmbientSound = None;
					SetLocation(ASP.Location);
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							StopPlayer(pPawn);
							LookAnim(pPawn);
							if (StartEventAfter == a_AlarmTime_a)
								StartSpecialEvent(pPawn);
							if (EndEventAfter == a_AlarmTime_a)
								EndSpecialEvent(pPawn);
						}
					}
				}
			}
			TimePassed = 0.0;
			TimeToCheck = b_LookTime;
			fBoom += 0.5;
			Enable('Tick');
		}

		// 3rd play ByeBye-Animation
		if (fBoom == 2.0) {
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					SetLocation(ASP.Location);
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							if ( StopPlayer(pPawn) )
								LookAnim(pPawn);
							else
								ByeByeAnim(pPawn);
							if (StartEventAfter == b_LookTime_b)
								StartSpecialEvent(pPawn);
							if (EndEventAfter == b_LookTime_b)
								EndSpecialEvent(pPawn);
						}
					}
				}
			}
			TimePassed = 0.0;
			TimeToCheck = c_ByeByeTime;
			fBoom += 0.5;
			Enable('Tick');
		}

		// 4th play Iginition-Sound
		if (fBoom == 3.0) {
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					SetLocation(ASP.Location);
					ASP.PlaySound(Sound'UnrealShare.Eightball.Ignite',Slot_None);
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							StopPlayer(pPawn);
							ByeByeAnim(pPawn);
							if (StartEventAfter == c_ByeByeTime_c)
								StartSpecialEvent(pPawn);
							if (EndEventAfter == c_ByeByeTime_c)
								EndSpecialEvent(pPawn);
						}
					}
				}
			}
			TimePassed = 0.0;
			TimeToCheck = d_BombingTime;
			fBoom += 0.5;
			Enable('Tick');
			SetTimer(BombingRate,True);
		}

		// 5th spawn explosions around pawns
		if (fBoom == 3.5) {
			posneg = Rand(2);
			if (posneg == 0) posneg = -1;
			xyz.x = FRand()*10*posneg;
			xyz.y = FRand()*10*posneg;
			xyz.z = 1;
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					SetLocation(ASP.Location);
					bFoundTarget = False;
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							bFoundTarget = True;
							StopPlayer(pPawn);
							ByeByeAnim(pPawn);
							f = spawn(class'SpriteBallExplosion',,,pPawn.Location + xyz*Rand(16),rot(16384,0,0));
							f.DrawScale = (1.4+FRand()*0.5)*4;
						}
					}
					if ( !bFoundTarget )
					{
						xyz.z = 0.5;
						tmpvec = Location;
						tmpvec.X += xyz.X * Rand(32);
						tmpvec.Y += xyz.Y * Rand(32);
						tmpvec.Z += xyz.Z * Rand(16);
						tmpvec.Z += ASP.zAxisCorrection;
						f = spawn(class'SpriteBallExplosion',,,tmpvec,rot(16384,0,0));
						f.DrawScale = (1.4+FRand()*0.5)*4;
					}
				}
 			}
		}

		// 6th let the last explosion hit the pawn
		// so... the pawn is dead!
		if (fBoom == 4.0) {
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					SetLocation(ASP.Location);
					foreach radiusactors (class'Pawn', pPawn, ASP.Radius)
					{
						if ( ClassIsChildOf(pPawn.Class, ASP.TargetPawnClass) )
						{
							StopPlayer(pPawn);
							if (StartEventAfter == d_BombingTime_d)
								StartSpecialEvent(pPawn);
							if (EndEventAfter == d_BombingTime_d)
								EndSpecialEvent(pPawn);
							f = spawn(class'SpriteBallExplosion',,,pPawn.Location + vect(0,0,1)*16,rot(16384,0,0));
							f.DrawScale = (1.4+FRand()*0.5)*4;
							pPawn.Died( None, '', pPawn.Location );
						}
					}
				}
	 		}
			GotoState('EndOfAirStrike');
		}
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		if (TimePassed > TimeToCheck) {
			fBoom += 0.5;
			Disable('Tick');
		}
	}

Begin:
	TimePassed = 0.0;
	TimeToCheck = a_AlarmTime;
	fBoom = 0.5;
	Enable('Tick');
	SetTimer(0.03,True);
}

state EndOfAirStrike
{
	function Trigger ( actor Other, pawn EventInstigator ) {}

	function Timer()
	{
		if (fBoom == 1.0)
		{
			foreach allactors (class'AirStrikePoint',ASP)
			{
				if ( ASP.Tag == Self.Tag )
				{
					ASP.AmbientSound = None;
				}
			}

			if (Event!='')
				foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Self, None );
			SetLocation(oLocation);
			GotoState('ReactivateAirStrike');
		}
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		if (TimePassed > TimeToCheck) {
			fBoom += 0.5;
			Disable('Tick');
		}
	}

Begin:
	foreach allactors (class'AirStrikePoint',ASP)
	{
		if ( ASP.Tag == Self.Tag )
		{
			ASP.AmbientSound = PlayEndAlarmSound;
		}
	}
	TimePassed = 0.0;
	TimeToCheck = e_EndAlarmTime;
	fBoom = 0.5;
	Enable('Tick');
	SetTimer(0.03,True);
}

state ReactivateAirStrike
{
	function Trigger ( actor Other, pawn EventInstigator )
	{
		if ( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
			Other.Instigator.ClientMessage( ReMessage );
	}

	function Timer()
	{
		if (fBoom == 1.0)
		{
			GotoState('Waiting');
		}
	}

	function Tick( float DeltaTime )
	{
		TimePassed += DeltaTime;
		TimeLeft = TimeToCheck - TimePassed;
		ReMessage = ReactivateMessage $ " " $ string(TimeLeft) $ " seconds!";
		if (TimePassed > TimeToCheck) {
			fBoom += 0.5;
			Disable('Tick');
		}
	}

Begin:
	TimePassed = 0.0;
	TimeToCheck = f_ReactivateTime;
	fBoom = 0.5;
	Enable('Tick');
	SetTimer(0.03,True);
}

defaultproperties
{
     a_AlarmTime=22.000000
     b_LookTime=3.000000
     c_ByeByeTime=1.800000
     d_BombingTime=4.000000
     ActivateMessage="Air support is on the way !"
     e_EndAlarmTime=10.000000
     f_ReactivateTime=30.000000
     ReActivateMessage="Air support available in"
     BombingRate=0.200000
     EndEventAfter=d_BombingTime_d
     bHidden=True
     bNetTemporary=False
     DrawType=DT_Sprite
     Texture=None
}
