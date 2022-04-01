//=============================================================================
// ut_ShieldBelt.
//=============================================================================
class UT_ShieldBelt extends TournamentPickup;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_UT_ShieldBelt FILE=Textures\Hud\B227_i_UT_ShieldBelt.pcx GROUP="Icons" MIPS=OFF

var UT_ShieldBeltEffect MyEffect;
var() string TeamFireTextureStrings[4];
var() string TeamTextureStrings[4];
var firetexture TeamFireTextures[4];
var texture TeamTextures[4];
var int TeamNum;

event float BotDesireability( pawn Bot )
{
	local inventory Inv;

	for ( Inv=Bot.inventory; Inv!=None; Inv=Inv.inventory )
		if ( Inv.IsA('RelicDefenseInventory') )
			return -1; //can't pickup up shieldbelt if have defense relic

	return Super.BotDesireability(Bot);
}

function bool HandlePickupQuery(Inventory Item)
{
	if (Item.Class == Class) 
		B227_HandleUTArmors(Pawn(Owner), Item.Charge, 0, 0);

	return super.HandlePickupQuery(Item);
}

function ArmorImpactEffect(vector HitLocation)
{ 
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).ClientFlash(-0.05, vect(400, 400, 400));

	if (Pawn(Owner) != none)
		Owner.PlaySound(DeActivateSound, SLOT_None, 2.7 * Pawn(Owner).SoundDampening);

	if ( MyEffect != None )
	{
		//MyEffect.Texture = MyEffect.LowDetailTexture;
		MyEffect.ScaleGlow = 4.0;
		MyEffect.Fatness = 255;
		SetTimer(0.8, false);
	}
}

function Timer()
{
	if ( MyEffect != None )
	{
		MyEffect.Fatness = MyEffect.Default.Fatness;
		SetEffectTexture();
	}
}

function Destroyed()
{
	if (MyEffect != none)
		MyEffect.Destroy();
	super.Destroyed();
}

function PickupFunction(Pawn Other)
{
	MyEffect = Spawn(class'UT_ShieldBeltEffect', Other,,Other.Location, Other.Rotation); 
	MyEffect.Mesh = Owner.Mesh;
	MyEffect.DrawScale = Owner.Drawscale;

	if ( Level.Game.bTeamGame && (Other.PlayerReplicationInfo != None) )
		TeamNum = Other.PlayerReplicationInfo.Team;
	else
		TeamNum = 3;
	SetEffectTexture();

	if (Owner.bHidden || Owner.Style == STY_Translucent)
		MyEffect.bHidden = true;

	B227_HandleUTArmors(Pawn(Owner), Charge, 0, 0, self);
}

function SetEffectTexture()
{
	if ( TeamNum != 3 )
		MyEffect.ScaleGlow = 0.5;
	else
		MyEffect.ScaleGlow = 1.0;
	MyEffect.ScaleGlow *= (0.25 + 0.75 * Charge/Default.Charge);
	if ( TeamFireTextures[TeamNum] == None )
		TeamFireTextures[TeamNum] =FireTexture(DynamicLoadObject(TeamFireTextureStrings[TeamNum], class'Texture'));
	MyEffect.Texture = TeamFireTextures[TeamNum];
	if ( TeamTextures[TeamNum] == None )
		TeamTextures[TeamNum] = Texture(DynamicLoadObject(TeamTextureStrings[TeamNum], class'Texture'));
	MyEffect.LowDetailTexture = TeamTextures[TeamNum];
}

defaultproperties
{
	TeamFireTextureStrings(0)="Botpack227_Base.Belt_fx.ShieldBelt.RedShield"
	TeamFireTextureStrings(1)="Botpack227_Base.Belt_fx.ShieldBelt.BlueShield"
	TeamFireTextureStrings(2)="Botpack227_Base.Belt_fx.ShieldBelt.Greenshield"
	TeamFireTextureStrings(3)="Botpack227_Base.Belt_fx.ShieldBelt.N_Shield"
	TeamTextureStrings(0)="UnrealShare.Belt_fx.ShieldBelt.newred"
	TeamTextureStrings(1)="UnrealShare.Belt_fx.ShieldBelt.newblue"
	TeamTextureStrings(2)="UnrealShare.Belt_fx.ShieldBelt.newgreen"
	TeamTextureStrings(3)="UnrealShare.Belt_fx.ShieldBelt.newgold"
	TeamFireTextures(0)=FireTexture'Botpack227_Base.Belt_fx.ShieldBelt.RedShield'
	TeamFireTextures(1)=FireTexture'Botpack227_Base.Belt_fx.ShieldBelt.BlueShield'
	TeamFireTextures(2)=FireTexture'Botpack227_Base.Belt_fx.ShieldBelt.Greenshield'
	TeamFireTextures(3)=FireTexture'Botpack227_Base.Belt_fx.ShieldBelt.N_Shield'
	TeamTextures(0)=Texture'UnrealShare.Belt_fx.ShieldBelt.newred'
	TeamTextures(1)=Texture'UnrealShare.Belt_fx.ShieldBelt.newblue'
	TeamTextures(2)=Texture'UnrealShare.Belt_fx.ShieldBelt.newgreen'
	TeamTextures(3)=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
	bDisplayableInv=True
	PickupMessage="You got the Shield Belt."
	ItemName="ShieldBelt"
	RespawnTime=60.000000
	PickupViewMesh=LodMesh'Botpack.ShieldBeltMeshM'
	ProtectionType1=ProtectNone
	ProtectionType2=ProtectNone
	Charge=150
	ArmorAbsorption=100
	bIsAnArmor=True
	AbsorptionPriority=10
	MaxDesireability=3.000000
	PickupSound=Sound'UnrealShare.Pickups.BeltSnd'
	DeActivateSound=Sound'UnrealShare.Pickups.Sbelthe2'
	Icon=Texture'Botpack.Icons.B227_I_UT_ShieldBelt'
	bOwnerNoSee=True
	RemoteRole=ROLE_DumbProxy
	Mesh=LodMesh'Botpack.ShieldBeltMeshM'
	CollisionRadius=25.000000
	CollisionHeight=10.000000
}
