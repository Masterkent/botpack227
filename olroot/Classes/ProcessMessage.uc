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
	if (W == box && Result == MR_Yes)
	{
		class'oldskoolRootwindow'.default.B227_bEnabled = false;
		//check if saved root exists.
		if (class'oldskoolRootwindow'.default.savedroot == "" ||
			class<UWindowRootWindow>(DynamicLoadObject(class'oldskoolRootwindow'.default.savedroot, class'class', true)) == none)
		{
			class'oldskoolRootwindow'.default.savedroot = "UMenu.UMenuRootWindow";
		}
		Root.Console.RootWindow = class'oldskoolRootwindow'.default.savedroot;   //set to saved one.
		Root.Console.default.RootWindow = Root.Console.RootWindow; //allows oldskool item to work right.
		Root.Console.SaveConfig();
		Root.Console.ResetUWindow();    //reinitialize root.
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
