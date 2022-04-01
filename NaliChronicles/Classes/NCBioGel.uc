// A special bio gel for the death fruit spell
// Sergey 'Eater' Levin, 2002

class NCBioGel extends UT_BioGel;

var NaliMage NaliOwner;

function Timer()
{
	local ut_GreenGelPuff f;

	f = spawn(class'ut_GreenGelPuff',,,Location + SurfaceNormal*8);
	f.numBlobs = numBio;
	if ( numBio > 0 )
		f.SurfaceNormal = SurfaceNormal;
	PlaySound (MiscSound,,3.0*DrawScale);
	if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
		Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

	ExpHurtRadius(damage * Drawscale, FMin(250, DrawScale * 75), MyDamageType, MomentumTransfer * Drawscale, Location);
	Destroy();
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if (!Other.IsA('NCDeathfruitSeed') && !Other.IsA('NCBioGel') && !Other.IsA('NCDeathfruit'))
			Global.Timer();
	}
}

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
			DealOutExp(Victims,damageScale * DamageAmount);
		}
	}
	bHurtEntry = false;
}

function DealOutExp(actor Other, optional int gain) {
	if (gain == 0)
		gain = damage;
	if ((Other != instigator) && (Nali(Other) == none) && (NaliWarrior(Other) == none) && (Pawn(Other) != none)) {
		NaliOwner.GainExp(0,gain);
	}
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType )
{
	if (isInState('Flying'))
		return; // can't be blown up
	if ( damageType == MyDamageType )
		numBio = 3;
	GoToState('Exploding');
}

state OnSurface
{
	function BeginState()
	{
		wallTime = 12;

		MyFear = Spawn(class'BioFear');
		if ( Mover(Base) != None )
		{
			BaseOffset = VSize(Location - Base.Location);
			SetTimer(0.2, true);
		}
		else
			SetTimer(wallTime, false);
	}
}

defaultproperties
{
     LifeSpan=24.000000
}
