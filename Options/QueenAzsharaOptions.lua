local L = IRTLocals;

IRT_QueenAzsharaOptions = CreateFrame("Frame", "IRT_QueenAzsharaOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_QueenAzsharaOptions.name = L.OPTIONS_QUEENAZSHARA_TITLE;
IRT_QueenAzsharaOptions.parent = "|cFFFFFF00The Eternal Palace Modules";
IRT_QueenAzsharaOptions:Hide();

local title = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_QUEENAZSHARA_TITLE);

local author = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -60)
info:SetSize(350, 600)
info:SetText(L.OPTIONS_HIGHTINKERMEKKATORQUE_INFO)
info:SetWordWrap(true)
info:SetJustifyH("LEFT");
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_QueenAzsharaEnabledCheckButton", IRT_QueenAzsharaOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_QueenAzsharaEnabled = true;
		PlaySound(856);
	else
		IRT_QueenAzsharaEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_QueenAzsharaOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);


IRT_QueenAzsharaOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_QueenAzsharaEnabled);
end);

InterfaceOptions_AddCategory(IRT_QueenAzsharaOptions);