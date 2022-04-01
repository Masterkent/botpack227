// The base of all pawn "enchantments"
// Code by Sergey 'Eater' Levin, 2001

class NCPawnEnchant extends Actor
	abstract;

var bool bTargetReceived;
var() float FadeTime;
var() bool bDisplayMesh;
var() sound SpawnSound;		// Sound made when projectile is spawned.
var pawn EnchantmentTarget;
var bool bFadingOut;
var float FadeStartTime;
var float MaxLifeSpan;
var() bool bPawnless;

function Resupply(float timeheld) {
	//called by spell when this enchantment is resupplied
}

function PostBeginPlay() {
	Super.PostBeginPlay();
	PlaySound(SpawnSound,SLOT_None,4.0);
	PlayStartAnim();
}

function PlayStartAnim() {

}

function FollowTarget(float DeltaTime) {
	if (EnchantmentTarget != none) {
		setLocation(EnchantmentTarget.location);
		setRotation(EnchantmentTarget.rotation);
	}
}

function CalculateFade() {
	if (((MaxLifeSpan-LifeSpan) >= FadeTime) && (LifeSpan >= FadeTime)) {
		Style=STY_Normal;
	}
	else {
		Style=STY_Translucent;
		if ((MaxLifeSpan-LifeSpan) >= FadeTime)
			ScaleGlow = LifeSpan/FadeTime;
		else
			ScaleGlow = FadeTime/(MaxLifeSpan-LifeSpan);
	}
}

function Fadeout() {
	Style=STY_Translucent;
	ScaleGlow = 1-((Level.TimeSeconds-FadeStartTime)/FadeTime);
	if (ScaleGlow <= 0.05)
		destroy();
}

function Tick(float DeltaTime) {
	local playerpawn pp;

	if (bTargetReceived) {
		if ((EnchantmentTarget != none) && (EnchantmentTarget.health <= 0)) EnchantmentTarget = none;
		if ((!bPawnless) && (EnchantmentTarget == none)) {
			if (bDisplayMesh) {
				if (!bFadingOut)
					FadeStartTime = Level.TimeSeconds;
				bFadingOut = true;
				Fadeout();
			}
			else {
				destroy();
			}
		}
		else {
			if (bDisplayMesh) {
				FollowTarget(DeltaTime);
				CalculateFade();
			}
		}
	}
}

defaultproperties
{
     bNetTemporary=True
     bReplicateInstigator=True
     LifeSpan=140.000000
     bDirectional=True
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Engine.S_Camera'
     bGameRelevant=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     NetPriority=2.500000
}
