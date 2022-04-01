// Weak Skaarj weapon
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkaarjGun extends NCWeapon;

var float TwirlTime;
var() sound FleshSound, DecoSound, HitSound;

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'skaarjgunl';
	else
		Mesh = mesh'skaarjgunr';
}

function DoFire( float Value )
{
	GotoState('NormalFire');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	ClientFire(value);
}

function PlayShooting()
{
      AnimSequence = '';
	PlayAnim( 'Fire', 2.25 );
	//Owner.PlaySound(FireSound);
}

function PlayHitting()
{
	if (FRand() > 0.5)
		PlayAnim('Cut1');
	else
		PlayAnim('Cut2');
	Owner.PlaySound(Misc1Sound);
}

function bool canHitClose() {
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 100 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if (Other != none)
		return true;
	return false;
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
	if (canHitClose() || AmmoType == None || AmmoType.AmmoAmount <= 0) { // melee attack
		PlayHitting();
		Sleep(0.2);
		TraceFire(0.0);
	}
	else {
		AmmoType.UseAmmo(1);
		PlayShooting();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		sleep(0.3);
	}
	TwirlTime = -2;
	FinishAnim();
	if (Pawn(Owner).bFire==0)
		Finish();
	else
		Goto('Begin');
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 100 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if (Pawn(Other) != none)
		Owner.PlaySound(FleshSound);
	else if (Decoration(Other) != none)
		Owner.PlaySound(DecoSound);
	else
		Owner.PlaySound(HitSound);

	Other.TakeDamage(35.0, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
}

state Idle
{
	function AnimEnd() {
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	function Fire(float f) {
		global.Fire(f);
	}

Begin:
	bPointing=False;
	if ( Pawn(Owner).bFire!=0 )
		Fire(0.0);
	FinishAnim();
	AnimFrame=0;
	PlayIdleAnim();
	Goto('Begin');
}

function Tick(float DeltaTime) {
	if ( AnimSequence == 'Idle1' || AnimSequence == 'Idle') {
		TwirlTime += DeltaTime;
		if (TwirlTime >= 3.0) {
			if (FRand() > 0.5)
				PlayAnim('Idle2');
			TwirlTime = 0;
		}
	}
}

function PlayIdleAnim()
{
	if (FRand() > 0.5)
		PlayAnim('Idle1');
	else
		PlayAnim('Idle');
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
	else if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else
		GotoState('Idle');
}

defaultproperties
{
     FleshSound=Sound'UnrealI.Razorjack.BladeThunk'
     DecoSound=Sound'UnrealI.General.Endpush'
     HitSound=Sound'UnrealI.Razorjack.BladeHit'
     InfoTexture=Texture'NaliChronicles.Icons.SkaarjGunInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCSkaarjBullets'
     PickupAmmoCount=50
     FireOffset=(X=40.000000,Y=-10.000000,Z=-3.000000)
     ProjectileClass=Class'NaliChronicles.NCSkaarjBullet'
     MyDamageType=zapped
     AltDamageType=slashed
     RefireRate=1.000000
     SelectSound=Sound'Botpack.PulseGun.PulsePickup'
     Misc1Sound=Sound'UnrealShare.Manta.fly1m'
     DeathMessage="%k filled %o with energy bolts from his %w."
     InventoryGroup=3
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found a Skaarj pistol."
     ItemName="Skaarj pistol"
     PlayerViewOffset=(X=4.500000,Y=-1.750000,Z=-1.400000)
     PlayerViewMesh=LodMesh'NaliChronicles.skaarjgunr'
     PlayerViewScale=0.070000
     PickupViewMesh=LodMesh'NaliChronicles.skaarjgun'
     PickupViewScale=0.700000
     ThirdPersonMesh=LodMesh'NaliChronicles.skaarjgunthird'
     ThirdPersonScale=0.700000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.SkaarjGunIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.skaarjgun'
     AmbientGlow=0
     bNoSmooth=False
}
