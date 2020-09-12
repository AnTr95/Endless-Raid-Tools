local L = EnRTLocals;

EnRT_UunatOptions = CreateFrame("Frame", "EnRT_UunatOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_UunatOptions.name = L.OPTIONS_UUNAT_TITLE;
EnRT_UunatOptions.parent = "|cFFFFFF00Crucible of Storms Modules";
EnRT_UunatOptions:Hide();

local title = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_UUNAT_TITLE);

local author = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local info = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", 220, -10);
info:SetSize(350, 200);
info:SetText(L.OPTIONS_UUNAT_INFO);
info:SetWordWrap(true);

local enabledButton = CreateFrame("CheckButton", "EnRT_UunatEnabledCheckButton", EnRT_UunatOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -90);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_UunatEnabled = true;
		PlaySound(856);
	else
		EnRT_UunatEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local stormText = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
stormText:SetPoint("TOPLEFT", 30, -150);
stormText:SetText("Storm: " .. L.OPTIONS_UUNAT_MARKTEXT);

local stormEdit = CreateFrame("EditBox", nil, EnRT_UunatOptions, "InputBoxTemplate");
stormEdit:SetPoint("TOPLEFT", stormText, "TOPLEFT", 0, -5);
stormEdit:SetAutoFocus(false);
stormEdit:SetSize(250, 45);
stormEdit:SetText("");
stormEdit:SetScript("OnEscapePressed", function(self)
	self:SetText("");
	self:ClearFocus();
end);
stormEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText();
	EnRT_UunatStormMark = input;
	self:ClearFocus();
end);
stormEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText();
	EnRT_UunatStormMark = input;
end);

local oceanText = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
oceanText:SetPoint("TOPLEFT", 30, -200);
oceanText:SetText("Ocean: " .. L.OPTIONS_UUNAT_MARKTEXT);

local oceanEdit = CreateFrame("EditBox", nil, EnRT_UunatOptions, "InputBoxTemplate");
oceanEdit:SetPoint("TOPLEFT", oceanText, "TOPLEFT", 0, -5);
oceanEdit:SetAutoFocus(false);
oceanEdit:SetSize(250, 45);
oceanEdit:SetText("");
oceanEdit:SetScript("OnEscapePressed", function(self)
	self:SetText("");
	self:ClearFocus();
end);
oceanEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText();
	EnRT_UunatOceanMark = input;
	self:ClearFocus();
end);
oceanEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText();
	EnRT_UunatOceanMark = input;
end);

local voidText = EnRT_UunatOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
voidText:SetPoint("TOPLEFT", 30, -250);
voidText:SetText("Void: " .. L.OPTIONS_UUNAT_MARKTEXT);

local voidEdit = CreateFrame("EditBox", nil, EnRT_UunatOptions, "InputBoxTemplate");
voidEdit:SetPoint("TOPLEFT", voidText, "TOPLEFT", 0, -5);
voidEdit:SetAutoFocus(false);
voidEdit:SetSize(250, 45);
voidEdit:SetText("");
voidEdit:SetScript("OnEscapePressed", function(self)
	self:SetText("");
	self:ClearFocus();
end);
voidEdit:SetScript("OnEnterPressed", function(self)
	local input = self:GetText();
	EnRT_UunatVoidMark = input;
	self:ClearFocus();
end);
voidEdit:SetScript("OnTextChanged", function(self)
	local input = self:GetText();
	EnRT_UunatVoidMark = input;
end);

EnRT_UunatOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_UunatEnabled);
	stormEdit:SetText(EnRT_UunatStormMark);
	oceanEdit:SetText(EnRT_UunatOceanMark);
	voidEdit:SetText(EnRT_UunatVoidMark);
end);

InterfaceOptions_AddCategory(EnRT_UunatOptions);