// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVDynLightWarning : Warning about dyanmic lighting
// ===============================================================

class TVDynLightWarning expands TVFogWarning;

function created(){
super(UWindowFramedWindow).created();
 bStatusBar = False;
//bleaveonscreen=true;
  bSizable = False;
  Box=MessageBox("WARNING","Operation: Na Pali has detected that Dynamic Lighting is disabled.  Without Dynamic Lighting, Operation: Na Pali WILL NOT BE PLAYABLE! \\nEnable Dynamic Lighting?\\n Note: This message will not appear again.", MB_YesNo, MR_No, MR_None);
  box.bleaveonscreen=true;
}
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)    //idiot wants to disable oldskool.
{
  if(Result == MR_Yes)
  {
    switch(W)
    {
    case Box:
      GetPlayerOwner().ConsoleCommand( "set ini:Engine.Engine.ViewportManager NoDynamicLights false" );
      close();
      break;
    }
  }
  if (Result == MR_No){
    switch(W)
    {
    case Box:
      bnofog=true;
      Saveconfig();
      close();
     }
   }
}

defaultproperties
{
}
