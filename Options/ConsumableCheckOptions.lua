local L = IRTLocals;

IRT_ConsumableCheckOptions = CreateFrame("Frame", "IRT_ConsumableCheckOptionsFrame", InterfaceOptionsFramePanelContainer);
IRT_ConsumableCheckOptions.name = "Consumable Module";
IRT_ConsumableCheckOptions.parent = "|cFFFFFF00General Modules|r";
IRT_ConsumableCheckOptions:Hide();

local title = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_CONSUMABLECHECK_TITLE);

local author = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10);
version:SetText(L.OPTIONS_VERSION);

local infoBorder = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoBorder:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse.PNG");
infoBorder:SetWidth(530);
infoBorder:SetHeight(180);
infoBorder:SetTexCoord(0.11,0.89,0.24,0.76);
infoBorder:SetPoint("TOP", 0, -85);

local info = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
info:SetPoint("TOPLEFT", infoBorder, "TOPLEFT", 10, -8);
info:SetSize(510, 200);
info:SetText(L.OPTIONS_CONSUMABLECHECK_INFO);
info:SetWordWrap(true);
info:SetJustifyV("TOP");

local enabledButton = CreateFrame("CheckButton", "IRT_ConsumableCheckEnabledCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
enabledButton:SetSize(26, 26);
enabledButton:SetPoint("TOPLEFT", 30, -275);
enabledButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumableCheckEnabled = true;
		PlaySound(856);
	else
		IRT_ConsumableCheckEnabled = false;
		PlaySound(857);
	end
end);

local enabledText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7);
enabledText:SetText(L.OPTIONS_ENABLED);

local senderReadyCheckButton = CreateFrame("CheckButton", "IRT_SenderReadyCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
senderReadyCheckButton:SetSize(26, 26);
senderReadyCheckButton:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 0, -20);
senderReadyCheckButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_SenderReadyCheck = true;
		PlaySound(856);
	else
		IRT_SenderReadyCheck = false;
		PlaySound(857);
	end
end);

local senderReadyCheckText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
senderReadyCheckText:SetPoint("TOPLEFT", senderReadyCheckButton, "TOPLEFT", 30, -7);
senderReadyCheckText:SetText(L.OPTIONS_CONSUMABLECHECK_SENDERREADYCHECK_TEXT);

local infoTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ConsumableCheck1.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 170, -83);
infoTexture:SetSize(256, 72);
infoTexture:SetTexCoord(0,1,0,0.56);

local barTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
barTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ConsumableCheck2.tga");
barTexture:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", -15, -79);
barTexture:SetSize(288, 28);
barTexture:SetTexCoord(0,0.56,0,0.88);

local autoKitTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoKitTexture:SetTexture("Interface\\Icons\\inv_leatherworking_armorpatch_heavy");
autoKitTexture:SetPoint("RIGHT", infoTexture, "RIGHT", 35, 12);
autoKitTexture:SetSize(25, 25);

local autoOilTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoOilTexture:SetTexture("Interface\\Icons\\inv_misc_potionseta");
autoOilTexture:SetPoint("RIGHT", infoTexture, "RIGHT", 35, -18);
autoOilTexture:SetSize(25, 25);

local previewTextureText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewTextureText:SetPoint("TOP", barTexture, "TOP", 0, -10);
previewTextureText:SetText(L.OPTIONS_CONSUMABLECHECK_PREVIEW_BARTEXT_BUFF);
previewTextureText:SetJustifyH("CENTER");
previewTextureText:SetJustifyV("TOP");
previewTextureText:SetFont(previewTextureText:GetFont(), 10);

local infoTexture2 = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ConsumableCheck1.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", 0, -110);
infoTexture2:SetSize(256, 72);
infoTexture2:SetTexCoord(0,1,0,0.56);

local barTexture2 = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
barTexture2:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\ConsumableCheck2.tga");
barTexture2:SetPoint("TOPLEFT", infoTexture2, "TOPLEFT", -15, -79);
barTexture2:SetSize(288, 28);
barTexture2:SetTexCoord(0,0.56,0,0.88);

local autoKitTexture2 = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoKitTexture2:SetTexture("Interface\\Icons\\inv_leatherworking_armorpatch_heavy");
autoKitTexture2:SetPoint("RIGHT", infoTexture2, "RIGHT", 35, 12);
autoKitTexture2:SetSize(25, 25);

local autoOilTexture2 = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoOilTexture2:SetTexture("Interface\\Icons\\inv_misc_potionseta");
autoOilTexture2:SetPoint("RIGHT", infoTexture2, "RIGHT", 35, -18);
autoOilTexture2:SetSize(25, 25);

local previewTextureText2 = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewTextureText2:SetPoint("TOP", barTexture2, "TOP", 0, -10);
previewTextureText2:SetText(L.OPTIONS_CONSUMABLECHECK_PREVIEW_BARTEXT_NOBUFF);
previewTextureText2:SetJustifyH("CENTER");
previewTextureText2:SetJustifyV("TOP");
previewTextureText2:SetFont(previewTextureText2:GetFont(), 10);

local autoButton = CreateFrame("CheckButton", "IRT_AutoCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
autoButton:SetSize(26, 26);
autoButton:SetPoint("TOPLEFT", senderReadyCheckButton, "TOPLEFT", 0, -70);
autoButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumableAutoButtonsEnabled = true;
		autoKitTexture:Show();
		autoKitTexture2:Show();
		autoOilTexture:Show();
		autoOilTexture2:Show();
		PlaySound(856);
	else
		IRT_ConsumableAutoButtonsEnabled = false;
		autoKitTexture:Hide();
		autoKitTexture2:Hide();
		autoOilTexture:Hide();
		autoOilTexture2:Hide();
		PlaySound(857);
	end
end);

local autoText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
autoText:SetPoint("TOPLEFT", autoButton, "TOPLEFT", 30, -7);
autoText:SetText(L.OPTIONS_CONSUMABLECHECK_AUTOBUTTONS_TEXT);

local previewText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewText:SetPoint("TOP", senderReadyCheckButton, "TOP", 255, -24);
previewText:SetText(L.OPTIONS_CONSUMABLECHECK_PREVIEW);
previewText:SetJustifyH("CENTER");
previewText:SetJustifyV("TOP");
previewText:SetSize(570,40);
previewText:SetWordWrap(true);

IRT_ConsumableCheckOptions:SetScript("OnShow", function(self)
	enabledButton:SetChecked(IRT_ConsumableCheckEnabled);
	senderReadyCheckButton:SetChecked(IRT_SenderReadyCheck);
	autoButton:SetChecked(IRT_ConsumableAutoButtonsEnabled);
	if (IRT_ConsumableAutoButtonsEnabled) then
		autoKitTexture:Show();
		autoKitTexture2:Show();
		autoOilTexture:Show();
		autoOilTexture2:Show();
	else
		autoKitTexture:Hide();
		autoKitTexture2:Hide();
		autoOilTexture:Hide();
		autoOilTexture2:Hide();
	end
end);

InterfaceOptions_AddCategory(IRT_ConsumableCheckOptions);