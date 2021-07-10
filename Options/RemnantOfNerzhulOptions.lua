local L = IRTLocals;

IRT_RemnantOfNerzhulOptions = CreateFrame("Frame", "IRT_RemnantOfNerzhulOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_RemnantOfNerzhulOptions.name = L.OPTIONS_REMNANTOFNERZHUL_TITLE;
IRT_RemnantOfNerzhulOptions.parent = "|cFFFFFF00Sanctum of Domination Modules|r";
IRT_RemnantOfNerzhulOptions:Hide();

local title = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_REMNANTOFNERZHUL_TITLE);

local author = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local difficultyText = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
difficultyText:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10);
difficultyText:SetText(L.OPTIONS_DIFFICULTY);

local heroicTexture = IRT_RemnantOfNerzhulOptions:CreateTexture(nil,"BACKGROUND");
heroicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
heroicTexture:SetWidth(32);
heroicTexture:SetHeight(32);
IRT_SetFlagIcon(heroicTexture, 3);
heroicTexture:SetPoint("TOPLEFT", difficultyText, "TOPLEFT", 60, 10);

local mythicTexture = IRT_RemnantOfNerzhulOptions:CreateTexture(nil,"BACKGROUND");
mythicTexture:SetTexture("Interface\\EncounterJournal\\UI-EJ-Icons.png");
mythicTexture:SetWidth(32);
mythicTexture:SetHeight(32);
IRT_SetFlagIcon(mythicTexture, 12);
mythicTexture:SetPoint("TOPLEFT", heroicTexture, "TOPLEFT", 20, 0);

local bossTexture = IRT_RemnantOfNerzhulOptions:CreateTexture(nil,"BACKGROUND");
bossTexture:SetTexture(4071439);
bossTexture:SetWidth(48);
bossTexture:SetHeight(68);
bossTexture:SetTexCoord(0.35,0.65,0,0.75);
bossTexture:SetPoint("TOPLEFT", 30, -43);

local bossBorder = IRT_RemnantOfNerzhulOptions:CreateTexture(nil,"BORDER");
bossBorder:SetTexture("Interface\\MINIMAP\\UI-MINIMAP-BORDER.PNG");
bossBorder:SetWidth(128);
bossBorder:SetHeight(128);
bossBorder:SetTexCoord(0,1,0.1,1);
bossBorder:SetPoint("TOPLEFT", -30, -35);

local infoBorder = IRT_RemnantOfNerzhulOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(450);
infoBorder:SetHeight(250);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 20, -85);

local info = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(430, 300);
info:SetText(L.OPTIONS_REMNANTOFNERZHUL_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_RemnantOfNerzhulEnabledCheckButton", IRT_RemnantOfNerzhulOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 60, -345);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_RemnantOfNerzhulEnabled = true;
		PlaySound(856);
	else
		IRT_RemnantOfNerzhulEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_RemnantOfNerzhulOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

IRT_RemnantOfNerzhulOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_RemnantOfNerzhulEnabled);
end);

InterfaceOptions_AddCategory(IRT_RemnantOfNerzhulOptions);