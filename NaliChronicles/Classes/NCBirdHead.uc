// The bird's head on the prophet's staff
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec TEXTURE IMPORT NAME=Jstaffbird FILE=TEXTURES\staffbirdskin.pcx GROUP=Skins PALETTE=Jstaffbird

class NCBirdHead extends NCDragonHead;

function AnimEnd() {
	if ((AnimSequence == 'Sway1' || AnimSequence == 'Sway2') && FRand() > 0.25)
		Owner.PlaySound(TalkSound[Rand(3)]);
	bAnimOver = true;
	staff.AnimEnd();
}

function setHand(float Hand)
{
	Super.setHand(Hand); // to get the smoke position
	if ( Hand == 1 )
		Mesh = mesh'staffbirdl';
	else
		Mesh = mesh'staffbird';
}

function ProcessTraceHit(vector HitLocation, vector HitNormal, actor Other, vector X, vector Y, vector Z) {
	Owner.PlaySound(HitSound);

	Other.TakeDamage(30, Pawn(Owner), HitLocation, 15000 * X, 'slashed');
	spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
	createSmoke();
}

function createSmoke() {
	local actor a;
	local vector effectlocation, X,Y,Z;
	local int i;

	GetAxes(pawn(owner).viewrotation,X,Y,Z);
	while (i < 5) {
		effectlocation = owner.location;
		effectlocation += staff.CalcDrawOffset();
		effectlocation += (-17+BigRand())*Z + (BigRand()+SmokeOffset.Y+(SmokeW/2))*Y + (40+BigRand())*X;
		a = Spawn(Class'NaliChronicles.NCHolySpark',,,effectlocation,pawn(owner).viewrotation);
		a.LightHue = 152;
		a.Texture = magicsparkskin[Rand(8)];
		i++;
	}
}

function ProjectileFire(float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local Pawn PawnOwner;
	local NCDevineBolt fb;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + staff.CalcDrawOffset() + staff.FireOffset.X * X + staff.FireOffset.Y * Y + staff.FireOffset.Z * Z;
	staff.AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, staff.AimError, True, bWarn);
	fb = Spawn(Class'NaliChronicles.NCDevineBolt',,, Start,staff.AdjustedAim);
	fb.damage = 250 + (FRand()*50);
	fb.drawScale += fb.damage/750;
	fb.gotoState('Flying');
	createSmoke();
}

defaultproperties
{
     MeleeSound=Sound'UnrealShare.Manta.injur2m'
     HitSound=Sound'UnrealShare.Manta.thumpmt'
     TalkSound(0)=Sound'UnrealShare.Bird.call2b'
     TalkSound(1)=Sound'UnrealShare.Manta.call1m'
     TalkSound(2)=Sound'UnrealShare.Manta.call2m'
     FireSound=Sound'UnrealShare.Manta.injur1m'
     SelectSound=Sound'UnrealShare.Manta.death2m'
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(1)=Texture'Botpack.RipperPulse.HEexpl1_a01'
     magicsparkskin(2)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicsparkskin(3)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(6)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(7)=Texture'UnrealShare.SKEffect.Skj_a00'
     sLightColor=152
     Style=STY_Masked
     Mesh=LodMesh'NaliChronicles.staffbird'
}
