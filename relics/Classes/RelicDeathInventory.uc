class RelicDeathInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

function PostBeginPlay()
{
	Super.PostBeginPlay();

	LoopAnim('Bob', 0.5);
}

function DropInventory()
{
	if ( Pawn(Owner).Health > 0 )
		Super.DropInventory();
	else
		Destroy();
}

function Destroyed()
{
	local Pawn Victim;
	local DeathWave DW;

	Victim = Pawn(Owner);

	if ( (Victim != None) && (Victim.Health <= 0) )
	{
	 	DW = Spawn(class'DeathWave', , , Victim.Location + vect(0,0,50), Victim.Rotation);
		DW.Instigator = Victim;
	}
	Super.Destroyed();
}

auto state Pickup
{
	function Landed(Vector HitNormal)
	{
		Super.Landed(HitNormal);
		LoopAnim('Bob', 0.5);
	}
}

defaultproperties
{
     PickupMessage="You picked up the Relic of Vengeance!"
     PickupViewMesh=Mesh'relics.RelicSkull'
     PickupViewScale=0.500000
     Icon=Texture'relics.Icons.RelicIconVengeance'
     Physics=PHYS_Rotating
     Texture=Texture'Botpack.Skins.JDomN0'
     Mesh=Mesh'relics.RelicSkull'
     CollisionHeight=55.000000
     RotationRate=(Yaw=5000,Roll=0)
     DesiredRotation=(Roll=0)
}
