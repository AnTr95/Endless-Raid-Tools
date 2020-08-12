local L = EnRTLocals;

EnRT_HuntsmanAltimorOptions = CreateFrame("Frame", "EnRT_HuntsmanAltimorOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_HuntsmanAltimorOptions.name = L.OPTIONS_HUNTSMANALTIMOR_TITLE;
EnRT_HuntsmanAltimorOptions.parent = "|cFFFFFF00Castle Nathria Modules";
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
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Xanesh.PNG");
bossTexture:SetWidth(128);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", -5, -47);

local bossBorder = EnRT_HuntsmanAltimorOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = EnRT_HuntsmanAltimorOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(420);
infoBorder:SetHeight(320);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOPLEFT", 190, -85);

local info = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 200, -110);
info:SetSize(400, 300);
info:SetText(L.OPTIONS_HUNTSMANALTIMOR_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_HuntsmanAltimorEnabledCheckButton", EnRT_HuntsmanAltimorOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -130);
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


EnRT_HuntsmanAltimorOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_HuntsmanAltimorEnabled);
end);

InterfaceOptions_AddCategory(EnRT_HuntsmanAltimorOptions);