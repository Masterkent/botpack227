// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVPulseGun : New projectiles.
// only made a new weapon however for the new skin. (no other way do to replication)
// ===============================================================

class TVPulseGun expands OSPulseGun;

//#exec TEXTURE IMPORT NAME=TVPulseGunSkin FILE=JPulseGun_02.pcx GROUP=Skins LODSET=2
//#exec TEXTURE IMPORT NAME=TVMuzzyPulse FILE=MuzzyPulse.PCX GROUP=Skins

/*simulated event RenderOverlays( canvas Canvas )
{
  multiskins[1]=texture'Botpack.Ammocount.Ammoled';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=default.MultiSkins[1];
}
  */
function float SuggestAttackStyle()
{
  if (Pawn(Owner).Enemy==none)
    return 0;
  return Super.SuggestAttackStyle();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Level.Game != none)
	{
		if (tvsp(Level.Game) != none || tvcoop(Level.Game) != none)
			InventoryGroup = 7;
	}
}

function B227_AdjustNPCFirePosition()
{
	if (B227_ShouldGuideBeam())
		super.B227_AdjustNPCFirePosition();
}

defaultproperties
{
     ProjectileClass=Class'XidiaMPack.TVPlasmaSphere'
     AltProjectileClass=Class'XidiaMPack.TvStarterBolt'
     InventoryGroup=5
}
