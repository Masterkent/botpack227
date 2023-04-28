//=============================================================================
// TournamentPickup.
//=============================================================================
class TournamentPickup extends UTC_Pickup;

function FireEffect();

function BecomeItem()
{
	local Bot B;
	local Pawn P;

	Super.BecomeItem();

	if ( Bot(Instigator) != none || Level.Game.bTeamGame || DeathMatchPlus(Level.Game) == none
		|| DeathMatchPlus(Level.Game).bNoviceMode
		|| (DeathMatchPlus(Level.Game).NumBots > 4) )
		return;

	// let high skill bots hear pickup if close enough
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		B = Bot(p);
		if ( (B != None)
			&& (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
		{
			B.HearPickup(Instigator);
			return;
		}
	}
}

// Auxiliary
static function int B227_HandleUTArmors(Pawn P, int UT_ShieldBeltCharge, int Armor2Charge, int ThighPadsCharge, optional Inventory NewArmor)
{
	local Inventory Inv;
	local Inventory SB, Ar, TP;
	local int SB_Charge, Ar_Charge, TP_Charge;
	local int Normal_SB_Charge, Normal_Ar_Charge, Normal_TP_Charge;
	local int GroupCharge, MaxGroupCharge;

	if (P == none)
		return 0;
	for (Inv = P.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.bIsAnArmor)
		{
			if (Inv.Class == class'UT_ShieldBelt' && SB == none)
			{
				SB = Inv;
				if (Inv != NewArmor)
					SB_Charge = Inv.Charge;
			}
			if (Inv.Class == class'Armor2' && Ar == none)
			{
				Ar = Inv;
				if (Inv != NewArmor)
					Ar_Charge = Inv.Charge;
			}
			if (Inv.Class == class'ThighPads' && TP == none)
			{
				TP = Inv;
				if (Inv != NewArmor)
					TP_Charge = Inv.Charge;
			}
		}
	GroupCharge = SB_Charge + Ar_Charge + TP_Charge;
	MaxGroupCharge = Max(class'UT_ShieldBelt'.default.Charge, GroupCharge);
	MaxGroupCharge = Max(MaxGroupCharge, UT_ShieldBeltCharge);
	MaxGroupCharge = Max(MaxGroupCharge, Armor2Charge);
	MaxGroupCharge = Max(MaxGroupCharge, ThighPadsCharge);
	Normal_SB_Charge = Max(SB_Charge, UT_ShieldBeltCharge);
	Normal_Ar_Charge = Max(0, Min(Max(Ar_Charge, Armor2Charge), MaxGroupCharge - Normal_SB_Charge));
	Normal_TP_Charge = Max(0, Min(Max(TP_Charge, ThighPadsCharge), MaxGroupCharge - Normal_SB_Charge - Normal_Ar_Charge));

	if (UT_ShieldBeltCharge > 0)
	{
		B227_SetUTArmorCharge(Ar, Normal_Ar_Charge);
		B227_SetUTArmorCharge(TP, Normal_TP_Charge);
		return Normal_SB_Charge;
	}
	if (Armor2Charge > 0)
	{
		B227_SetUTArmorCharge(TP, Normal_TP_Charge);
		return Normal_Ar_Charge;
	}
	if (ThighPadsCharge > 0)
		return Normal_TP_Charge;
	return 0;
}

static function B227_SetUTArmorCharge(Inventory Inv, int Value)
{
	if (Inv == none)
		return;

	if (Value <= 0)
		Inv.Destroy();
	else
		Inv.Charge = Value;
}

// UT_ShieldBelt + Armor2 + ThighPads
function int B227_TotalUTArmor()
{
	local int Result;
	local Inventory Inv;

	if (Owner == none)
		return 0;
	for (Inv = Owner.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.bIsAnArmor &&
			(Inv.Class == class'UT_ShieldBelt' || Inv.Class == class'Armor2' || Inv.Class == class'ThighPads'))
		{
			Result += Inv.Charge;
		}
	return Result;
}

defaultproperties
{
	// [U227] Excluded
	///M_Activated=""
	///M_Selected=""
	///M_Deactivated=""
	PickupMessageClass=Class'Botpack.PickupMessagePlus'
	ItemMessageClass=Class'Botpack.ItemMessagePlus'
	bRepAnimations=False
}
