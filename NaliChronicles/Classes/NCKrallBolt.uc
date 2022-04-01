// Special Krall bolt with decal and fireable by player
// Code by Sergey 'Eater' Levin

class NCKrallBolt extends KraalBolt;

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector momentum;

		if ( (Other != instigator) && (KraalBolt(Other) == None))
		{
			if ( Role == ROLE_Authority )
			{
				momentum = MomentumTransfer * Normal(Velocity);
				Other.TakeDamage( Damage, instigator, HitLocation, momentum, 'zapped');
			}
			Destroy();
		}
	}

Begin:
	Sleep(7.0); //self destruct after 7.0 seconds
	Explode(Location, vect(0,0,0));
}

defaultproperties
{
     speed=880.000000
     Damage=35.000000
     ExplosionDecal=Class'Botpack.BoltScorch'
     Mesh=LodMesh'UnrealI.eplasma'
}
