//=============================================================================
// SCUBAGear.
//=============================================================================
class FreezeGear extends Pickup;

var vector X,Y,Z;

function bool HandlePickupQuery( inventory Item )
{
	if (item.class == class)
	{
		if (bCanHaveMultipleCopies)
		{   // for items like Artifact
			NumCopies++;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			Item.PlaySound (Item.PickupSound,,2.0);
			Item.SetRespawn();
		}
		else if ( bDisplayableInv )
		{
			if ( Charge<Item.Charge )
				Charge= Item.Charge;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			Item.PlaySound (item.PickupSound,,2.0);
			Item.SetReSpawn();
		}
		Item.Charge+=Charge;
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	//BroadCastMessage(string(DamageType));
        if (DamageType == 'KKFreezed')
	{
		NextArmor = None;
		Return Self;
	}
	return Super.PrioritizeArmor(Damage, DamageType, HitLocation);
}

function UsedUp()
{
	local Pawn OwnerPawn;

	OwnerPawn = Pawn(Owner);
//	if ( (OwnerPawn != None) && !OwnerPawn.FootRegion.Zone.bPainZone && OwnerPawn.HeadRegion.Zone.bWaterZone )
//		OwnerPawn.PainTime = 15;
	Owner.AmbientSound = None;
	Super.UsedUp();
}

state Activated
{
	function endstate()
	{

		Owner.PlaySound(DeactivateSound);
		Owner.AmbientSound = None;
		bActive = false;
	}

	function Timer()
	{
		local float LocalTime;

		if ( Pawn(Owner) == None )
		{
			UsedUp();
			return;
		}
		ArmorAbsorption=100;
		Charge -= 1;
		if (Charge<-0)
		{
			Pawn(Owner).ClientMessage(ExpireMessage);
			UsedUp();
			return;
		}
		LocalTime += 0.1;
		LocalTime = LocalTime - int(LocalTime);
	}
Begin:
	if ( Owner == None )
		GotoState('');
	SetTimer(0.1,True);
	if ( Owner.IsA('PlayerPawn') && PlayerPawn(Owner).HeadRegion.Zone.bWaterZone)
		Owner.AmbientSound = ActivateSound;
	else
		Owner.AmbientSound = RespawnSound;
}

state DeActivated
{
Begin:

}

defaultproperties
{
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You picked up the oxygen"
     RespawnTime=20.000000
     PickupViewMesh=LodMesh'UnrealShare.Scuba'
     Charge=100
     ArmorAbsorption=100
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealShare.Pickups.Scubal1'
     DeActivateSound=Sound'UnrealShare.Pickups.Scubada1'
     RespawnSound=Sound'UnrealShare.Pickups.Scubal2'
     Icon=Texture'UnrealShare.Icons.I_Scuba'
     RemoteRole=ROLE_DumbProxy
     Mesh=LodMesh'UnrealShare.Scuba'
     SoundRadius=16
     CollisionRadius=18.000000
     CollisionHeight=15.000000
}
