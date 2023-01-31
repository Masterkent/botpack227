class B227_BaseConfig expands Info
	config(Botpack);

var(Weapon) config bool bDrawMuzzleFlash;
var(Weapon) config float MuzzleFlashScale;
// 0 - no scaling (U227 behavior)
// 1 - scaling PlayerViewOffset.X by FOV angle
// 2 - scaling PlayerViewOffset by FOV angle (UT436 behavior)
var(Weapon) config int WeaponViewOffsetMode;

defaultproperties
{
	bDrawMuzzleFlash=True
	MuzzleFlashScale=1.0
	WeaponViewOffsetMode=1
}
