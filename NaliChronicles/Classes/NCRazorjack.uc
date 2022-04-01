// Nali Chronicles version of the popular weapon - alt fire removed and melee mode added
// Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCRazorjack extends NCWeapon;

var() sound FleshSound, DecoSound, HitSound;

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(500, 0, 650));
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z + FireOffset.Y * Y;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

function DoFire(float value)
{
	GotoState('NormalFire');
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	bPointing=True;
	if ( !bRapidFire && (FiringSpeed > 0) )
		Pawn(Owner).PlayRecoil(FiringSpeed);
	if (canHitClose() || ammotype.ammoamount <= 0) {
		PlayAltFiring();
		TraceFire(0.0);
	}
	else {
		AmmoType.UseAmmo(1);
		PlayFiring();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
	if ( Owner.bHidden )
		CheckVisibility();
}

function bool canHitClose() {
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 60 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if (Other != none)
		return true;
	return false;
}

function PlayAltFiring()
{
	PlayAnim( 'Fire', 0.7,0.05 );
      PlaySound(FireSound);
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * 2 * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 60 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if (Pawn(Other) != none)
		Owner.PlaySound(FleshSound);
	else if (Decoration(Other) != none)
		Owner.PlaySound(DecoSound);
	else
		Owner.PlaySound(HitSound);

	Other.TakeDamage(50.0, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
}

function PlayFiring()
{
	PlayAnim( 'Fire', 0.7,0.05 );
}

function PlayIdleAnim()
{
	LoopAnim('Idle', 0.4);
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
		if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if (PawnOwner.Weapon != self)
		GotoState('Idle');
	else if ( PawnOwner.bFire!=0 )
		Global.Fire(0);
	else
		GotoState('Idle');
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
	Disable('AnimEnd');
	PlayIdleAnim();
}

defaultproperties
{
     FleshSound=Sound'UnrealI.Razorjack.BladeThunk'
     DecoSound=Sound'UnrealI.General.Endpush'
     HitSound=Sound'UnrealI.Razorjack.BladeHit'
     InfoTexture=Texture'NaliChronicles.Icons.razorjackInfo'
     AmmoName=Class'NaliChronicles.NCRazorAmmo'
     PickupAmmoCount=15
     FireOffset=(X=16.000000,Y=-10.000000,Z=-15.000000)
     ProjectileClass=Class'NaliChronicles.NCRazorBlade'
     shakemag=120.000000
     AIRating=0.500000
     RefireRate=0.830000
     AltRefireRate=0.830000
     FireSound=Sound'UnrealShare.Manta.fly1m'
     SelectSound=Sound'UnrealI.Razorjack.beam'
     DeathMessage="%k took a bloody chunk out of %o with the %w."
     InventoryGroup=6
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You got the Razorjack"
     ItemName="Razorjack"
     PlayerViewOffset=(X=2.000000,Y=-1.000000,Z=-0.900000)
     PlayerViewMesh=LodMesh'UnrealI.Razor'
     BobDamping=0.970000
     PickupViewMesh=LodMesh'UnrealI.RazPick'
     ThirdPersonMesh=LodMesh'UnrealI.Razor3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.razorjackicon'
     Mesh=LodMesh'UnrealI.RazPick'
     AmbientGlow=0
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=7.000000
     Mass=17.000000
}
