// Increases casting ability
// Code by Sergey 'Eater' Levin

class NCSkillBooster extends Pickup;

var int skillIncrease[7];
var int oldSkills[7];

function UsedUp()
{
	local int i;

	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		Pawn(Owner).NextItem();
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	while (i < 6 && NaliMage(Owner) != none) {
		NaliMage(Owner).SpellSkills[i] -= skillIncrease[i];
		i++;
	}
	Pawn(Owner).DeleteInventory(Self);
	Destroy();
}

function calcIncrease() {
	local int i;
	local int newInc;
	local int newSkill;

	if (NaliMage(Owner) == none) return;
	newInc = fMin((float(charge)/60.0),1)*8.0;
	if (newInc < 1) newInc = 1;
	while (i < 6) {
		newSkill = NaliMage(Owner).SpellSkills[i] + (newInc-skillIncrease[i]);
		if (newSkill > 8) newSkill = 8;
		skillIncrease[i] += newSkill-NaliMage(Owner).SpellSkills[i];
		NaliMage(Owner).SpellSkills[i] = newSkill;
		i++;
	}
}

function Tick(float DeltaTime) {
	local int i;

	if (NaliMage(Owner) == none) return;
	while(i < 6) {
		if (NaliMage(Owner).SpellSkills[i] != oldSkills[i]) {
			calcIncrease();
			break;
		}
		oldSkills[i] = NaliMage(Owner).SpellSkills[i];
	}
}

function Timer() {
	if (Owner != none && charge > 0) {
		charge -= 1;
		calcIncrease();
		if (charge <= 0)
			UsedUp();
	}
	SetTimer(0.75,false);
}

defaultproperties
{
     Charge=120
}
