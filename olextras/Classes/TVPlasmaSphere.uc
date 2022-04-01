// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVPlasmaSphere : A reskinned sphere that is blue.
// Also has cool chaotic sinusoidal movement :)
// Does more damage to make up for chaos ;p
// ===============================================================

class TVPlasmaSphere expands PlasmaSphere;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

//sinusoidal motion:
var bool bSetInitial;
var float TotalTime; //time in existance
var int YAmplitude; //amplitude in Y direction
var int YSpeed; //rotational velocity in Y dir
var int ZAmplitude; //amplitude in Z direction
var int ZSpeed; //rotational velocity in Z dir
var float LastYOffSet, LastZOffSet; //last offsets of sinusoidal motion
var vector Y, Z;
var rotator OldRot; //warpzone

replication{
  reliable if (role==role_authority)
    YAmplitude, YSpeed, ZAmplitude, ZSpeed;
}

simulated function HitWall (vector HitNormal, actor Wall)
{
  Super.HitWall(HitNormal,Wall);
}

simulated function Tick(float delta)
{
  local vector X;
  local int Dec;
  if (bExplosionEffect){
    disable('tick');
    return;
  }
  if (!bSetInitial){
    SetRotation(rotator(Velocity)); //warp-zone hack
    GetAxes (Rotation, X, Y, Z);
    oldrot=rotation;
    bSetInitial=true;
    if (Role==role_authority){
      Dec=rand(4);
      YAmplitude=rand(10)+7;
      ZAmplitude=rand(10)+5;
      YSpeed=rand(10)+12;
      if (Dec<2)
        YSpeed*=-1;
      ZSpeed=rand(5)+7;
      if (Dec%2==0)
        ZSpeed*=-1;
    }
  }
  TotalTime+=delta;
  if (oldrot!=rotation){
    GetAxes (Rotation, X, Y, Z);
    oldrot=rotation;
  }
  X = LastYOffSet * Y + LastZOffSet * Z;
  LastYOffset= YAmplitude*sin(YSpeed*totaltime);
  LastZOffset= ZAmplitude*sin(ZSpeed*totaltime);
  SetLocation(Location+LastYOffSet * Y + LastZOffSet * Z - X);
}

defaultproperties
{
     YAmplitude=12
     YSpeed=17
     ZAmplitude=10
     ZSpeed=10
     ExpType=Texture'olextras.BluePlasmaExplo.pblst_a00'
     Damage=22.000000
     Texture=Texture'olextras.BluePlasmaExplo.pblst_a00'
     LightHue=170
}
