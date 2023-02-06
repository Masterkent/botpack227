//=============================================================================
// UnrealTournamentFemaleBot.
//=============================================================================
class UnrealTournamentFemaleBot extends HumanBotPlus
	abstract;

function PlayRightHit(float tweentime)
{
	if ( AnimSequence == 'RightHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

function PlayDying(name DamageType, vector HitLoc)
{
	local carcass carc;

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
		PlayAnim('Dead7',,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( (HitLoc.Z < Location.Z) && !class'GameInfo'.Default.bVeryLowGore && (FRand() < 0.6) )
		{
			PlayAnim('Dead5',,0.05);
			if ( Level.NetMode != NM_Client )
			{
				carc = Spawn(class 'UT_FemaleFoot',,, Location - CollisionHeight * vect(0,0,0.5));
				if (carc != None)
				{
					carc.Initfor(self);
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
			}
		}
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		PlayAnim('Dead5',, 0.1);
		return;
	}

	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap();
		else
			PlayAnim('Dead3',, 0.1);
		return;
	}

	//then hit in front or back
	if ( FRand() < 0.5 )
		PlayAnim('Dead4',, 0.1);
	else
		PlayAnim('Dead1',, 0.1);
}

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead6',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'UT_HeadFemale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
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
     CarcassType=Class'Botpack.TFemale1Carcass'
     drown=Sound'UnrealShare.Female.mdrown2fem'
     HitSound3=Sound'UnrealShare.Female.linjur3fem'
     HitSound4=Sound'UnrealShare.Female.hinjur4fem'
     Deaths(0)=Sound'UnrealShare.Female.death1dfem'
     Deaths(1)=Sound'UnrealShare.Female.death2afem'
     Deaths(2)=Sound'UnrealShare.Female.death3cfem'
     Deaths(3)=Sound'UnrealShare.Female.death4cfem'
     Deaths(4)=Sound'UnrealShare.Female.death1dfem'
     Deaths(5)=Sound'UnrealShare.Female.death2afem'
     UWHit1=Sound'UnrealShare.Female.FUWHit1'
     UWHit2=Sound'UnrealShare.Female.FUWHit1'
     LandGrunt=Sound'UnrealShare.Female.lland1fem'
     JumpSound=Sound'UnrealShare.Female.jump1fem'
     StatusDoll=Texture'Botpack.Icons.Woman'
     StatusBelt=Texture'Botpack.Icons.WomanBelt'
     VoicePackMetaClass="BotPack.VoiceFemale"
     bIsFemale=True
     HitSound1=Sound'UnrealShare.Female.linjur1fem'
     HitSound2=Sound'UnrealShare.Female.linjur2fem'
     Die=Sound'UnrealShare.Female.death2afem'
}
