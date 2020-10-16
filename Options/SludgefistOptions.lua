local L = IRTLocals;

IRT_SludgefistOptions = CreateFrame("Frame", "IRT_SludgefistOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_SludgefistOptions.name = L.OPTIONS_SLUDGEFIST_TITLE;
IRT_SludgefistOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
IRT_SludgefistOptions:Hide();

local title = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_SLUDGEFIST_TITLE);

local author = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local mythicTexture = IRT_SludgefistOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
IRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local bossTexture = IRT_SludgefistOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Sludgefist.PNG");
bossTexture:SetWidth(75);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,0.8);
bossTexture:SetPoint("TOPLEFT", 25, -47);

local bossBorder = IRT_SludgefistOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_SLUDGEFIST_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_SludgefistEnabledCheckButton", IRT_SludgefistOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_SludgefistEnabled = true;
		PlaySound(856);
	else
		IRT_SludgefistEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\SludgefistInfoBox.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 5, -95);
infoTexture:SetSize(210, 85);
infoTexture:SetTexCoord(0,0.82,0,0.66);

local soakStarTexture = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
soakStarTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\SoakStar.tga");
soakStarTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 275, -65);
soakStarTexture:SetSize(110, 16);
soakStarTexture:SetTexCoord(0,0.86,0,1);

local yellStarTexture = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
yellStarTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\YellStar.tga");
yellStarTexture:SetPoint("TOPLEFT", soakStarTexture, "TOP", -20, -30);
yellStarTexture:SetSize(51, 94);
yellStarTexture:SetTexCoord(0,0.8,0,0.73);

local starTexture1 = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
starTexture1:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture1:SetPoint("TOPLEFT", soakStarTexture, "TOPLEFT", -20, 1);
starTexture1:SetSize(20, 20);

local starTexture2 = IRT_SludgefistOptions:CreateTexture(nil, "BACKGROUND");
starTexture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
starTexture2:SetPoint("TOPLEFT", soakStarTexture, "TOPRIGHT", 1, 1);
starTexture2:SetSize(20, 20);

local previewText = IRT_SludgefistOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", enabledButton, "TOP", 225, -24);
previewText:SetText(L.OPTIONS_SLUDGEFIST_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetJustifyV("TOP");
previewText:SetSize(570,25);
previewText:SetWordWrap(true);


IRT_SludgefistOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_SludgefistEnabled);
end);

InterfaceOptions_AddCategory(IRT_SludgefistOptions);