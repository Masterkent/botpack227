class RelicRedemptionInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	local int PointNumber, PointCount;
	local Pawn Victim;
	local NavigationPoint NP;

	Victim = Pawn(Owner);
	if ( (Victim == None) || (Victim.Health - Damage > 0) || !bActive )
		return Super.PrioritizeArmor(Damage, DamageType, HitLocation);

	// Redeem this poor soul.
	if (MyRelic != none)
		PointNumber = Rand(MyRelic.NumPoints);
	else if (B227_Relics != none)
		PointNumber = Rand(B227_Relics.NumPoints);

	for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
	{
		if (PathNode(NP) != none && (NP.bStatic || NP.bNoDelete))
		{
			if (PointCount == PointNumber)
			{
				if (CTFFlag(Victim.PlayerReplicationInfo.HasFlag) != none)
					CTFFlag(Victim.PlayerReplicationInfo.HasFlag).Drop(vect(0,0,0));

				Spawn(class'RelicSpawnEffect', Victim,, Victim.Location, Victim.Rotation);

				Victim.SetLocation(NP.Location);
				if ( Victim.IsA('PlayerPawn') )
					PlayerPawn(Victim).SetFOVAngle(170);

				Victim.Health = Victim.default.Health;
				Victim.AddVelocity(vect(0,0,-1000));
			}
			PointCount++;
		}
	}

	// Move the relic.
	Victim.DeleteInventory(self);
	Destroy();
	NextArmor = None;
	Return self;
}

//
// Absorb damage.
//
function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	if ( Pawn(Owner) != None )
		Pawn(Owner).Health = Pawn(Owner).default.Health;
	return 0;
}

defaultproperties
{
     PickupMessage="You picked up the Relic of Redemption!"
     PickupViewMesh=Mesh'relics.RelicRedemption'
     PickupViewScale=0.600000
     Icon=Texture'relics.Icons.RelicIconRedemption'
     Physics=PHYS_Rotating
     Skin=Texture'relics.Skins.JRelicRedemption'
     CollisionHeight=40.000000
     ItemName="Relic of Redemption"
}
