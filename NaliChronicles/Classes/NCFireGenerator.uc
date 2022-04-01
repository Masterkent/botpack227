// Generates fire particles
// Code by Sergey 'Eater' Levin, 2001

class NCFireGenerator extends Effects;

var() float SmokeDelay; // pause between each particle
var() float SizeVariance; // how different each particle is
var() float BasePuffSize; // how large each particle should be
var() float SmokeScale; // this scale factor will be applied to smoke particles
var() float XRadius; // X size
var() float YRadius; // Y size
var() float particleLifeSpanFactor; // this basically determines how high each particle can go. particle lifespan multiplied by this
var() float RisingVelocity; // just what it says
var() float SmokeVelocity; // just what it says
var() float damagePerParticle; // how much damage each particle deals
var() texture fireTextures[10]; // the different textures for fire particles
var() texture smokeTextures[10]; // the different textures for smoke particles
var() int fireToSmoke; // how many fires per smoke
var() bool bInitiallyActive;
var() float particleSaturation;
var() float particleBrightness;
var() float particleHue;
var int numFires;
var int numSmokes;
var int smokeCount;

function PostBeginPlay() {
	local int i;
	local bool smokeSet, fireSet;
	local float bigRadius;

	Super.PostBeginPlay();
	setTimer(SmokeDelay,true);

	while (i < 10) {
		if ((fireTextures[i] == None) && (!fireSet)) {
			numFires = i;
			fireSet = true;
		}
		if ((smokeTextures[i] == None) && (!smokeSet)) {
			numSmokes = i;
			smokeSet = true;
		}
		i++;
	}
	if (!smokeSet)
		numSmokes=10;
	if (!fireSet)
		numFires=10;
}

final function UniformHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			Victims.TakeDamage
			(
				DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(Momentum * dir),
				DamageName
			);
		}
	}
	bHurtEntry = false;
}

function Timer()
{
	local Effects d;
	local float littleRadius;

	if (!bInitiallyActive) return;

	if (XRadius < YRadius)
		littleRadius = XRadius;
	else
		littleRadius = YRadius;

	UniformHurtRadius( damagePerParticle*2, littleRadius+10, 'burned', 15, location );

	if (numFires > 0) {
		d = Spawn(Class'NaliChronicles.NCFireParticle',,,calcFireLoc()); //lifeSpanMult));
		d.DrawScale = BasePuffSize+FRand()*SizeVariance;
		d.Texture = fireTextures[Rand(numFires)];
		if (NCFireParticle(d)!=None) {
			NCFireParticle(d).RisingRate = RisingVelocity;
			NCFireParticle(d).Damage = damagePerParticle;
			NCFireParticle(d).LifeSpan = particleLifeSpanFactor;//*lifeSpanMult;
		}
		d.LightBrightness = particleBrightness;
		d.LightSaturation = particleSaturation;
		d.LightHue = particleHue;
		if (particleBrightness > 0)
			d.LightType = LT_Steady;
	}
	smokeCount++;
	if (smokeCount>=fireToSmoke) {
		smokeCount = 0;
		if (numSmokes > 0) {
			d = Spawn(Class'NaliChronicles.NCFireParticle',,,calcFireLoc());//lifeSpanMult));
			d.DrawScale = BasePuffSize+FRand()*SizeVariance*SmokeScale;
			d.Texture = smokeTextures[Rand(numSmokes)];
			if (NCFireParticle(d)!=None) {
				NCFireParticle(d).RisingRate = SmokeVelocity;
				NCFireParticle(d).Damage = 0;
				NCFireParticle(d).LifeSpan = particleLifeSpanFactor;//*lifeSpanMult;
			}
		}
	}
}

function vector calcFireLoc() {//out float lifeSpanMult) {
	local vector newLoc, X, Y, Z;
	//local vector farlocation;

	newLoc = location;
	getAxes(rotation,X,Y,Z);
	if (FRand() > 0.5)
		newLoc += (FRand()*XRadius)*X;
	else
		newLoc += (-FRand()*XRadius)*X;
	if (FRand() > 0.5)
		newLoc += (FRand()*YRadius)*Y;
	else
		newLoc += (-FRand()*YRadius)*Y;
	/*farlocation.x = location.X+Xradius;
	farlocation.y = location.Y+YRadius;
	farlocation.z = location.z;
	if (newLoc == location)
		lifeSpanMult = 1.0;
	else
		lifeSpanMult = 1-(VSize(location-newLoc)/VSize(location-farlocation));*/
	return newLoc;
}

state() NormalGenerator
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!bInitiallyActive) {
			bInitiallyActive = true;
		}
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
	}
}

defaultproperties
{
     SmokeDelay=0.030000
     SizeVariance=0.200000
     BasePuffSize=0.750000
     SmokeScale=1.500000
     XRadius=10.000000
     YRadius=10.000000
     particleLifeSpanFactor=1.000000
     RisingVelocity=75.000000
     SmokeVelocity=100.000000
     damagePerParticle=1.000000
     fireTextures(0)=Texture'Botpack.FlakGlow.fglow_a00'
     smokeTextures(0)=Texture'Botpack.utsmoke.us10_a00'
     smokeTextures(1)=Texture'Botpack.utsmoke.us1_a00'
     smokeTextures(2)=Texture'Botpack.utsmoke.us2_a00'
     smokeTextures(3)=Texture'Botpack.utsmoke.US3_A00'
     smokeTextures(4)=Texture'Botpack.utsmoke.us4_a00'
     smokeTextures(5)=Texture'Botpack.utsmoke.us5_a00'
     smokeTextures(6)=Texture'Botpack.utsmoke.us6_a00'
     smokeTextures(7)=Texture'Botpack.utsmoke.us7_a00'
     smokeTextures(8)=Texture'Botpack.utsmoke.us8_a00'
     smokeTextures(9)=Texture'Botpack.utsmoke.us9_a00'
     fireToSmoke=2
     bInitiallyActive=True
     particleSaturation=32.000000
     particleHue=27.000000
     bHidden=True
     bNetTemporary=False
     bDirectional=True
     DrawType=DT_Sprite
     Style=STY_Masked
     Texture=Texture'UnrealShare.Effects.SmokePuff43'
}
