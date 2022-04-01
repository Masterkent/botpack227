// ============================================================
// olroot.ticky: the entry level ticker to tick the good 'old root window.
// ============================================================

class ticky expands Actor;
var oldskoolrootwindow root;
function tick(float delta){
root.tick(delta);
}
function destroyed(){ //no garbage collecting in entry level.
root.ticky=none;
}

defaultproperties
{
}
