// A small fish that explodes on impact :)
// Code by Sergey 'Eater' Levin, 2002

class NCFlyFish extends Projectile;

var NaliMage NaliOwner;

var Texture fishskins[6];
var bool bNoHitInst;

auto state Flying
{
	function BeginState() {
		Super.PostBeginPlay();
		Skin = fishskins[Rand(6)];
		velocity = vector(rotation)*speed;
		velocity.z += 600;
		LoopAnim('All');
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (NCPawnEnchantLake(Other) == none && (instigator != other || !bNoHitInst)) {
			Other.TakeDamage(damage,instigator,HitLocation,vect(0,0,0),'slimed');
			if (NaliMage(Other) == none && Nali(Other) == none && NaliWarrior(Other) == none && Pawn(Other) != none)
				NaliOwner.GainExp(1,damage);
			Explode(location,vect(0,0,0));
		}
	}

	simulated function Landed(vector HitNormal)
	{
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BloodSplat',,,Location, rotator(HitNormal));
		Explode(location,HitNormal);
	}

	function HitWall(vector HitNormal, actor wall) {
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BloodSplat',,,Location, rotator(HitNormal));
		Explode(location,HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		PlaySound(ImpactSound,SLOT_Interact);
		spawn(class'ut_BloodPuff',,,location);
		destroy();
	}

Begin:
	LifeSpan=Default.LifeSpan;
	//SetPhysics(PHYS_Projectile);
	//sleep(1.0);
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
     FishSkins(0)=Texture'UnrealShare.Skins.Jfish21'
     FishSkins(1)=Texture'UnrealShare.Skins.Jfish22'
     FishSkins(2)=Texture'UnrealShare.Skins.Jfish23'
     FishSkins(3)=Texture'UnrealShare.Skins.Jfish24'
     FishSkins(4)=Texture'UnrealShare.Skins.Jfish25'
     FishSkins(5)=Texture'UnrealShare.Skins.Jfish26'
     speed=60.000000
     MaxSpeed=1000.000000
     Damage=6.000000
     ImpactSound=Sound'Botpack.BioRifle.GelHit'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     Mesh=LodMesh'UnrealShare.AmbientFish'
}
