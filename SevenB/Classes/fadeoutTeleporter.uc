// ============================================================
// fadeoutteleporter. A teleporter that is a fadeviewtrigger and teleporter in one
// also notifies HUD and such (scoreing entry point)
// ============================================================

class fadeoutTeleporter expands UTC_Teleporter;
var(ZoneLight) vector ViewFlash, ViewFog;
var() vector TargetFlash;
var() float FadeSeconds;
var(Teleporter) string CoOpURL; //a different URL in co-op mode. (To skip cutscenes).

var bool doflash;
var vector OldViewFlash;
var actor actorbackup;
event BeginPlay()
{
  Super.BeginPlay();
  Disable('Tick');
  enable('touch');
}

event Tick(float DeltaTime)
{
   local float X, Y, Z;
   local bool bXDone, bYDone, bZDone;

    if (doflash)
   {
    bXDone = False;
    bYDone = False;
    bZDone = False;

    X = Region.Zone.ViewFlash.X;
    Y = Region.Zone.ViewFlash.Y;
    Z = Region.Zone.ViewFlash.Z;

    X = X - (OldViewFlash.X - TargetFlash.X)*(DeltaTime / FadeSeconds);
    Y = Y - (OldViewFlash.Y - TargetFlash.Y)*(DeltaTime / FadeSeconds);
    Z = Z - (OldViewFlash.Z - TargetFlash.Z)*(DeltaTime / FadeSeconds);

    if( X < TargetFlash.X ) { X = TargetFlash.X; bXDone = True; }
    if( Y < TargetFlash.Y ) { Y = TargetFlash.Y; bYDone = True; }
    if( Z < TargetFlash.Z ) { Z = TargetFlash.Z; bZDone = True; }

    Region.Zone.ViewFlash.X = X;
    Region.Zone.ViewFlash.Y = Y;
    Region.Zone.ViewFlash.Z = Z;
    //Enable ('tick'); //ensure it stays.....
    if(bXDone && bYDone && bZDone)
      tele(actorbackup);
      }

}
function touch (actor Other){
//log ("someone touched a fade out tele! defaults set to other.bispawn="$other.bispawn$" and pawn(other).bisplayer="$(pawn(other)!=none&&pawn(other).bisplayer));
 if ( !bEnabled )
   return;
IF (!other.bispawn||!pawn(other).bisplayer)
return;
if (level.netmode!=nm_standalone){ //screw this, just teleport
  if (CoopURL!="")
    URL=CoopURL;
  super.touch(other);
  return;
}
//log ("activating fade-out teleporter");
actorbackup=Other; //so tick can call it
    OldViewFlash = Region.Zone.ViewFlash;
    doflash=true;
    if (playerpawn(other)!=none){
      playerpawn(other).clientsetmusic(music(DynamicLoadObject("olroot.null",class'music')),0,255,MTRAN_SlowFade);
      if (TvHUD(PlayerPawn(other).myhud)!=none)
        TVHUD(PlayerPawn(other).myhud).TelePorting(FadeSeconds);
    }
    Enable('Tick');
}

function tele( actor Other )
{
  local Teleporter Dest;
  local int i;
  local Actor A;

  if ( !bEnabled )
    return;

  Disable ('tick');
  if( Other.bCanTeleport && Other.PreTeleport(Self)==false )
  {
    if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
    {
      // Teleport to a level on the net.
      if( PlayerPawn(Other) != None ) {
       //do this the hard way :(
     //  playerpawn(other).player.console.bnodrawworld=true; //will not draw the freaken world now!
       Level.Game.SendPlayer(PlayerPawn(Other), URL);   //moves player? ought to fix...
            }
    }
    else
    {
      // Teleport to a random teleporter in this local level, if more than one pick random.

      foreach AllActors( class 'Teleporter', Dest )
        if( string(Dest.tag)~=URL && Dest!=Self )
          i++;
      i = rand(i);
      foreach AllActors( class 'Teleporter', Dest )
        if( string(Dest.tag)~=URL && Dest!=Self && i-- == 0 )
          break;
      if( Dest != None )
      {
        // Teleport the actor into the other teleporter.
       // if ( Other.IsA('Pawn') )
        //  PlayTeleportEffect( Pawn(Other), false);
        UTSF_Accept(Dest, Other, self);
        if( (Event != '') && (Other.IsA('Pawn')) )
          foreach AllActors( class 'Actor', A, Event )
            A.Trigger( Other, Other.Instigator );
      }
      else if ( Role == ROLE_Authority )
        Pawn(Other).ClientMessage( "Teleport destination for "$self$" not found!" );
    }
  }
}
function PlayTeleportEffect(actor Incoming, bool bOut); //no effect.

defaultproperties
{
     TargetFlash=(X=-2.000000,Y=-2.000000,Z=-2.000000)
     FadeSeconds=5.000000
     bStatic=False
}
