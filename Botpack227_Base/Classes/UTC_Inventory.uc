class UTC_Inventory expands Inventory
	abstract;

var() class<LocalMessage> PickupMessageClass;

static function class<LocalMessage> B227_GetPickupMessageClass(Inventory this)
{
	if (UTC_Inventory(this) != none)
		return UTC_Inventory(this).PickupMessageClass;
	if (UTC_Ammo(this) != none)
		return UTC_Ammo(this).PickupMessageClass;
	if (UTC_Weapon(this) != none)
		return UTC_Weapon(this).PickupMessageClass;
	return none;
}

static function B227_SetPickupMessageClass(Inventory this, class<LocalMessage> MessageClass)
{
	if (UTC_Inventory(this) != none)
		UTC_Inventory(this).PickupMessageClass = MessageClass;
	else if (UTC_Ammo(this) != none)
		UTC_Ammo(this).PickupMessageClass = MessageClass;
	else if (UTC_Weapon(this) != none)
		UTC_Weapon(this).PickupMessageClass = MessageClass;
}
