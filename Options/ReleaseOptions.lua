local L = IRTLocals;

IRT_ReleaseOptions = CreateFrame("Frame", "IRT_ReleaseOptionsFrame", InterfaceOptionsFramePanelContainer)
IRT_ReleaseOptions.name = "Release Module"
IRT_ReleaseOptions.parent = "|cFFFFFF00General Modules|r"
IRT_ReleaseOptions:Hide()

local title = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)
	
local tabinfo = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_RELEASE_TITLE)

local author = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = IRT_ReleaseOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(530);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(510, 200)
info:SetText(L.OPTIONS_RELEASE_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_ReleaseEnabledCheckButton", IRT_ReleaseOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ReleaseEnabled = true;
		PlaySound(856);
	else
		IRT_ReleaseEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local infoTexture = IRT_ReleaseOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\Release.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOP", 100, -70);
infoTexture:SetSize(256, 56);
infoTexture:SetTexCoord(0,1,0,0.88);

local previewText = IRT_ReleaseOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", infoTexture, "TOP", 0, 30);
previewText:SetText(L.OPTIONS_RELEASE_PREVIEW);
previewText:SetJustifyH("CENTER");

IRT_ReleaseOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_ReleaseEnabled)
end)

InterfaceOptions_AddCategory(IRT_ReleaseOptions)