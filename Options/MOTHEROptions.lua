local L = PGFinderLocals

EnRT_MOTHEROptions = CreateFrame("Frame", "EnRT_MOTHEROptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_MOTHEROptions.name = L.OPTIONS_MOTHER_TITLE
EnRT_MOTHEROptions.parent = "|cFFFFFF00Uldir Modules"
EnRT_MOTHEROptions:Hide()

local title = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_MOTHER_TITLE)

local author = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_MOTHER_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_MOTHEREnabledCheckButton", EnRT_MOTHEROptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_MOTHEREnabled = true
		PlaySound(856)
	else
		EnRT_MOTHEREnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_MOTHEROptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


EnRT_MOTHEROptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_MOTHEREnabled)
end)

InterfaceOptions_AddCategory(EnRT_MOTHEROptions)