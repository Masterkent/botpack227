class ONPLocationTest expands Info;

var Pawn AssociatedPawn;

function bool IsClearLocationFor(vector Pos, Pawn P)
{
	SetCollisionSize(P.CollisionRadius, P.CollisionHeight);
	SetCollision(true, true, true);
	bCollideWorld = true;
	AssociatedPawn = P;

	return SetLocation(Pos);
}

event bool EncroachingOn(actor A)
{
	if (A == none || A == AssociatedPawn)
		return false;
	if (Pawn(A) != none || A.bBlockPlayers || A.bBlockActors)
		return true;
	return Super.EncroachingOn(A);
}
