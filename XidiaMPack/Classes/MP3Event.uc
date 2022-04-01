// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Mp3Event: makes use of support of MP3's which galaxy can handle already.
// Note that transition, song, and songsection mean nothing!
// ============================================================

class MP3Event expands MusicEvent;
var (MusicEvent) sound RightMP3; //if none.. then stop the muzac
var (MusicEvent) sound LeftMp3; //if none.. is mono (right only.. though played at center as well)
var (MusicEvent) bool bAllowTouch;      //can be all simulated.

// When gameplay starts.
simulated function BeginPlay()   //fixme: coop
{
  if( bSilence )
  {
    RightMP3=none;
    LeftMp3=none;
  }
}
simulated function touch(actor other){  //can be client-side
  if (bAllowTouch&&other.isa('TvPlayer')&&(level.netmode!=NM_client||!baffectAllPlayers))
    trigger(other,pawn(other));
}
// When triggered.
simulated function Trigger( actor Other, pawn EventInstigator )
{
  local TvPlayer P;
  local Pawn A;

  if (role<role_authority&&!ballowtouch)   //simulated problems?
  return;
  if( bAffectAllPlayers )
  {
   for (A=level.pawnlist;A!=none;A=A.nextpawn)
    {
      if ( A.IsA('TvPlayer') ){
        TVPlayer(A).ClientSetMP3( RightMp3, LeftMp3);
      }
    }
  }
  else
  {
    // Only affect the one player.
    P = TvPlayer(EventInstigator);
    if( P==None )
      return;

    // Go to music.
    P.ClientSetMP3(RightMp3, LeftMp3);
  }

  // Turn off if once-only.
  if( bOnceOnly )
  {
    SetCollision(false,false,false);
    disable( 'Trigger' );
    disable( 'Touch' );
  }
}

defaultproperties
{
}
