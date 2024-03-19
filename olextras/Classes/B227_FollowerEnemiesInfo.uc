class B227_FollowerEnemiesInfo expands Info;

struct EnemyInfo // private
{
	var Pawn Enemy;
	var Follower Attacker;
};

var private EnemyInfo EnemiesInfo[16]; // static array for compatibility with 227i
var private int Count;

function bool AddEnemy(Pawn Enemy, Follower Attacker)
{
	local int i;
	local int EmptySlot;

	if (!IsActualPawn(Enemy))
		return false;

	EmptySlot = -1;

	for (i = Count - 1; i >= 0; --i)
	{
		if (EmptySlot < 0 &&
			!(IsActualPawn(EnemiesInfo[i].Enemy) && IsActualPawn(EnemiesInfo[i].Attacker) && EnemiesInfo[i].Attacker.Enemy == EnemiesInfo[i].Enemy))
		{
			if (i == Count - 1)
				Count--;
			else
				EmptySlot = i;
		}
		else if (EnemiesInfo[i].Enemy == Enemy && EnemiesInfo[i].Attacker == Attacker)
			return false;
	}

	if (EmptySlot < 0 && Count < ArrayCount(EnemiesInfo))
		EmptySlot = Count++;

	if (EmptySlot >= 0)
	{
		EnemiesInfo[EmptySlot].Enemy = Enemy;
		EnemiesInfo[EmptySlot].Attacker = Attacker;
		return true;
	}

	return false;
}

function bool IsAttackedEnemy(Pawn Enemy)
{
	local int i;

	if (Enemy == none)
		return false;

	for (i = 0; i < Count; ++i)
		if (EnemiesInfo[i].Enemy == Enemy && IsActualPawn(EnemiesInfo[i].Attacker) && EnemiesInfo[i].Attacker.Enemy == Enemy)
			return true;
	return false;
}

static function bool IsActualPawn(Pawn P)
{
	return P != none && !P.bDeleteMe && P.Health > 0;
}

defaultproperties
{
	RemoteRole=ROLE_None
}