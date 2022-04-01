// The dragon's head on the prophet's staff
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDragonHead extends Actor;

var travel NCProphetStaff staff;
var travel bool bAnimOver;
var() sound MeleeSound, HitSound;
var actor smoke1, smoke2; // smoke from nostrils
var() vector smokeOffset;
var() float smokeW;
var() sound TalkSound[3];
var() sound FireSound;
var travel float headLastTime;
var travel float starttime;
var() sound selectsound;
var() Texture magicsparkskin[8];
var() int sLightColor;

function Tick(float DeltaTime) {
	local rotator NewRot;
	local int Hand;
	local PlayerPawn PlayerOwner;
	local vector X,Y,Z;

	if ( staff.bHideWeapon || (Owner == None) )
		return;

	if (staff.Style == STY_Translucent) {
		Style = staff.Style;
		ScaleGlow = staff.ScaleGlow;
	}
	else {
		Style = default.Style;
	}

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		Hand = PlayerOwner.Handedness;
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
	}
	SetLocation( Owner.Location + staff.CalcDrawOffset() );
	NewRot = Pawn(Owner).ViewRotation;

	if ( Hand == 0 )
		newRot.Roll = -2 * staff.Default.Rotation.Roll;
	else
		newRot.Roll = staff.Default.Rotation.Roll * Hand;

	setRotation(newRot);
	getAxes(PlayerOwner.viewrotation,X,Y,Z);
	if (smoke1 != none)
		smoke1.setLocation(Owner.Location + staff.CalcDrawOffset()
		                   + smokeOffset.x*X + smokeOffset.z*Z + smokeOffset.y*Y);
	if (smoke2 != none)
		smoke2.setLocation(Owner.Location + staff.CalcDrawOffset()
				       + smokeOffset.x*X + smokeOffset.z*Z + smokeOffset.y*Y + smokeW*Y);

	if ((level.timeseconds-starttime) > headLastTime) {
		staff.fRemoveHead();
	}
}

function PostBeginPlay() {
	Super.PostBeginPlay();
	starttime = level.timeseconds;
	if (PlayerPawn(Owner) != none) {
		setHand(playerpawn(owner).handedness);
	}
	//setTimer(0.1,true);
}

/*function Timer() {
	local actor a;
	local vector effectlocation, X,Y,Z;

	GetAxes(pawn(owner).viewrotation,X,Y,Z);
	effectlocation = owner.location;
	effectlocation += staff.CalcDrawOffset();
	effectlocation += (-10+BigRand())*Z + (BigRand()+SmokeOffset.Y+(SmokeW/2))*Y + (40+BigRand())*X;
	a = Spawn(Class'NaliChronicles.NCHolySpark',,,effectlocation,pawn(owner).viewrotation);
	a.DrawScale *= 0.6;
	a.LightBrightness *= 0.2;
	a.LightRadius *= 0.2;
	a.LightHue = sLightColor;
	a.Texture = magicsparkskin[Rand(8)];
	a.velocity = vect(0,0,400);
}*/

function float BigRand() {
	local float f;

	f = Frand()*5;
	if (Frand() >= 0.5)
		f = -f;
	return f;
}

function setHand(float Hand)
{
	if ( Hand == 1 ) {
		Mesh = mesh'dragonheadl';
		SmokeOffset.Y = -default.SmokeOffset.Y;
		smokeW = -default.smokeW;
	}
	else {
		Mesh = mesh'dragonhead';
		SmokeOffset.Y = default.SmokeOffset.Y;
		smokeW = default.smokeW;
	}
}

function AnimEnd() {
	if ((AnimSequence == 'Sway1' || AnimSequence == 'Sway2') && FRand() > 0.6) {
		createSmoke();
		Owner.PlaySound(Sound'UnrealShare.ASMD.Vapour');
	}
	if ((AnimSequence == 'Sway1' || AnimSequence == 'Sway2') && FRand() > 0.25)
		Owner.PlaySound(TalkSound[Rand(3)]);
	bAnimOver = true;
	staff.AnimEnd();
}

function ProcessTraceHit(vector HitLocation, vector HitNormal, actor Other, vector X, vector Y, vector Z) {
	local actor a;
	local SpriteSmokePuff s;

	Owner.PlaySound(HitSound);

	Other.TakeDamage(40, Pawn(Owner), HitLocation, 15000 * X, 'slashed');
	//if ( !Other.bIsPawn && !Other.IsA('Carcass') )
	spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
	createSmoke();
}

function createSmoke() {
	local vector X,Y,Z;

	if (playerpawn(owner) == none) return;
	if (smoke1 != none) smoke1.destroy();
	if (smoke2 != none) smoke2.destroy();
	GetAxes(PlayerPawn(Owner).viewrotation,X,Y,Z);
	smoke1 = spawn(class'SmokeColumn',,,Owner.Location + staff.CalcDrawOffset()
			   + smokeOffset.x*X + smokeOffset.z*Z + smokeOffset.y*Y);
	smoke1.drawscale /= 10;
	smoke2 = spawn(class'SmokeColumn',,,Owner.Location + staff.CalcDrawOffset()
		         + smokeOffset.x*X + smokeOffset.z*Z + smokeOffset.y*Y + smokeW*Y);
	smoke2.drawscale /= 10;
}

function ProjectileFire(float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local Pawn PawnOwner;
	local NCFireball fb;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + staff.CalcDrawOffset() + staff.FireOffset.X * X + staff.FireOffset.Y * Y + staff.FireOffset.Z * Z;
	staff.AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, staff.AimError, True, bWarn);
	fb = Spawn(Class'NaliChronicles.NCFireball',,, Start,staff.AdjustedAim);
	fb.damage = 200 + (FRand()*20);
	fb.drawScale += fb.damage/400;
	fb.gotoState('Flying');
      createSmoke();
	spawn(class'SawHit',,,Start, staff.AdjustedAim);
}

defaultproperties
{
     MeleeSound=Sound'UnrealShare.Skaarj.claw2s'
     HitSound=Sound'UnrealShare.Skaarj.clawhit1s'
     smokeOffset=(X=50.000000,Y=1.000000,Z=-7.000000)
     smokeW=5.000000
     TalkSound(0)=Sound'UnrealShare.Skaarj.roam11s'
     TalkSound(1)=Sound'UnrealShare.Skaarj.spin1s'
     TalkSound(2)=Sound'UnrealShare.Skaarj.death1sk'
     FireSound=Sound'UnrealShare.Skaarj.death2sk'
     SelectSound=Sound'UnrealShare.Skaarj.lunge1sk'
     magicsparkskin(0)=Texture'Botpack.utsmoke.s3r_a00'
     magicsparkskin(1)=Texture'Botpack.utsmoke.us10_a00'
     magicsparkskin(2)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.us4_a00'
     magicsparkskin(4)=Texture'Botpack.utsmoke.us5_a00'
     magicsparkskin(5)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(6)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(7)=FireTexture'UnrealShare.Effect16.fireeffect16'
     bHidden=True
     DrawType=DT_Mesh
     Mesh=LodMesh'NaliChronicles.dragonhead'
     bTravel=True
}
