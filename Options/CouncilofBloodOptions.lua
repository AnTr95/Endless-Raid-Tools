local L = EnRTLocals;

EnRT_CouncilofBloodOptions = CreateFrame("Frame", "EnRT_CouncilofBloodOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_CouncilofBloodOptions.name = L.OPTIONS_COUNCILOFBLOOD_TITLE;
EnRT_CouncilofBloodOptions.parent = "|cFFFFFF00Castle Nathria Modules";
EnRT_CouncilofBloodOptions:Hide();

local title = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_COUNCILOFBLOOD_TITLE);

local author = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_COUNCILOFBLOOD_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_CouncilofBloodEnabledCheckButton", EnRT_CouncilofBloodOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_CouncilofBloodEnabled = true;
		PlaySound(856);
	else
		EnRT_CouncilofBloodEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_CouncilofBloodOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


EnRT_CouncilofBloodOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_CouncilofBloodEnabled);
end);

InterfaceOptions_AddCategory(EnRT_CouncilofBloodOptions);