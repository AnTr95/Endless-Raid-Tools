local L = EnRTLocals;

EnRT_BonusRollOptions = CreateFrame("Frame", "EnRT_BonusRollOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_BonusRollOptions.name = "Bonus Roll Module"
EnRT_BonusRollOptions.parent = "|cFFFFFF00General Modules|r"
EnRT_BonusRollOptions:Hide()

local title = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_BONUSROLL_TITLE)

local author = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = EnRT_BonusRollOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(470);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(450, 200)
info:SetText(L.OPTIONS_BONUSROLL_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_BonusRollEnabledCheckButton", EnRT_BonusRollOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_BonusRollEnabled = true;
		PlaySound(856);
	else
		EnRT_BonusRollEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local showText = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
showText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 0, -35)
showText:SetText("Open your coin plan")
local showButton = CreateFrame("Button", "EnRT_BR_OpenButton", EnRT_BonusRollOptions, "UIPanelButtonTemplate")
showButton:SetText("My plan")
showButton:SetSize(120, 25)
showButton:SetPoint("TOPLEFT", showText, "TOPLEFT", 0, -25)
showButton:HookScript("OnClick", function(self)
	EnRT_BR_Settings:Show()
end)

local infoTexture = EnRT_BonusRollOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\BonusRoll.tga");
infoTexture:SetPoint("TOPLEFT", showButton, "TOPLEFT", 120, -60);
infoTexture:SetSize(420, 50);
infoTexture:SetTexCoord(0,1,0,1);

local infoTexture2 = EnRT_BonusRollOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\BonusRollBLP.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 35, -50);
infoTexture2:SetSize(280, 70);
infoTexture2:SetTexCoord(0,0.55,0,0.56);

local previewText = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", -40, 20);
previewText:SetText(L.OPTIONS_BONUSROLL_PREVIEW);
previewText:SetJustifyH("CENTER");

EnRT_BonusRollOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_BonusRollEnabled)
end)

InterfaceOptions_AddCategory(EnRT_BonusRollOptions)