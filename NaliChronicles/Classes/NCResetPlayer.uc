// Resets the player's skills and inventory
// Code by Sergey 'Eater' Levin, 2002

class NCResetPlayer extends Triggers;

var() bool bTriggerOnceOnly;
var bool bTriggered;

auto state Enabled
{
	function Touch( Actor Other )
	{
		local inventory Inv;
		local NaliMage P;
		local int i;

		if((NaliMage(Other) != none) && (!bTriggered || !bTriggerOnceOnly))
		{
			bTriggered = true;
			P = NaliMage(Other);
			for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				Inv.destroy();
			}
			P.CurrentVial = none;
			for (i=0;i<7;i++) {
				P.SpellSkills[i] = P.default.SpellSkills[i];
				P.SpellExp[i] = P.default.SpellExp[i];
				if (i < 5)
					P.LevelNeeds[i] = P.default.LevelNeeds[i];
				if (i < 4)
					P.QuickSpells[i] = none;
				P.OpenBooks[i] = P.default.OpenBooks[i];
			}
			P.currentbook = 0;
			P.HighlightedSpell = none;
			P.SelectedSpell = none;
			P.CurrQuickSpell = 0;
			P.mana = 100;
			P.maxmana = 100;
			P.health = 100;
			P.manaLevel = 0;
		}
	}
}

defaultproperties
{
}
