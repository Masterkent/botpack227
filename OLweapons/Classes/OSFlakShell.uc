// ============================================================
// OLweapons.OSFlakShell: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSFlakShell expands FlakShell;
/*simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.ulweapons'.default.busedecals)
    ExplosionDecal=Class'Botpack.BlastMark';
    else
    ExplosionDecal=None;
    }  */
var vector initialDir;

simulated function PostBeginPlay()
  {
    Super.PostBeginPlay();
    initialDir = Velocity;
  }
simulated function Timer()        //drop detail allowed to....
{
  local SpriteSmokePuff s;

  initialDir = Velocity;
  if (Level.NetMode!=NM_DedicatedServer)
  {
    s = Spawn(class'SpriteSmokePuff');
    s.RemoteRole = ROLE_None;
  }
  if ( Level.bDropDetail )
    SetTimer(0.25,True);
  else if ( Level.bHighDetailMode )
    SetTimer(0.04,True);
}

simulated function Landed( vector HitNormal )
{
  local DirectionalBlast D;

  if (( Level.NetMode != NM_DedicatedServer )&&(class'olweapons.uiweapons'.default.bUseDecals))
  {
    D = Spawn(class'odDirectionalBlast',self);
    if ( D != None )
      D.DirectionalAttach(initialDir, HitNormal);
  }
  Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
  local DirectionalBlast D;

  if (( Level.NetMode != NM_DedicatedServer )&&(class'olweapons.uiweapons'.default.bUseDecals))
  {
    D = Spawn(class'odDirectionalBlast',self);
    if ( D != None )
      D.DirectionalAttach(initialDir, HitNormal);
  }
  Super.HitWall(HitNormal, Wall);
}
function Explode(vector HitLocation, vector HitNormal)
  {
    local vector start;

    HurtRadiusProj(damage, 150, 'exploded', MomentumTransfer, HitLocation);
    start = Location + 10 * HitNormal;
     Spawn( class'FlameExplosion',,,Start);
    Spawn(class 'OSMasterChunk',,,Start);
    Spawn( class 'OSChunk2',, '', Start);
    Spawn( class 'OSChunk3',, '', Start);
    Spawn( class 'OSChunk4',, '', Start);
    Spawn( class 'OSChunk1',, '', Start);
    Spawn( class 'OSChunk2',, '', Start);
     Destroy();
  }

defaultproperties
{
}
