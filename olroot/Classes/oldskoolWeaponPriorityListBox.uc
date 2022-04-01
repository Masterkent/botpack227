// ============================================================
// oldskool.oldskoolWeaponPriorityListBox: calls the new list
// ============================================================

class oldskoolWeaponPriorityListBox expands UMenuWeaponPriorityListBox
config(oldskool);
var config bool bnewmag;
function Created()          //reads all weapons
{
  local name PriorityName;
  local string WeaponClassName;
  local class<Weapon> WeaponClass;
  local int WeaponNum, i;
  local UMenuWeaponPriorityList L;
  local PlayerPawn P;

  Super(uwindowlistbox).Created();

  SetHelpText(WeaponPriorityHelp);

  P = GetPlayerOwner();

  // Load weapons into the list
  for(i=0;i< ArrayCount(P.WeaponPriority);i++)             //all weapons
  {
    PriorityName = P.WeaponPriority[i];
    if(PriorityName == 'None' || PriorityName == '') break;
    L = UMenuWeaponPriorityList(Items.Insert(ListClass));
    L.PriorityName = PriorityName;
    L.WeaponName = "(unk) "$PriorityName;
  }

  WeaponNum = 1;
  WeaponClassName = P.GetNextInt(WeaponClassParent, 0);
  while( WeaponClassName != "" && WeaponNum < 50 )
  {
    for(L = UMenuWeaponPriorityList(Items.Next); L != None; L = UMenuWeaponPriorityList(L.Next))
    {
      if( string(L.PriorityName) ~= P.GetItemName(WeaponClassName) )
      {
        L.WeaponClassName = WeaponClassName;
        L.bFound = True;
        if( L.ShowThisItem() )
        {
          WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
          ReadWeapon(L, WeaponClass);
        }
        else
          L.bFound = False;
        break;
      }
    }

    WeaponClassName = P.GetNextInt(WeaponClassParent, WeaponNum);
    WeaponNum++;
  }
}
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)    //color change of olweapons and UT's...
{
  if(UMenuWeaponPriorityList(Item).bSelected)
  {
    C.DrawColor.r = 0;
    C.DrawColor.g = 0;
    C.DrawColor.b = 128;
    DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
    C.DrawColor.r = 255;
    C.DrawColor.g = 255;
    C.DrawColor.b = 255;
  }
  else
  {
    if  ((Left(UMenuWeaponPriorityList(Item).WeaponClassName, 10)) ~= "OLweapons."){    //my weapons....
    C.DrawColor.r = 29;
    C.DrawColor.g = 0;
    C.DrawColor.b = 147;
    }
    else if ((Left(UMenuWeaponPriorityList(Item).WeaponClassName, 7)) ~= "Legacy."){ //Legacy......
    C.DrawColor.r = 0;
    C.DrawColor.g = 147;
    C.DrawColor.b = 29;
    }
    else if ((Left(UMenuWeaponPriorityList(Item).WeaponClassName, 8)) ~= "Botpack."){      //UT weapons
    C.DrawColor.r = 0;
    C.DrawColor.g = 0;
    C.DrawColor.b = 0;
    }
    else { //custom weapons.....
    C.DrawColor.r = 128;
    C.DrawColor.g = 0;
    C.DrawColor.b = 0;
    }
  }


  C.Font = Root.Fonts[F_Normal];

  ClipText(C, X+1, Y, UMenuWeaponPriorityList(Item).WeaponName);
}
/*-
function ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)      //stuff, so item name different and SMP shows different....
{
  if (L.WeaponClassName ~= "olweapons.olflakcannon")               //morph names.....
  L.WeaponName = "Unreal I Flak Cannon";
  else if (L.WeaponClassName ~= "olweapons.olrifle")
  L.WeaponName = "Unreal I Sniper Rifle";
  else if (L.WeaponClassName ~= "olweapons.olgesbiorifle")
  L.WeaponName = "Unreal I GES Bio Rifle";
  else if (L.WeaponClassName ~= "olweapons.olminigun")
  L.WeaponName = "Unreal I Minigun";
  else if (L.WeaponClassName ~= "olweapons.olsmmag"){  //two forms....
  if (bnewmag)
  L.WeaponName = "SMP 8920";
  else
  L.WeaponName = "SMP 7243";}
  else
  L.WeaponName = WeaponClass.default.ItemName;
  if ((L.WeaponClassName ~= "olweapons.olsmmag")&&bnewmag)  //two forms....
  L.WeaponMesh = LodMesh'Botpack.MagPick';
  else
  L.WeaponMesh = WeaponClass.default.Mesh;
  L.WeaponSkin = WeaponClass.default.Skin;
  UTWeaponPriorityList(L).WeaponDescription = class<TournamentWeapon>(WeaponClass).default.WeaponDescription;
}
*/
/*-
function SaveConfigs()
{
  local int i;
  local UMenuWeaponPriorityList L;
  local PlayerPawn P;

  i=0;
  P = GetPlayerOwner();

  for(L = UMenuWeaponPriorityList(Items.Last); L != None && L != Items; L = UMenuWeaponPriorityList(L.Prev))
  {
    P.WeaponPriority[i] = L.PriorityName;
    i++;
  }
  while(i<20)     //stop any nones!
  {
    P.WeaponPriority[i] = '';
    i++;
  }
  for (i=0;i<50;i++){ //fix all nones
  If (p.weaponpriority[i]=='none')
  p.weaponpriority[i]='';
  }
  P.UpdateWeaponPriorities();
  P.SaveConfig();
  Super(Uwindowlistbox).SaveConfigs();
}
*/
/*-
function SelectWeapon()      //SMP skinz.....
{
  if(MeshWindow == None)
    MeshWindow = UMenuWeaponPriorityMesh(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UMenuWeaponPriorityMesh'));

  MeshWindow.MeshActor.Mesh = UMenuWeaponPriorityList(SelectedItem).WeaponMesh;
  MeshWindow.MeshActor.Skin = UMenuWeaponPriorityList(SelectedItem).WeaponSkin;
  if (uMenuWeaponPriorityList(SelectedItem).WeaponClassName ~= "olweapons.olsmmag"){  //set skinz
  if (bnewmag)
  meshwindow.meshactor.multiskins[1]=texture(dynamicloadobject("olweapons.thirdskin",class'texture'));
  else
  meshwindow.meshactor.multiskins[1]=texture(dynamicloadobject("olweapons.newmagskin",class'texture'));}
  else
  meshwindow.meshactor.multiskins[1]=none;
    if(Description == None)
    Description = UWindowDynamicTextArea(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UWindowDynamicTextArea'));

  Description.Clear();
  Description.AddText(UTWeaponPriorityList(SelectedItem).WeaponDescription);
}
*/

defaultproperties
{
     ListClass=Class'olroot.oldskoolWeaponPriorityList'
}
