// Krall staff weapon
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCKrallStaff extends NCWeapon;

var float TwirlTime;
var bool bFirePos;
var int lastHit;

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'krallstaffl';
	else
		Mesh = mesh'krallstaff';
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
	PlayAnim( 'Fire', 2.25 );
	//Owner.PlaySound(FireSound);
}

function PlayHitting()
{
	switch (lastHit) {
		case 0:
			PlayAnim('Hit1');
			break;
		case 1:
			PlayAnim('Hit2');
			break;
		case 2:
			PlayAnim('Hit3');
			break;
		default:
			PlayAnim('Hit1');
			break;
	}
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

	function EndState() {
		if (bFirePos)
			PlayAnim('PutUp');
		Super.EndState();
	}

Begin:
	if (canHitClose() || AmmoType == None || AmmoType.AmmoAmount <= 0) { // melee attack
		if ((lastHit >= 2) && (FRand() > 0.5)) {
			PlayAnim('PutUp');
			bFirePos = false;
			FinishAnim();
			lastHit = 0;
			PlayHitting();
			Sleep(0.5);
			TraceFire(0.0);
		}
		else {
			if (bFirePos) {
				if ((FRand() > 0.2 && lastHit != 1) || (FRand() > 0.6))
					lastHit = 1;
				else
					lastHit = 2;
				PlayHitting();
				Sleep(0.2*lastHit);
				TraceFire(0.0);
			}
			else {
				if (FRand() > 0.6) {
					PlayAnim('PutDown');
					bFirePos = true;
					FinishAnim();
					lastHit = 1;
					PlayHitting();
					Sleep(0.2);
					TraceFire(0.0);
				}
				else {
					lastHit = 0;
					PlayHitting();
					Sleep(0.5);
					TraceFire(0.0);
				}
			}
		}
	}
	else {
		AmmoType.UseAmmo(1);
		if (!bFirePos) {
			PlayAnim('PutDown');
			bFirePos = true;
			FinishAnim();
		}
		PlayShooting();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
	TwirlTime = -2;
	FinishAnim();
	if (Pawn(Owner).bFire==0) {
		if (bFirePos) {
			bFirePos = false;
			PlayAnim('PutUp');
		}
		Finish();
	}
	else {
		Goto('Begin');
	}
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + (FireOffset.Z/4) * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 100 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	Owner.PlaySound(Misc2Sound);

	if (lastHit == 1)
		Other.TakeDamage(30, Pawn(Owner), HitLocation, 110000 * X, AltDamageType);
	else
		Other.TakeDamage(60, Pawn(Owner), HitLocation, 140000 * X, AltDamageType);
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
	if ( AnimSequence == 'Sway1' || AnimSequence == 'Sway2' || AnimSequence == 'Sway3') {
		TwirlTime += DeltaTime;
		if (TwirlTime >= 3.0) {
			if (FRand() > 0.5)
				PlayAnim('Twirl');
			TwirlTime = 0;
		}
	}
}

function PlayIdleAnim()
{
	local float r;

	r = FRand();
	if (r > 0.66)
		PlayAnim('Sway1');
	else if (r > 0.33)
		PlayAnim('Sway2');
	else
		PlayAnim('Sway3');
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
     InfoTexture=Texture'NaliChronicles.Icons.krallstaffInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCKrallAmmo'
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=50.000000,Y=-8.000000,Z=-22.000000)
     ProjectileClass=Class'NaliChronicles.NCKrallBolt'
     MyDamageType=zapped
     AltDamageType=slashed
     RefireRate=1.000000
     SelectSound=Sound'UnrealI.Pickups.DampSnd'
     Misc1Sound=Sound'UnrealShare.Manta.fly1m'
     Misc2Sound=Sound'UnrealI.Krall.hit2k'
     DeathMessage="%k executed %o with a %w."
     InventoryGroup=4
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found a Krall staff."
     ItemName="Krall staff"
     PlayerViewOffset=(X=3.000000,Y=-1.500000,Z=-0.700000)
     PlayerViewMesh=LodMesh'NaliChronicles.krallstaff'
     PlayerViewScale=0.050000
     PickupViewMesh=LodMesh'NaliChronicles.krallstaffpick'
     PickupViewScale=0.800000
     ThirdPersonMesh=LodMesh'NaliChronicles.krallstaffthird'
     ThirdPersonScale=0.800000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.krallstaffIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.krallstaffpick'
     AmbientGlow=0
     bNoSmooth=False
}
