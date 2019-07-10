local L = EnRTLocals;

EnRT_LadyAshvaneOptions = CreateFrame("Frame", "EnRT_LadyAshvaneOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_LadyAshvaneOptions.name = L.OPTIONS_LADYASHVANE_TITLE;
EnRT_LadyAshvaneOptions.parent = "|cFFFFFF00The Eternal Palace Modules";
EnRT_LadyAshvaneOptions:Hide();

local title = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_LADYASHVANE_TITLE);

local author = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_LADYASHVANE_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_LadyAshvaneEnabledCheckButton", EnRT_LadyAshvaneOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_LadyAshvaneEnabled = true;
		PlaySound(856);
	else
		EnRT_LadyAshvaneEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


EnRT_LadyAshvaneOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_LadyAshvaneEnabled);
end);

InterfaceOptions_AddCategory(EnRT_LadyAshvaneOptions);