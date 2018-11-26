local L = EnRTLocals

EnRT_ReadyCheckOptions = CreateFrame("Frame", "EnRT_ReadyCheckOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_ReadyCheckOptions.name = "Ready Check Module"
EnRT_ReadyCheckOptions.parent = "|cFFFFFF00General Modules"
EnRT_ReadyCheckOptions:Hide()

local title = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)

local tabinfo = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_READYCHECK_TITLE)

local author = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_READYCHECK_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_ReadyCheckEnabledCheckButton", EnRT_ReadyCheckOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_ReadyCheckEnabled = true
		PlaySound(856)
	else
		EnRT_ReadyCheckEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


EnRT_ReadyCheckOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_ReadyCheckEnabled)
end)

InterfaceOptions_AddCategory(EnRT_ReadyCheckOptions)