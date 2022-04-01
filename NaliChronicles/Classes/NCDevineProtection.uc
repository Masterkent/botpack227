// A magical that blocks projectiles, deflects enemies, and dry-cleans your laundry
// Code by Sergey 'Eater' Levin

class NCDevineProtection extends NCProtectEffect;

var NCShieldEffect myEffect;

function Destroyed()
{
	if (myEffect != none) {
		myEffect.destroy();
	}
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCShieldEffect',,,other.location,other.rotation);
	myEffect.setOwner(Other);
	myEffect.Texture = Texture'UnrealShare.Belt_fx.Effect_1';
	myEffect.Mesh = Other.mesh;
	myEffect.DrawScale = Other.DrawScale;
	Super.GiveTo(Other);
	SetPhysics(PHYS_Trailer);
	goToState('Active');
      //setTimer(0.2,false);
}

state Active {
	function intercept() {
		local projectile proj;
		local pawn attacker;
		local float damageScale, dist;
		local NCInterceptor inter;
		local vector dir;

		//pawn(owner).clientmessage("timer");
		if (owner != none) {
			foreach VisibleCollidingActors( class 'Pawn', attacker, fMax(Owner.CollisionHeight,Owner.CollisionRadius)*2, owner.location )
			{
				if( attacker != pawn(owner) && attacker.attitudeToPlayer < ATTITUDE_Ignore )
				{
					dir = attacker.Location - owner.location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;
					//attacker.velocity += 5000*dir;
					attacker.TakeDamage(1,pawn(owner),attacker.location,50000*dir,'crushed');
				}
				//pawn(owner).clientmessage(attacker);
			}
			foreach VisibleCollidingActors( class 'Projectile', proj, fMax(Owner.CollisionHeight,Owner.CollisionRadius)*4, owner.location )
			{
				if( proj.instigator != pawn(owner) && FRand() > 0.2 )
				{
					proj.HitWall(Normal(proj.location-owner.location),self);
					inter = Spawn(Class'NaliChronicles.NCInterceptor',,,owner.location,owner.rotation);
					inter.targetLoc = proj.location;
					inter.launch();
				}
			}
		}
	}

	Begin:
	sleep(0.2);
	intercept();
	goTo('Begin');
}

defaultproperties
{
     timeBeforeDecay=120.000000
     decayTimePerArmor=0.500000
     Charge=120
     ArmorAbsorption=95
     Icon=Texture'NaliChronicles.Icons.HolyDevineProtectionBarIcon'
     Physics=PHYS_Trailer
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=90
     LightSaturation=255
     LightRadius=6
     LightCone=128
     VolumeBrightness=64
}
