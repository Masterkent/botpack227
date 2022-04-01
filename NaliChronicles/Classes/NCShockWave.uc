// Same as the UT shockwave, only this one gives exp
// Sergey 'Eater' Levin, 2002

class NCShockWave extends Effects;

var float OldShockDistance, ShockSize;
var int ICount;
var NaliMage NaliOwner;
var float charge;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  charge*(13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

function DealOutExp(actor Other, int gain) {
	if ((Other != instigator) && (Nali(Other) == none) && (NaliWarrior(Other) == none) && (Pawn(Other) != none)) {
		NaliOwner.GainExp(5,gain);
	}
}

simulated function Timer()
{

	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize =  charge*(13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (ICount==4) spawn(class'WarExplosion2',,,Location);
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3);
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = charge*FMax(0, 1100 - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);
						if (Pawn(victims) != none && Pawn(victims).health > 0)
							DealOutExp(victims,fMin(MoScale,Pawn(victims).health));
						Victims.TakeDamage
						(
							MoScale,
							Instigator,
							Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
							(1000 * dir),
							'RedeemerDeath'
						);
					}
				}
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3);
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = charge*FMax(0, 1100 - 1.1 * Dist);
			if ( Victims.bIsPawn )
				Pawn(Victims).AddVelocity(dir * (MoScale + 20));
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);
			if (Pawn(victims) != none && Pawn(victims).health > 0)
				DealOutExp(victims,fMin(MoScale,Pawn(victims).health));
			Victims.TakeDamage
			(
				MoScale,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(1000 * dir),
				'RedeemerDeath'
			);
		}
	}
	OldShockDistance = ShockSize*29;
}

simulated function PostBeginPlay()
{
	local Pawn P;

	if ( Role == ROLE_Authority )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (VSize(P.Location - Location) < 3000) )
				PlayerPawn(P).ShakeView(0.5, 600000.0/VSize(P.Location - Location), 10);

		if ( Instigator != None )
			MakeNoise(10.0);
	}

	SetTimer(0.1, True);

	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEffects();
}

simulated function SpawnEffects()
{
	 local WarExplosion W;

	 PlaySound(Sound'Expl03', SLOT_Interface, 16.0);
	 PlaySound(Sound'Expl03', SLOT_None, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Misc, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Talk, 16.0);
	 W = spawn(class'WarExplosion',,,Location);
	 W.RemoteRole = ROLE_None;
}

defaultproperties
{
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.ShockWavem'
     AmbientGlow=255
     bUnlit=True
}
