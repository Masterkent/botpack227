//=============================================================================
// UT_jumpBoots
//=============================================================================
class UT_JumpBoots extends TournamentPickup;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_UT_JumpBoots FILE=Textures\Hud\B227_i_UT_JumpBoots.pcx GROUP="Icons" MIPS=OFF

var int TimeCharge;

function PickupFunction(Pawn Other)
{
	TimeCharge = 0;
	SetTimer(1.0, True);
}

function ResetOwner()
{
	local pawn P;

	P = Pawn(Owner);
	if (P == none)
		return;
	P.JumpZ = P.Default.JumpZ * Level.Game.PlayerJumpZScaling();
	if (DeathMatchPlus(Level.Game) != none)
		P.AirControl = DeathMatchPlus(Level.Game).AirControl;
	else
		P.AirControl = P.Default.AirControl;
	P.bCountJumps = False;
}

function OwnerJumped()
{
	if (Pawn(Owner) == none)
		return;
	if (bActive &&
		(TournamentPlayer(Owner) == none || !Pawn(Owner).bIsWalking) &&
		B227_UseCharge())
	{
		if (Inventory != none && Pawn(Owner).JumpZ > Pawn(Owner).default.JumpZ * 3)
			Inventory.OwnerJumped();
	}
	else if (Inventory != none)
		Inventory.OwnerJumped();
}

function Timer()
{
	if ( Charge <= 0 )
	{
		if ( Owner != None )
		{
			if ( Owner.Physics == PHYS_Falling )
			{
				SetTimer(0.3, true);
				return;
			}
			Owner.PlaySound(DeActivateSound);
			ResetOwner();
		}
		UsedUp();
		return;
	}

	if (Pawn(Owner) != none && !Pawn(Owner).bAutoActivate)
	{
		TimeCharge++;
		if (TimeCharge>20)
		{
			B227_UseCharge();
			TimeCharge = 0;
		}
	}
}

state Activated
{
	event BeginState()
	{
		bActive = true;
		Pawn(Owner).bCountJumps = true;
		Pawn(Owner).AirControl = FMax(Pawn(Owner).AirControl, 1.0);
		Pawn(Owner).JumpZ = FMax(Pawn(Owner).JumpZ, Pawn(Owner).default.JumpZ * 3);
	}
	event EndState()
	{
		ResetOwner();
		bActive = false;
	}

	event Tick(float DeltaTime)
	{
		if (Pawn(Owner) != none)
		{
			Pawn(Owner).bCountJumps = true;
			Pawn(Owner).AirControl = FMax(Pawn(Owner).AirControl, 1.0);
			Pawn(Owner).JumpZ = FMax(Pawn(Owner).JumpZ, Pawn(Owner).default.JumpZ * 3);
		}
	}

Begin:
	if (Pawn(Owner) != none)
		Owner.PlaySound(ActivateSound, SLOT_None);
}

state DeActivated
{
Begin:
}

function bool B227_UseCharge()
{
	TimeCharge = 0;
	if (Charge <= 0)
	{
		if (bActive)
		{
			Owner.PlaySound(DeActivateSound, SLOT_None);
			ResetOwner();
		}
		UsedUp();
		return false;
	}
	Owner.PlaySound(sound'BootJmp', SLOT_None);
	Charge -= 1;
	return true;
}

defaultproperties
{
	ExpireMessage="The AntiGrav Boots have drained."
	bAutoActivate=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the AntiGrav boots."
	ItemName="AntiGrav Boots"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'Botpack.jboot'
	Charge=3
	MaxDesireability=0.500000
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'Botpack.Pickups.BootSnd'
	Icon=Texture'Botpack.Icons.B227_I_UT_JumpBoots'
	RemoteRole=ROLE_DumbProxy
	Mesh=LodMesh'Botpack.jboot'
	AmbientGlow=64
	CollisionRadius=22.000000
	CollisionHeight=14.000000
}
