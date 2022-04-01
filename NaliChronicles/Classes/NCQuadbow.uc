// Nali Quadbow
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCQuadbow extends NCWeapon;

var bool bReloading;
var bool bReloaded;

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'quadbowl';
	else
		Mesh = mesh'quadbow';
}

function DoFire( float Value )
{
	bCanClientFire = true;
	bPointing=True;
	if (AmmoType.UseAmmo(4)) {
		GotoState('NormalFire');
		Pawn(Owner).PlayRecoil(FiringSpeed);
	}
	ClientFire(value);
}

function PlayShooting()
{
      AnimSequence = '';
	PlayAnim( 'Fire', 2.25 );
	Owner.PlaySound(FireSound);
}

function PlayReloading()
{
	PlayAnim('Reload');
	Owner.PlaySound(Misc1Sound);
	bReloaded = true;
}

function TweenDown()
{
	if ( (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') ) {
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	}
	else {
		if (bReloaded)
			PlayAnim('Down', 1.0, 0.05);
		else
			PlayAnim('DownEm', 1.0, 0.05);
	}
}

state NormalFire
{
	ignores AnimEnd;

	function Fire(float F)
	{
		//Pawn(Owner).ClientMessage("FFIRE!");
	}

	function AltFire(float F)
	{
	}

Begin:
	if (!bReloaded) {
		PlayReloading();
		FinishAnim();
	}
	PlayShooting();
	ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	bReloaded = false;
	FinishAnim();
	if (AmmoType.AmmoAmount >= 4) {
		PlayReloading();
		FinishAnim();
	}
	if (Pawn(Owner).bFire==0 || (!AmmoType.UseAmmo(4)))
		Finish();
	else
		Goto('Begin');
}

function BringUp()
{
	bReloaded = false;
	Super.BringUp();
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + (FireOffset.Y+5) * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	Spawn(ProjClass,,, Start,AdjustedAim);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + (FireOffset.Y-5) * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	Spawn(ProjClass,,, Start,AdjustedAim);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + (FireOffset.Z+10) * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	Spawn(ProjClass,,, Start,AdjustedAim);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + (FireOffset.Z-10) * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}


state Idle
{
	function AnimEnd() {
		if (bReloaded) {
			bReloading = false;
			PlayIdleAnim();
		}
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	function Fire(float f) {
		if (!bReloading)
			global.Fire(f);
	}

Begin:
	bPointing=False;
	FinishAnim();
	AnimFrame=0;
	if (bReloaded) {
		if ( Pawn(Owner).bFire!=0 && !bReloading)
			Fire(0.0);
		PlayIdleAnim();
		Goto('Begin');
	}
	else {
		if (AmmoType.AmmoAmount >= 4) {
			bReloading = true;
			PlayReloading();
			Goto('Begin');
		}
		else {
			PlayAnim('EmStill');
			Goto('Begin');
		}
	}
}

function PlayIdleAnim()
{
	local float d;

	d = FRand();
	if (d > 0.66)
		PlayAnim('Idle1');
	else if (d > 0.33)
		PlayAnim('Idle2');
	else
		PlayAnim('Idle3');
}

function Finish()
{
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( PlayerPawn(Owner) == None )
	{
		if ( (Pawn(Owner).bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if (PlayerPawn(Owner).Weapon != self)
		GotoState('Idle');
	else if ( Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount >= 4 )
		Global.Fire(0);
	else
		GotoState('Idle');
}

defaultproperties
{
     InfoTexture=Texture'NaliChronicles.Icons.QuadbowInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCNaliArrows'
     PickupAmmoCount=40
     bWarnTarget=True
     FireOffset=(X=40.000000,Y=-10.000000,Z=-5.000000)
     ProjectileClass=Class'NaliChronicles.NCArrow'
     RefireRate=1.000000
     FireSound=Sound'UnrealShare.General.ArrowSpawn'
     SelectSound=Sound'NaliChronicles.PickupSounds.DrawWoodWep'
     Misc1Sound=Sound'NaliChronicles.PickupSounds.DrawWoodWep'
     DeathMessage="%k nailed %o with his %w."
     InventoryGroup=5
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found the Nali quadbow."
     ItemName="Quadbow"
     PlayerViewOffset=(X=3.000000,Y=-1.750000,Z=-1.400000)
     PlayerViewMesh=LodMesh'NaliChronicles.quadbow'
     PlayerViewScale=0.070000
     PickupViewMesh=LodMesh'NaliChronicles.quadbowpick'
     PickupViewScale=0.700000
     ThirdPersonMesh=LodMesh'NaliChronicles.quadbowthird'
     ThirdPersonScale=0.700000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.QuadbowIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.quadbowpick'
     DrawScale=0.700000
     AmbientGlow=0
     bNoSmooth=False
}
