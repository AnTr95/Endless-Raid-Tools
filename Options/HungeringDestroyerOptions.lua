local L = EnRTLocals;

EnRT_HungeringDestroyerOptions = CreateFrame("Frame", "EnRT_HungeringDestroyerOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_HungeringDestroyerOptions.name = L.OPTIONS_HUNGERINGDESTROYER_TITLE;
EnRT_HungeringDestroyerOptions.parent = "|cFFFFFF00Castle Nathria Modules";
EnRT_HungeringDestroyerOptions:Hide();

local title = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_HUNGERINGDESTROYER_TITLE);

local author = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_HUNGERINGDESTROYER_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_HungeringDestroyerEnabledCheckButton", EnRT_HungeringDestroyerOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_HungeringDestroyerEnabled = true;
		PlaySound(856);
	else
		EnRT_HungeringDestroyerEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_HungeringDestroyerOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


EnRT_HungeringDestroyerOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_HungeringDestroyerEnabled);
end);

InterfaceOptions_AddCategory(EnRT_HungeringDestroyerOptions);