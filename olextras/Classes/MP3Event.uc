// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Mp3Event: makes use of support of MP3's which galaxy can handle already.
// Note that transition, song, and songsection mean nothing!
// ============================================================

class MP3Event expands MusicEvent;
var (MusicEvent) sound MP3;
var (MusicEvent) bool bAllowTouch;      //can be all simulated.

// When gameplay starts.
simulated function BeginPlay()   //fixme: coop
{
  if (level.netmode==NM_client){ //no ginfo
  MP3 = Level.ambientsound;
  if( bSilence )
   MP3=none;
  return;}
  if( MP3==None &&level.game.isa('tvsp'))
  {
    if (level.ambientsound!=none)     //no idea if gameinfo or level is spaned first????
    MP3 = Level.ambientsound;
    else
    MP3 = TVSP(Level.game).MP3;
  }
  if( bSilence )
  {
   MP3=none;
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
        TVPlayer(A).ClientSetMP3( Mp3, Soundvolume, SoundPitch );

        TvPlayer(A).clientsetmusic(music'olroot.null',0,255,MTRAN_FADE);
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
    P.ClientSetMP3( Mp3, Soundvolume, SoundPitch );
    TvPlayer(A).clientsetmusic(music'olroot.null',0,255,MTRAN_FADE);
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
