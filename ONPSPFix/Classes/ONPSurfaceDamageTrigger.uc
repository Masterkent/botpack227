class ONPSurfaceDamageTrigger expands Triggers;

var name TextureName;
var int DamagePerSec;
var name DamageType;

struct AffectedPawnData
{
	var Pawn Pawn;
	var int Count;
	var float TimePassed;
	var bool bDamaged;
};

var array<AffectedPawnData> AffectedPawns;
var int AffectedPawnsCount;

event Trigger(Actor A, Pawn EventInstigator)
{
	if (EventInstigator != none)
		AddAffectedPawn(EventInstigator);
}

event Untrigger(Actor A, Pawn EventInstigator)
{
	if (EventInstigator != none)
		SubtractAffectedPawn(EventInstigator);
}

event Tick(float DeltaTime)
{
	local int i;

	for (i = 0; i < AffectedPawnsCount; ++i)
		if (AffectedPawns[i].Pawn != none &&
			!AffectedPawns[i].Pawn.bDeleteMe)
		{
			if (!AffectedPawns[i].bDamaged && PawnIsOnThisSurface(AffectedPawns[i].Pawn))
			{
				AffectedPawns[i].Pawn.TakeDamage(DamagePerSec, none, AffectedPawns[i].Pawn.Location, vect(0, 0, 0), DamageType);
				AffectedPawns[i].bDamaged = true;
			}

			if (AffectedPawns[i].bDamaged)
			{
				AffectedPawns[i].TimePassed += DeltaTime;
				if (AffectedPawns[i].TimePassed >= 1)
				{
					AffectedPawns[i].TimePassed = FMin(AffectedPawns[i].TimePassed - 1, 1);
					AffectedPawns[i].bDamaged = false;
				}
			}
		}
}

function AddAffectedPawn(Pawn AffectedPawn)
{
	local int i;

	for (i = 0; i < AffectedPawnsCount; ++i)
		if (AffectedPawns[i].Pawn == AffectedPawn)
		{
			AffectedPawns[i].Count++;
			AffectedPawns[i].TimePassed = 0;
			AffectedPawns[i].bDamaged = false;
			return;
		}

	for (i = 0; i < AffectedPawnsCount; ++i)
		if (AffectedPawns[i].Pawn == none)
			break;

	AffectedPawns[i].Pawn = AffectedPawn;
	AffectedPawns[i].Count = 1;
	AffectedPawns[i].TimePassed = 0;
	AffectedPawns[i].bDamaged = false;
	if (i == AffectedPawnsCount)
		AffectedPawnsCount++;
}

function SubtractAffectedPawn(Pawn AffectedPawn)
{
	local int i;

	for (i = 0; i < AffectedPawnsCount; ++i)
		if (AffectedPawns[i].Pawn == AffectedPawn)
		{
			if (--AffectedPawns[i].Count <= 0)
				AffectedPawns[i].Pawn = none;
			return;
		}
}

function bool PawnIsOnThisSurface(Pawn P)
{
	local float TraceDist;
	local Texture HitTexture;

	if (P.Physics != PHYS_Walking)
		return false;

	TraceDist = P.CollisionHeight + P.CollisionRadius + 30;
	P.TraceSurfHitInfo(P.Location, P.Location - vect(0,0,1) * TraceDist,,, HitTexture);

	return HitTexture != none && HitTexture.Name == TextureName;
}
