local L = IRTLocals;

IRT_RadenOptions = CreateFrame("Frame", "IRT_RadenOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_RadenOptions.name = L.OPTIONS_RADEN_TITLE;
IRT_RadenOptions.parent = "|cFFFFFF00Ny'alotha, the Waking City Modules";
IRT_RadenOptions:Hide();

local title = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_RADEN_TITLE);

local author = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_RADEN_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "IRT_RadenEnabledCheckButton", IRT_RadenOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_RadenEnabled = true;
		PlaySound(856);
	else
		IRT_RadenEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local redText = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
redText:SetPoint("TOPLEFT", 30, -180);
redText:SetText(L.OPTIONS_RADEN_RED);

local redEdit = CreateFrame("EditBox", nil, IRT_RadenOptions, "InputBoxTemplate");
redEdit:SetPoint("TOPLEFT", redText, "TOPLEFT", 0, -5);
redEdit:SetAutoFocus(false);
redEdit:SetSize(250, 45);
redEdit:SetText("");
redEdit:SetScript("OnEscapePressed", function(self)
	self:ClearFocus();
end);
redEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText();
	IRT_RadenColors.RED = tonumber(input);
	self:ClearFocus();
end);
local redPreviousText = redEdit:GetText();
redEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText();
	if (not tonumber(input)) then
		redEdit:SetText(redPreviousText);
	end
	redPreviousText = redEdit:GetText();
	IRT_RadenColors.RED = tonumber(input);
end);

local yellowText = IRT_RadenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
yellowText:SetPoint("TOPLEFT", 30, -230);
yellowText:SetText(L.OPTIONS_RADEN_YELLOW);

local yellowEdit = CreateFrame("EditBox", nil, IRT_RadenOptions, "InputBoxTemplate");
yellowEdit:SetPoint("TOPLEFT", yellowText, "TOPLEFT", 0, -5);
yellowEdit:SetAutoFocus(false);
yellowEdit:SetSize(250, 45);
yellowEdit:SetText("");
yellowEdit:SetScript("OnEscapePressed", function(self)
	self:ClearFocus();
end);
yellowEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText();
	IRT_RadenColors.YELLOW = tonumber(input);
	self:ClearFocus();
end);
local yellowPreviousText = redEdit:GetText();
yellowEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText();
	if (not tonumber(input)) then
		yellowEdit:SetText(yellowPreviousText);
	end
	yellowPreviousText = yellowEdit:GetText();
	IRT_RadenColors.YELLOW = tonumber(input);
end);


IRT_RadenOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_RadenEnabled);
	redEdit:SetText(IRT_RadenColors.RED);
	yellowEdit:SetText(IRT_RadenColors.YELLOW);
end);

InterfaceOptions_AddCategory(IRT_RadenOptions);