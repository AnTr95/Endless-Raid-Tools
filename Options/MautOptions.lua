local L = EnRTLocals;

EnRT_MautOptions = CreateFrame("Frame", "EnRT_MautOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_MautOptions.name = L.OPTIONS_MAUT_TITLE;
EnRT_MautOptions.parent = "|cFFFFFF00Ny'alotha, the Waking City Modules|r";
EnRT_MautOptions:Hide();

local title = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);

local tabinfo = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_MAUT_TITLE);

local author = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_MAUT_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_MautEnabledCheckButton", EnRT_MautOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_MautEnabled = true;
		PlaySound(856);
	else
		EnRT_MautEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_MautOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

EnRT_MautOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_MautEnabled);
end);

InterfaceOptions_AddCategory(EnRT_MautOptions);