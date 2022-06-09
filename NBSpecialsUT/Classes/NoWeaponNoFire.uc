//=============================================================================
// NoWeaponNoFire.
//
// script by N.Bogenrieder (Beppo)
//
// this weapon is used for the ControlRotatingMover,
// and the SpecialControlCannon for replacing the currently
// held weapon....
//
// DON'T USE THIS WEAPON AS A DEFAULT WEAPON !!!
// CAUSE ELSE THE TWO CLASSES NAMED ABOVE WILL NOT WORK 
// CORRECTLY (I SUPPOSE) !!!
//
// USE THE NOWeaponAtAll CLASS INSTEAD !!!
//
//=============================================================================
class NoWeaponNoFire expands Weapon;

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	if ( bOwnsCrossHair )
	{
		// if you turn bOwnsCrossHair to TRUE this Crosshair will
		// be displayed !! (used for special Projectiles)
		Canvas.SetPos(0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8 );
		Canvas.Style = 2;
		Canvas.DrawIcon(Texture'Crosshair6', 1.0);
		Canvas.Style = 1;	
	}
}

function Fire(float F){}
function AltFire(float F){}

function float SuggestAttackStyle()
{
	return 1.0;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

function float RateSelf( out int bUseAltMode )
{
	bUseAltMode = int(FRand() < 0.4);
	return (AIRating + FRand() * 0.05);
}

// if spawned (by CRM or else) DON'T let it be picked up !!
auto state Pickup
{
	function Touch( actor Other ) {}
}

state Active
{
	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function bool PutDown()
	{
		if ( bWeaponUp )
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	function BeginState()
	{
		bChangeWeapon = false;
	}

Begin:
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
}

function BringUp()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).EndZoom();	
	bWeaponUp = false;
	GotoState('Active');
}

function TweenDown()
{
}

defaultproperties
{
     bWarnTarget=True
     bCanThrow=False
     AIRating=1.000000
     RefireRate=0.250000
     AltRefireRate=0.250000
     DeathMessage="%o was killed by %k"
     bAmbientGlow=False
     PickupMessage="You have no weapon"
     ItemName=""
     RespawnTime=0.000000
     bHidden=True
     bOwnerNoSee=True
     DrawType=DT_None
     AmbientGlow=0
     bIsItemGoal=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
}
