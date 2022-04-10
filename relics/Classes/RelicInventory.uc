class RelicInventory expands TournamentPickup;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var Relic MyRelic;
var float IdleTime;
var RelicShell ShellEffect;
var texture ShellSkin;
var class<RelicShell> ShellType;

var B227_AllRelics B227_Relics;

replication
{
	reliable if (Role < ROLE_Authority)
		TossRelic;
}

function Destroyed()
{
	if ( ShellEffect != None )
		ShellEffect.Destroy();
	if ( (MyRelic != None) && (MyRelic.SpawnedRelic == self) )
		MyRelic.SpawnRelic(0);
	if (B227_Relics != none && B227_Relics.HasSpawnedRelic(self))
		B227_Relics.B227_SpawnRelic(Class);

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	CheckForHUDMutator();
}

simulated function CheckForHUDMutator()
{
	local PlayerPawn P;

	P = Level.GetLocalPlayerPawn();
	if (P != none && P.myHUD != none)
	{
		if (ChallengeHUD(P.myHUD) == none ||
			ChallengeHUD(P.myHUD).B227_FindHUDMutator(class'RelicHUDMutator', true) != none ||
			ChallengeHUD(P.myHUD).B227_AddHUDMutator(class'RelicHUDMutator') != none)
		{
			if (Level.NetMode == NM_Client)
				SetTimer(0, false);
			return;
		}
	}

	if (Level.NetMode == NM_Client)
		SetTimer(1.0, true);
}

simulated function Timer()
{
	Super.Timer();
	if (Level.NetMode == NM_Client)
		CheckForHUDMutator();
}

function bool HandlePickupQuery( inventory Item )
{
	if ( Item.IsA('RelicInventory') )
		return True;
	else
		return Super.HandlePickupQuery( Item );
}

auto state Pickup
{
	function BeginState()
	{
		Super.BeginState();
		IdleTime = 0;
		SetOwner(None);
	}

	function Touch( actor Other )
	{
		if ( ValidTouch(Other) )
		{
			bHeldItem = True;
			Instigator = Pawn(Other);
			CheckForHUDMutator();
			BecomeItem();
			Pawn(Other).AddInventory( Self );

			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));

			if (bActivatable && Pawn(Other).SelectedItem==None)
				Pawn(Other).SelectedItem=Self;

			if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate)
				Self.Activate();

			if ( PickupMessageClass == None )
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Other), PickupMessageClass, 0, none, none, self.Class);
			PlaySound (PickupSound,,2.0);
			PickupFunction(Pawn(Other));
		}
	}

	simulated function Landed(Vector HitNormal)
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation(newRot);
		SetPhysics(PHYS_Rotating);
		IdleTime = 0;
		SetCollision( True, False, False );
	}
}

state Activated
{
	function EndState()
	{
		bActive = false;
	}

	function Timer()
	{
		if ( Role == ROLE_SimulatedProxy )
			CheckForHUDMutator();
	}

	function BeginState()
	{
		IdleTime = 0;
		bActive = true;
	}
}

state DeActivated
{
Begin:
}

function DropInventory()
{
	local RelicInventory Dropped;
	local vector X,Y,Z;

	Dropped = Spawn(Class);
	Dropped.MyRelic = MyRelic;
	Dropped.B227_Relics = B227_Relics;
	if (MyRelic != none)
		MyRelic.SpawnedRelic = Dropped;
	if (B227_Relics != none)
		B227_Relics.AddSpawnedRelic(Dropped);
	if (Owner != None )
	{
		Owner.GetAxes(Owner.Rotation,X,Y,Z);
		Dropped.SetLocation( Owner.Location + 0.8 * Owner.CollisionRadius * X + -0.5 * Owner.CollisionRadius * Y );
	}
	Dropped.RemoteRole	  = ROLE_SimulatedProxy;
	Dropped.Mesh          = PickupViewMesh;
	Dropped.DrawScale     = PickupViewScale;
	Dropped.bOnlyOwnerSee = false;
	Dropped.bHidden       = false;
	Dropped.bCarriedItem  = false;
	Dropped.NetPriority   = 1.4;
	Dropped.SetCollision( False, False, False );
	Dropped.SetPhysics(PHYS_Falling);
	Dropped.bCollideWorld = True;
	if ( Owner != None )
		Dropped.Velocity = Vector(Pawn(Owner).ViewRotation) * 500 + vect(0,0,220);
	Dropped.GotoState('PickUp', 'Dropped');
	// Remove from player's inventory.
	Destroy();
}

function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);

	LightType = LT_None;
}


function FlashShell(float Duration)
{
	if (ShellEffect == None)
	{
		ShellEffect = Spawn(ShellType, Owner,,Owner.Location, Owner.Rotation);
	}
	if ( ShellEffect != None && !Owner.bHidden )
	{
		ShellEffect.DrawType = ShellEffect.default.DrawType;
		ShellEffect.Mesh = Owner.Mesh;
		ShellEffect.DrawScale = Owner.Drawscale;
		ShellEffect.Texture = ShellSkin;
		ShellEffect.SetTimer(Duration, false);
	}
}

event float BotDesireability( pawn Bot )
{
	local Inventory Inv;

	// If we already have a Relic, we don't want another one.

	for( Inv=Bot.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.IsA('RelicInventory') )
			return -1;

	return MaxDesireability;
}

exec function TossRelic()
{
	DropInventory();
}

defaultproperties
{
     ShellSkin=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield'
     ShellType=Class'relics.RelicShell'
     bAutoActivate=True
     bActivatable=True
     PickupMessage="You picked up a null Relic."
     PickupViewMesh=LodMesh'Botpack.DomN'
     MaxDesireability=3.000000
     PickupSound=Sound'relics.relics.RelicPickup'
     bUnlit=True
     CollisionRadius=22.000000
     CollisionHeight=8.000000
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=255
     LightRadius=5
     LightPeriod=64
     LightPhase=255
     Mass=10.000000
     RotationRate=(Yaw=30000,Roll=20000)
     DesiredRotation=(Roll=20000)
}
