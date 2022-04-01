// ===============================================================
// SevenB.SBPlasmaSphere: sinusoidal motion and more damage
// ===============================================================

class SBPlasmaSphere extends PlasmaSphere;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

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

replication
{
  reliable if (role==role_authority)
    YAmplitude, YSpeed, ZAmplitude, ZSpeed;
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
      YAmplitude=rand(6)+6;
      ZAmplitude=rand(6)+6;
      YSpeed=rand(7)+7;
      if (Dec<2)
        YSpeed*=-1;
      ZSpeed=rand(7)+7;
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

function int B227_GetDamage()
{
	return Damage;
}

defaultproperties
{
     YAmplitude=12
     YSpeed=17
     ZAmplitude=10
     ZSpeed=10
     ExpType=Texture'SevenB.RedPlasmaExplo.pfpblst_a00'
     Damage=36.000000
     MyDamageType=exploded
     Texture=Texture'SevenB.RedPlasmaExplo.pfpblst_a00'
     LightHue=10
}
