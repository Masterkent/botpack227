// Skaarj rocket launcher
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkaarjRL extends NCWeapon;

var int attacktype;
var float TwirlTime;
var() sound FleshSound, DecoSound, HitSound;

simulated event RenderOverlays( canvas Canvas )
{
	Texture'RLMFD'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'RLMFD'.NotifyActor = None;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local float ap;

	Tex.DrawTile(0,128*(1-(Float(AmmoType.AmmoAmount)/Float(AmmoType.MaxAmmo))),
                   32,128*(Float(AmmoType.AmmoAmount)/Float(AmmoType.MaxAmmo)),
                   0,128*(1-(Float(AmmoType.AmmoAmount)/Float(AmmoType.MaxAmmo))),
                   32,128*(Float(AmmoType.AmmoAmount)/Float(AmmoType.MaxAmmo)),Texture'NCSkaarjSideL',true);
	ap = AmmoType.AmmoAmount;
	while (ap > 8)
		ap -= 8;
	ap = ap/8;
	Tex.DrawTile(96,128*(1-ap),32,128*ap,0,128*(1-ap),32,128*ap,Texture'NCSkaarjSideL',true);
	if (canHitClose() || AmmoType.AmmoAmount <= 0)
		Tex.DrawTile(32,24,64,64,0,0,64,64,Texture'NCSkaarjMelee',true);
	else
		Tex.DrawTile(32,24,64,64,0,0,64,64,Texture'NCSkaarjRocket',true);
}

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'skaarjrll';
	else
		Mesh = mesh'skaarjrlr';
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
	Owner.PlaySound(FireSound);
}

function PlayHitting()
{
	if (FRand() > 0.5) {
		PlayAnim('Cut1');
		attacktype = 1;
	}
	else {
		PlayAnim('Cut2');
		attacktype = 2;
	}
	Owner.PlaySound(Misc1Sound);
}

function bool canHitClose() {
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 150 * vector(AdjustedAim);
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
		Sleep(0.2*attacktype);
		TraceFire(0.0);
	}
	else {
		AmmoType.UseAmmo(1);
		PlayShooting();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		sleep(0.6);
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
	EndTrace = Owner.Location + (150+(50*(attacktype-1))) * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if (Pawn(Other) != none)
		Owner.PlaySound(FleshSound);
	else if (Decoration(Other) != none)
		Owner.PlaySound(DecoSound);
	else
		Owner.PlaySound(HitSound);

	Other.TakeDamage(35.0*attacktype, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
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
	if ( AnimSequence == 'Idle1' || AnimSequence == 'Idle2' || AnimSequence == 'Idle3') {
		TwirlTime += DeltaTime;
		if (TwirlTime >= 3.0) {
			if (FRand() > 0.5)
				PlayAnim('Idle4');
			TwirlTime = 0;
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
     InfoTexture=Texture'NaliChronicles.Icons.SkaarjRLInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCSkaarjRLammo'
     PickupAmmoCount=16
     bWarnTarget=True
     FireOffset=(X=20.000000,Y=-10.000000,Z=-3.000000)
     ProjectileClass=Class'NaliChronicles.NCSkaarjRocket'
     AltDamageType=slashed
     RefireRate=1.000000
     FireSound=Sound'Botpack.PulseGun.PulseDown'
     SelectSound=Sound'Botpack.PulseGun.PulsePickup'
     Misc1Sound=Sound'UnrealShare.Manta.fly1m'
     DeathMessage="%k obliterated %o with his %w."
     InventoryGroup=8
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found the Skaarj Krun'ta rocket launcher."
     ItemName="Rocket Launcher"
     PlayerViewOffset=(X=2.000000,Y=-1.750000,Z=-1.400000)
     PlayerViewMesh=LodMesh'NaliChronicles.skaarjrlr'
     PlayerViewScale=0.070000
     PickupViewMesh=LodMesh'NaliChronicles.skaarjrlpick'
     PickupViewScale=0.700000
     ThirdPersonMesh=LodMesh'NaliChronicles.skaarjrlthird'
     ThirdPersonScale=0.700000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.SkaarjRLIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.skaarjrlpick'
     AmbientGlow=0
     bNoSmooth=False
}
