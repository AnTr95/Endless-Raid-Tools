local L = IRTLocals;

IRT_MOTHEROptions = CreateFrame("Frame", "IRT_MOTHEROptionsFrame", InterfaceOptionsFramePanelContainer)
IRT_MOTHEROptions.name = L.OPTIONS_MOTHER_TITLE
IRT_MOTHEROptions.parent = "|cFFFFFF00Uldir Modules"
IRT_MOTHEROptions:Hide()

local title = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_MOTHER_TITLE)

local author = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_MOTHER_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "IRT_MOTHEREnabledCheckButton", IRT_MOTHEROptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		IRT_MOTHEREnabled = true
		PlaySound(856)
	else
		IRT_MOTHEREnabled = false
		PlaySound(857)
	end
end)

local enabledText = IRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


IRT_MOTHEROptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_MOTHEREnabled)
end)

InterfaceOptions_AddCategory(IRT_MOTHEROptions)