// Thundercloud - flies forward and shoots out lightning bolts at passing objects
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCThundercloud extends NCMagicProj;

state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		If ( (Other!=Instigator) && (NCSeaBlast(Other) == none) ) {
			//DealOutExp(Other);
			//Other.TakeDamage(damage,instigator,hitlocation,vector(rotation*MomentumTransfer),MyDamageType);
			TExplode(HitLocation,Normal(HitLocation-Other.Location),other);
		}
	}

	function HitWall(vector HitNormal, actor HitWall) {
		TExplode(location,HitNormal,none);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		TExplode(HitLocation, HitNormal, None);
	}

	function TExplode(vector HitLocation, vector HitNormal, actor HitActor) {
		local rotator newrot;
		local vector newdest;
		local vector X,Y,Z;
		local int i;
		local NCLightning light;

		PlaySound(ImpactSound);
		GetAxes(rotation,X,Y,Z);
		while (damage > 0) {
			newrot = rotation;
			if (HitActor == none) {
				if (FRand() > 0.5)
					newrot.yaw += Rand(8192);
				else
					newrot.yaw -= Rand(8192);
				if (FRand() > 0.5)
					newrot.pitch += Rand(8192);
				else
					newrot.pitch -= Rand(8192);
			}
			else {
				newdest = HitActor.location;
				GetAxes(HitActor.rotation,X,Y,Z);
				if (FRand() > 0.5)
					newdest += Rand(HitActor.CollisionHeight/2) * Z;
				else
					newdest -= Rand(HitActor.CollisionHeight/2) * Z;
				if (FRand() > 0.5)
					newdest += Rand(HitActor.CollisionRadius/2) * X;
				else
					newdest -= Rand(HitActor.CollisionRadius/2) * X;
				if (FRand() > 0.5)
					newdest += Rand(HitActor.CollisionRadius/2) * Y;
				else
					newdest -= Rand(HitActor.CollisionRadius/2) * Y;
				newrot = rotator(newdest-(location+(-15*X)));
			}
			light = Spawn(Class'NaliChronicles.NCLightning',,,location+(-15*X),newrot);
			light.bGuiding = true;
			light.damage = 20 + (FRand()*10);
			if (light.damage > damage) light.damage = damage;
			damage -= light.damage;
			light.drawScale = 0.5 + ((light.damage-2)/21);
			light.NaliOwner = NaliOwner;
			light.book = book;
			light.gotoState('Flying');
			light.Target = HitActor;
			//instigator.ClientMessage(light.name $ " created with a power of " $ light.damage);
		}
		destroy();
	}

	function BeginState()
	{
		Super.BeginState();
		Velocity = vector(Rotation) * speed;
		setTimer(0.5,True);
	}

	function Timer() {
		local actor a;
		local actor t;
		local float closestdist;
		local NCLightning light;
		local rotator newrot;
		local vector X,Y,Z, newloc;

		foreach VisibleCollidingActors(Class'actor',a,400) {
			if ((Pawn(a) != none || Decoration(a) != none) && (VSize(a.location-location) < 400) && (a != instigator)) {
				if (t == none) {
					t = a;
					closestdist = VSize(a.location - location);
				}
				else {
					if ((VSize(a.location-location)<closestdist) || (Pawn(t) == none && Pawn(a) != none)) {
						t = a;
						closestdist = VSize(a.location - location);
					}
				}
			}
		}
		if (t != none) {
			newrot = rotator(t.location-location);
		}
		else {
			newrot.yaw = Rand(65536);
			newrot.pitch = Rand(65536);
		}
		newloc = location;
		GetAxes(newrot, X, Y, Z);
		newloc += X * (DrawScale*10);
		light = Spawn(Class'NaliChronicles.NCLightning',,,newloc,newrot);
		light.damage = (6*(damage/70)) + (FRand()*(10*(damage/70)));
		if (light.damage < 2) light.damage = 2;
		light.drawScale = 0.5 + ((light.damage-2)/21);
		light.NaliOwner = NaliOwner;
		light.book = book;
		light.gotoState('Flying');
	}

	Begin:
	LifeSpan=Default.LifeSpan;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     speed=600.000000
     Damage=1.000000
     MomentumTransfer=4000
     MyDamageType=zapped
     ImpactSound=Sound'UnrealShare.General.Expl03'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=12.000000
     AmbientSound=Sound'UnrealShare.General.BRocket'
     Texture=Texture'UnrealShare.Effects.SmokeE3'
     Mesh=LodMesh'NaliChronicles.nccloud'
     DrawScale=1.500000
     SoundRadius=64
     SoundVolume=218
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=24
     LightHue=152
     LightSaturation=32
     LightRadius=24
     LightPeriod=50
}
