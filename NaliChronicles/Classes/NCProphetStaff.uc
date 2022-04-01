// Final weapon - the prophet staff
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCProphetStaff extends NCWeapon;

var float TwirlTime;
var bool bFirePos;
var int lastHit;
var() sound FleshSound, DecoSound, HitSound;
var travel int mode;
var travel NCDragonHead head;
var bool bGoingDown;
var travel class<NCDragonHead> curHeadClass;
var travel float maxheadlifespan;
var travel float headStartTime;
var travel float lastlvltime;
var float lastlvl;

replication
{
	reliable if (Role == ROLE_Authority)
		head;
}

event TravelPreAccept() {
	lastlvl = lastlvltime;
	lastlvltime = 0;
	Super.TravelPreAccept();
}

simulated function RenderOverlays(canvas canvas) {
	Super.RenderOverlays(canvas);
	if (head != none)
		Canvas.DrawActor(head,false);
}

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'prophetstaffl';
	else
		Mesh = mesh'prophetstaff';
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
	PlayAnim('Fire'); //2.25);
	head.PlayAnim('Fire'); //2.25);
	Owner.PlaySound(head.FireSound);
}

function PlayHitting()
{
	if (mode == 0) {
		switch (lastHit) {
			case 0:
				PlayAnim('Hit1');
				break;
			case 1:
				PlayAnim('Hit2');
				break;
			default:
				PlayAnim('Hit1');
				break;
		}
		Owner.PlaySound(Misc1Sound);
	}
}

function createHead(int newmode, class<NCDragonHead> headclass, float hlifeSpan) {
	if (hlifeSpan < 0) {
		mode = 0;
		Finish();
		return;
	}
	lastlvl = 0;
	mode = newmode;
	curHeadClass = headclass;
	maxheadLifespan = hlifeSpan;
	if (head != none)
		GotoState('RemoveHeadReplace');
	else
		GotoState('GettingHead');
}

function fRemoveHead() {
	mode = 0;
	if (isInState('Idle'))
		PlayIdleAnim();
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

state GettingHead
{
	ignores AnimEnd;

	function Fire(float f) { }

	function AltFire(float f) { }

	Begin:
	if (!bFirePos) {
		PlayAnim('PutDown');
		bFirePos = true;
		FinishAnim();
	}
	head = Spawn(curHeadClass,owner,,location,rotation);
	head.staff = self;
	head.drawScale = playerViewScale;
	head.PlayAnim('Select');
	Owner.PlaySound(head.selectsound);
	headStartTime = Level.timeseconds;
	head.headLastTime = maxheadlifespan;
	sleep(0.75);
	Finish();
}

state RemoveHead
{
	ignores AnimEnd;

	function Fire(float f) { }

	function AltFire(float f) { }

	Begin:
	head.PlayAnim('Down');
	Owner.PlaySound(head.selectsound);
	sleep(0.75);
	head.destroy();
	head = none;
	if (bFirePos) {
		PlayAnim('PutUp');
		bFirePos = false;
		FinishAnim();
	}
	if (bGoingDown) {
		bGoingDown = false;
		GotoState('DownWeapon');
	}
	else {
		Finish();
	}
}

state RemoveHeadReplace
{
	ignores AnimEnd;

	function Fire(float f) { }

	function AltFire(float f) { }

	Begin:
	head.PlayAnim('Down');
	Owner.PlaySound(head.selectsound);
	sleep(0.75);
	head.destroy();
	head = none;
	GotoState('GettingHead');
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
		//if (bFirePos)
		//	PlayAnim('PutUp');
		Super.EndState();
	}

Begin:
	if (mode == 0 || canHitClose() || AmmoType == None || AmmoType.AmmoAmount <= 0) { // melee attack
		if (mode == 0) {
			if (bFirePos) {
				PlayAnim('PutUp');
				bFirePos = false;
				lastHit = 0;
			}
			if ((lastHit != 1 || FRand() > 0.75) && FRand() > 0.25) {
				lastHit = 1;
				PlayHitting();
				sleep(0.6);
				TraceFire(0.0);
			}
			else {
				lastHit = 0;
				PlayHitting();
				sleep(0.5);
				TraceFire(0.0);
			}
		}
		else {
			if (head == none)
				createHead(mode,curheadclass,maxheadlifespan-((level.timeseconds+lastlvl)-headstarttime));
			PlayAnim('ArmedHit');
			head.PlayAnim('ArmedHit');
			Owner.PlaySound(head.MeleeSound);
			sleep(0.3);
			TraceArmedFire(0.0);
		}
	}
	else {
		if (head == none)
			createHead(mode,curheadclass,maxheadlifespan-((level.timeseconds+lastlvl)-headstarttime));
		AmmoType.UseAmmo(1);
		PlayShooting();
		head.ProjectileFire(ProjectileSpeed,bWarnTarget);
	}
	TwirlTime = -2;
	FinishAnim();
	if (Pawn(Owner).bFire==0) {
		Finish();
	}
	else {
		if (mode == 0 && head != none)
			GotoState('RemoveHead');
		Goto('Begin');
	}
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	if (lastHit == 1)
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + (-3*FireOffset.Z) * Z;
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

	if (lastHit == 1)
		Other.TakeDamage(25, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
	else
		Other.TakeDamage(50, Pawn(Owner), HitLocation, 15000 * X, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
}

function TraceArmedFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + (-1*FireOffset.Z) * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + 100 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	head.ProcessTraceHit(HitLocation,HitNormal,Other,X,Y,Z);
}


state Idle
{
	function AnimEnd() {
		//pawn(owner).clientmessage("Staff animation has ended!");
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		if (head != none) {
			bGoingDown = true;
			GotoState('removeHead');
			return True;
		}
		else {
			GotoState('DownWeapon');
			return True;
		}
	}

	function Fire(float f) {
		global.Fire(f);
	}

	/*function EndState() {
		Super.EndState();
		if (head != none) {
			head.bPlayStill = false;
		}
	}*/

Begin:
	bPointing=False;
	if ( Pawn(Owner).bFire!=0 )
		Fire(0.0);
	FinishAnim();
	AnimFrame=0;
	if (head != none)
		head.bAnimOver = true;
	PlayIdleAnim();
	//Goto('Begin');
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
	if (owner == none && head != none) {
		head.destroy();
		head = none;
		bFirePos = false;
	}
	lastlvltime = level.timeseconds;
}

function PlayIdleAnim()
{
	local float r;

	r = FRand();
	if (mode == 0) {
		if (head != none) {
			goToState('RemoveHead');
			return;
		}
		if (bFirePos) {
			PlayAnim('PutUp');
			bFirePos = false;
			return;
		}
		if (r > 0.66)
			PlayAnim('Sway1');
		else if (r > 0.33)
			PlayAnim('Sway2');
		else
			PlayAnim('Sway3');
	}
	else {
		if (mode != 0 && head == none) {
			createHead(mode,curheadclass,maxheadlifespan-((level.timeseconds+lastlvl)-headstarttime));
		}
		else {
			if (AnimSequence != 'DownStill')
				PlayAnim('DownStill');
			//head.bPlayStill = true;
			//head.AnimEnd();
			if (head.bAnimOver) {
				if (r > 0.5)
					head.PlayAnim('Sway1');
				else
					head.PlayAnim('Sway2');
				head.bAnimOver = false;
			}
		}
	}
}

function Finish()
{
	if ( bChangeWeapon )
	{
		if (head != none) {
			bGoingDown = true;
			GotoState('removeHead');
		}
		else {
			GotoState('DownWeapon');
		}
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
     HitSound=Sound'UnrealShare.General.WoodHit2'
     InfoTexture=Texture'NaliChronicles.Icons.prophetstaffInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCPStaffAmmo'
     PickupAmmoCount=20
     bWarnTarget=True
     FireOffset=(X=50.000000,Y=-8.000000,Z=-22.000000)
     MyDamageType=zapped
     AltDamageType=slashed
     SelectSound=Sound'UnrealShare.General.WoodHit1'
     Misc1Sound=Sound'UnrealShare.Manta.fly1m'
     DeathMessage="%k destroyed %o with the %w."
     InventoryGroup=10
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found the Staff of the Prophet."
     ItemName="Prophet's Staff"
     PlayerViewOffset=(X=3.000000,Y=-1.500000,Z=-0.700000)
     PlayerViewMesh=LodMesh'NaliChronicles.prophetstaff'
     PlayerViewScale=0.050000
     PickupViewMesh=LodMesh'NaliChronicles.prophetstaffpick'
     PickupViewScale=0.800000
     ThirdPersonMesh=LodMesh'NaliChronicles.prophetstaffthird'
     ThirdPersonScale=0.800000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.prophetstaffIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.prophetstaffpick'
     AmbientGlow=0
     bNoSmooth=False
     CollisionHeight=40.000000
}
