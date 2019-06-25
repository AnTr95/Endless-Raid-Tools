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

InterfaceOptions_AddCategory(EnRT_Options)

EnRT_GeneralModules = CreateFrame("Frame", "EnRT_GeneralModulesFrame")
EnRT_GeneralModules.name = "|cFFFFFF00General Modules"
EnRT_GeneralModules.parent = "Endless Raid Tools"
EnRT_GeneralModules:SetScript("OnShow", function(EnRT_GeneralModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions)
end)
InterfaceOptions_AddCategory(EnRT_GeneralModules)

EnRT_UldirModules = CreateFrame("Frame", "EnRT_UldirModulesFrame")
EnRT_UldirModules.name = "|cFFFFFF00Uldir Modules"
EnRT_UldirModules.parent = "Endless Raid Tools"
EnRT_UldirModules:SetScript("OnShow", function(EnRT_UldirModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_MOTHEROptions)
end)

InterfaceOptions_AddCategory(EnRT_UldirModules)

EnRT_BoDModules = CreateFrame("Frame", "EnRT_BoDModulesFrame")
EnRT_BoDModules.name = "|cFFFFFF00Battle of Dazar'alor Modules"
EnRT_BoDModules.parent = "Endless Raid Tools"
EnRT_BoDModules:SetScript("OnShow", function(EnRT_BoDModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_HighTinkerMekkatorqueOptions)
end)
InterfaceOptions_AddCategory(EnRT_BoDModules)

EnRT_CoSModules = CreateFrame("Frame", "EnRT_CoSModulesFrame")
EnRT_CoSModules.name = "|cFFFFFF00Crucible of Storms Modules"
EnRT_CoSModules.parent = "Endless Raid Tools"
EnRT_CoSModules:SetScript("OnShow", function(EnRT_CoSModules)
	InterfaceOptionsFrame_OpenToCategory(EnRT_Uunatptions)
end)
InterfaceOptions_AddCategory(EnRT_CoSModules)