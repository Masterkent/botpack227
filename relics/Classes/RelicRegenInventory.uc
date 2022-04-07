class RelicRegenInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var vector InstFog;
var float InstFlash;

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
					if (UTC_PlayerPawn(Owner) != none)
						UTC_PlayerPawn(Owner).UTF_ClientPlaySound(sound'RegenHiss', false);
					else
						PlayerPawn(Owner).ClientPlaySound(sound'RegenHiss');
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
}
