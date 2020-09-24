local L = EnRTLocals;

EnRT_StoneLegionGeneralsOptions = CreateFrame("Frame", "EnRT_StoneLegionGeneralsOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_StoneLegionGeneralsOptions.name = L.OPTIONS_STONELEGIONGENERALS_TITLE;
EnRT_StoneLegionGeneralsOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
EnRT_StoneLegionGeneralsOptions:Hide();

local title = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_STONELEGIONGENERALS_TITLE);

local author = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
EnRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-StoneLegionGenerals.PNG");
bossTexture:SetWidth(50);
bossTexture:SetHeight(56);
bossTexture:SetTexCoord(0.05,0.8,0,0.8);
bossTexture:SetPoint("TOPLEFT", 30, -56);

local bossBorder = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_STONELEGIONGENERALS_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_StoneLegionGeneralsEnabledCheckButton", EnRT_StoneLegionGeneralsOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_StoneLegionGeneralsEnabled = true;
		PlaySound(856);
	else
		EnRT_StoneLegionGeneralsEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\SLG1.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 5, -70);
infoTexture:SetSize(188, 128);
infoTexture:SetTexCoord(0,0.73,0,1);

local infoTexture2 = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\SLG2.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 230, 0);
infoTexture2:SetSize(188, 96);
infoTexture2:SetTexCoord(0,0.73,0,0.74);

local infoTexture3 = EnRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture3:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\tcobdf.tga");
infoTexture3:SetPoint("BOTTOMLEFT", infoTexture2, "BOTTOMLEFT", 0, -50);
infoTexture3:SetSize(256, 37);
infoTexture3:SetTexCoord(0,1,0,0.7);

local previewText = EnRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", 140, 50);
previewText:SetText(L.OPTIONS_STONELEGIONGENERALS_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetSize(570,45);
previewText:SetWordWrap(true);


EnRT_StoneLegionGeneralsOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_StoneLegionGeneralsEnabled);
end);

InterfaceOptions_AddCategory(EnRT_StoneLegionGeneralsOptions);