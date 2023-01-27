class NewGameInterimObject expands Info;

#exec OBJ LOAD FILE="LadderSounds.uax"

var string GameWindowType;

function PostBeginPlay()
{
	local LadderInventory LadderObj;
	local int EmptySlot, j;
	local WindowConsole Console;

	EmptySlot = -1;
	for (j=0; j<5; j++)
	{
		if (class'SlotWindow'.Default.Saves[j] == "") {
			EmptySlot = j;
			break;
		}
	}

	Console = WindowConsole(PlayerPawn(Owner).Player.Console);

	if (EmptySlot < 0)
	{
		// Create "You must first free a slot..." dialog.
		Console.Root.CreateWindow(class'FreeSlotsWindow', 100, 100, 200, 200);
		return;
	}

	// Create new game dialog.
	Console.bNoDrawWorld = True;
	Console.bLocked = True;
	UMenuRootWindow(Console.Root).MenuBar.HideWindow();

	// Make them a ladder object.
	LadderObj = LadderInventory(PlayerPawn(Owner).FindInventoryType(class'LadderInventory'));
	if (LadderObj == None)
	{
		// Make them a ladder object.
		LadderObj = Spawn(class'LadderInventory');
		Log("Created a new LadderInventory.");
		LadderObj.GiveTo(PlayerPawn(Owner));
	}
	LadderObj.Reset();
	LadderObj.Slot = EmptySlot; // Find a free slot.
	class'ManagerWindow'.Default.DOMDoorOpen[EmptySlot] = 0;
	class'ManagerWindow'.Default.CTFDoorOpen[EmptySlot] = 0;
	class'ManagerWindow'.Default.ASDoorOpen[EmptySlot] = 0;
	class'ManagerWindow'.Default.ChalDoorOpen[EmptySlot] = 0;
	class'ManagerWindow'.Static.StaticSaveConfig();
	Log("Assigned player a LadderInventory.");

	// Clear all slots.
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_None, 0.1);
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_Misc, 0.1);
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_Pain, 0.1);
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_Interact, 0.1);
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_Talk, 0.1);
	Owner.PlaySound(sound'LadderSounds.ladvance', SLOT_Interface, 0.1);

	// Go to the character creation screen.
	Console.Root.CreateWindow(Class<UWindowWindow>(DynamicLoadObject(GameWindowType, Class'Class')), 100, 100, 200, 200, Console.Root, True);
}

defaultproperties
{
     GameWindowType="UTMenu.NewCharacterWindow"
}
