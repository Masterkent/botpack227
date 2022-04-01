// ============================================================
// olroot.ProcessMessage: spawns and recieves messages, returning to last thing.
// ============================================================

class ProcessMessage expands UWindowFramedWindow;
var object receiver;
var uwindowmessagebox box;
function Created(){
hidewindow();
}
function setupbox (object ob, string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult ESCResult, optional MessageBoxResult EnterResult, optional bool leaveonscreen){
receiver=ob;
box=messagebox(title,message,buttons,escresult,enterresult);
box.bleaveonscreen=leaveonscreen;
}
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)    //idiot wants to disable oldskool.
{
//receiver.messageboxdone(w,result);
  local uwindowrootwindow testroot;
  if(Result == MR_Yes)
  {
    switch(W)
    {
    case Box:
      testroot=uwindowrootwindow(dynamicloadobject(oldskoolrootwindow(root).SavedRoot,class'class')); //check if saved root exists.
      if (testroot==none)
      oldskoolrootwindow(root).savedroot="umenu.UMenuRootWindow";
      root.console.rootwindow=oldskoolrootwindow(root).savedroot;   //set to saved one.
      root.console.default.rootwindow=oldskoolrootwindow(root).savedroot; //allows oldskool item to work right.
      root.console.saveconfig();
      root.console.resetuwindow();    //reinitailize root.
      break;
    }
  }
}
//don't run these
function BeforePaint(Canvas C, float X, float Y);
function Paint(Canvas C, float X, float Y);
function LMouseDown(float X, float Y);
function Resized();
function MouseMove(float X, float Y);
function ToolTip(string strTip);
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key);
function WindowHidden();

defaultproperties
{
}
