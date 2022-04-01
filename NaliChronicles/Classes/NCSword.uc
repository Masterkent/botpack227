// Nali sword weapon
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSword extends NCWeapon;

var() float Range;
var() sound HitSound, DownSound, FleshSound, DecoSound;
var float TwirlTime;
var int attackstyle;

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'naliswordl';
	else
		Mesh = mesh'nalisword';
}

function PickAttackStyle() {
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 100 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if (Other == none) {
		attackstyle = Rand(2);
	}
	else {
		if (VSize(HitLocation - Start) <= 45) // very close, use stab
			attackstyle = 2;
		else if (VSize(HitLocation - Start) <= 75)
			attackstyle = 1;
		else
			attackstyle = 0;
		if ((attackstyle == 2) && (Frand() > 0.7))
			attackstyle = Rand(3);
		if ((attackstyle == 1) && (Frand() > 0.84))
			attackstyle = Rand(3);
	}
}

function DoFire( float Value )
{
	//Pawn(Owner).ClientMessage("FIRE!");
	PickAttackStyle();
	GotoState('NormalFire');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	ClientFire(value);
}

function PlayFiring()
{
	if (attackstyle == 0)
		PlayAnim( 'Stab', 1.0 );
	else if (attackstyle == 1)
		PlayAnim( 'Slash', 1.0 );
	else
		PlayAnim( 'DownStab', 1.0 );
	Owner.PlaySound(FireSound);
}

function EndFiring()
{
	LoopAnim('Idle', 1.0);
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

	function BeginState() {
		//Pawn(Owner).ClientMessage("FIRE STATE STARTS!");
	}

	function EndState() {
		//Pawn(Owner).ClientMessage("FIRE STATE OVER!");
	}

Begin:
	Sleep(0.5);
	TraceFire(0.0);
	FinishAnim();
	if (Pawn(Owner).bFire==0)
		EndFiring();
	//FinishAnim();
	Finish();
}

state Idle
{
	//function AnimEnd() {
	//	if (Pawn(Owner).bFire==0)
	//		PlayIdleAnim();
	//}

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

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim( 'Idle' );
}

function Tick(float DeltaTime) {
	if ( AnimSequence == 'Idle' ) {
		TwirlTime += DeltaTime;
		if (TwirlTime >= 3.0) {
			if (FRand() > 0.5)
				PlayAnim('Twirl');
			TwirlTime = 0;
		}
	}
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

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	TwirlTime = -2; // set back twirl time to make sure we don't twirl between attacks
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + (Range) * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if (Pawn(Other) != none)
		Owner.PlaySound(FleshSound);
	else if (Decoration(Other) != none)
		Owner.PlaySound(DecoSound);
	else
		Owner.PlaySound(HitSound);

	if (attackstyle != 1)
		Other.TakeDamage((10.0*(attackstyle+1))+10, Pawn(Owner), HitLocation, 15000 * X, MyDamageType);
	else
		Other.TakeDamage(30.0, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
}

function TweenDown()
{
	Owner.PlaySound(SelectSound);
	Super.TweenDown();
	AmbientSound = None;
}

defaultproperties
{
     Range=90.000000
     HitSound=Sound'UnrealI.Razorjack.BladeHit'
     FleshSound=Sound'UnrealI.Razorjack.BladeThunk'
     DecoSound=Sound'UnrealI.General.Endpush'
     InfoTexture=Texture'NaliChronicles.Icons.NaliSwordInfo'
     bHasHand=True
     bInstantHit=True
     bMeleeWeapon=True
     bRapidFire=True
     FireOffset=(X=14.000000,Y=-3.500000,Z=5.000000)
     MyDamageType=slashed
     AltDamageType=Decapitated
     RefireRate=1.000000
     FireSound=Sound'UnrealShare.Manta.fly1m'
     SelectSound=Sound'UnrealShare.Skaarj.blade1s'
     DeathMessage="%k slashed down %o with a blood soaked %w."
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found a short Nali sword."
     ItemName="sword"
     PlayerViewOffset=(X=2.000000,Y=-1.500000,Z=-0.900000)
     PlayerViewMesh=LodMesh'NaliChronicles.nalisword'
     PlayerViewScale=0.080000
     PickupViewMesh=LodMesh'NaliChronicles.naliswordpick'
     PickupViewScale=0.500000
     ThirdPersonMesh=LodMesh'NaliChronicles.naliswordthird'
     ThirdPersonScale=0.500000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.NaliSwordIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.naliswordpick'
     AmbientGlow=0
     bNoSmooth=False
}
