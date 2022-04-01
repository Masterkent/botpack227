// modified to allow heart-shots
// Sergey 'Eater' Levin, 2002

class NCRazorBlade extends RazorBlade;

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector newloc;
		local actor heart;

		if ( bCanHitInstigator || (Other != Instigator) )
		{
			if ( Role == ROLE_Authority )
			{
				newloc = other.location;
				newloc.z += other.collisionheight*0.35;
				if ( Other.IsA('Pawn') && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
					&& (instigator.IsA('PlayerPawn') || (instigator.skill > 1))
					&& (!Other.IsA('ScriptedPawn') || !ScriptedPawn(Other).bIsBoss) )
					Other.TakeDamage(3.5 * damage, instigator,HitLocation,
						(MomentumTransfer * Normal(Velocity)), 'decapitated' );
				else
					Other.TakeDamage(damage, instigator,HitLocation,
						(MomentumTransfer * Normal(Velocity)), 'shredded' );
				if (hasHeart(Other) && (abs(Hitlocation.Z-newloc.z) < other.collisionradius*0.25) && Pawn(Other).health <= 0) {
					heart = Spawn(Class'PHeart',,,hitlocation,other.rotation); // heart shot effect
					heart.velocity = (0.125)*velocity;
				}
			}
			if ( Other.IsA('Pawn') )
				PlaySound(MiscSound, SLOT_Misc, 2.0);
			else
				PlaySound(ImpactSound, SLOT_Misc, 2.0);
			destroy();
		}
	}
}

function bool hasHeart(actor a) { // UGLY, UGLY way of coding this
	if ((Skaarj(a) != none || Nali(a) != none || NaliWarrior(a) != none || Krall(a) != none || Brute(a) != none ||
          Warlord(a) != none || PlayerPawn(a) != none || Slith(a) != none) && (ScriptedPawn(a) == none || !ScriptedPawn(a).bGreenBlood)) // kid-friendly :)
		return true;
	else
		return false;
}

defaultproperties
{
}
