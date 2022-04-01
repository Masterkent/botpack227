// ============================================================
// oldskool.OldSkoolSaveGameScrollClient: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OldSkoolSaveGameScrollClient expands UWindowScrollingDialogClient;

function Created()
{
  ClientClass = class'OldSkoolSaveGameClientWindow';
  Super.Created();
}

defaultproperties
{
}
