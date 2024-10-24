class UTXMenuRootWindowSelectorClientWindow227 expands UWindowDialogClientWindow;

var UWindowSmallButton Button_UMenu;
var UWindowSmallButton Button_PreviousMenu;

function Created()
{
	Button_UMenu = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 10, 270, 16));
	Button_UMenu.SetFont(F_Normal);

	Button_PreviousMenu = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 10, 270, 16));
	Button_PreviousMenu.SetFont(F_Normal);
}

function SetupSelector()
{
	Button_UMenu.SetText("UMenu.UMenuRootWindow");
	Button_PreviousMenu.SetText(class'UTMenuRootWindow227'.default.PreviousRootWindowType);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float ControlLeft;
	local float YOffset;

	super.BeforePaint(C, X, Y);

	ControlLeft = (WinWidth - Button_UMenu.WinWidth) / 2;

	YOffset = 10;
	Button_UMenu.WinLeft = ControlLeft;
	Button_UMenu.WinTop = YOffset;
	YOffset += Button_UMenu.WinHeight;

	YOffset += 10;
	Button_PreviousMenu.WinLeft = ControlLeft;
	Button_PreviousMenu.WinTop = YOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	local UTXMenuRootWindowSelector227 Parent;

	Parent = UTXMenuRootWindowSelector227(ParentWindow);

	if (E == DE_Click)
	{
		switch (C)
		{
			case Button_UMenu:
				Parent.Close();
				ChangeRootWindowTo("UMenu.UMenuRootWindow");
				break;

			case Button_PreviousMenu:
				Parent.Close();
				ChangeRootWindowTo(class'UTMenuRootWindow227'.default.PreviousRootWindowType);
				break;
		}
	}
}

function ChangeRootWindowTo(string RootWindowType)
{
	class'UTMenuRootWindow227'.static.SwitchRootWindow(Root.Console, RootWindowType);
}
