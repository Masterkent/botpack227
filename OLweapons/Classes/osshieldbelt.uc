// ============================================================
// oldskool.oldskoolshieldbelt: hack to use in DM and change the HUD... will destroy other armors as its DMP :D note: also uses the effects ripped shamelessly from unreal I
// Psychic_313: unchanged
// ============================================================

class osshieldbelt expands ut_shieldbelt;

//warning: data ripped utx file!  will crash ued!
#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

var ShieldBeltEffect MyEffectold;

function prebeginplay(){
super.prebeginplay();
if (level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules)
charge=150;
}

function SetEffectTexture()
{
  if ( TeamNum != 3 )
    MyEffectold.ScaleGlow = 0.5;
  else
    MyEffectold.ScaleGlow = 1.0;
  MyEffectold.ScaleGlow *= (0.25 + 0.75 * Charge/Default.Charge);
  if ( TeamFireTextures[TeamNum] == None )
    TeamFireTextures[TeamNum] =FireTexture(DynamicLoadObject(TeamFireTextureStrings[TeamNum], class'Texture'));
  MyEffectold.Texture = TeamFireTextures[TeamNum];
  if ( TeamTextures[TeamNum] == None )
    TeamTextures[TeamNum] = Texture(DynamicLoadObject(TeamTextureStrings[TeamNum], class'Texture'));
  MyEffectold.LowDetailTexture = TeamTextures[TeamNum];
}
function bool HandlePickupQuery( inventory Item )
{
  local Inventory I;

  if (item.class == class&&level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules)
  {
    // remove other armors
    for ( I=Owner.Inventory; I!=None; I=I.Inventory )
      if ( I.bIsAnArmor && (I != self) )
        I.Destroy();
  }

  return Super(TournamentPickup).HandlePickupQuery(Item);
}
function PickupFunction(Pawn Other)
{
  local inventory i;
  MyEffectold = Spawn(class'ShieldBeltEffect', Owner,,Owner.Location, Owner.Rotation);
  MyEffectold.Mesh = Owner.Mesh;
  MyEffectold.DrawScale = Owner.Drawscale;

  if ( Level.Game.bTeamGame && (Other.PlayerReplicationInfo != None) )
    TeamNum = Other.PlayerReplicationInfo.Team;
  else
    TeamNum = 3;
  SetEffectTexture();
  //copied as we WANT this code....
   //-I = Pawn(Owner).FindInventoryType(class'UT_Invisibility');
  //-if ( I != None )
  //-  MyEffectold.bHidden = true;
  if (Owner.bHidden || Owner.Style == STY_Translucent)
    MyEffectold.bHidden = true;

  // remove other armors    (if DMP)
  if (level.game.isa('deathmatchplus')&&class'olweapons.uiweapons'.default.newarmorrules)
  for ( I=Owner.Inventory; I!=None; I=I.Inventory )
    if ( I.bIsAnArmor && (I != self)&&(!I.isa('suits')||i.isa('kevlarsuit') ))
      I.Destroy();
}

function ArmorImpactEffect(vector HitLocation)
{
  if (PlayerPawn(Owner) != none)
    PlayerPawn(Owner).ClientFlash(-0.05,vect(400,400,400));
  if (Pawn(Owner) != none)
    Owner.PlaySound(DeActivateSound, SLOT_None, 2.7 * Pawn(Owner).SoundDampening);
  if ( MyEffectold != None )
  {
    MyEffectold.ScaleGlow = 4.0;
    MyEffectold.Fatness = 255;
    SetTimer(0.8, false);
  }
}

function Timer()
{
  if ( MyEffectold != None )
  {
    MyEffectold.Fatness = MyEffectold.Default.Fatness;
    SetEffectTexture();
  }
}

function Destroyed()
{
  if ( Owner != None )
  {
    Owner.SetDefaultDisplayProperties();
    if( Owner.Inventory != None )
      Owner.Inventory.SetOwnerDisplay();
  }
  if ( MyEffectold != None )
    MyEffectold.Destroy();
  Super(tournamentpickup).Destroyed();
}

defaultproperties
{
     TeamFireTextureStrings(0)="olweapons.Belt_fx.ShieldBelt.RedShield"
     TeamFireTextureStrings(1)="olweapons.Belt_fx.ShieldBelt.BlueShield"
     TeamFireTextureStrings(2)="olweapons.Belt_fx.ShieldBelt.Greenshield"
     TeamFireTextureStrings(3)="olweapons.Belt_fx.ShieldBelt.N_Shield"
     TeamFireTextures(0)=FireTexture'OLweapons.Belt_fx.ShieldBelt.RedShield'
     TeamFireTextures(1)=FireTexture'OLweapons.Belt_fx.ShieldBelt.BlueShield'
     TeamFireTextures(2)=FireTexture'OLweapons.Belt_fx.ShieldBelt.Greenshield'
     TeamFireTextures(3)=FireTexture'OLweapons.Belt_fx.ShieldBelt.N_Shield'
     PickupViewMesh=LodMesh'UnrealShare.ShieldBeltMesh'
     Charge=100
     Mesh=LodMesh'UnrealShare.ShieldBeltMesh'
}
