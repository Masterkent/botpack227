// Skaarj rail gun type weapon
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec TEXTURE IMPORT NAME=ScopeCutout FILE=TEXTURES\ScopeCutout.pcx GROUP=Icons MIPS=OFF FLAGS=2

class NCSkaarjCannon extends NCWeapon;

var float rechargeTime;
var float HitDamage;
var int attacktype;
var() sound FleshSound, DecoSound, HitSound;

var PlayerPawn B227_ZoomingPlayer;
var bool B227_bZooming;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		B227_bZooming;
}

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	//-if (AnimSequence == 'ScopeStill' ||
	//-    (AnimSequence == 'ScopeUp' && PlayerPawn(Owner).DesiredFOV != PlayerPawn(Owner).DefaultFOV)) {
	if (B227_bZooming)
	{
		bOwnsCrosshair = true;
		/*Canvas.CurX = 0;
		Canvas.CurY = 0;
		Canvas.Style = 2;
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.DrawRect(Texture'NaliChronicles.ScopeCutout',Canvas.ClipX,Canvas.ClipY);*/
		Canvas.CurX = Canvas.ClipX/2-128*(Canvas.ClipX/1024);
		Canvas.CurY = Canvas.ClipY/2-128*(Canvas.ClipX/1024);
		Canvas.Style = 3;
		Canvas.DrawColor = Canvas.default.DrawColor;
		Canvas.DrawIcon(Texture'NaliChronicles.ScopeCH',Canvas.ClipX/1024);
	}
	else if (bOwnsCrosshair) bOwnsCrosshair = false;
}

simulated event RenderOverlays( canvas Canvas )
{
	Texture'RLMFD'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'RLMFD'.NotifyActor = None;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local float r;

	r = HitDamage/default.HitDamage;
	Tex.DrawTile(0,128*(1-r),32,128*r,0,128*(1-r),32,128*r,Texture'NCSkaarjSideL',false);
}

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'skaarjcannonl';
	else
		Mesh = mesh'skaarjcannonr';
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
	if (AnimSequence != 'ScopeUp') {
      	AnimSequence = '';
		PlayAnim( 'Fire', 2.25 );
	}
	else {
	      AnimSequence = '';
		PlayAnim( 'ScopeStill', 2.25 );
	}
	Owner.PlaySound(FireSound,,4.5);
}

function PlayHitting()
{
	if (FRand() > 0.5) {
		PlayAnim('Cut2');
		attacktype = 1;
	}
	else {
		PlayAnim('Cut1');
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

	event EndState()
	{
		B227_EndZoom();
		super.EndState();
	}

Begin:
	if ((canHitClose() && AnimSequence != 'ScopeUp') || AmmoType == None || AmmoType.AmmoAmount <= 0) { // melee attack
		PlayHitting();
		Sleep(0.2*attacktype);
		TraceFire(0.0);
	}
	else {
		sleep(0.17);
		if (Pawn(Owner) == none)
			stop;
		if (Pawn(Owner).bFire == 0 || PlayerPawn(Owner) == none) {
			AmmoType.UseAmmo(1);
			PlayShooting();
			RangedTraceFire(0.0);
			if (AnimSequence == 'ScopeStill' && PlayerPawn(Owner) != none) {
				PlayerPawn(Owner).StopZoom();
				FinishAnim();
				B227_EndZoom();
				//-PlayerPawn(Owner).DesiredFOV = PlayerPawn(Owner).defaultFOV;
				//-Pawn(Owner).FovAngle = PlayerPawn(Owner).defaultFOV;
				//-PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(0,0,-255));
				PlayAnim('ScopeDwn');
			}
		}
		else {
			if (AnimSequence != 'ScopeUp') {
				PlayAnim('ScopeUp');
				FinishAnim();
				B227_StartZoom();
				//-PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(0,0,255));
				//-PlayerPawn(Owner).ToggleZoom();
			}
			else {
				sleep(0.1);
			}
			GoTo('Begin');
		}
	}
	FinishAnim();
	if (Pawn(Owner).bFire==0)
		Finish();
	else
		Goto('Begin');
}

function RangedTraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + Pawn(Owner).Eyeheight * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	EndTrace = StartTrace + (10000 * vector(AdjustedAim));
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	//if (Other != none)
	//	EndTrace = HitLocation+10*X;
	//StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	//Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal,X,Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;
	local actor a;
	local vector SmokeLocation,DVector;
	local rotator SmokeRotation;
	local float NumPoints;

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	SmokeLocation = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * 3.3 * Y + FireOffset.Z * Z * 3.0;
	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/70.0;
	SmokeLocation += DVector/NumPoints;
	SmokeRotation = rotator(HitLocation-Owner.Location);
	if (NumPoints>15) NumPoints=15;
	if ( NumPoints>1.0 ) SpawnRingEffect(DVector, NumPoints, SmokeRotation, SmokeLocation);

	a = Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));
	a.DrawScale*=(HitDamage/default.HitDamage)*1.5;
	a = Spawn( class'FlameExplosion',,,HitLocation+HitNormal*8,rotator(HitNormal));
	a.DrawScale*=(HitDamage/default.HitDamage);

	if ( (Other != self) && (Other != Owner) && (Other != None) ) {
		if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight) )
			Other.TakeDamage(HitDamage*2.5, Pawn(Owner), HitLocation, 60000.0*X, 'Decapitated');
		else
			Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
	}
	HitDamage = default.HitDamage/10;
}

function SpawnRingEffect(Vector DVector, int NumPoints, rotator SmokeRotation, vector SmokeLocation)
{
	local NCSkaarjRingExplosion Smoke;

	Smoke = Spawn(class'NCSkaarjRingExplosion',,,SmokeLocation,SmokeRotation);
      Smoke.DrawScale *= HitDamage/default.HitDamage;
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints;
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local SuperShockBeam Smoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
	Smoke.DrawScale*=HitDamage/default.HitDamage;
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + (100+(50*(attacktype-1))) * vector(AdjustedAim);
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

function Tick(float DeltaTime) {
	if (Owner != none) {
		rechargeTime += DeltaTime;
		while (rechargeTime >= 0.25) {
			rechargeTime -= 0.25;
			if (isInState('NormalFire') && AmmoType.AmmoAmount < 2) return; // leave 1 ammo to shoot with

			if ((HitDamage < default.HitDamage) && AmmoType.UseAmmo(1))
				HitDamage += default.HitDamage/10;
		}
	}
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

function PlayIdleAnim()
{
	local float d;

	d = FRand();
	if (d > 0.4)
		PlayAnim('Idle');
	else if (d > 0.2)
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

function B227_StartZoom()
{
	if (B227_bZooming)
		return;

	if (PlayerPawn(Owner) != none)
	{
		B227_bZooming = true;
		B227_ZoomingPlayer = PlayerPawn(Owner);
		B227_ZoomingPlayer.StartZoom();
		B227_ZoomingPlayer.ClientAdjustGlow(0.15, vect(0,0,255));
	}
}

function B227_EndZoom()
{
	if (!B227_bZooming)
		return;
	B227_bZooming = false;
	if (B227_ZoomingPlayer != none)
	{
		B227_ZoomingPlayer.ClientAdjustGlow(-0.15, vect(0,0,-255));
		B227_ZoomingPlayer.EndZoom();
		B227_ZoomingPlayer = none;
	}
}

defaultproperties
{
     hitdamage=90.000000
     FleshSound=Sound'UnrealI.Razorjack.BladeThunk'
     DecoSound=Sound'UnrealI.General.Endpush'
     HitSound=Sound'UnrealI.Razorjack.BladeHit'
     InfoTexture=Texture'NaliChronicles.Icons.SkaarjCannonInfo'
     AmmoName=Class'NaliChronicles.NCSkaarjBullets'
     PickupAmmoCount=50
     bInstantHit=True
     bWarnTarget=True
     FireOffset=(X=30.000000,Y=-6.000000,Z=-5.000000)
     MyDamageType=zapped
     AltDamageType=slashed
     RefireRate=1.000000
     FireSound=Sound'UnrealShare.General.Expla02'
     SelectSound=Sound'Botpack.Redeemer.WarheadPickup'
     Misc1Sound=Sound'UnrealShare.Manta.fly1m'
     DeathMessage="%k obliterated %o with his %w."
     InventoryGroup=9
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found the Skaarj Cannon."
     ItemName="Skaarj Cannon"
     PlayerViewOffset=(X=2.200000,Y=-1.750000,Z=-2.200000)
     PlayerViewMesh=LodMesh'NaliChronicles.skaarjCannonr'
     PlayerViewScale=0.070000
     PickupViewMesh=LodMesh'NaliChronicles.skaarjCannonpick'
     PickupViewScale=0.700000
     ThirdPersonMesh=LodMesh'NaliChronicles.skaarjCannonthird'
     ThirdPersonScale=0.500000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.SkaarjCannonIcon'
     Mesh=LodMesh'NaliChronicles.skaarjCannonpick'
     AmbientGlow=0
     bNoSmooth=False
}
