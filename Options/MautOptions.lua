local L = IRTLocals;

IRT_MautOptions = CreateFrame("Frame", "IRT_MautOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_MautOptions.name = L.OPTIONS_MAUT_TITLE;
IRT_MautOptions.parent = "|cFFFFFF00Ny'alotha, the Waking City Modules";
IRT_MautOptions:Hide();

local title = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);

local tabinfo = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_MAUT_TITLE);

local author = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_MAUT_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "IRT_MautEnabledCheckButton", IRT_MautOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_MautEnabled = true;
		PlaySound(856);
	else
		IRT_MautEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

IRT_MautOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_MautEnabled);
end);

InterfaceOptions_AddCategory(IRT_MautOptions);