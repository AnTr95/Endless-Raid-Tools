local L = EnRTLocals;

EnRT_QueenAzsharaOptions = CreateFrame("Frame", "EnRT_QueenAzsharaOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_QueenAzsharaOptions.name = L.OPTIONS_QUEENAZSHARA_TITLE;
EnRT_QueenAzsharaOptions.parent = "|cFFFFFF00The Eternal Palace Modules";
EnRT_QueenAzsharaOptions:Hide();

local title = EnRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_QUEENAZSHARA_TITLE);

local author = EnRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_QUEENAZSHARA_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_QueenAzsharaEnabledCheckButton", EnRT_QueenAzsharaOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_QueenAzsharaEnabled = true;
		PlaySound(856);
	else
		EnRT_QueenAzsharaEnabled = false;
		PlaySound(857);
	end
end);


EnRT_QueenAzsharaOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_QueenAzsharaEnabled);
end);

InterfaceOptions_AddCategory(EnRT_QueenAzsharaOptions);