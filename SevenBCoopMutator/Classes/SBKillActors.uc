class SBKillActors expands Info;

var class<Actor> ActorClass;

event Trigger(Actor A, Pawn EventInstigator)
{
	if (ActorClass == none)
		return;
	A = none;
	foreach AllActors(ActorClass, A)
		A.Destroy();
}
