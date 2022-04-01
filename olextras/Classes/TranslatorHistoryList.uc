// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TranslatorHistoryList : Stores translator message history.
// ============================================================

class TranslatorHistoryList expands Actor;

var TranslatorHistoryList next; //older history
var TranslatorHistoryList Prev; //newer history.
var string message;

function Remove(){ //on any item (only removes from list.. not destroys)
  if (next!=none)
    Next.Prev=Prev;
  if (Prev!=none)
    Prev.next=next;
  Prev=none;
}

function TranslatorHistoryList Add(string newmessage){ //called only on front of list.
   prev=Spawn (class,owner);
   prev.next=self;
   prev.message=newmessage;
   return prev;
}
function TranslatorHistoryList Process(string newmessage){ //Called by HUD when the translator changes message by world.
   local translatorHistoryList hist;
   if (newmessage=="")
      return self;
   if (Prev!=none) //loop to front of list for checks.
     return Prev.Process(newmessage);
   for (hist=self;hist!=none;hist=hist.next)
      if (hist.message==newmessage)
        break;
   if (hist==self) //front
     return self;
   if (hist==none) //new message
      return Add(newmessage);
   Hist.Remove();
   Hist.next=self;
   prev=Hist;
   return Hist;
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
