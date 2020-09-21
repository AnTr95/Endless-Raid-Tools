local L = EnRTLocals;

EnRT_ReadyCheckOptions = CreateFrame("Frame", "EnRT_ReadyCheckOptionsFrame", InterfaceOptionsFramePanelContainer)
EnRT_ReadyCheckOptions.name = "Ready Check Module"
EnRT_ReadyCheckOptions.parent = "|cFFFFFF00General Modules|r"
EnRT_ReadyCheckOptions:Hide()

local title = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText(L.OPTIONS_TITLE)

local tabinfo = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
tabinfo:SetPoint("TOPLEFT", 16, -16)
tabinfo:SetText(L.OPTIONS_READYCHECK_TITLE)

local author = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
author:SetPoint("TOPLEFT", 450, -20)
author:SetText(L.OPTIONS_AUTHOR)

local version = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local infoBorder = EnRT_ReadyCheckOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(470);
infoBorder:SetHeight(120);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -25)
info:SetSize(450, 200)
info:SetText(L.OPTIONS_READYCHECK_INFO)
info:SetWordWrap(true)
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "EnRT_ReadyCheckEnabledCheckButton", EnRT_ReadyCheckOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -215);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		EnRT_InnervateEnabled = true;
		PlaySound(856);
	else
		EnRT_ReadyCheckEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local readyCheckListInfoTexture = EnRT_ReadyCheckOptions:CreateTexture(nil, "BACKGROUND");
readyCheckListInfoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ReadyCheckList.tga");
readyCheckListInfoTexture:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 275, -145);
readyCheckListInfoTexture:SetSize(200,200);
readyCheckListInfoTexture:SetTexCoord(0,1,0,1);

local readyCheckButtonInfoTexture = EnRT_ReadyCheckOptions:CreateTexture(nil, "BACKGROUND");
readyCheckButtonInfoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ReadyCheckButton.tga");
readyCheckButtonInfoTexture:SetPoint("TOPLEFT", readyCheckListInfoTexture, "TOPLEFT", -200, 2);
readyCheckButtonInfoTexture:SetSize(180, 34);
readyCheckButtonInfoTexture:SetTexCoord(0,0.7,0,1);

local ag = readyCheckButtonInfoTexture:CreateAnimationGroup();
ag:SetLooping("REPEAT");

local aniFade = ag:CreateAnimation("Alpha");
aniFade:SetDuration(2);
aniFade:SetToAlpha(0.5);
aniFade:SetFromAlpha(1);
aniFade:SetOrder(1);

local aniAppear = ag:CreateAnimation("Alpha");
aniAppear:SetDuration(1.5);
aniAppear:SetToAlpha(1);
aniAppear:SetFromAlpha(0.5);
aniAppear:SetOrder(2);

local previewText = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", readyCheckListInfoTexture, "TOP", -130, 85);
previewText:SetText(L.OPTIONS_READYCHECK_PREVIEW);
previewText:SetJustifyH("CENTER");

local flashingButton = CreateFrame("CheckButton", "EnRT_ReadyCheckFlashingCheckButton", EnRT_ReadyCheckOptions, "UICheckButtonTemplate")
flashingButton:SetSize(26, 26)
flashingButton:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 0, -20)
flashingButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_ReadyCheckFlashing = true
		ag:Play();
		PlaySound(856)
	else
		EnRT_ReadyCheckFlashing = false
		ag:Stop();
		PlaySound(857)
	end
end)

local flashingText = EnRT_ReadyCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
flashingText:SetPoint("TOPLEFT", flashingButton, "TOPLEFT", 30, -7)
flashingText:SetText(L.OPTIONS_READYCHECK_FLASHING)
flashingText:SetJustifyH("LEFT");

EnRT_ReadyCheckOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(EnRT_ReadyCheckEnabled)
	flashingButton:SetChecked(EnRT_ReadyCheckFlashing)
	if (EnRT_ReadyCheckFlashing) then
		ag:Play();
	end
end)

InterfaceOptions_AddCategory(EnRT_ReadyCheckOptions)