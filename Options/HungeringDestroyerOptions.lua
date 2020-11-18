local L = IRTLocals;

IRT_HungeringDestroyerOptions = CreateFrame("Frame", "IRT_HungeringDestroyerOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_HungeringDestroyerOptions.name = L.OPTIONS_HUNGERINGDESTROYER_TITLE;
IRT_HungeringDestroyerOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
IRT_HungeringDestroyerOptions:Hide();

local title = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_HUNGERINGDESTROYER_TITLE);

local author = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = IRT_HungeringDestroyerOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
IRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = IRT_HungeringDestroyerOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-HungeringDestroyer.PNG");
bossTexture:SetWidth(72);
bossTexture:SetHeight(68);
bossTexture:SetTexCoord(0.1,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", 32, -45);

local bossBorder = IRT_HungeringDestroyerOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_HUNGERINGDESTROYER_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_HungeringDestroyerEnabledCheckButton", IRT_HungeringDestroyerOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_HungeringDestroyerEnabled = true;
		PlaySound(856);
	else
		IRT_HungeringDestroyerEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local moveToStarTexture = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
moveToStarTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\MoveToStar.tga");
moveToStarTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 30, -65);
moveToStarTexture:SetSize(164, 16);
moveToStarTexture:SetTexCoord(0,0.64,0,1);

local yellStarDebuff = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
yellStarDebuff:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\YellStarDebuff.tga");
yellStarDebuff:SetPoint("TOPLEFT", moveToStarTexture, "TOP", -25, -25);
yellStarDebuff:SetSize(80, 105);
yellStarDebuff:SetTexCoord(0,0.81,0,1);

local soakStarTexture = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
soakStarTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\SoakStar.tga");
soakStarTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 295, -65);
soakStarTexture:SetSize(110, 16);
soakStarTexture:SetTexCoord(0,0.86,0,1);

local yellStarTexture = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
yellStarTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\YellStar.tga");
yellStarTexture:SetPoint("TOPLEFT", soakStarTexture, "TOP", -20, -25);
yellStarTexture:SetSize(51, 94);
yellStarTexture:SetTexCoord(0,0.8,0,0.73);

local starTexture1 = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
starTexture1:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture1:SetPoint("TOPLEFT", soakStarTexture, "TOPLEFT", -20, 2);
starTexture1:SetSize(20, 20);

local starTexture2 = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
starTexture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture2:SetPoint("TOPLEFT", soakStarTexture, "TOPRIGHT", 2, 2);
starTexture2:SetSize(20, 20);

local starTexture3 = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
starTexture3:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture3:SetPoint("TOPLEFT", moveToStarTexture, "TOPLEFT", -20, 1);
starTexture3:SetSize(20, 20);

local starTexture4 = IRT_HungeringDestroyerOptions:CreateTexture(nil, "BACKGROUND");
starTexture4:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture4:SetPoint("TOPLEFT", moveToStarTexture, "TOPRIGHT", 1, 1);
starTexture4:SetSize(20, 20);

local previewText = IRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", enabledButton, "TOP", 225, -24);
previewText:SetText(L.OPTIONS_HUNGERINGDESTROYER_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetJustifyV("TOP");
previewText:SetSize(570,25);
previewText:SetWordWrap(true);


IRT_HungeringDestroyerOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_HungeringDestroyerEnabled);
end);

InterfaceOptions_AddCategory(IRT_HungeringDestroyerOptions);