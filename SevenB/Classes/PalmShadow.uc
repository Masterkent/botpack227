// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PalmShadow : Shadow of the palm tree :)
// Specifications:
// texture: 512x512
// Shadow area Y: Top (leaves) at 100, Bottom (trunk) at 487 (387 total area)
// Midpoint: 294
// scriptedtextures are used to allow varying size.
// ============================================================

class PalmShadow expands Decal;
//#exec ScriptedTexture IMPORT NAME=BlankDecal FILE=TEXTURES\BlankDecal.PCX GROUP="Decal" MIPS=OFF
//#exec OBJ LOAD FILE=..\Textures\MaskedDecal.utx  PACKAGE=Olextras.Decal
var texture Shadow, Scripted; //shadow texture
//no calculations in render:
var float ShadowUStart; //where to start horizontal.
var float ShadowUsize; //Ustretch of shadow
var float ShadowVStart; //where to start drawing verticle.
var float ShadowVsize; //how long shadow is.   (Vstretch)

simulated event PostBeginPlay()
{
//  Texture=ScriptedTexture'Blank';
  Shadow=Texture(DynamicLoadObject("davidmgras.palmsil",class'Texture')); //DLO 512x512 texture!
  Scripted=Texture; //back up.
  ScriptedTexture(Texture).NotifyActor=self;
//  ScriptedTexture(Texture).SourceTexture=Texture'BlankDecal'; //set blank 512x512 decal as source.
 // Texture=Shadow;
}
simulated event Destroyed(){
  Super.Destroyed();
  ScriptedTexture(Texture).NotifyActor=none;
}
simulated function SetShadow(actor other, vector BaseLoc){
   local float length;
   local vector temp, temp2;
   //drawscale=other.drawscale*0.13; //to match..
   temp=Baseloc;
   temp.z-=25*other.drawscale; //tree is 50.67 un high at scale 1.
   temp2=location-BaseLoc;
   temp2.z=0;
   temp-=other.collisionradius*normal(temp2);
   length=Vsize(temp-location)+25; //shadow is 2x this.
   drawscale=fmax(length/96,0.2*other.drawscale); //as locaion is midpoint. of shadow and decal. one side is length. must be at least tree width
   ShadowUsize=(0.2*other.drawscale)/drawscale; //coef.
   ShadowUsize*=Texture.Usize; //real
   ShadowUstart=(Texture.Usize-ShadowUsize)/2;
   ShadowVSize=((length-25)/96)/drawscale;
   ShadowVsize*=Texture.Vsize;
   ShadowVstart=(Texture.Vsize-ShadowVsize)/2-25/drawscale-2*other.collisionradius/drawscale;
 /*  log ("Other.location-location normal:"@normal(other.location-Location),'PalmShadow');
   log ("Shadow length:"@Length,'PalmShadow');
   log ("DrawScale:"@DrawScale,'PalmShadow');
   log ("Shadow U start:"@ShadowUstart,'PalmShadow');
   log ("Shadow V start:"@ShadowVstart,'PalmShadow');
   log ("Texture U size:"@Texture.Usize,'PalmShadow');
   log ("Shadow U size:"@ShadowUsize,'PalmShadow');
   log ("Shadow V size:"@ShadowVsize,'PalmShadow');*/

 //  if (AttachDecal(100,1000*normal(other.location-Location))== None){
  if (AttachDecal(100,1000*normal(location-BaseLoc))== None){
      //-log ("Failed to attach decal!!!",'PalmShadow');
      destroy();
   }
}
/*
simulated function Tick(float delta){
//  Texture=Shadow; //hack so only renders scriptedtextures when should be.
//  LogBroadCastMessage("Old lastrendered:"@lastrenderedtime);
//   LogBroadCastMessage("Ticking with texture"@Texture);
  if (Level.TimeSeconds - LastRenderedTime > 0.35+delta)  //not just this tick. swap texture
      Texture=Shadow;
   else
      Texture=Scripted; //reset.
}
*/
event RenderTexture(ScriptedTexture Tex){
  Tex.DrawTile(ShadowUstart,ShadowVstart,ShadowUsize,ShadowVsize,0,0,Shadow.Usize,Shadow.Vsize,Shadow,false);
//  LogBroadCastMessage("Doing scriptedtexture render!");
//  Texture=none;
//  LogBroadCastMessage("lastrendered in post render texture:"@lastrenderedtime);
}
/*
//temp!
event LogBroadcastMessage( coerce string Msg, optional bool bBeep, optional name Type )
{
  local Pawn P;

  if (Type == '')
    Type = 'Event';

  if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
    for( P=Level.PawnList; P!=None; P=P.nextPawn )
      if( P.bIsPlayer || P.IsA('MessagingSpectator') )
      {
        if ( (Level.Game != None) && (Level.Game.MessageMutator != None) )
        {
          if ( Level.Game.MessageMutator.MutatorBroadcastMessage(Self, P, Msg, bBeep, Type) )
            P.ClientMessage( Msg, Type, bBeep );
        } else
          P.ClientMessage( Msg, Type, bBeep );
        break;
      }
    if (p==none)
      Log(MSG,'PalmShadow');
}
*/

defaultproperties
{
     MultiDecalLevel=12
}
