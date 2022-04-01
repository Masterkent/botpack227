// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvEverythingNotify : Handles other sorts of replacements..
// ===============================================================

class TvEverythingNotify expands EverythingNotify;

simulated function PostBeginPlay()
{
  local actor other;
  if (level.netmode!=nm_client) //mutator works on server.
    return;
  Super(SpawnNotify).PostBeginPlay(); //add.
  log ("TvEveryThing Notify Initialized");
  ForEach Allactors(class'actor',other){   //mask.
    //-if (other.style==STY_NORMAL&&(other.IsA('decoration')&&((other.isa('tree')||left(getitemname(string(other.class)),5)~="plant"))||(other.role==role_authority&&other.isa('pawn')&&(other.isa('skaarjwarrior')||other.isa('krall')||other.isa('warlord')||other.isa('bird1')||other.isa('Slith')||other.isa('manta')))))
    //-  Other.Style=Sty_masked;
    //-if (other.IsA('scriptedpawn')&&!other.isa('tentacle')&&pawn(other).shadow==none)     //no decal for them.
    //-  scriptedpawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
    if (other.class==class'tree5'||other.class==class'tree6'){ //replace palm trees w/ new mesh
      other.mesh=class'leetpalm'.default.mesh;
      other.prepivot.z-=16*other.drawscale;
      other.MultiSkins[0]=Texture'Jdmisgay12';
      if (other.class==class'tree5')
        other.drawscale*=3.3;
      else
        other.drawscale*=3.85;
      other.SetCollisionSize(0.8*other.collisionradius,other.collisionheight);
    }
  }
}
simulated event Actor SpawnNotification(Actor other)
{
    if (other.style==STY_NORMAL&&(other.IsA('decoration')&&((other.isa('tree')||left(getitemname(string(other.class)),5)~="plant"))||(other.role==role_authority&&other.isa('pawn')&&(other.isa('skaarjwarrior')||other.isa('krall')||other.isa('warlord')||other.isa('bird1')||other.isa('Slith')||other.isa('manta')))))
      Other.Style=Sty_masked;
    //-if (other.IsA('scriptedpawn')&&!other.isa('tentacle')&&pawn(other).shadow==none)     //no decal for them.
    //-  scriptedpawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
  return other;
}

defaultproperties
{
}
