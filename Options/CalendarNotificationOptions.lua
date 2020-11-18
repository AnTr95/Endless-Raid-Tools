local L = IRTLocals;

IRT_CalendarNotificationOptions = CreateFrame("Frame", "IRT_CalendarNotificationOptionsFrame", InterfaceOptionsFramePanelContainer)
IRT_CalendarNotificationOptions.name = L.OPTIONS_CALENDARNOTIFICATION_TITLE
IRT_CalendarNotificationOptions.parent = "|cFFFFFF00General Modules|r"
IRT_CalendarNotificationOptions:Hide()

local title = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_CALENDARNOTIFICATION_TITLE)

local author = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = IRT_CalendarNotificationOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(530);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(510, 200)
info:SetText(L.OPTIONS_CALENDARNOTIFICATION_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_CalendarNotificationEnabledCheckButton", IRT_CalendarNotificationOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_CalendarNotificationEnabled = true;
		PlaySound(856);
	else
		IRT_CalendarNotificationEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_CalendarNotificationOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

IRT_CalendarNotificationOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_CalendarNotificationEnabled)
end)

InterfaceOptions_AddCategory(IRT_CalendarNotificationOptions)