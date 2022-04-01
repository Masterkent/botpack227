// ============================================================
// backrounds.  those that extend this have functions that load the background.
// \me can't spell :P :P
// ============================================================

class backrounds expands UWindowWindow;
var texture f43, f33, f23, f13, f42, f32, f22, f12, f41, f31, f21, f11;

static function drawbackground(oldskoolRootwindow olroot, canvas c){    //function allows customizability (as well as OSX format support)
 local int XOffset, YOffset;
  local float W, H;
   W = olroot.WinWidth / 4;
    H = W;

    if(H > olroot.WinHeight / 3)
    {
      H = olroot.WinHeight / 3;
      W = H;
    }

    XOffset = (olroot.WinWidth - (4 * (W-1))) / 2;
    YOffset = (olroot.WinHeight - (3 * (H-1))) / 2;

    C.bNoSmooth = False;

    olroot.DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (2 * (H-1)), W, H, default.f43);
    olroot.DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (2 * (H-1)), W, H, default.f33);
    olroot.DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (2 * (H-1)), W, H, default.f23);
    olroot.DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (2 * (H-1)), W, H, default.f13);

    olroot.DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (1 * (H-1)), W, H, default.f42);
    olroot.DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (1 * (H-1)), W, H, default.f32);
    olroot.DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (1 * (H-1)), W, H, default.f22);
    olroot.DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (1 * (H-1)), W, H, default.f12);

    olroot.DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (0 * (H-1)), W, H, default.f41);
    olroot.DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (0 * (H-1)), W, H, default.f31);
    olroot.DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (0 * (H-1)), W, H, default.f21);
    olroot.DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (0 * (H-1)), W, H, default.f11);
    C.bNoSmooth = True;
}

defaultproperties
{
}
