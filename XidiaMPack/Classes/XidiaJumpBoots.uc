// ===============================================================
// XidiaMPack.XidiaJumpBoots: 20 second delay... but no charge!
// ===============================================================

class XidiaJumpBoots expands ut_jumpboots;

var bool bCanJump;
var() float JumpDelay;
var bool B227_bReloading;

function PickupFunction(Pawn Other)
{
	TimeCharge = 0;
	SetTimer(0.0, false);
	bCanJump = true;
	B227_bReloading = false;
}

function SetJumpZ()
{
	if (Pawn(Owner) != none)
	{
		if (bCanJump)
		{
			Pawn(Owner).bCountJumps = true;
			Pawn(Owner).AirControl = FMax(Pawn(Owner).AirControl, 1.0);
			Pawn(Owner).JumpZ = FMax(Pawn(Owner).JumpZ, Pawn(Owner).default.JumpZ * 3);
		}
		else if (!B227_bReloading && Owner.Physics != PHYS_Falling)
		{
			B227_bReloading = true;
			ResetOwner();
		}
	}
}

event Timer()
{
	bCanJump = true;
	B227_bReloading = false;
	if (IsInState('Activated'))
		Owner.PlaySound(sound'BootSnd');
}

function OwnerJumped()
{
	if (Pawn(Owner) != none && IsInState('Activated'))
	{
		SetJumpZ();
		if (bCanJump)
		{
			Owner.PlaySound(sound'BootJmp');
			bCanJump = false;
			SetTimer(JumpDelay, false);
		}
	}

	if (Inventory != none)
		Inventory.OwnerJumped();
}

state Activated
{
	event BeginState()
	{
		bActive = true;
		SetJumpZ();
	}
	event EndState()
	{
		ResetOwner();
		bActive = false;
	}

	event Tick(float DeltaTime)
	{
		SetJumpZ();
	}

Begin:
	if (Pawn(Owner) != none && bCanJump)
		Owner.PlaySound(ActivateSound);
}

defaultproperties
{
     bCanJump=True
     JumpDelay=11.000000
     PickupMessage="You picked up the AntiGrav boots with an 11 second recharge time!"
}
