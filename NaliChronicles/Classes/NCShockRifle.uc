// The human weapon
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCShockRifle extends NCWeapon;

var() int HitDamage;

function DoFire(float F) { // the actual fire function
	if (AmmoType.UseAmmo(1))
	{
		GotoState('NormalFire');
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		bPointing=True;
		PlayFiring();
		if ( !bRapidFire && (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		TraceFire(0.4);
		if ( Owner.bHidden )
			CheckVisibility();
	}
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.40 + 0.40 * FireAdjust,0.05);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;
	local actor a;

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	a = Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) )
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}


function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'ShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Still',0.04,0.3);
}

state Idle
{

	function BeginState()
	{
		bPointing = false;
		SetTimer(0.5 + 2 * FRand(), false);
		Super.BeginState();
		if (Pawn(Owner).bFire!=0) Fire(0.0);
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}
}

function Finish()
{
	local Pawn PawnOwner;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( PawnOwner.bFire!=0 )
		Global.Fire(0);
	else
		GotoState('Idle');
}

function AltFire(float f) {
	// do nothing
}

defaultproperties
{
     hitdamage=25
     InfoTexture=Texture'NaliChronicles.Icons.ASMDInfo'
     InstFlash=-0.400000
     InstFog=(Z=800.000000)
     AmmoName=Class'NaliChronicles.NCShockCore'
     PickupAmmoCount=40
     bInstantHit=True
     bSplashDamage=True
     FiringSpeed=2.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.000000)
     MyDamageType=jolted
     AIRating=0.630000
     FireSound=Sound'UnrealShare.ASMD.TazerFire'
     SelectSound=Sound'UnrealShare.ASMD.TazerSelect'
     DeathMessage="%k inflicted mortal damage upon %o with the %w."
     InventoryGroup=7
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You got the ASMD Assault Rifle."
     ItemName="ASMD Assault Rifle"
     PlayerViewOffset=(X=4.400000,Y=-1.700000,Z=-1.600000)
     PlayerViewMesh=LodMesh'Botpack.ASMD2M'
     PlayerViewScale=2.000000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.ASMD2pick'
     ThirdPersonMesh=LodMesh'Botpack.ASMD2hand'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.ASMDIcon'
     Mesh=LodMesh'Botpack.ASMD2pick'
     AmbientGlow=0
     bNoSmooth=False
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     Mass=50.000000
}
