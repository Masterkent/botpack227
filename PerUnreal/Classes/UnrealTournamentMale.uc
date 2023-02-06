//=============================================================================
// UnrealTournamentMale.
//=============================================================================
class UnrealTournamentMale extends TournamentPlayer
	abstract;

function PlayDying(name DamageType, vector HitLoc)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead3',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
	{
		PlayDecap();
		return;
	}

	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead2',,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( FRand() < 0.5 )
			PlayAnim('Dead1',,0.1);
		else
			PlayAnim('Dead5',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		PlayAnim('Dead6',, 0.1);
		return;
	}

	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap();
		else
			PlayAnim('Dead7',, 0.1);
		return;
	}

	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead6',, 0.1);
}

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'UT_HeadMale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead7') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead7', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else
		TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead1', tweentime);
}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName;
	local string TeamColor[4];

	TeamColor[0]="Red";
    TeamColor[1]="Blue";
    TeamColor[2]="Green";
    TeamColor[3]="Gold";


	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	if( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if(TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture'));
	else if( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));

	// Set skin
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;
}

function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if (Weapon == None)
		PlayAnim('RunSM', 0.9, tweentime);
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSMFR', 0.9, tweentime);
		else
			PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSM', 0.9, tweentime);
		else
			PlayAnim('RunLG', 0.9, tweentime);
	}
}

function PlayRunning()
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if (Weapon == None)
		LoopAnim('RunSM');
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSMFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSM');
		else
			LoopAnim('RunLG');
	}
}

function PlayDyingSound()
{
	local int rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		PlaySound(UWHit1, SLOT_Pain);
		return;
	}

	rnd = Rand(4);
	PlaySound(Deaths[rnd], SLOT_Talk);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(drown, SLOT_Pain);
		else
			PlaySound(UWHit1, SLOT_Pain);
		return;
	}
	damage *= FRand();

	if (damage < 8)
		PlaySound(HitSound1, SLOT_Pain);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain);
		else PlaySound(HitSound3, SLOT_Pain);
	}
	else
		PlaySound(HitSound4, SLOT_Pain);
}

function Gasp()
{
	if ( Role != ROLE_Authority )
		return;
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk);
	else
		PlaySound(BreathAgain, SLOT_Talk);
}

defaultproperties
{
     Deaths(0)=Sound'UnrealShare.Male.MDeath1'
     Deaths(1)=Sound'UnrealShare.Male.MDeath3'
     Deaths(2)=Sound'UnrealShare.Male.MDeath4'
     HitSound3=Sound'UnrealShare.Male.MInjur3'
     HitSound4=Sound'UnrealShare.Male.MInjur4'
     VoicePackMetaClass="BotPack.VoiceMale"
     CarcassType=Class'Botpack.TMale1Carcass'
     JumpSound=Sound'UnrealShare.Male.MJump1'
     HitSound1=Sound'UnrealShare.Male.MInjur1'
     HitSound2=Sound'UnrealShare.Male.MInjur2'
}
