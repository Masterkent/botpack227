class ONPSpawnPoint expands SpawnPoint;

function bool Create()
{
	local pawn newcreature;
	local CreatureFactory pawnFactory;
	local actor temp;
	local rotator newRot;

	if ( factory.bCovert && PlayerCanSeeMe() ) //make sure no player can see this
		return false;

	if (ClassIsChildOf(factory.prototype, class'Projectile'))
		newRot = Rotation;
	else
		newRot.yaw = Rotation.Yaw;

	temp = Spawn(factory.prototype,,factory.itemtag,,newRot);
	if (temp == None)
		return false;
	temp.event = factory.tag;
	newcreature = pawn(temp);

	TriggerEvent(Event,Self,Instigator);

	if ( factory.bFalling )
		temp.SetPhysics(PHYS_Falling);
	if (newcreature == None)
		return true;

	pawnFactory = CreatureFactory(factory);
	if (pawnFactory == None)
		return true;
	if (ScriptedPawn(newcreature) != None)
	{
		ScriptedPawn(newcreature).Orders = pawnFactory.Orders;
		ScriptedPawn(newcreature).OrderTag = pawnFactory.OrderTag;
		ScriptedPawn(newcreature).SetEnemy(pawnFactory.enemy);
		ScriptedPawn(newcreature).Alarmtag = pawnFactory.AlarmTag;
	}
	else
		newcreature.enemy = pawnFactory.enemy;
	if (newcreature.enemy != None)
		newcreature.lastseenpos = newcreature.enemy.location;
	newcreature.SetMovementPhysics();
	if ( newcreature.Physics == PHYS_Walking)
		newcreature.SetPhysics(PHYS_Falling);
	return true;
}

defaultproperties
{
	bCollideWhenPlacing=False
	bStatic=False
}
