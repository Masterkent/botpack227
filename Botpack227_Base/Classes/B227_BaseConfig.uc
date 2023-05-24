class B227_BaseConfig expands Info
	config(Botpack);

var(Weapon) globalconfig bool bDrawMuzzleFlash;

// 0 - no scaling (U227 behavior)
// 1 - scaling PlayerViewOffset.X by FOV angle
// 2 - scaling PlayerViewOffset by FOV angle (UT436 behavior)
var(Weapon) globalconfig int WeaponViewOffsetMode;

// Defines how the weapon is moved towards the viewport
// when using WeaponViewOffsetMode == 1 with a large FOV angle.
// Min value is 0.0 which corresponds to mode 0, max value is 1.0.
var(Weapon) globalconfig float WeaponViewOffsetScaling;

defaultproperties
{
	bDrawMuzzleFlash=True
	WeaponViewOffsetMode=1
	WeaponViewOffsetScaling=0.67
}
