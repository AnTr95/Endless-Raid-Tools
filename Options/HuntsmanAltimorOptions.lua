local L = EnRTLocals;

EnRT_HuntsmanAltimorOptions = CreateFrame("Frame", "EnRT_HuntsmanAltimorOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_HuntsmanAltimorOptions.name = L.OPTIONS_HUNTSMANALTIMOR_TITLE;
EnRT_HuntsmanAltimorOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
EnRT_HuntsmanAltimorOptions:Hide();

local title = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_HUNTSMANALTIMOR_TITLE);

local author = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = EnRT_HuntsmanAltimorOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
EnRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = EnRT_HuntsmanAltimorOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-HuntsmanAltimor.PNG");
bossTexture:SetWidth(120);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", 2, -47);

local bossBorder = EnRT_HuntsmanAltimorOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = EnRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_HUNTSMANALTIMOR_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_HuntsmanAltimorEnabledCheckButton", EnRT_HuntsmanAltimorOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_HuntsmanAltimorEnabled = true;
		PlaySound(856);
	else
		EnRT_HuntsmanAltimorEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local playersPerLineText = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
playersPerLineText:SetText(L.OPTIONS_HUNTSMANALTIMOR_PLAYERSPERLINE);
playersPerLineText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 0, -35);
playersPerLineText:SetSize(400,100);
playersPerLineText:SetWordWrap(true);
playersPerLineText:SetJustifyH("LEFT");
playersPerLineText:SetJustifyV("TOP");

local playersPerLineStateMenu = CreateFrame("Button", nil, EnRT_HuntsmanAltimorOptions, "UIDropDownMenuTemplate");
playersPerLineStateMenu:SetPoint("TOPLEFT", playersPerLineText, "TOPLEFT", -20, -15);

local playersPerLineStates = {"2", "3", "4", "5"};

local function playersPerLineState_OnClick(self)
	UIDropDownMenu_SetSelectedID(playersPerLineStateMenu, self:GetID());
	local state = self:GetText();
	EnRT_HuntsmanAltimorPlayersPerLine = tonumber(state);
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


EnRT_HuntsmanAltimorOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_HuntsmanAltimorEnabled);
	Initialize_PlayersPerLineState();
	UIDropDownMenu_SetSelectedName(playersPerLineStateMenu, tostring(EnRT_HuntsmanAltimorPlayersPerLine));
end);

InterfaceOptions_AddCategory(EnRT_HuntsmanAltimorOptions);