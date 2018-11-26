local L = EnRTLocals;

EnRT_HighTinkerMekkatorqueOptions = CreateFrame("Frame", "EnRT_HighTinkerMekkatorqueOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_HighTinkerMekkatorqueOptions.name = L.OPTIONS_HIGHTINKERMEKKATORQUE_TITLE
EnRT_HighTinkerMekkatorqueOptions.parent = "|cFFFFFF00Battle of Dazar'alor Modules";
EnRT_HighTinkerMekkatorqueOptions:Hide()

local title = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_HIGHTINKERMEKKATORQUE_TITLE)

local author = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_HIGHTINKERMEKKATORQUE_INFO)
info:SetWordWrap(true)
info:SetJustifyH("LEFT");

local enabledButton = CreateFrame("CheckButton", "EnRT_HTMEnabledCheckButton", EnRT_HighTinkerMekkatorqueOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_HTMEnabled = true
		PlaySound(856)
	else
		EnRT_HTMEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


EnRT_HighTinkerMekkatorqueOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_HTMEnabled)
end)

InterfaceOptions_AddCategory(EnRT_HighTinkerMekkatorqueOptions)