local L = EnRTLocals

EnRT_InnervateOptions = CreateFrame("Frame", "EnRT_InnervateOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_InnervateOptions.name = "Innervate Module"
EnRT_InnervateOptions.parent = "|cFFFFFF00General Modules"
EnRT_InnervateOptions:Hide()

local title = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_INNERVATE_TITLE)

local author = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_INNERVATE_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_InnervateEnabledCheckButton", EnRT_InnervateOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_InnervateEnabled = true
		PlaySound(856)
	else
		EnRT_InnervateEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_InnervateOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


EnRT_InnervateOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_InnervateEnabled)
end)

InterfaceOptions_AddCategory(EnRT_InnervateOptions)