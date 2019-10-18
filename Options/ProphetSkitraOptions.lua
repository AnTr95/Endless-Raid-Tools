local L = EnRTLocals;

EnRT_ProphetSkitraOptions = CreateFrame("Frame", "EnRT_ProphetSkitraOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_ProphetSkitraOptions.name = L.OPTIONS_PROPHETSKITRA_TITLE;
EnRT_ProphetSkitraOptions.parent = "|cFFFFFF00Ny'alotha, the Waking City Modules";
EnRT_ProphetSkitraOptions:Hide();

local title = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);

local tabinfo = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_PROPHETSKITRA_TITLE);

local author = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_PROPHETSKITRA_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_ProphetSkitraEnabledCheckButton", EnRT_ProphetSkitraOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_ProphetSkitraEnabled = true;
		PlaySound(856);
	else
		EnRT_ProphetSkitraEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_ProphetSkitraOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

EnRT_ProphetSkitraOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_ProphetSkitraEnabled);
end);

InterfaceOptions_AddCategory(EnRT_ProphetSkitraOptions);