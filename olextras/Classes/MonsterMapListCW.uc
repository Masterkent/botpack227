// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// MonsterMapListCW : Simply grabs maps from original list, rather than reiterating (which is slower and gets bad list)
// ===============================================================

class MonsterMapListCW expands UMenuMapListCW;

var TVMonstersMaps MapSource;
function Created()
{
  MapSource=TVMonstersMaps(OwnerWindow);
  OwnerWindow=MapSource.BotmatchParent;
  Super.Created();
  DefaultCombo.Hidewindow();
}

function LoadDefaultClasses(); //only 1 list

function LoadMapList()
{
  local string MapName;
  local UWindowComboListItem Copy;
  local int i, IncludeCount;
  local UMenuMapList L;

  Exclude.Items.Clear();
  //rip right from source:
  for (Copy=UWindowComboListItem(MapSource.MapCombo.List.Items.Sentinel.Next);Copy!=none;Copy=UWindowComboListItem(Copy.Next))
  {
    // Add the map.
    L = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
    L.MapName = Copy.Value2;
    L.DisplayName = Copy.Value;
  }


  // Now load the current maplist into Include, and remove them from Exclude.
  Include.Items.Clear();
  IncludeCount = ArrayCount(BotmatchParent.GameClass.Default.MapListType.Default.Maps);
  for(i=0;i<IncludeCount;i++)
  {
    MapName = BotmatchParent.GameClass.Default.MapListType.Default.Maps[i];
    if(MapName == "")
      break;

    L = UMenuMapList(Exclude.Items).FindMap(MapName);

    if(L != None)
    {
      L.Remove();
      Include.Items.AppendItem(L);
    }
    else
      Log("Unknown map in Map List: "$MapName);
  }

  Exclude.Sort();
}

defaultproperties
{
}
