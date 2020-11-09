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

local infoTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\cc.tga");
infoTexture:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 256, -120);
infoTexture:SetSize(256, 72);
infoTexture:SetTexCoord(0,1,0,0.56);

local autoKitTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoKitTexture:SetTexture("Interface\\Icons\\inv_leatherworking_armorpatch_heavy");
autoKitTexture:SetPoint("RIGHT", infoTexture, "RIGHT", 35, 12);
autoKitTexture:SetSize(25, 25);

local autoOilTexture = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
autoOilTexture:SetTexture("Interface\\Icons\\inv_misc_potionseta");
autoOilTexture:SetPoint("RIGHT", infoTexture, "RIGHT", 35, -18);
autoOilTexture:SetSize(25, 25);

local infoTexture2 = IRT_ConsumableCheckOptions:CreateTexture(nil, "BACKGROUND");
infoTexture2:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\cc2.tga");
infoTexture2:SetPoint("TOPLEFT", infoTexture, "TOPLEFT", -15, -79);
infoTexture2:SetSize(288, 28);
infoTexture2:SetTexCoord(0,0.56,0,0.88);

local previewTextureText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
previewTextureText:SetPoint("TOP", infoTexture2, "TOP", 0, -10);
previewTextureText:SetText(L.OPTIONS_CONSUMABLECHECK_PREVIEW);
previewTextureText:SetJustifyH("CENTER");
previewTextureText:SetJustifyV("TOP");
previewTextureText:SetFont(previewTextureText:GetFont(), 10);

local buffIconIDs = {
	["MAGE"] = 135932, 
	["PRIEST"] = 135987, 
	["WARRIOR"] = 132333,
};

local function updatePreview()
	if (IRT_ConsumableAutoButtonsEnabled) then
		autoKitTexture:Show();
		autoOilTexture:Show();
	else
		autoKitTexture:Hide();
		autoOilTexture:Hide();
	end
	local text = "";
	local isEmpty = true;
	if (IRT_ConsumablesEnabled["Flask"]) then
		text = text .. "|T2057568:16|t|cFF00FF00132min|r ";
		isEmpty = false;
	end
	if (IRT_ConsumablesEnabled["Oil"]) then
		text = text .. "|T463543:16|t|cFF00FF0057min|r ";
		isEmpty = false;
	end
	if (IRT_ConsumablesEnabled["ArmorKit"]) then
		text = text .. "|T3528447:16|t|cFF00FF002hrs|r ";
		isEmpty = false;
	end
	if (IRT_ConsumablesEnabled["Food"]) then
		text = text .. "|T136000:16|t|TInterface\\addons\\InfiniteRaidTools\\Res\\check:16|t ";
		isEmpty = false;
	end
	if (IRT_ConsumablesEnabled["AugmentRune"]) then
		text = text .. "|T134078:16|t|TInterface\\addons\\InfiniteRaidTools\\Res\\cross:16|t ";
		isEmpty = false;
	end
	if (IRT_ConsumablesEnabled["Buff"]) then
		local class = select(2, UnitClass("player"));
		if (class == "MAGE" or class == "PRIEST" or class == "WARRIOR") then
			text = text .. "|T" .. buffIconIDs[class] .. ":16|t|cFF00FF0020/20|r ";
			isEmpty = false;
		end
	end
	if (isEmpty) then
		infoTexture2:Hide();
	else
		infoTexture2:Show();
	end

	previewTextureText:SetText(text);
		--132min 57min 2hrs check cross 20/20
end

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
	updatePreview();
end);

local senderReadyCheckText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
senderReadyCheckText:SetPoint("TOPLEFT", senderReadyCheckButton, "TOPLEFT", 30, -7);
senderReadyCheckText:SetText(L.OPTIONS_CONSUMABLECHECK_SENDERREADYCHECK_TEXT);

local autoButton = CreateFrame("CheckButton", "IRT_AutoCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
autoButton:SetSize(26, 26);
autoButton:SetPoint("TOPLEFT", senderReadyCheckButton, "TOPLEFT", 0, -110);
autoButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumableAutoButtonsEnabled = true;
		PlaySound(856);
	else
		IRT_ConsumableAutoButtonsEnabled = false;
		PlaySound(857);
	end
	updatePreview();
end);

local autoText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
autoText:SetPoint("TOPLEFT", autoButton, "TOPLEFT", 30, -7);
autoText:SetText(L.OPTIONS_CONSUMABLECHECK_AUTOBUTTONS_TEXT);

local flaskButton = CreateFrame("CheckButton", "IRT_FlaskCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
flaskButton:SetSize(26, 26);
flaskButton:SetPoint("TOPLEFT", autoButton, "TOPLEFT", 0, -20);
flaskButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["Flask"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["Flask"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local flaskText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
flaskText:SetPoint("TOPLEFT", flaskButton, "TOPLEFT", 30, -7);
flaskText:SetText(L.OPTIONS_CONSUMABLECHECK_FLASK_TEXT);

local oilButton = CreateFrame("CheckButton", "IRT_OilCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
oilButton:SetSize(26, 26);
oilButton:SetPoint("TOPLEFT", flaskButton, "TOPLEFT", 0, -20);
oilButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["Oil"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["Oil"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local oilText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
oilText:SetPoint("TOPLEFT", oilButton, "TOPLEFT", 30, -7);
oilText:SetText(L.OPTIONS_CONSUMABLECHECK_OIL_TEXT);

local armorKitButton = CreateFrame("CheckButton", "IRT_ArmorKitCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
armorKitButton:SetSize(26, 26);
armorKitButton:SetPoint("TOPLEFT", oilButton, "TOPLEFT", 0, -20);
armorKitButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["ArmorKit"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["ArmorKit"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local armotKitText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
armotKitText:SetPoint("TOPLEFT", armorKitButton, "TOPLEFT", 30, -7);
armotKitText:SetText(L.OPTIONS_CONSUMABLECHECK_ARMORKIT_TEXT);

local foodButton = CreateFrame("CheckButton", "IRT_FoodCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
foodButton:SetSize(26, 26);
foodButton:SetPoint("TOPLEFT", armorKitButton, "TOPLEFT", 0, -20);
foodButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["Food"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["Food"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local foodText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
foodText:SetPoint("TOPLEFT", foodButton, "TOPLEFT", 30, -7);
foodText:SetText(L.OPTIONS_CONSUMABLECHECK_FOOD_TEXT);

local augmentRuneButton = CreateFrame("CheckButton", "IRT_AugmentRuneCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
augmentRuneButton:SetSize(26, 26);
augmentRuneButton:SetPoint("TOPLEFT", foodButton, "TOPLEFT", 0, -20);
augmentRuneButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["AugmentRune"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["AugmentRune"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local augmentRuneText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
augmentRuneText:SetPoint("TOPLEFT", augmentRuneButton, "TOPLEFT", 30, -7);
augmentRuneText:SetText(L.OPTIONS_CONSUMABLECHECK_AUGMENTRUNE_TEXT);

local buffButton = CreateFrame("CheckButton", "IRT_BuffCheckButton", IRT_ConsumableCheckOptions, "UICheckButtonTemplate");
buffButton:SetSize(26, 26);
buffButton:SetPoint("TOPLEFT", augmentRuneButton, "TOPLEFT", 0, -20);
buffButton:HookScript("OnClick", function(self)
	if (self:GetChecked()) then
		IRT_ConsumablesEnabled["Buff"] = true;
		PlaySound(856);
	else
		IRT_ConsumablesEnabled["Buff"] = false;
		PlaySound(857);
	end
	updatePreview();
end);

local buffText = IRT_ConsumableCheckOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
buffText:SetPoint("TOPLEFT", buffButton, "TOPLEFT", 30, -7);
buffText:SetText(L.OPTIONS_CONSUMABLECHECK_BUFF_TEXT);

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
	flaskButton:SetChecked(IRT_ConsumablesEnabled["Flask"]);
	oilButton:SetChecked(IRT_ConsumablesEnabled["Oil"]);
	armorKitButton:SetChecked(IRT_ConsumablesEnabled["ArmorKit"]);
	foodButton:SetChecked(IRT_ConsumablesEnabled["Food"]);
	augmentRuneButton:SetChecked(IRT_ConsumablesEnabled["AugmentRune"]);
	buffButton:SetChecked(IRT_ConsumablesEnabled["Buff"]);
	updatePreview();
end);

InterfaceOptions_AddCategory(IRT_ConsumableCheckOptions);