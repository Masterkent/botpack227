class B227_PendingWeaponSwitcher expands Info;

auto state WeaponSwitching
{
	function SwitchWeapon()
	{
		if (Instigator != none &&
			!Instigator.bDeleteMe &&
			Instigator.Health > 0 &&
			Instigator.PendingWeapon != none &&
			!Instigator.PendingWeapon.bDeleteMe &&
			(Instigator.Weapon == none || Instigator.Weapon.bDeleteMe))
		{
			Instigator.ChangedWeapon();
		}
	}
Begin:
	Sleep(0.1);
	SwitchWeapon();
	Destroy();
}
