//=============================================================================
// ParticleSystem_43.
// Applied a network-related fix for Unreal 227.
// Fixed "accessing none" errors.
//=============================================================================
class ParticleSystem_42 expands Effects;

var(ParticleSystemPhysics) Vector InitialVelocity;			//The velocity at which the particles are fired
var(ParticleSystemPhysics) Vector InitialAcceleration;		//The acceleration of the particles
var(ParticleSystemPhysics) Int NumParticles;				//Number of particles created
var(ParticleSystemPhysics) Float SpawnTime;					//The time between particle creations
var(ParticleSystemPhysics) Float SpawnTimeRandomizer;		//Looks more natural but takes a small performance hit probably maybe
var(ParticleSystemPhysics) vector TerminalVelocity;			//The mazimum velocity of the particles
var(ParticleSystemPhysics) float ParticleLifeSpan;			//The life span of the particles
var(ParticleSystemPhysics) float ParticleLifeSpanVarience;	//How much the life span can change by
var(ParticleSystemPhysics) vector EffectArea;				//The area in which the particles could be spawned
var(ParticleSystemPhysics) vector InitialVelocityRandomizer;//An initial velocity randomizer
var(ParticleSystemPhysics) bool bInitiallyActive;			//Active at the start of the match?
var(ParticleProperties) Float ParticleDrawScale;			//The draw scale of the particles
var(ParticleProperties) Float ParticleDrawVarience;			//Possible change in size
var(ParticleProperties) bool bModulated;					//Makes particles modulated instead of transparent
var(ParticleProperties) Texture ParticleTextures[6];		//Select up to 6 textures for the particles
var(ParticleProperties) class<particle_42> ParticleType;	//For possibility of particles that hurt when touched etc.
var(ParticleProperties) float ParticleScaleGlow;			//Initial scale glow (brightness) of the particles
var(ParticleProperties) float ParticleFadeTime;				//Set to 0 if no fade (waaay better performance with none)
var(ParticleProperties) float ParticleFadeInTime;			//0 for less lag probability

var Particle_42 Particle;
var vector SpawnPoint;
var int NumSpawned;
var bool bActive, bClientActive;	//Is particle system active?


replication
{
	reliable if (Role == ROLE_Authority)
		InitialVelocity,
		InitialAcceleration,
		NumParticles,
		SpawnTime,
		SpawnTimeRandomizer,
		TerminalVelocity,
		ParticleLifeSpan,
		ParticleLifeSpanVarience,
		EffectArea,
		InitialVelocityRandomizer,
		bInitiallyActive,
		ParticleDrawScale,
		ParticleDrawVarience,
		bModulated,
		ParticleTextures,
		ParticleType,
		ParticleScaleGlow,
		ParticleFadeTime,
		ParticleFadeInTime;

	reliable if (Role == ROLE_Authority)
		bActive;
}


function Trigger(Actor Other, Pawn EventInstigator)
{
	bActive = !bActive;
	if (Level.NetMode != NM_DedicatedServer)
		UpdateTimer();
}

simulated function UpdateTimer()
{
	if (bActive)
		SetTimer(SpawnTime, true);
	else
		SetTimer(0, false);
}

event PreBeginPlay()
{
	Enable('Trigger');
	bActive = bInitiallyActive;
	if (Level.NetMode != NM_DedicatedServer)
		UpdateTimer();

	//Just to make sure particle fade time is valid
	if ( ParticleFadeTime > ParticleLifeSpan - ParticleLifeSpanVarience )
		ParticleFadeTime = ParticleLifeSpan - ParticleLifeSpanVarience;
}

simulated event PostNetReceive()
{
	if (bActive != bClientActive)
	{
		UpdateTimer();
		bClientActive = bActive;
	}
}

simulated event Timer()
{
	for (NumSpawned = 0; NumSpawned < numParticles; NumSpawned++)
	{
		SpawnPoint.Z = Location.Z + (1 - FRand() * 2) * EffectArea.Z;
		SpawnPoint.X = Location.X + (1 - FRand() * 2) * EffectArea.X;
		SpawnPoint.Y = Location.Y + (1 - FRand() * 2) * EffectArea.Y;
		Particle = spawn(ParticleType,,,SpawnPoint);	//Actually spawn the particle
		if (Particle == none)
			return;

		Particle.RemoteRole = ROLE_None;

		//Need to set the life span now for later calculation on fading
		Particle.LifeSpan = ParticleLifeSpan + (1 - FRand() * 2) * ParticleLifeSpanVarience;
		Particle.ScaleGlow = ParticleScaleGlow;
		//set velocity for this particle
		Particle.Velocity.Z = InitialVelocity.Z + ( - 1 + FRand() * 2 ) * InitialVelocityRandomizer.Z;
		Particle.Velocity.X = InitialVelocity.X + ( - 1 + FRand() * 2 ) * InitialVelocityRandomizer.X;
		Particle.Velocity.Y = InitialVelocity.Y + ( - 1 + FRand() * 2 ) * InitialVelocityRandomizer.Y;
		//If we have particle acceleration then must set the particle's timer
		if ((InitialAcceleration != vect(0,0,0))||(ParticleFadeInTime != 0))
		{
			if (InitialAcceleration != vect(0,0,0))
			{
				Particle.bAccelerating = true;
				Particle.InitialAccel.Z = InitialAcceleration.Z;
				Particle.InitialAccel.X = InitialAcceleration.X;
				Particle.InitialAccel.Y = InitialAcceleration.Y;
				Particle.TerminalVelocity = TerminalVelocity;
			}
			else
			{
				Particle.FadeInTime = ParticleFadeInTime;
				Particle.bFadingInNow = true;
				Particle.FadeInScaleFactor = ParticleScaleGlow / 10;
				Particle.ScaleGlow = 0;
			}
			Particle.SetTimer(0.1, true);
			if ( ParticleFadeTime > 0 )
				Particle.FadeTime = ParticleFadeTime;
		}
		//If there is no acceleration, but we do want fading, then we can start the timer a lot later
		else
		{
			if ( ParticleFadeTime > 0 )
			{
				Particle.FadeTime = ParticleFadeTime;
				//Don't start the timer till we need to fade the particle
				Particle.SetTimer( Particle.LifeSpan - ParticleFadeTime, false );
			}
		}
		//set lifespan, texture etc.
		Particle.Texture = ParticleTextures[rand(6)];
		Particle.FadeScaleFactor = ParticleScaleGlow / 10;
		Particle.DrawScale = ParticleDrawScale + (1 - FRand() * 2) * ParticleDrawVarience;
		Particle.SpawnTime = Level.TimeSeconds;
		if ( bModulated )
			particle.Style=STY_Modulated;
	}
	if ( SpawnTimeRandomizer != 0 )
		SetTimer( SpawnTime + (1 - FRand() * 2) * SpawnTimeRandomizer, False );
}

defaultproperties
{
	InitialVelocity=(Z=30.000000)
	Numparticles=1
	SpawnTime=0.100000
	TerminalVelocity=(X=2500.000000,Y=2500.000000,Z=2500.000000)
	particleLifeSpan=0.500000
	EffectArea=(X=10.000000,Y=10.000000)
	InitialVelocityRandomizer=(X=5.000000,Y=5.000000)
	ParticleDrawScale=0.250000
	ParticleType=Class'ParticleSystem_43.Particle_42'
	ParticleScaleGlow=0.500000
	bHidden=True
	DrawType=DT_Sprite
	bAlwaysRelevant=True
	bNetNotify=True
	RemoteRole=ROLE_SimulatedProxy
}
