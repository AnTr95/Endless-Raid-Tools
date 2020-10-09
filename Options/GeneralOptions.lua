local L = IRTLocals;

IRT_GeneralOptions = CreateFrame("Frame", "IRT_GeneralOptionsFrame", InterfaceOptionsFramePanelContainer)
IRT_GeneralOptions.name = L.OPTIONS_GENERAL_TITLE
IRT_GeneralOptions.parent = "|cFFFFFF00General Modules|r"
IRT_GeneralOptions:Hide()

local title = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_GENERAL_TITLE)

local author = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = IRT_GeneralOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(470);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(450, 200)
info:SetText(L.OPTIONS_GENERAL_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local fontOptionsText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
fontOptionsText:SetPoint("TOPLEFT", 30, -230)
fontOptionsText:SetText(L.OPTIONS_POPUPSETTINGS_TEXT);

local fontText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fontText:SetPoint("TOPLEFT", fontOptionsText, "TOPLEFT", 0, -25)
fontText:SetText(L.OPTIONS_FONTSIZE_TEXT)

local fontSizeText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fontSizeText:SetPoint("TOPLEFT", fontText, "TOPLEFT", 65, -27)

local fontSlider = CreateFrame("Slider", "IRT_FontSlider", IRT_GeneralOptions, "OptionsSliderTemplate")
fontSlider:SetPoint("TOPLEFT", fontText, "TOPLEFT", 0, -10)
fontSlider:SetMinMaxValues(15, 80)
fontSlider:SetValueStep(1)
IRT_FontSliderLow:SetText(15)
IRT_FontSliderHigh:SetText(80)
fontSlider:SetScript("OnValueChanged", function(self)
	IRT_PopupTextFontSize = math.floor(fontSlider:GetValue())
	fontSizeText:SetText(IRT_PopupTextFontSize)
	IRT_PopupUpdateFontSize()
end)

local popupToggleButton = CreateFrame("Button", "IRT_PopupToggleButton", IRT_GeneralOptions, "UIPanelButtonTemplate");
popupToggleButton:SetSize(150, 35);
popupToggleButton:SetPoint("TOPLEFT", fontText, "TOPLEFT", 160, 0);
popupToggleButton:SetText(L.OPTIONS_FONTSLIDER_BUTTON_TEXT);
popupToggleButton:HookScript("OnClick", function(self)
	IRT_PopupMove();
end)


local infoBoxText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
infoBoxText:SetPoint("TOPLEFT", fontText, "TOPLEFT", 0, -50);
infoBoxText:SetText(L.OPTIONS_INFOBOXSETTINGS_TEXT);

local infoBoxToggleButton = CreateFrame("Button", "IRT_InfoBoxToggleButton", IRT_GeneralOptions, "UIPanelButtonTemplate");
infoBoxToggleButton:SetSize(150, 35);
infoBoxToggleButton:SetPoint("TOPLEFT", infoBoxText, "TOPLEFT", 0, -25);
infoBoxToggleButton:SetText(L.OPTIONS_INFOBOX_BUTTON_TEXT);
infoBoxToggleButton:HookScript("OnClick", function(self)
	IRT_InfoBoxMove();
end);

local generalText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
generalText:SetPoint("TOPLEFT", infoBoxText, "TOPLEFT", 0, -70);
generalText:SetText(L.OPTIONS_GENERALSETTINGS_TEXT);

local minimapModeText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
minimapModeText:SetText(L.OPTIONS_MINIMAP_MODE_TEXT);
minimapModeText:SetPoint("TOPLEFT", generalText, "TOPLEFT", 0, -25);

local minimapStateMenu = CreateFrame("Button", nil, IRT_GeneralOptions, "UIDropDownMenuTemplate");
minimapStateMenu:SetPoint("TOPLEFT", minimapModeText, "TOPLEFT", 145, 8);

local minimapStates = {"Always", "On Hover", "Never"};

local function minimapState_OnClick(self)
	UIDropDownMenu_SetSelectedID(minimapStateMenu, self:GetID());
	local state = self:GetText();
	IRT_MinimapMode = state;
	if (state == "Always") then
		IRT_MinimapButton:Show();
	else
		IRT_MinimapButton:Hide();
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

local vcText = IRT_GeneralOptions:CreateFontString(nil, "ARTWORK", "GameFontWhite");
vcText:SetText(L.OPTIONS_VERSIONCHECK_TEXT);
vcText:SetPoint("TOPLEFT", generalText, "TOPLEFT", 0, -70);

local vcButton = CreateFrame("Button", "IRT_VCButton", IRT_GeneralOptions, "UIPanelButtonTemplate");
vcButton:SetSize(150, 35);
vcButton:SetPoint("TOPLEFT", vcText, "TOPLEFT", 190, 15);
vcButton:SetText(L.OPTIONS_VERSIONCHECK_BUTTON_TEXT);
vcButton:HookScript("OnClick", function(self)
	C_ChatInfo.SendAddonMessage("IRT_VC", "vc", "RAID");
end);

IRT_GeneralOptions:SetScript("OnShow", function(self)
	fontSlider:SetValue(IRT_PopupTextFontSize)
	fontSizeText:SetText(IRT_PopupTextFontSize)
	Initialize_MinimapState();
	UIDropDownMenu_SetSelectedName(minimapStateMenu, IRT_MinimapMode);
end)

InterfaceOptions_AddCategory(IRT_GeneralOptions)