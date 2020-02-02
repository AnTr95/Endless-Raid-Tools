local L = EnRTLocals;

EnRT_GeneralOptions = CreateFrame("Frame", "EnRT_GeneralOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_GeneralOptions.name = L.OPTIONS_GENERAL_TITLE
EnRT_GeneralOptions.parent = "|cFFFFFF00General Modules"
EnRT_GeneralOptions:Hide()

local title = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_GENERAL_TITLE)

local author = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 130, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_GENERAL_INFO)
info:SetWordWrap(true)

local fontOptionsText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
fontOptionsText:SetPoint("TOPLEFT", 30, -155)
fontOptionsText:SetText(L.OPTIONS_POPUPSETTINGS_TEXT);

local fontText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fontText:SetPoint("TOPLEFT", 30, -180)
fontText:SetText(L.OPTIONS_FONTSIZE_TEXT)

local fontSizeText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fontSizeText:SetPoint("TOPLEFT", fontText, "TOPLEFT", 65, -27)

local fontSlider = CreateFrame("Slider", "EnRT_FontSlider", EnRT_GeneralOptions, "OptionsSliderTemplate")
fontSlider:SetPoint("TOPLEFT", fontText, "TOPLEFT", 0, -10)
fontSlider:SetMinMaxValues(15, 80)
fontSlider:SetValueStep(1)
EnRT_FontSliderLow:SetText(15)
EnRT_FontSliderHigh:SetText(80)
fontSlider:SetScript("OnValueChanged", function(self)
	EnRT_PopupTextFontSize = math.floor(fontSlider:GetValue())
	fontSizeText:SetText(EnRT_PopupTextFontSize)
	EnRT_PopupUpdateFontSize()
end)

local popupToggleButton = CreateFrame("Button", "EnRT_PopupToggleButton", EnRT_GeneralOptions, "UIPanelButtonTemplate");
popupToggleButton:SetSize(150, 35);
popupToggleButton:SetPoint("TOPLEFT", fontText, "TOPLEFT", 160, 0);
popupToggleButton:SetText(L.OPTIONS_FONTSLIDER_BUTTON_TEXT);
popupToggleButton:HookScript("OnClick", function(self)
	EnRT_PopupMove();
end)


local infoBoxText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
infoBoxText:SetPoint("TOPLEFT", 30, -250);
infoBoxText:SetText(L.OPTIONS_INFOBOXSETTINGS_TEXT);

local infoBoxToggleButton = CreateFrame("Button", "EnRT_InfoBoxToggleButton", EnRT_GeneralOptions, "UIPanelButtonTemplate");
infoBoxToggleButton:SetSize(150, 35);
infoBoxToggleButton:SetPoint("TOPLEFT", infoBoxText, "TOPLEFT", 0, -25);
infoBoxToggleButton:SetText(L.OPTIONS_INFOBOX_BUTTON_TEXT);
infoBoxToggleButton:HookScript("OnClick", function(self)
	EnRT_InfoBoxMove();
end);

local generalText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
generalText:SetPoint("TOPLEFT", 30, -345);
generalText:SetText(L.OPTIONS_GENERALSETTINGS_TEXT);

local minimapModeText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
minimapModeText:SetText(L.OPTIONS_MINIMAP_MODE_TEXT);
minimapModeText:SetPoint("TOPLEFT", 30, -370);

local minimapStateMenu = CreateFrame("Button", nil, EnRT_GeneralOptions, "UIDropDownMenuTemplate");
minimapStateMenu:SetPoint("TOPLEFT", 175, -360);

local minimapStates = {"Always", "On Hover", "Never"};

local function minimapState_OnClick(self)
	UIDropDownMenu_SetSelectedID(minimapStateMenu, self:GetID());
	local state = self:GetText();
	EnRT_MinimapMode = state;
	if (state == "Always") then
		EnRT_MinimapButton:Show();
	else
		EnRT_MinimapButton:Hide();
	end
end

local function Initialize_MinimapState(self, level)
	local info = UIDropDownMenu_CreateInfo()
	for k,v in pairs(minimapStates) do
	  info = UIDropDownMenu_CreateInfo()
	  info.text = v
	  info.value = v
	  info.func = minimapState_OnClick
	  UIDropDownMenu_AddButton(info, level)
	end
end

UIDropDownMenu_SetWidth(minimapStateMenu, 110)
UIDropDownMenu_SetButtonWidth(minimapStateMenu, 110)
UIDropDownMenu_JustifyText(minimapStateMenu, "CENTER")
UIDropDownMenu_Initialize(minimapStateMenu, Initialize_MinimapState)

local vcText = EnRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
vcText:SetText(L.OPTIONS_VERSIONCHECK_TEXT);
vcText:SetPoint("TOPLEFT", 30, -410);

local vcButton = CreateFrame("Button", "EnRT_VCButton", EnRT_GeneralOptions, "UIPanelButtonTemplate");
vcButton:SetSize(150, 35);
vcButton:SetPoint("TOPLEFT", vcText, "TOPLEFT", 140, 15);
vcButton:SetText(L.OPTIONS_VERSIONCHECK_BUTTON_TEXT);
vcButton:HookScript("OnClick", function(self)
	C_ChatInfo.SendAddonMessage("EnRT_VC", "vc", "RAID");
end);

EnRT_GeneralOptions:SetScript("OnShow", function(self)
	fontSlider:SetValue(EnRT_PopupTextFontSize)
	fontSizeText:SetText(EnRT_PopupTextFontSize)
	Initialize_MinimapState();
	UIDropDownMenu_SetSelectedName(minimapStateMenu, EnRT_MinimapMode);
end)

InterfaceOptions_AddCategory(EnRT_GeneralOptions)