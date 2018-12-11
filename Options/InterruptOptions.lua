
local L = EnRTLocals

EnRT_InterruptOptions = CreateFrame("Frame", "EnRT_InterruptOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_InterruptOptions.name = "Interrupt Module"
EnRT_InterruptOptions.parent = "|cFFFFFF00General Modules"
EnRT_InterruptOptions:Hide()

local title = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_INTERRUPT_TITLE)

local author = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_INTERRUPT_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_InterruptEnabledCheckButton", EnRT_InterruptOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_InterruptEnabled = true
		PlaySound(856)
	else
		EnRT_InterruptEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)

local orderText = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
orderText:SetPoint("TOPLEFT", 30, -180)
orderText:SetText(L.OPTIONS_INTERRUPT_ORDER)

local orderEdit = CreateFrame("EditBox", "EnRT_OrderEdit", EnRT_InterruptOptions, "InputBoxTemplate")
orderEdit:SetPoint("TOPLEFT", orderText, "TOPLEFT", 0, -2)
orderEdit:SetAutoFocus(false)
orderEdit:SetSize(250, 45)
orderEdit:SetText("")
orderEdit:SetScript("OnEscapePressed", function(self)
	self:SetText("")
	self:ClearFocus()
end)
orderEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText()
	input = input:gsub("^%l", string.upper)
	EnRT_NextInterrupt = input
	orderEdit:SetText(input)
	self:ClearFocus()
end)
orderEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText()
	input = input:gsub("^%l", string.upper)
	EnRT_NextInterrupt = input
end)

EnRT_InterruptOptions:SetScript("OnShow", function(self)
	if EnRT_NextInterrupt ~= nil then
		orderEdit:SetText(EnRT_NextInterrupt)
	end
	enabledButton:SetChecked(EnRT_InterruptEnabled)
end)

InterfaceOptions_AddCategory(EnRT_InterruptOptions)