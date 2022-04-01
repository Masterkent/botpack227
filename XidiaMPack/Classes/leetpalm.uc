//=============================================================================
// leetpalm.  Note that it is 152 un. high at default drawscale.
// tree is special in that it can spawn its own decal shadow.
//=============================================================================
class leetpalm expands Tree;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

//#exec MESH ORIGIN MESH=leetpalm X=5 Y=-50 Z=0

//#exec TEXTURE IMPORT NAME=Jdmisgay12 FILE=MODELS\palmtex2.pcx GROUP=Skins MIPS=OFF

//#exec MESHMAP SETTEXTURE MESHMAP=leetpalm NUM=0 TEXTURE=Jdmisgay12

//AUTOMATIC SHADOW STUFF:
var () name LightTag; //set light tag to the tag of an actor that light should be calculated from! (rotation)
var () bool bShadowImportant; //if true, shadow is spawned even if decals off and bhighdetail false. still will fail in software renderer...
//add dynamic light turning?

simulated function PostBeginPlay(){
  //fix skin:
  if (Multiskins[0]!=none)
    MultiSkins[0].DrawScale=0.9;
}
simulated function SpawnShadow(class<Decal> DecalClass){
  local actor MyLight;
  local Decal Shadow;
  local vector HitLoc,HitNorm;
  local vector BaseLoc;
  local vector temp, temp2;
  local rotator temprot;

  if (LightTag=='')
    return;
  bShadowCast=true; //?
  foreach AllActors (class'actor',MyLight,LightTag) //find light.
      break;
  if (MyLight==none){
    log ("Error:"@self@"Light source of given tag does not exist!",'ONP');
    return;
  }
  if (Mylight.location.z<location.z){
    log ("Error:"@self@"shadow light source is below palm tree!",'ONP');
    return;
  }
  temprot=rotation;
  temprot.yaw-=7000; //with yaw of 7000, tree bends only toward vect(1,0,0)
  BaseLoc=Location-2*collisionradius*vector(temprot);
  temp=BaseLoc;
  temp.z+=22*drawscale; //top of tree.
  if (Trace(HitLoc,HitNorm,Baseloc+1000*normal(temp-Mylight.Location),BaseLoc)==None){
    log ("Error:"@self@"cannot find ground to spawn shadow on!",'ONP');
    return;
  }
  if (bShadowImportant)
    DecalClass.default.bHighDetail=false;
  Shadow=Spawn(DecalClass,,,HitLoc,rotator(HitNorm));
  //Shadow.SetShadow(self, BaseLoc); //shadow handles property setting.
  if (!bShadowImportant)
    Shadow.SetPropertyText("bImportant","False");
  temp2=temp-Mylight.Location;
  temp2.z=0;
  temp.z-=43*drawscale; //move to bottom
//  temp-=collisionradius*normal(temp2);
  Shadow.oddsofappearing=2*Vsize(temp-HitLoc); //shadow is 2x this.
  Shadow.DrawScale=51*drawscale; //width... (make 51?)
  log (self@"Attaching Shadow. Length is"@Shadow.oddsofappearing$". Width is"@Shadow.DrawScale@"real length is"@2*Vsize(Baseloc-HitLoc),'ONP');
  Shadow.Update(self); //more hacks.
  if (Shadow.AttachDecal(100,normal(hitloc-MyLight.Location))==none)
  {
      log ("Failed to attach decal!!!",'ONP');
      Shadow.destroy();
  }
  if (bShadowImportant)
    DecalClass.default.bHighDetail=true;

}

defaultproperties
{
     bShadowImportant=True
     Style=STY_Masked
     Mesh=LodMesh'XidiaMPack.leetpalm'
     DrawScale=3.000000
     MultiSkins(0)=Texture'XidiaMPack.Skins.Jdmisgay12'
     CollisionRadius=6.000000
     CollisionHeight=76.000000
}
