// ============================================================
// Oldskool.OldskoolUTMenuBotmatchCW: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class oldskoolUTMenuBotmatchCW expands UMenuBotmatchClientWindow;
function CreatePages()
{
  local class<UWindowPageWindow> PageClass;

  log ("botmatchstep 1 done");
  Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
  Pages.SetMultiLine(True);
  Pages.AddPage(StartMatchTab, class'UMenuStartMatchScrollClient');

  PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
  if(PageClass != None)
    Pages.AddPage(RulesTab, PageClass);

  PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
  if(PageClass != None)
    Pages.AddPage(SettingsTab, PageClass);

  if (GameClass.Default.BotMenuType~="UTMenu.UTBotConfigSClient")
  PageClass = class<UWindowPageWindow>(DynamicLoadObject("olroot.oldskoolutbotconfigsclient", class'Class'));
  else
  PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
  if(PageClass != None)
    Pages.AddPage(BotConfigTab, PageClass);
}

defaultproperties
{
     Map="DM-Synergy.unr"
     MutatorList="oldskool.oldskool"
}
