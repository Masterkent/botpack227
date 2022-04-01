// ===============================================================
// SevenB.SBAltDispersionAmmo: basically has more powerful momentum transfer for alt mode
// only exists in xidia dm
// ===============================================================

class SBAltDispersionAmmo extends OSDispersionAmmo;

function InitSplash(float DamageScale)
{
  MomentumTransfer=26000;
	super.InitSplash(DamageScale);
}

defaultproperties
{
}
