class NaliDefiler extends Nali;

var() bool bTriggeredOnly;
var() int SleepTime;
var() bool bChangeLocation;
var() float LocationOffset;
var bool bCanNotTrigger, WeAreGood;
var int mni;

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local GameRules GR;

	if( bHidden || instigatedBy.IsA('Skaarj') )
		return;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	//log(self@"take damage in state"@GetStateName());
	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	//-if ( Level.Game.DamageMutator != None )
	//-	Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	// Handling Damage with 227 GameRules
	for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules )
		if (GR.bModifyDamage)
			GR.ModifyDamage(self, instigatedBy, Damage, HitLocation, DamageType, Momentum);

	AddVelocity( momentum );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		//PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function eAttitude AttitudeWithFear()
{
	return ATTITUDE_Ignore;
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	if ( (Nali(Other) != None) && Killer.bIsPlayer )
		AttitudeToPlayer = ATTITUDE_Ignore;
	Super.Killed(Killer, Other, damageType);
}

function damageAttitudeTo(pawn Other)
{
	AttitudeToPlayer = ATTITUDE_Ignore;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	return ATTITUDE_Ignore;
}

function SpawnSkaarjW(vector Loc)
{
	Spawn(class'KKSkaarjWarrior',none,'',Loc*vect(1,1,0));
	Spawn(class'UTTeleEffect',none,'',Loc*vect(1,1,0));
}

auto state HiddenNali
{
Begin:
	bHidden=true;

}

function Trigger( actor Other, pawn EventInstigator )
{
	if( bCanNotTrigger ) return;
	bCanNotTrigger=true;
	GoToState('FadeIn');
}

state SleepingBeauty
{
Begin:
	Sleep(SleepTime);
	if( bChangeLocation && LocationOffset > 0 )
	{
		SetLocation(Location+( (VRand() * Vect(1,1,0)) * LocationOffset ) );
	}
	GoToState('FadeIn');
}


state FadeOut
{
	ignores HitWall, EnemyNotVisible, HearNoise, SeePlayer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
	}

	function Tick(float DeltaTime)
	{
		local int NewFatness;

		if ( !bFading )
		{
			NewFatness = fatness + 50 * DeltaTime;
			bFading = ( NewFatness > 160 );
		}
		else if ( Style == STY_Translucent )
		{
			ScaleGlow -= 3 * DeltaTime;
			if ( ScaleGlow < 0.3 )
			{
				PlaySound(sound'Teleport1',, 2.0);
				bHidden=true;
				SetCollision(False, false, false);
				if(bTriggeredOnly)
					bCanNotTrigger=false;
				else
					WeAreGood=true;
			}
			return;
		}
		else
		{
			NewFatness = fatness - 100 * DeltaTime;
			if ( NewFatness < 80 )
			{
				bUnlit = true;
				ScaleGlow = 2.0;
				Style = STY_Translucent;
			}
		}

		fatness = Clamp(NewFatness, 0, 255);
	}

	function BeginState()
	{
		bFading = false;
		WeAreGood=false;
		Disable('Tick');
	}

	function EndState()
	{
		bUnlit = false;
		Style = STY_Normal;
		ScaleGlow = 1.0;
		fatness = Default.fatness;
	}

Begin:
	Acceleration = Vect(0,0,0);
	if ( NearWall(100) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	PlayAnim('Levitate', 0.3, 1.0);
	FinishAnim();
	PlayAnim('Levitate', 0.3);
	FinishAnim();
	LoopAnim('Levitate', 0.3);
	Enable('Tick');
}

state FadeIn
{
	ignores HitWall, EnemyNotVisible, HearNoise, SeePlayer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		if( bHidden )
			return;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
	}

	function Tick(float DeltaTime)
	{
		local int NewFatness;

		if(bFading)
		{
			NewFatness = fatness + 100 * DeltaTime;
			if ( NewFatness > 80 && Style != STY_Translucent )
			{
				bUnlit = false;
				ScaleGlow = 1;
				Style = STY_Normal;
				bHidden=false;
				SetCollision(true, true, true);
			}
		}
		//BroadCastMessage(NewFatness);
		fatness = Clamp(NewFatness, 0, default.fatness);
		if( fatness >= default.fatness )
		{
			GoToState('SpawnSkaarjWarriors');
		}
	}

	function BeginState()
	{
		bFading = false;
		Disable('Tick');
		ScaleGlow = 0;
		fatness = 0;
	}

	function EndState()
	{
		bUnlit = false;
		Style = STY_Normal;
		ScaleGlow = 1.0;
		fatness = Default.fatness;
	}

Begin:
	Acceleration = Vect(0,0,0);
	if ( NearWall(100) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('Tick');
	bFading=true;
	LoopAnim('Levitate', 0.3);
}

state SpawnSkaarjWarriors
{
Begin:
	mni=0;
SpawnSW:
	if( mni < 6 )
	{
                SpawnSkaarjW( Location+(VRand()*512) );
		Sleep(2);
		GoTo('SpawnSW');
	}
	Sleep(3);
	GoToState('FadeOut');
}

defaultproperties
{
     SleepTime=30
}
