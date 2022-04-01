// The base of all magic projectiles
// Code by Sergey 'Eater' Levin, 2001

class NCMagicProj extends Projectile;

var NaliMage NaliOwner;
var int book;

// our own HurtRadius that gives exp
final function ExpHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
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
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
			if (NaliOwner != none)
				DealOutExp(Victims,damageScale * DamageAmount);
		}
	}
	bHurtEntry = false;
}

auto State Casting {
	simulated function ProcessTouch(Actor Other, Vector HitLocation) { }
	simulated function HitWall (vector HitNormal, actor Wall) { }
	simulated function Explode(vector HitLocation, vector HitNormal) { }
	function BeginState() {
		SetPhysics(PHYS_None);
	}
}

function DoneCasting() {
	GotoState('Flying');
}

function DealOutExp(actor Other, optional int gain) {
	if (NaliOwner == none) return;
	if (gain == 0)
		gain = damage;
	if ((Other != instigator) && (Nali(Other) == none) && (NaliWarrior(Other) == none) && (Pawn(Other) != none)) {
		NaliOwner.GainExp(book,gain);
	}
}

State flying {
	function BeginState() {
		SetPhysics(Default.Physics);
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		Global.ProcessTouch(Other,HitLocation);
	}
	simulated function HitWall(vector HitNormal, actor Wall) {
		Global.HitWall(HitNormal,Wall);
	}
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		Global.Explode(HitLocation,HitNormal);
	}
}

defaultproperties
{
}
