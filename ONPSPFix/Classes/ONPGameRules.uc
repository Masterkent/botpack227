class ONPGameRules expands GameRules;

var ONPSPFix MutatorPtr;

event BeginPlay()
{
	MutatorPtr = ONPSPFix(Owner);
}

function bool PreventDeath(Pawn P, Pawn Killer, name DamageType)
{
	return MutatorPtr.bPreventFallingOutOfWorld &&
		PlayerPawn(P) != none &&
		P.Region.ZoneNumber == 0 &&
		MoveToNearestNavPoint(P);
}

function bool MoveToNearestNavPoint(Pawn P)
{
	local NavigationPoint NavPoint, BestNavPoint;
	local float Dist, BestDist;
	local bool bCollideActors;
	local bool bBlockActors;
	local bool bBlockPlayers;
	local bool bMoved;

	BestDist = 256;

	for (NavPoint = Level.NavigationPointList; NavPoint != none; NavPoint = NavPoint.nextNavigationPoint)
		if (NavPoint.Class == class'NavigationPoint' ||
			PathNode(NavPoint) != none ||
			AlarmPoint(NavPoint) != none ||
			PatrolPoint(NavPoint) != none)
		{
			Dist = VSize(NavPoint.Location - P.Location);
			if (Dist < BestDist)
			{
				BestNavPoint = NavPoint;
				BestDist = Dist;
			}
		}

	if (BestNavPoint == none)
		return false;

	bCollideActors = P.bCollideActors;
	bBlockActors = P.bBlockActors;
	bBlockPlayers = P.bBlockPlayers;
	P.SetCollision(false, false, false);
	bMoved = P.SetLocation(BestNavPoint.Location);
	if (bMoved)
		P.SetPhysics(PHYS_Falling);
	P.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);

	return bMoved;
}

function float PlayerJumpZScaling()
{
	return Level.Game.PlayerJumpZScaling();
}

defaultproperties
{
	bHandleDeaths=True
}
