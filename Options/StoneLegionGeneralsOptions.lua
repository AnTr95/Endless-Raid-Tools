local L = IRTLocals;

IRT_StoneLegionGeneralsOptions = CreateFrame("Frame", "IRT_StoneLegionGeneralsOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_StoneLegionGeneralsOptions.name = L.OPTIONS_STONELEGIONGENERALS_TITLE;
IRT_StoneLegionGeneralsOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
IRT_StoneLegionGeneralsOptions:Hide();

local title = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_STONELEGIONGENERALS_TITLE);

local author = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local heroicTexture = IRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BACKGROUND");
heroicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
heroicTexture:SetWidth(32);
heroicTexture:SetHeight(32);
IRT_SetFlagIcon(heroicTexture, 3);
heroicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local mythicTexture = IRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
IRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", heroicTexture, "TOPLEFT", 20, 0);

local bossTexture = IRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-StoneLegionGenerals.PNG");
bossTexture:SetWidth(50);
bossTexture:SetHeight(56);
bossTexture:SetTexCoord(0.05,0.8,0,0.8);
bossTexture:SetPoint("TOPLEFT", 30, -56);

local bossBorder = IRT_StoneLegionGeneralsOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = IRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_STONELEGIONGENERALS_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_StoneLegionGeneralsEnabledCheckButton", IRT_StoneLegionGeneralsOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_StoneLegionGeneralsEnabled = true;
		PlaySound(856);
	else
		IRT_StoneLegionGeneralsEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = IRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\SLG1.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 5, -70);
infoTexture:SetSize(188, 128);
infoTexture:SetTexCoord(0,0.73,0,1);

local infoTexture2 = IRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\SLG2.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 230, 0);
infoTexture2:SetSize(188, 96);
infoTexture2:SetTexCoord(0,0.73,0,0.74);

local infoTexture3 = IRT_StoneLegionGeneralsOptions:CreateTexture(nil, "BACKGROUND");
infoTexture3:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\Dispel.tga");
infoTexture3:SetPoint("BOTTOMLEFT", infoTexture2, "BOTTOMLEFT", 0, -50);
infoTexture3:SetSize(256, 37);
infoTexture3:SetTexCoord(0,1,0,0.7);

local previewText = IRT_StoneLegionGeneralsOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", enabledButton, "TOP", 225, -24);
previewText:SetText(L.OPTIONS_STONELEGIONGENERALS_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetJustifyV("TOP");
previewText:SetSize(570,45);
previewText:SetWordWrap(true);


IRT_StoneLegionGeneralsOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_StoneLegionGeneralsEnabled);
end);

InterfaceOptions_AddCategory(IRT_StoneLegionGeneralsOptions);