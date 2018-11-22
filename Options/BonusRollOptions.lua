local L = PGFinderLocals

EnRT_BonusRollOptions = CreateFrame("Frame", "EnRT_BonusRollOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_BonusRollOptions.name = "Bonus Roll Module"
EnRT_BonusRollOptions.parent = "|cFFFFFF00General Modules"
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

local info = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_BONUSROLL_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_BonusRollEnabledCheckButton", EnRT_BonusRollOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_BonusRollEnabled = true
		PlaySound(856)
	else
		EnRT_BonusRollEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)

local showText = EnRT_BonusRollOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
showText:SetPoint("TOPLEFT", 30, -150)
showText:SetText("Open your coin plan")
local showButton = CreateFrame("Button", "EnRT_BR_OpenButton", EnRT_BonusRollOptions, "UIPanelButtonTemplate")
showButton:SetText("My plan")
showButton:SetSize(120, 25)
showButton:SetPoint("TOPLEFT", showText, "TOPLEFT", 0, -15)
showButton:HookScript("OnClick", function(self)
	EnRT_BR_Settings:Show()
end)


EnRT_BonusRollOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_BonusRollEnabled)
end)

InterfaceOptions_AddCategory(EnRT_BonusRollOptions)