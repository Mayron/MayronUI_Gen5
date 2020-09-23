-- luacheck: ignore MayronUI self 143

local _, namespace = ...;
local C_ChatFrame = namespace.C_ChatFrame;
local Engine = namespace.Engine;
local tk, _, em, _, _, L = MayronUI:GetCoreComponents();

local _G = _G;
local LoadAddOn, IsTrialAccount, IsInGuild, UnitLevel, UnitInBattleground =
_G.LoadAddOn, _G.IsTrialAccount, _G.IsInGuild, _G.UnitLevel, _G.UnitInBattleground;

-- GLOBALS:
--[[ luacheck: ignore
ToggleCharacter ContainerFrame1 ToggleBackpack OpenAllBags ToggleFrame SpellBookFrame PlayerTalentFrame MacroFrame
ToggleFriendsFrame ToggleGuildFrame ToggleHelpFrame TogglePVPUI ToggleAchievementFrame ToggleCalendar ToggleQuestLog
ToggleLFDParentFrame ToggleRaidFrame ToggleEncounterJournal ToggleCollectionsJournal ToggleWorldMap
ToggleWorldStateScoreFrame TalentFrame
]]

local buttonKeys = {
  Character   = L["Character"],
  Bags        = L["Bags"],
  Friends     = L["Friends"],
  Guild       = L["Guild"],
  HelpMenu    = L["Help Menu"],
  SpellBook   = L["Spell Book"],
  Talents     = L["Talents"],
  Raid        = L["Raid"],
  Macros      = L["Macros"],
  WorldMap    = L["World Map"],
  QuestLog    = L["Quest Log"],
  Reputation  = L["Reputation"],
  PVPScore    = L["PVP Score"],
  Skills    = "Skills"
};

if (tk:IsClassic()) then
  namespace.ButtonNames = {
    L["Character"],
    L["Bags"],
    L["Friends"],
    L["Guild"],
    L["Help Menu"],
    L["Spell Book"],
    L["Talents"],
    L["Raid"],
    L["Macros"],
    L["World Map"],
    L["Quest Log"],
    L["Reputation"],
    L["PVP Score"],
    "Skills"
  };
else
  namespace.ButtonNames = {
    L["Character"],
    L["Bags"],
    L["Friends"],
    L["Guild"],
    L["Help Menu"],
    L["PVP"],
    L["Spell Book"],
    L["Talents"],
    L["Achievements"],
    L["Glyphs"],
    L["Calendar"],
    L["LFD"],
    L["Raid"],
    L["Encounter Journal"],
    L["Collections Journal"],
    L["Macros"],
    L["World Map"],
    L["Quest Log"],
    L["Reputation"],
    L["PVP Score"],
    L["Currency"],
    "Skills"
  };

  buttonKeys.PVP = L["PVP"];
  buttonKeys.Achievements = L["Achievements"];
  buttonKeys.Calendar = L["Calendar"];
  buttonKeys.LFD = L["LFD"];
  buttonKeys.Currency = L["Currency"];
  buttonKeys.EncounterJournal = L["Encounter Journal"];
  buttonKeys.CollectionsJournal = L["Collections Journal"];
end

local clickHandlers = {};

-- Character
clickHandlers[buttonKeys.Character] = function()
  ToggleCharacter("PaperDollFrame");
end

-- Bags
clickHandlers[buttonKeys.Bags] = function()
  if (ContainerFrame1:IsVisible()) then
    ToggleBackpack();
  else
    OpenAllBags();
  end
end

-- Friends
clickHandlers[buttonKeys.Friends] = function()
  ToggleFriendsFrame(_G.FRIEND_TAB_FRIENDS);
end

-- Guild
clickHandlers[buttonKeys.Guild] = function()
  if (IsTrialAccount()) then
    tk:Print(L["Starter Edition accounts cannot perform this action."]);
  elseif (IsInGuild()) then
    ToggleGuildFrame();
  end
end

-- Help Menu
clickHandlers[buttonKeys.HelpMenu] = ToggleHelpFrame;

if (tk:IsRetail()) then
  -- PVP
  clickHandlers[buttonKeys.PVP] = function()
    if (UnitLevel("player") < 10) then
      tk:Print(L["Requires level 10+ to view the PVP window."]);
    else
      TogglePVPUI();
    end
  end
end

-- Spell Book
clickHandlers[buttonKeys.SpellBook] = function()
    ToggleFrame(SpellBookFrame);
end

-- Talents
clickHandlers[buttonKeys.Talents] = function()
  if (UnitLevel("player") < 10) then
    tk:Print(L["Must be level 10 or higher to use Talents."]);
  else
    local talentFrame = PlayerTalentFrame or TalentFrame;

    if (not talentFrame) then
      LoadAddOn("Blizzard_TalentUI");
      talentFrame = PlayerTalentFrame or TalentFrame;
    end

    ToggleFrame(talentFrame);
  end
end

-- Raid
clickHandlers[buttonKeys.Raid] = ToggleRaidFrame;

if (tk:IsRetail()) then
  -- Achievements
  clickHandlers[buttonKeys.Achievements] = ToggleAchievementFrame;

  -- Calendar
  clickHandlers[buttonKeys.Calendar] = ToggleCalendar;

  -- LFD
  clickHandlers[buttonKeys.LFD] = ToggleLFDParentFrame;

  -- Encounter Journal
  clickHandlers[buttonKeys.EncounterJournal] = ToggleEncounterJournal;

  -- Collections Journal
  clickHandlers[buttonKeys.CollectionsJournal] = function()
      ToggleCollectionsJournal();
  end

  -- Currency
  clickHandlers[buttonKeys.Currency] = function()
    ToggleCharacter("TokenFrame");
  end
end

-- -- Macros
clickHandlers[buttonKeys.Macros] = function()
    if (not MacroFrame) then
        LoadAddOn("Blizzard_MacroUI");
    end

    ToggleFrame(MacroFrame);
end

-- World Map
clickHandlers[buttonKeys.WorldMap] = ToggleWorldMap;

-- Quest Log
clickHandlers[buttonKeys.QuestLog] = ToggleQuestLog;

-- Repuation
clickHandlers[buttonKeys.Reputation] = function()
    ToggleCharacter("ReputationFrame");
end

-- PVP Score
clickHandlers[buttonKeys.PVPScore] = function()
    if (not UnitInBattleground("player")) then
        tk:Print(L["Requires being inside a Battle Ground."]);
    else
        ToggleWorldStateScoreFrame();
    end
end

-- Skill
clickHandlers[buttonKeys.Skills] = function()
  ToggleCharacter("SkillFrame");
end

local function ChatButton_OnClick(self)
  if (_G.InCombatLockdown()) then
    tk:Print(L["Cannot toggle menu while in combat."]);
    return;
  end

  clickHandlers[self:GetText()]();
end

local function ChatFrame_OnModifierStateChanged(_, _, data)
  if (data.chatModuleSettings.swapInCombat or not _G.InCombatLockdown()) then
    for _, buttonStateData in ipairs(data.settings.buttons) do
      if (not buttonStateData.key or (buttonStateData.key and tk:IsModComboActive(buttonStateData.key))) then
        data.buttons[1]:SetText(buttonStateData[1]);
        data.buttons[2]:SetText(buttonStateData[2]);
        data.buttons[3]:SetText(buttonStateData[3]);
      end
    end
  end
end

Engine:DefineParams("table")
function C_ChatFrame:SetUpButtonHandler(data, buttonSettings)
  data.settings.buttons = buttonSettings;

  em:CreateEventHandlerWithKey("MODIFIER_STATE_CHANGED", data.anchorName.."_OnModifierStateChanged",
  ChatFrame_OnModifierStateChanged, data):Run();

  data.buttons[1]:SetScript("OnClick", ChatButton_OnClick);
  data.buttons[2]:SetScript("OnClick", ChatButton_OnClick);
  data.buttons[3]:SetScript("OnClick", ChatButton_OnClick);
end