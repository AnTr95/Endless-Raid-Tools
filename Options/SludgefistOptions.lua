local L = EnRTLocals;

EnRT_SludgefistOptions = CreateFrame("Frame", "EnRT_SludgefistOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_SludgefistOptions.name = L.OPTIONS_SLUDGEFIST_TITLE;
EnRT_SludgefistOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
EnRT_SludgefistOptions:Hide();

local title = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_SLUDGEFIST_TITLE);

local author = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = EnRT_SludgefistOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
EnRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = EnRT_SludgefistOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Sludgefist.PNG");
bossTexture:SetWidth(75);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", 25, -47);

local bossBorder = EnRT_SludgefistOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = EnRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_SLUDGEFIST_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_SludgefistEnabledCheckButton", EnRT_SludgefistOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_SludgefistEnabled = true;
		PlaySound(856);
	else
		EnRT_SludgefistEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = EnRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\Sludgefist.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 5, -50);
infoTexture:SetSize(465, 170);
infoTexture:SetTexCoord(0,0.9,0,0.65);

local starTexture1 = EnRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
starTexture1:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture1:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", -45, 5);
starTexture1:SetSize(40, 40);

local starTexture2 = EnRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
starTexture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture2:SetPoint("TOPLEFT", infoTexture, "TOPRIGHT", 3, 5);
starTexture2:SetSize(40, 40);

local previewText = EnRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", 0, 25);
previewText:SetText(L.OPTIONS_SLUDGEFIST_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetSize(570,25);
previewText:SetWordWrap(true);


EnRT_SludgefistOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_SludgefistEnabled);
end);

InterfaceOptions_AddCategory(EnRT_SludgefistOptions);