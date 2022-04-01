class MyFreezeZoneInfo extends FreezeZoneInfo;

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
	Super(ZoneInfo).ActorEntered(Other);
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
	Super(ZoneInfo).ActorLeaving(Other);
}

function Trigger( actor Other, pawn EventInstigator )
{
	bPainZone=!bPainZone;
	Super(ZoneInfo).Trigger(Other, EventInstigator);
}

defaultproperties
{
}
