local L = EnRTLocals;

EnRT_CalendarNotificationOptions = CreateFrame("Frame", "EnRT_CalendarNotificationOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_CalendarNotificationOptions.name = L.OPTIONS_CALENDARNOTIFICATION_TITLE
EnRT_CalendarNotificationOptions.parent = "|cFFFFFF00General Modules|r"
EnRT_CalendarNotificationOptions:Hide()

local title = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_CALENDARNOTIFICATION_TITLE)

local author = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = EnRT_CalendarNotificationOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(470);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(450, 200)
info:SetText(L.OPTIONS_CALENDARNOTIFICATION_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_CalendarNotificationEnabledCheckButton", EnRT_CalendarNotificationOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_CalendarNotificationEnabled = true;
		PlaySound(856);
	else
		EnRT_CalendarNotificationEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

EnRT_CalendarNotificationOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_CalendarNotificationEnabled)
end)

InterfaceOptions_AddCategory(EnRT_CalendarNotificationOptions)