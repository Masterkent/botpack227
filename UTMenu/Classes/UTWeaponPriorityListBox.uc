class UTWeaponPriorityListBox expands UMenuWeaponPriorityListBox;

var UWindowDynamicTextArea Description;

function SelectWeapon()
{
	Super.SelectWeapon();

	if(Description == None)
		Description = UWindowDynamicTextArea(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UWindowDynamicTextArea'));

	Description.Clear();
	Description.AddText(UTWeaponPriorityList(SelectedItem).WeaponDescription);
}

function UTF_ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)
{
	Super.ReadWeapon(L, WeaponClass);
	UTWeaponPriorityList(L).WeaponDescription = class<TournamentWeapon>(WeaponClass).default.WeaponDescription;
}

function Created()
{
	local name PriorityName;
	local string WeaponClassName;
	local class<Weapon> WeaponClass;
	local int i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;

	Super.Created();

	SetHelpText(WeaponPriorityHelp);

	P = GetPlayerOwner();

	// Load weapons into the list
	for (i=0; i<ArrayCount(P.WeaponPriority); i++)
	{
		PriorityName = P.WeaponPriority[i];
		if (PriorityName == 'None') break;
		L = UMenuWeaponPriorityList(Items.Insert(ListClass));
		L.PriorityName = PriorityName;
		L.WeaponName = "(unk) "$PriorityName;
	}

	foreach P.IntDescIterator(WeaponClassParent,WeaponClassName,,true)
	{
		for (L = UMenuWeaponPriorityList(Items.Next); L != None; L = UMenuWeaponPriorityList(L.Next))
		{
			if ( string(L.PriorityName) ~= P.GetItemName(WeaponClassName) )
			{
				L.WeaponClassName = WeaponClassName;
				L.bFound = True;
				if ( L.ShowThisItem() )
				{
					WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
					if( WeaponClass!=None )
						UTF_ReadWeapon(L, WeaponClass);
				}
				else
					L.bFound = False;
				break;
			}
		}
	}
}

defaultproperties
{
     WeaponClassParent="Botpack.TournamentWeapon"
     ListClass=Class'UTMenu.UTWeaponPriorityList'
}
