// Ice shard
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCLightning extends NCMagicProj;

var float DelayTime;
var rotator origRotation;
var vector oldEndLoc;
var float starttime;
var bool bNotFirst;
var bool bGuiding;
var actor Target;
var() float flyTime;

state Flying
{
	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;
		local actor other;

		if (target != none)
			other = target;
		else
			other = H;
		if (Other != instigator && NCIceshard(Other) == none)
		{
			DealOutExp(Other);
			PlaySound(MiscSound);
			if ( Role == ROLE_Authority )
			{
				hitDir = Normal(Velocity);
				if ( FRand() < 0.2 )
					hitDir *= 5;
				Other.TakeDamage(damage, instigator,HitLocation,
					(MomentumTransfer * hitDir), 'zapped');
				//instigator.ClientMessage(damage $ " damage dealt to " $ other.name $ " by " $ name);
			}
			makeLine();
			Destroy();
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		if (target != none) {
			ProcessTouch(target,target.location);
		}
		else {
			Super.HitWall(HitNormal, Wall);
			PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
			spawn(class 'Botpack.UT_SpriteSmokePuff',,,Location+HitNormal*9);
			makeLine();
			destroy();
		}
	}

	function makeLine() {
		local NCLineEffect l;
		local int i;
		local actor b;
		local vector X,Y,Z;
		local vector newloc;

		if (Level.NetMode!=NM_DedicatedServer)
		{
			GetAxes(rotator(location-oldEndLoc),X,Y,Z);
			i = ((VSize(location-oldEndLoc)-(15*DrawScale))/(30*DrawScale))+1;
			while (i >= 0) {
				newloc = location - (i*(30*DrawScale))*X;
				l=spawn(class'NCLightningLineEffect',,,newloc);
				if (oldEndLoc != vect(0,0,0))
					l.setRotation(rotator(newloc-oldEndLoc));
				l.DrawScale = DrawScale;
				oldEndLoc = newloc + (15*DrawScale)*X;
				i--;
			}
			if( Region.zone.bWaterZone )	{
	 			b=spawn(class'Bubble1');
 				b.DrawScale= 0.1 + FRand()*0.2;
 				b.SetLocation(Location+FRand()*vect(2,0,0)+FRand()*Vect(0,2,0)+FRand()*Vect(0,0,2));
 				b.buoyancy = b.mass+(FRand()*0.4+0.1);
			}
 		}
	}

	simulated function Timer()
	{
		local rotator newrot;
		local actor a;
		local NCLightning light;

		makeLine();
		if ((rotation == origRotation) && (bNotFirst) && (!bGuiding)) {
			newrot = rotation;
			if (FRand() > 0.5)
				newrot.pitch += Rand(2048);
			else
				newrot.pitch -= Rand(2048);
			if (FRand() > 0.5)
				newrot.yaw += Rand(2048);
			else
				newrot.yaw -= Rand(2048);
			foreach VisibleCollidingActors(Class'actor',a,200) {
				if ((Pawn(a) != none || Decoration(a) != none) && (VSize(a.location-location) < 200)) {
					if ((VSize(a.location-location) < 100) || (damage < 8)) {
						newrot = rotator(a.location-location);
						bGuiding = True;
					}
					else {
						if (damage >= 8) {
							light = Spawn(Class'NaliChronicles.NCLightning',,,location,rotator(a.location-location));
							light.damage = damage * ((FRand()/10)+0.15);
							if (light.damage < 2) light.damage = 2;
							damage -= light.damage;
							light.drawScale = 0.5 + ((light.damage-2)/21);
							light.NaliOwner = NaliOwner;
							light.book = book;
							light.gotoState('Flying');
						}
					}
				}
			}
			setRotation(newrot);
		}
		else {
			if (!bNotFirst) bNotFirst = true;
			setRotation(origRotation);
		}
		Velocity = Vector(Rotation) * speed;
	}

	function BeginState()
	{
		local rotator RandRot;

		Super.BeginState();
		startTime = level.timeseconds;
		PlaySound(MiscSound);
		oldEndLoc = location;
		origRotation = rotation;
		Velocity = Vector(Rotation) * speed;
		setTimer(0.1,true);
	}
	Begin:
	sleep(flyTime);
	if (target != none)
		ProcessTouch(target,target.location);
	else
		destroy();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     flyTime=1.000000
     speed=2000.000000
     Damage=2.000000
     MomentumTransfer=4000
     MyDamageType=zapped
     ImpactSound=Sound'NaliChronicles.SFX.NCLightningSound'
     MiscSound=Sound'NaliChronicles.SFX.NCLightningSound'
     ExplosionDecal=Class'Botpack.BoltScorch'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.SKEffect.Skj_a00'
     DrawScale=0.500000
     AmbientGlow=215
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightSaturation=255
     LightRadius=16
     LightPeriod=50
}
