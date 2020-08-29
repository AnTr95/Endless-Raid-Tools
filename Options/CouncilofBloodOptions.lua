local L = EnRTLocals;

EnRT_CouncilofBloodOptions = CreateFrame("Frame", "EnRT_CouncilofBloodOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_CouncilofBloodOptions.name = L.OPTIONS_COUNCILOFBLOOD_TITLE;
EnRT_CouncilofBloodOptions.parent = "|cFFFFFF00Castle Nathria Modules|r";
EnRT_CouncilofBloodOptions:Hide();

local title = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_COUNCILOFBLOOD_TITLE);

local author = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local heroicTexture = EnRT_CouncilofBloodOptions:CreateTexture(nil,"BACKGROUND");
heroicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
heroicTexture:SetWidth(32);
heroicTexture:SetHeight(32);
EnRT_SetFlagIcon(heroicTexture, 3);
heroicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local mythicTexture = EnRT_CouncilofBloodOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
EnRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", heroicTexture, "TOPLEFT", 20, 0);

local bossTexture = EnRT_CouncilofBloodOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-TheCouncilOfBlood.PNG");
bossTexture:SetWidth(64);
bossTexture:SetHeight(64);
bossTexture:SetTexCoord(0,1,0,1);
bossTexture:SetPoint("TOPLEFT", 28, -47);

local bossBorder = EnRT_CouncilofBloodOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = EnRT_CouncilofBloodOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_COUNCILOFBLOOD_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local dmEnabledButton = CreateFrame("CheckButton", "EnRT_CouncilofBlood1EnabledCheckButton", EnRT_CouncilofBloodOptions, "UICheckButtonTemplate");
dmEnabledButton:SetSize(26, 26);
dmEnabledButton:SetPoint("TOPLEFT", 60, -345);
dmEnabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_TCOBDMEnabled = true;
		PlaySound(856);
	else
		EnRT_TCOBDMEnabled = false;
		PlaySound(857);
	end
end);

local dmEnabledText = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
dmEnabledText:SetPoint("TOPLEFT", dmEnabledButton, "TOPLEFT", 30, -7);
dmEnabledText:SetText(L.OPTIONS_COUNCILOFBLOOD_DM);

local dfEnabledButton = CreateFrame("CheckButton", "EnRT_CouncilofBlood2EnabledCheckButton", EnRT_CouncilofBloodOptions, "UICheckButtonTemplate");
dfEnabledButton:SetSize(26, 26);
dfEnabledButton:SetPoint("TOPLEFT", dmEnabledButton, "TOPLEFT", 0, -20);
dfEnabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_TCOBDFEnabled = true;
		PlaySound(856);
	else
		EnRT_TCOBDFEnabled = false;
		PlaySound(857);
	end
end);

local dfEnabledText = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
dfEnabledText:SetPoint("TOPLEFT", dfEnabledButton, "TOPLEFT", 30, -7);
dfEnabledText:SetText(L.OPTIONS_COUNCILOFBLOOD_DF);

local dmInfoTexture = EnRT_CouncilofBloodOptions:CreateTexture(nil, "BACKGROUND");
dmInfoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\tcobdm.tga");
dmInfoTexture:SetPoint("TOPLEFT", dfEnabledButton, "TOPLEFT", -30, -50);
dmInfoTexture:SetSize(256, 128);
dmInfoTexture:SetTexCoord(0,0.95,0.1,1);

local previewText = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", dmInfoTexture, "TOP", 150, 20);
previewText:SetText(L.OPTIONS_COUNCILOFBLOOD_PREVIEW);
previewText:SetJustifyH("CENTER");

local dfInfoTexture = EnRT_CouncilofBloodOptions:CreateTexture(nil, "BACKGROUND");
dfInfoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\tcobdf.tga");
dfInfoTexture:SetPoint("TOPLEFT", dmInfoTexture, "TOPLEFT", 290, -5);
dfInfoTexture:SetSize(256, 37);
dfInfoTexture:SetTexCoord(0,1,0,0.7);

EnRT_CouncilofBloodOptions:SetScript("OnShow", function(self)
	dmEnabledButton:SetChecked(EnRT_TCOBDMEnabled);
	dfEnabledButton:SetChecked(EnRT_TCOBDFEnabled);
end);

InterfaceOptions_AddCategory(EnRT_CouncilofBloodOptions);