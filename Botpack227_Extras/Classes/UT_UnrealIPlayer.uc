class UT_UnrealIPlayer expands TournamentPlayer;

var transient byte WetSteps;

function PlayDodge(eDodgeDir DodgeMove)
{
	Velocity.Z = 210;
	PlayDuck();
}

function PlayDyingSound()
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk);
	else
		PlaySound(Die4, SLOT_Talk);
}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName,Chck;
	local string TeamColor[4];
	local int i;

	TeamColor[0]="Red";
	TeamColor[1]="Blue";
	TeamColor[2]="Green";
	TeamColor[3]="Yellow";

	if ( SkinActor.Mesh!=None )
		MeshName = string(SkinActor.Mesh.Name);

	if ( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if (TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture',True));
	else if ( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));
	else if ( Left(SkinName,8)~="UnrealI." ) // Handle special skins.
	{
		Chck = Caps(Mid(SkinName,8));
		i = InStr(Chck,".");
		if ( i>=0 )
			Chck = Mid(Chck,i+1);
		if ( MeshName~="Female2" )
		{
			if ( Chck!="F2FEMALE2" && Chck!="F2FEMALE4" )
				Return;
		}
		else if ( MeshName~="Male1" )
		{
			if ( Left(Chck,5)!="JMALE" || Right(Chck,2)=="22" ) // Disallow Ivan Male2 skin on Male1 mesh.
				Return;
		}
		else Return;
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));
	}
	else if ( (Left(SkinName,17)~="UnrealShare.JNali" || Left(SkinName,23)~="UnrealShare.Skins.JNali") && Left(MeshName,4)~="Nali" && !(Right(SkinName,5)~="Fruit") ) // Handle more special skins.
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));

	// Set skin
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;
}

function class<Actor> B227_BotpackExtrasVersionClass()
{
	return class'Botpack.B227_ExtrasVersion'; // makes class B227_ExtrasVersion loaded
}

defaultproperties
{
	bSinglePlayer=True
	Intelligence=BRAINS_HUMAN
	bCanStrafe=True
	MeleeRange=50.00
	GroundSpeed=400.00
	AirSpeed=400.00
	AccelRate=2048.00
	UnderWaterTime=20.00
	Land=Sound'Land1'
	WaterStep=Sound'LSplash'
	AnimSequence=WalkSm
	DrawType=DT_Mesh
	LightBrightness=70
	LightHue=40
	LightSaturation=128
	LightRadius=6
	RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
	bNoDynamicShadowCast=false
}
