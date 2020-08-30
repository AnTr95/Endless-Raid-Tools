local L = EnRTLocals;

EnRT_ConsumableCheckOptions = CreateFrame("Frame", "EnRT_ConsumableCheckOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_ConsumableCheckOptions.name = "Consumable Module"
EnRT_ConsumableCheckOptions.parent = "|cFFFFFF00General Modules|r"
EnRT_ConsumableCheckOptions:Hide()

local title = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_CONSUMABLECHECK_TITLE)

local author = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = EnRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(470);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(450, 200)
info:SetText(L.OPTIONS_CONSUMABLECHECK_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_ConsumableCheckEnabledCheckButton", EnRT_ConsumableCheckOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_ConsumableCheckEnabled = true;
		PlaySound(856);
	else
		EnRT_ConsumableCheckEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = EnRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\ConsumableCheck1.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 130, -60);
infoTexture:SetSize(315, 95);
infoTexture:SetTexCoord(0,0.65,0,0.72);

local infoTexture2 = EnRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\ConsumableCheck2.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 0, -110);
infoTexture2:SetSize(315, 95);
infoTexture2:SetTexCoord(0,0.65,0,0.72);

local previewText = EnRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", 0, 25);
previewText:SetText(L.OPTIONS_CONSUMABLECHECK_PREVIEW);
previewText:SetJustifyH("CENTER");

EnRT_ConsumableCheckOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_ConsumableCheckEnabled)
end)

InterfaceOptions_AddCategory(EnRT_ConsumableCheckOptions)