local L = IRTLocals;

IRT_LadyAshvaneOptions = CreateFrame("Frame", "IRT_LadyAshvaneOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_LadyAshvaneOptions.name = L.OPTIONS_LADYASHVANE_TITLE;
IRT_LadyAshvaneOptions.parent = "|cFFFFFF00The Eternal Palace Modules";
IRT_LadyAshvaneOptions:Hide();

local title = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_LADYASHVANE_TITLE);

local author = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_LADYASHVANE_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "IRT_LadyAshvaneEnabledCheckButton", IRT_LadyAshvaneOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_LadyAshvaneEnabled = true;
		PlaySound(856);
	else
		IRT_LadyAshvaneEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_LadyAshvaneOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


IRT_LadyAshvaneOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_LadyAshvaneEnabled);
end);

InterfaceOptions_AddCategory(IRT_LadyAshvaneOptions);