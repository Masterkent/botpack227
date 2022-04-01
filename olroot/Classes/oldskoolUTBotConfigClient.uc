// ============================================================
// oldskool.oldskoolUTBotConfigClient: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class oldskoolUTBotConfigClient expands UMenuBotConfigClientWindow;

function ConfigureIndivBots()
{
  if(int(NumBotsEdit.GetValue()) == 0)
    MessageBox(AtLeastOneBotTitle, AtLeastOneBotText, MB_OK, MR_OK, MR_OK);
  else
    GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'oldskoolUTConfigIndivBotsWindow', 100, 100, 200, 200, Self));
}

defaultproperties
{
}
