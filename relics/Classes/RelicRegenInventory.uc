class RelicRegenInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var vector InstFog;
var float InstFlash;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_PlayRegenSound;
}

state Activated
{
	function Timer()
	{
		if ( (Owner != None) && Owner.bIsPawn )
		{
			if ( Pawn(Owner).Health < 150 )
			{
				Pawn(Owner).Health = FMin(150, Pawn(Owner).Health + 10);
				FlashShell(0.3);
				if (PlayerPawn(Owner) != none)
				{
					B227_PlayRegenSound();
					PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);
				}
			}
		}

		Super.Timer();
	}

	function BeginState()
	{
		Super.BeginState();
		SetTimer(2.0, True);
	}

	function EndState()
	{
		SetTimer(0.0, False);
		Super.EndState();
	}
}

simulated function B227_PlayRegenSound()
{
	local int i;

	if (PlayerPawn(Owner) != none)
		for (i = 0; i < 4; ++i)
			Owner.PlaySound(sound'RegenHiss', SLOT_None, 16.0);
}

defaultproperties
{
     InstFog=(X=475.000000,Y=325.000000,Z=145.000000)
     InstFlash=-0.400000
     ShellSkin=Texture'relics.Skins.RelicBlue'
     PickupMessage="You picked up the Relic of Regeneration!"
     PickupViewMesh=Mesh'relics.RelicRegen'
     PickupViewScale=0.500000
     Icon=Texture'relics.Icons.RelicIconRegen'
     Physics=PHYS_Rotating
     Texture=Texture'relics.Skins.JRelicRegen_01'
     Skin=Texture'relics.Skins.JRelicRegen_01'
     CollisionHeight=40.000000
     LightSaturation=0
     ItemName="Relic of Regeneration"
}
