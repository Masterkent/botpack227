class RelicSpeedInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);

	ShellEffect = Spawn(ShellType, Owner,,Owner.Location, Owner.Rotation);
}

state Activated
{
	function BeginState()
	{
		SetTimer(0.2, True);

		Super.BeginState();

		// Alter player's stats.
		Pawn(Owner).AirControl = FMax(0.65, Pawn(Owner).AirControl);
		Pawn(Owner).JumpZ *= 1.1;
		Pawn(Owner).GroundSpeed *= 1.3;
		Pawn(Owner).WaterSpeed *= 1.3;
		Pawn(Owner).AirSpeed *= 1.3;
		Pawn(Owner).Acceleration *= 1.3;

		// Add wind blowing.
		Pawn(Owner).AmbientSound = sound'SpeedWind';
		Pawn(Owner).SoundRadius = 64;
	}

	function EndState()
	{
		local float SpeedScale;
		SetTimer(0.0, False);

		Super.EndState();

		if ( Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).bMegaSpeed )
			SpeedScale = 1.4; // B227 note: 1.3 was replaced with 1.4 according to the scaling defined in DMMutator.CheckReplacement
		else
			SpeedScale = 1.0;

		// Restore player's stats.
		Pawn(Owner).AirControl = DeathMatchPlus(Level.Game).AirControl;
		Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
		Pawn(Owner).GroundSpeed = Pawn(Owner).Default.GroundSpeed * SpeedScale;
		Pawn(Owner).WaterSpeed = Pawn(Owner).Default.WaterSpeed * SpeedScale;
		Pawn(Owner).AirSpeed = Pawn(Owner).Default.AirSpeed * SpeedScale;
		Pawn(Owner).Acceleration = Pawn(Owner).Default.Acceleration * SpeedScale;

		// Remove sound.
		Pawn(Owner).AmbientSound = None;
	}
}

defaultproperties
{
     ShellType=Class'relics.speedshell'
     PickupMessage="You picked up the Relic of Speed!"
     PickupViewMesh=Mesh'relics.RelicHourglass'
     PickupViewScale=0.500000
     Icon=Texture'relics.Icons.RelicIconSpeed'
     Physics=PHYS_Rotating
     Skin=Texture'relics.Skins.JRelicHourglass_01'
     CollisionHeight=40.000000
}
