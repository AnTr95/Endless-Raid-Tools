local L = EnRTLocals;

EnRT_IlgynothOptions = CreateFrame("Frame", "EnRT_IlgynothOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_IlgynothOptions.name = L.OPTIONS_ILGYNOTH_TITLE;
EnRT_IlgynothOptions.parent = "|cFFFFFF00Ny'alotha, the Waking City Modules";
EnRT_IlgynothOptions:Hide();

local title = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);

local tabinfo = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_ILGYNOTH_TITLE);

local author = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_ILGYNOTH_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_IlgynothEnabledCheckButton", EnRT_IlgynothOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_IlgynothEnabled = true;
		PlaySound(856);
	else
		EnRT_IlgynothEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_IlgynothOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

EnRT_IlgynothOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_IlgynothEnabled);
end);

InterfaceOptions_AddCategory(EnRT_IlgynothOptions);