local L = IRTLocals;

IRT_HuntsmanAltimorOptions = CreateFrame("Frame", "IRT_HuntsmanAltimorOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_HuntsmanAltimorOptions.name = L.OPTIONS_HUNTSMANALTIMOR_TITLE;
IRT_HuntsmanAltimorOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
IRT_HuntsmanAltimorOptions:Hide();

local title = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_HUNTSMANALTIMOR_TITLE);

local author = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = IRT_HuntsmanAltimorOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
IRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = IRT_HuntsmanAltimorOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-HuntsmanAltimor.PNG");
bossTexture:SetWidth(120);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", 2, -47);

local bossBorder = IRT_HuntsmanAltimorOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_HUNTSMANALTIMOR_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_HuntsmanAltimorEnabledCheckButton", IRT_HuntsmanAltimorOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_HuntsmanAltimorEnabled = true;
		PlaySound(856);
	else
		IRT_HuntsmanAltimorEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local playersPerLineText = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
playersPerLineText:SetText(L.OPTIONS_HUNTSMANALTIMOR_PLAYERSPERLINE);
playersPerLineText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 0, -30);
playersPerLineText:SetSize(400,100);
playersPerLineText:SetWordWrap(true);
playersPerLineText:SetJustifyH("LEFT");
playersPerLineText:SetJustifyV("TOP");

local playersPerLineStateMenu = CreateFrame("Button", nil, IRT_HuntsmanAltimorOptions, "UIDropDownMenuTemplate");
playersPerLineStateMenu:SetPoint("TOPLEFT", playersPerLineText, "TOPLEFT", -20, -15);

local playersPerLineStates = {"2", "3", "4", "5"};

local function playersPerLineState_OnClick(self)
	UIDropDownMenu_SetSelectedID(playersPerLineStateMenu, self:GetID());
	local state = self:GetText();
	IRT_HuntsmanAltimorPlayersPerLine = tonumber(state);
end

local function Initialize_PlayersPerLineState(self, level)
	local info = UIDropDownMenu_CreateInfo();
	for k,v in pairs(playersPerLineStates) do
	  info = UIDropDownMenu_CreateInfo();
	  info.text = v;
	  info.value = v;
	  info.func = playersPerLineState_OnClick;
	  UIDropDownMenu_AddButton(info, level);
	end
end

UIDropDownMenu_SetWidth(playersPerLineStateMenu, 110);
UIDropDownMenu_SetButtonWidth(playersPerLineStateMenu, 110);
UIDropDownMenu_JustifyText(playersPerLineStateMenu, "CENTER");
UIDropDownMenu_Initialize(playersPerLineStateMenu, Initialize_PlayersPerLineState);

local infoTexture = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\HuntsmanAltimor1.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", -40, -105);
infoTexture:SetSize(256, 118);
infoTexture:SetTexCoord(0,1,0,0.89);

local starTexture1 = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
starTexture1:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture1:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", -20, 2);
starTexture1:SetSize(20, 20);

local starTexture2 = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
starTexture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture2:SetPoint("TOPLEFT", infoTexture, "TOPRIGHT", 2, 2);
starTexture2:SetSize(20, 20);

local infoTexture2 = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\HuntsmanAltimor2.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 330, 0);
infoTexture2:SetSize(168, 118);
infoTexture2:SetTexCoord(0,0.66,0,0.89);

local starTexture3 = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
starTexture3:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture3:SetPoint("TOPLEFT", infoTexture2, "TOPLEFT", -20, 1);
starTexture3:SetSize(20, 20);

local starTexture4 = IRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
starTexture4:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture4:SetPoint("TOPLEFT", infoTexture2, "TOPRIGHT", 1, 1);
starTexture4:SetSize(20, 20);

local previewText = IRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", 150, 30);
previewText:SetText(L.OPTIONS_HUNTSMANALTIMOR_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetSize(570,25);
previewText:SetWordWrap(true);


IRT_HuntsmanAltimorOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_HuntsmanAltimorEnabled);
	Initialize_PlayersPerLineState();
	UIDropDownMenu_SetSelectedName(playersPerLineStateMenu, tostring(IRT_HuntsmanAltimorPlayersPerLine));
end);

InterfaceOptions_AddCategory(IRT_HuntsmanAltimorOptions);