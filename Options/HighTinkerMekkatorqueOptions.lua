local L = IRTLocals;

IRT_HighTinkerMekkatorqueOptions = CreateFrame("Frame", "IRT_HighTinkerMekkatorqueOptionsFrame", InterfaceOptionsFramePanelContainer)
IRT_HighTinkerMekkatorqueOptions.name = L.OPTIONS_HIGHTINKERMEKKATORQUE_TITLE
IRT_HighTinkerMekkatorqueOptions.parent = "|cFFFFFF00Battle of Dazar'alor Modules";
IRT_HighTinkerMekkatorqueOptions:Hide()

local title = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_HIGHTINKERMEKKATORQUE_TITLE)

local author = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -60)
info:SetSize(350, 600)
info:SetText(L.OPTIONS_HIGHTINKERMEKKATORQUE_INFO)
info:SetWordWrap(true)
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_HTMEnabledCheckButton", IRT_HighTinkerMekkatorqueOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		IRT_HTMEnabled = true
		PlaySound(856)
	else
		IRT_HTMEnabled = false
		PlaySound(857)
	end
end)

local enabledText = IRT_HighTinkerMekkatorqueOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)


IRT_HighTinkerMekkatorqueOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_HTMEnabled)
end)

InterfaceOptions_AddCategory(IRT_HighTinkerMekkatorqueOptions)