local L = EnRTLocals;

EnRT_LadyInervaDarkveinOptions = CreateFrame("Frame", "EnRT_LadyInervaDarkveinOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_LadyInervaDarkveinOptions.name = L.OPTIONS_LADYINERVADARKVEIN_TITLE;
EnRT_LadyInervaDarkveinOptions.parent = "|cFFFFFF00Castle Nathria Modules";
EnRT_LadyInervaDarkveinOptions:Hide();

local title = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_LADYINERVADARKVEIN_TITLE);

local author = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_LADYINERVADARKVEIN_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_LadyInervaDarkveinEnabledCheckButton", EnRT_LadyInervaDarkveinOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_LadyInervaDarkveinEnabled = true;
		PlaySound(856);
	else
		EnRT_LadyInervaDarkveinEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_LadyInervaDarkveinOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


EnRT_LadyInervaDarkveinOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_LadyInervaDarkveinEnabled);
end);

InterfaceOptions_AddCategory(EnRT_LadyInervaDarkveinOptions);