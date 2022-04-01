// Nali Chronicles version of razor ammo, with icon
// Sergey 'Eater' Levin, 2002

class NCRazorAmmo extends Ammo;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

var bool bOpened;

auto state Pickup
{
	function Touch( Actor Other )
	{
		local Vector Dist2D;

		if ( bOpened )
		 Super.Touch(Other);
		if ( (Pawn(Other) == None) || !Pawn(Other).bIsPlayer )
			return;
		Dist2D = Other.Location - Location;
		Dist2D.Z = 0;
		if ( VSize(Dist2D) <= 40.0 )
			Super.Touch(Other);
		else
		{
			SetCollisionSize(20.0, CollisionHeight);
			SetLocation(Location); //to force untouch
			bOpened = true;
			PlayAnim('Open', 0.05);
		}
	}

	function Landed(vector HitNormal)
	{
		Super.Landed(HitNormal);
		if ( !bOpened )
		{
			bCollideWorld = false;
			SetCollisionSize(170,CollisionHeight);
		}
	}
}

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=75
     UsedInWeaponSlot(6)=1
     bAmbientGlow=False
     PickupMessage="You picked up Razor Blades"
     PickupViewMesh=LodMesh'UnrealI.RazorAmmoMesh'
     MaxDesireability=0.220000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.RazorAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'UnrealI.RazorAmmoMesh'
     AmbientGlow=0
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
