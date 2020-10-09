local L = IRTLocals;

IRT_Options = CreateFrame("Frame", "IRT_OptionsFrame", InterfaceOptionsFramePanelContainer)
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
	InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions);
end);

InterfaceOptions_AddCategory(IRT_Options)

IRT_GeneralModules = CreateFrame("Frame", "IRT_GeneralModulesFrame")
IRT_GeneralModules.name = "|cFFFFFF00General Modules|r"
IRT_GeneralModules.parent = "Infinite Raid Tools"
IRT_GeneralModules:SetScript("OnShow", function(IRT_GeneralModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions)
end)
InterfaceOptions_AddCategory(IRT_GeneralModules)

IRT_UldirModules = CreateFrame("Frame", "IRT_UldirModulesFrame")
IRT_UldirModules.name = "|cFFFFFF00Uldir Modules"
IRT_UldirModules.parent = "Infinite Raid Tools"
IRT_UldirModules:SetScript("OnShow", function(IRT_UldirModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_MOTHEROptions)
end)

InterfaceOptions_AddCategory(IRT_UldirModules)

IRT_BoDModules = CreateFrame("Frame", "IRT_BoDModulesFrame")
IRT_BoDModules.name = "|cFFFFFF00Battle of Dazar'alor Modules"
IRT_BoDModules.parent = "Infinite Raid Tools"
IRT_BoDModules:SetScript("OnShow", function(IRT_BoDModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_HighTinkerMekkatorqueOptions)
end)
InterfaceOptions_AddCategory(IRT_BoDModules)

IRT_CoSModules = CreateFrame("Frame", "IRT_CoSModulesFrame")
IRT_CoSModules.name = "|cFFFFFF00Crucible of Storms Modules"
IRT_CoSModules.parent = "Infinite Raid Tools"
IRT_CoSModules:SetScript("OnShow", function(IRT_CoSModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_UunatOptions)
end)
InterfaceOptions_AddCategory(IRT_CoSModules)

IRT_EPModules = CreateFrame("Frame", "IRT_EPModulesFrame")
IRT_EPModules.name = "|cFFFFFF00The Eternal Palace Modules"
IRT_EPModules.parent = "Infinite Raid Tools"
IRT_EPModules:SetScript("OnShow", function(IRT_EPModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_QueenAzsharaOptions);
end)
InterfaceOptions_AddCategory(IRT_EPModules)


IRT_NyalothaModules = CreateFrame("Frame", "IRT_NyalothaModulesFrame")
IRT_NyalothaModules.name = "|cFFFFFF00Ny'alotha, the Waking City Modules"
IRT_NyalothaModules.parent = "Infinite Raid Tools"
IRT_NyalothaModules:SetScript("OnShow", function(IRT_NyalothaModules)
	InterfaceOptionsFrame_OpenToCategory(IRT_MautOptions);
end)
InterfaceOptions_AddCategory(IRT_NyalothaModules)
