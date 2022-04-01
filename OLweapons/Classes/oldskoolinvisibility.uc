// ============================================================
//oldskoolinvisibility.  ensures that the invisibility unhides if stuff......
// Psychic_313: unchanged
// ============================================================

class oldskoolinvisibility expands TournamentPickup;

var byte TempVis;
var bool waspointing;


function Invisibility (bool Vis)
{
  if (Pawn(Owner)==None) Return;

  if( Vis )
  {
    PlaySound(ActivateSound,,4.0);
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(156.25,156.25,351.625));
    Pawn(Owner).Visibility = 10;
    Pawn(Owner).bHidden=True;
    if ( Pawn(Owner).Weapon != None )
      Pawn(Owner).Weapon.bOnlyOwnerSee=False;
  }
  else
  {
    PlaySound(DeActivateSound);
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(-156.25,-156.25,-351.625));
    Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
    if ( Pawn(Owner).health > 0 )
      Pawn(Owner).bHidden=False;
    if ( Pawn(Owner).Weapon != None )
      Pawn(Owner).Weapon.bOnlyOwnerSee=True;
  }
}

state Activated
{
  function endstate()
  {
    Invisibility(False);
    bActive = false;
  }

  function tick(float deltatime){        //tick to verify if weapon is firing........
  If (Pawn(Owner).weapon.Isinstate('normalfire')||Pawn(Owner).weapon.Isinstate('altfiring'))   //check states
  Owner.bHidden = false;
  Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
  }

  function Timer()
  {
    Charge -= 1;
    Owner.bHidden=True;
    Pawn(Owner).Visibility = 10;
    if (Charge<-0)
    {
      Pawn(Owner).ClientMessage(ExpireMessage);
      UsedUp();
    }
  }

  function BeginState()
  {
    Invisibility(True);
    SetTimer(0.5,True);
  }
}

state DeActivated
{
Begin:
}

defaultproperties
{
     ExpireMessage="Invisibility has worn off."
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You have Invisibility"
     RespawnTime=100.000000
     PickupViewMesh=LodMesh'UnrealI.InvisibilityMesh'
     Charge=100
     MaxDesireability=1.200000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealI.Pickups.Invisible'
     Icon=Texture'UnrealI.Icons.I_Invisibility'
     RemoteRole=ROLE_DumbProxy
     Mesh=LodMesh'UnrealI.InvisibilityMesh'
     AmbientGlow=96
     CollisionRadius=15.000000
     CollisionHeight=17.000000
}
