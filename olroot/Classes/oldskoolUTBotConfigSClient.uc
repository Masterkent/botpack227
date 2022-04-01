// ============================================================
// Oldskool.oldskoolUTBotConfigSClient: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class oldskoolUTBotConfigSClient expands UWindowScrollingDialogClient;
function Created()
{
  ClientClass = class'oldskoolUTBotConfigClient';
  FixedAreaClass = None;
  Super.Created();
}

defaultproperties
{
}
