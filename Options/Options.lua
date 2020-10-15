local L = IRTLocals;

IRT_Options = CreateFrame("Frame", "IRT_OptionsFrame", InterefaceOptionsFramePanelContainer)
IRT_Options.name = "Infinite Raid Tools"
IRT_Options:Hide()

local title = IRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)

local author = IRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

IRT_Options:SetScript("OnShow", function(IRT_OptionsFrame)
	InterfaceOptionsFrame_OpenToCategory(IRT_GeneralModules);
	InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions)
end);

InterfaceOptions_AddCategory(IRT_Options)

IRT_GeneralModules = CreateFrame("Frame", "IRT_GeneralModulesFrame")
IRT_GeneralModules.name = "|cFFFFFF00General Modules|r"
IRT_GeneralModules.parent = "Infinite Raid Tools"
IRT_GeneralModules:SetScript("OnShow", function(IRT_GeneralModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions)
end);
InterfaceOptions_AddCategory(IRT_GeneralModules)


IRT_CastleModules = CreateFrame("Frame", "IRT_CastleModulesFrame")
IRT_CastleModules.name = "|cFFFFFF00Castle Nathria Modules|r"
IRT_CastleModules.parent = "Infinite Raid Tools"
IRT_CastleModules:SetScript("OnShow", function(IRT_CastleModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_HuntsmanAltimorOptions);
end);
InterfaceOptions_AddCategory(IRT_CastleModules)
