local L = EnRTLocals;

EnRT_OpulenceOptions = CreateFrame("Frame", "EnRT_OpulenceOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_OpulenceOptions.name = L.OPTIONS_OPULENCE_TITLE
EnRT_OpulenceOptions.parent = "|cFFFFFF00Battle of Dazar'alor Modules"
EnRT_OpulenceOptions:Hide()

local title = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_OPULENCE_TITLE)

local author = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_OPULENCE_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_OpulenceEnabledCheckButton", EnRT_OpulenceOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_OpulenceEnabled = true
		PlaySound(856)
	else
		EnRT_OpulenceEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_OpulenceOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


EnRT_OpulenceOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_OpulenceEnabled)
end)

InterfaceOptions_AddCategory(EnRT_OpulenceOptions)