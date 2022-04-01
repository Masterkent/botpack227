// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVDecalsWarning : balh
// ===============================================================

class TVDecalsWarning expands TVFogWarning;

function created(){
super(UWindowFramedWindow).created();
 bStatusBar = False;
//bleaveonscreen=true;
  bSizable = False;
  Box=MessageBox("WARNING","Xidia has detected that Decals are disabled.  Not only are decals a critical part of a Single Player experience. "$" Furthermore, if decals are disabled, you will NOT be able to HEAR DYNAMIC foot step sounds!\\nEnable Decals?\\n Note: This message will not appear again.", MB_YesNo, MR_No, MR_None);
  box.bleaveonscreen=true;
}
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)    //idiot wants to disable oldskool.
{
  if(Result == MR_Yes)
  {
    switch(W)
    {
    case Box:
      GetPlayerOwner().ConsoleCommand( "set ini:Engine.Engine.ViewportManager Decals true" );
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
