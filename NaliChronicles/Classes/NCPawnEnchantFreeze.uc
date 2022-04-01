// This enchantment freezes creatures
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantFreeze extends NCPawnEnchant;

var bool bPlayStarted;
var bool bOldReg;
var float OldGS, OldAS, OldWS, OldWalk, OldJZ;
var class<actor> rp;
var NCPawnEnchantSlow sle;

function CalculateFade() {
	Style=STY_Normal;
}

function Fadeout() {
	destroy();
}

function FollowTarget(float DeltaTime) {
	local vector newlocation;
	local float slowdownpercent;
	local NCPawnEnchantSlow se;

	if (mesh != EnchantmentTarget.Mesh) {
		mesh = EnchantmentTarget.Mesh;
		drawscale = EnchantmentTarget.drawscale;
		fatness = EnchantmentTarget.fatness*1.125;
	}

	if (!bOldReg) {
		setRotation(EnchantmentTarget.rotation);
		bOldReg = true;
		LifeSpan = LifeSpan*(100/float(EnchantmentTarget.health));
		if (ScriptedPawn(EnchantmentTarget) != none)
			rp = ScriptedPawn(EnchantmentTarget).RangedProjectile;
		oldJZ = EnchantmentTarget.JumpZ;
		setCollisionSize(EnchantmentTarget.CollisionRadius+2,EnchantmentTarget.CollisionHeight+2);
		AnimSequence = EnchantmentTarget.AnimSequence;
		foreach allactors(Class'NCPawnEnchantSlow',se) {
			if (se.EnchantmentTarget == EnchantmentTarget) {
				sle = se;
				OldGS = se.OldGS;
				OldAS = se.OldAS;
				OldWS = se.OldWS;
				if (ScriptedPawn(EnchantmentTarget) != none)
					OldWalk = se.OldWalk;
				se.OldGS = 0;
				se.OldAS = 0;
				se.OldWS = 0;
				se.OldWalk = 0;
			}
		}
		if (sle == none) {
			OldGS = EnchantmentTarget.GroundSpeed;
			OldAS = EnchantmentTarget.AirSpeed;
			OldWS = EnchantmentTarget.WaterSpeed;
			if (ScriptedPawn(EnchantmentTarget) != none)
				OldWalk = ScriptedPawn(EnchantmentTarget).WalkingSpeed;
		}
	}
	EnchantmentTarget.GroundSpeed = 0;
	EnchantmentTarget.AirSpeed = 0;
	EnchantmentTarget.WaterSpeed = 0;
	if (ScriptedPawn(EnchantmentTarget) != none) {
		ScriptedPawn(EnchantmentTarget).WalkingSpeed = 0;
		ScriptedPawn(EnchantmentTarget).RangedProjectile = none;
	}
	EnchantmentTarget.JumpZ = -1;
	EnchantmentTarget.goToState('');
	EnchantmentTarget.bHidden = true;

	setLocation(EnchantmentTarget.location);
}

function destroyed() {
	local int i;
	local GlassFragments s;

	EnchantmentTarget.GroundSpeed = OldGS;
	EnchantmentTarget.AirSpeed = OldAS;
	EnchantmentTarget.WaterSpeed = OldWS;
	if (ScriptedPawn(EnchantmentTarget) != none) {
		ScriptedPawn(EnchantmentTarget).WalkingSpeed = OldWalk;
		ScriptedPawn(EnchantmentTarget).RangedProjectile = rp;
	}
	EnchantmentTarget.JumpZ = oldjz;
	EnchantmentTarget.goToState('Wandering');
	EnchantmentTarget.bHidden = false;
	for (i=0 ; i<(collisionheight/3) ; i++) {
		s = Spawn( class 'GlassFragments',,,Location+CollisionRadius*VRand());
		if ( s != None )
		{
			s.CalcVelocity(vector(rotation), CollisionRadius*2);
			s.DrawScale = 0.5;
			s.Skin = Texture;
			s.Style = STY_Translucent;
		}
	}
	PlaySound(Sound'UnrealShare.General.BreakGlass');
	if (sle != none) {
		sle.OldGS = OldGS;
		sle.OldAS = OldAS;
		sle.OldWS = OldWS;
		sle.OldWalk = OldWalk;
	}
	super.destroyed();
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	destroy();
}

defaultproperties
{
     bDisplayMesh=True
     SpawnSound=Sound'UnrealShare.Stinger.StingerAltFire'
     LifeSpan=3.000000
     Texture=Texture'UnrealI.Skins.JBlob1'
     bMeshEnviroMap=True
     bCollideActors=True
     bProjTarget=True
}
