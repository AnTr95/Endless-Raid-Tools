local L = EnRTLocals;

EnRT_Options = CreateFrame("Frame", "EnRT_OptionsFrame", InterefaceOptionsFramePanelContainer)
EnRT_Options.name = "Endless Raid Tools"
EnRT_Options:Hide()

local title = EnRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_READYCHECK_TITLE)

local author = EnRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_Options:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

EnRT_Options:SetScript("OnShow", function(EnRT_OptionsFrame)
	InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions);
end);

InterfaceOptions_AddCategory(EnRT_Options)

EnRT_GeneralModules = CreateFrame("Frame", "EnRT_GeneralModulesFrame")
EnRT_GeneralModules.name = "|cFFFFFF00General Modules"
EnRT_GeneralModules.parent = "Endless Raid Tools"
EnRT_GeneralModules:SetScript("OnShow", function(EnRT_GeneralModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions)
end)
InterfaceOptions_AddCategory(EnRT_GeneralModules)


EnRT_CastleModules = CreateFrame("Frame", "EnRT_CastleModulesFrame")
EnRT_CastleModules.name = "|cFFFFFF00Castle Nathria Modules"
EnRT_CastleModules.parent = "Endless Raid Tools"
EnRT_CastleModules:SetScript("OnShow", function(EnRT_CastleModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_HuntsmanAltimorOptions);
end)
InterfaceOptions_AddCategory(EnRT_CastleModules)
