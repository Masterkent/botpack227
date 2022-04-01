class FreezeZoneInfo extends ZoneInfo;

var PlayerPawn RPlayerPawn;
var() texture Overlay;
var float LastTime;

event ActorEntered( actor Other )
{
	if(PlayerPawn(Other) != none)
	{
		RPlayerPawn=PlayerPawn(Other);
		//BroadCastMessage(RPlayerPawn@"Entered");
		KKHUD(RPlayerPawn.myHUD).Overlay = Overlay;
		KKHUD(RPlayerPawn.myHUD).bForceOverlay = true;

		if( RPlayerPawn.FindInventoryType(class'FreezeGear') != none)
		{
		    RPlayerPawn.FindInventoryType(class'FreezeGear').GoToState('Activated');
		    //BroadCastMessage(RPlayerPawn.FindInventoryType(class'FreezeGear'));
		}
		LastTime = Level.TimeSeconds;
		Enable('Tick');
	}
	Super.ActorEntered(Other);
}

event ActorLeaving( actor Other )
{
	if(PlayerPawn(Other) != none)
	{
		//BroadCastMessage(RPlayerPawn@"Leaves");
		KKHUD(RPlayerPawn.myHUD).bShouldFadeOut = true;
		if( RPlayerPawn.FindInventoryType(class'FreezeGear') != none)
		    RPlayerPawn.FindInventoryType(class'FreezeGear').GoToState('DeActivated');
		RPlayerPawn=none;
		Disable('Tick');
	}
	Super.ActorLeaving(Other);
}

function Trigger( actor Other, pawn EventInstigator )
{
	bPainZone=!bPainZone;
	Super.Trigger(Other, EventInstigator);
}

/*function Tick(float DeltaTime)
{
	if( RPlayerPawn != none )
	{
	        BroadCastMessage(RPlayerPawn);
		if ( Level.TimeSeconds - LastTime < 2 )
			return;
		LastTime = Level.TimeSeconds;

		RPlayerPawn.TakeDamage( 10, Instigator, RPlayerPawn.Location, vect(2,2,2), 'Corroded');
	}
}*/

defaultproperties
{
     DamagePerSec=5
     DamageType=KKFreezed
     bPainZone=True
}
