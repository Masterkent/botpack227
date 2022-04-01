// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVPulseGun : New projectiles.
// only made a new weapon however for the new skin. (no other way do to replication)
// ===============================================================

class TVPulseGun expands OSPulseGun;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

simulated event RenderOverlays( canvas Canvas )
{
  multiskins[1]=texture'Botpack.Ammocount.Ammoled';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=default.MultiSkins[1];
}

function float SuggestAttackStyle()
{
  if (Pawn(Owner).Enemy==none)
    return 0;
  return Super.SuggestAttackStyle();
}

function B227_AdjustNPCFirePosition()
{
	if (B227_ShouldGuideBeam())
		super.B227_AdjustNPCFirePosition();
}

defaultproperties
{
     ProjectileClass=Class'olextras.TVPlasmaSphere'
     AltProjectileClass=Class'olextras.TvStarterBolt'
     MuzzleFlashTexture=Texture'olextras.Skins.TVMuzzyPulse'
     MultiSkins(1)=Texture'olextras.Skins.TVPulseGunSkin'
     MultiSkins(2)=Texture'olextras.Skins.TVPulseGunSkin'
}
