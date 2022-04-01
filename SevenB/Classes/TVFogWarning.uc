// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVFogWarning : detects for fog.
// ============================================================

class TVFogWarning expands UWindowFramedWindow
config;
var UWindowMessageBox Box;
var config bool bnofog;
function created(){
super.created();
 bStatusBar = False;
//bleaveonscreen=true;
  bSizable = False;
  Box=MessageBox("WARNING","Seven Bullets has detected that fog is disabled.  This mod places a high dependency on fog and for best gameplay/visuals, it is recommended that fog is enabled.\\nEnable fog?\\n Note: This message will not appear again.", MB_YesNo, MR_No, MR_None);
  box.bleaveonscreen=true;
}
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)    //idiot wants to disable oldskool.
{
  if(Result == MR_Yes)
  {
    switch(W)
    {
    case Box:
      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice VolumetricLighting true");
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
function Close(optional bool bByParent) //reset all this stuff
{
  local UWindowWindow Child;
  Super.Close(bByParent);

  for(Child = root.LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
  {
     if(Child != self && Child.IsA('TvFogWarning')) //multiple warnings..
        return;
  }
  Root.Console.bQuickKeyEnable = False;
  Root.Console.CloseUWindow();
}

defaultproperties
{
}
