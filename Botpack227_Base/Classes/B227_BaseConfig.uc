class B227_BaseConfig expands Info
	config(Botpack);

var(Weapon) globalconfig bool bDrawMuzzleFlash;

// 0 - no scaling (U227 behavior)
// 1 - scaling PlayerViewOffset.X by FOV angle
// 2 - scaling PlayerViewOffset by FOV angle (UT436 behavior)
var(Weapon) globalconfig int WeaponViewOffsetMode;

defaultproperties
{
	bDrawMuzzleFlash=True
	WeaponViewOffsetMode=1
}
