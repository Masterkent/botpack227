// ============================================================
// OldSkool.OldSkoolScreenshotCW: so that the SP stuff is read properly.....
// ============================================================

class OldSkoolScreenshotCW expands UMenuScreenshotCW;

function SetMap(string MapName)
{
  local int i;
  local LevelSummary L;

  log("reading from a map");
  i = InStr(Caps(MapName), ".UNR");
  if(i != -1)
    MapName = Left(MapName, i);

  Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture'));
  L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));
  //I killed the if thing as we want this info showing regardless of if there is a screenshot or not...
  // Unreal I levels don't have a level summary, but UT does...
  If (L != None){
    MapTitle = "An Unreal Tournament Map";
    MapAuthor = L.Title;
    IdealPlayerCount = L.Author; }
    else{
    MapTitle = "An Unreal 1 Map";
    MapAuthor = "OldSkool cannot read level";
    IdealPlayerCount = "information from Unreal Maps"; }
}
//for use with setting the MapPack stuff
function SetPack(string PackName)
{
  local class<mappack> PackClass;
  //load the screeny from the pack.  No accessed nones will occur unless some total dumbass wrote the pack...
  PackClass=Class<mappack>(DynamicLoadObject(Packname, class'class'));
  //was going to make this direct but for some stupid reason it wasn't reading the texture correctly :(
  Screenshot = Packclass.default.Screenshot;
   //load all this junk from mappack...

   MapTitle = Packclass.default.Title;
   MapAuthor = Packclass.default.Author;
   IdealPlayerCount = "";




}
//gotto stop the screenshot != none from killing everything....
function Paint(Canvas C, float MouseX, float MouseY)
{
  local float X, Y, W, H;

  DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
  if(Screenshot != None)
  {
    W = Min(WinWidth, Screenshot.USize);
    H = Min(WinHeight, Screenshot.VSize);

    if(W > H)
      W = H;
    if(H > W)
      H = W;

    X = (WinWidth - W) / 2;
    Y = (WinHeight - H) / 2;

    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;

    DrawStretchedTexture(C, X, Y, W, H, Screenshot);

    C.Font = Root.Fonts[F_Normal];
    }
      TextSize(C, IdealPlayerCount, W, H);
      X = (WinWidth - W) / 2;
      Y = WinHeight - H*2;
      ClipText(C, X, Y, IdealPlayerCount);
    if(MapAuthor != "")
    {
      TextSize(C, MapAuthor, W, H);
      X = (WinWidth - W) / 2;
      Y = WinHeight - H*3;
      ClipText(C, X, Y, MapAuthor);
    }

    if(MapTitle != "")
    {
      TextSize(C, MapTitle, W, H);
      X = (WinWidth - W) / 2;
      Y = WinHeight - H*4;
      ClipText(C, X, Y, MapTitle);
    }

}

defaultproperties
{
}
