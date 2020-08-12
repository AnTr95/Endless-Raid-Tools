local L = EnRTLocals;

EnRT_HuntsmanAltimorOptions = CreateFrame("Frame", "EnRT_HuntsmanAltimorOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_HuntsmanAltimorOptions.name = L.OPTIONS_HUNTSMANALTIMOR_TITLE;
EnRT_HuntsmanAltimorOptions.parent = "|cFFFFFF00Castle Nathria Modules";
EnRT_HuntsmanAltimorOptions:Hide();

local title = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_HUNTSMANALTIMOR_TITLE);

local author = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 300);
info:SetText(L.OPTIONS_HUNTSMANALTIMOR_INFO);
info:SetWordWrap(true);
info:SetJustifyH("LEFT");

local enabledButton = CreateFrame("CheckButton", "EnRT_HuntsmanAltimorEnabledCheckButton", EnRT_HuntsmanAltimorOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_HuntsmanAltimorEnabled = true;
		PlaySound(856);
	else
		EnRT_HuntsmanAltimorEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_HuntsmanAltimorOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


EnRT_HuntsmanAltimorOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_HuntsmanAltimorEnabled);
end);

InterfaceOptions_AddCategory(EnRT_HuntsmanAltimorOptions);