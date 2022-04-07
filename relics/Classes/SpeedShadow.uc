class SpeedShadow expands Effects;

simulated function PostBeginPlay()
{
	local int i;

	Mesh = Owner.Mesh;
	AnimFrame = Owner.AnimFrame;
	AnimSequence = Owner.AnimSequence;
	AnimRate = Owner.AnimRate;
	TweenRate = Owner.TweenRate;
	AnimMinRate = Owner.AnimMinRate;
	AnimLast = Owner.AnimLast;
	bAnimLoop = Owner.bAnimLoop;
	bAnimFinished = Owner.bAnimFinished;

	if ( Owner.IsA('Pawn') && Pawn(Owner).bIsMultiSkinned )
	{
		for (i=0; i<8; i++)
			MultiSkins[i] = Owner.MultiSkins[i];
	}
	else
		Skin = Owner.Skin;
}

simulated function Tick(float Delta)
{
	ScaleGlow -= 3*Delta;
	if (ScaleGlow <= 0)
		Destroy();
}

defaultproperties
{
     bAnimLoop=True
     bOwnerNoSee=True
     bHighDetail=True
     RemoteRole=ROLE_None
     AnimRate=17.000000
     LODBias=0.100000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.Soldier'
     bUnlit=True
}
