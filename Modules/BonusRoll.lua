--Todo, hook blizzards bonus roll button and make it show until either button is pressed / times out by copying the bonus roll timer
local L = IRTLocals;
local f = CreateFrame("Frame");
local bossLex = {
	[1] = "Wrathion",
	[2] = "Maut",
	[3] = "Prophet Skitra",
	[4] = "Dark Inquisitor Xanesh",
	[5] = "The Hivemind",
	[6] = "Shad'har the Insatiable",
	[7] = "Drest'agath",
	[8] = "Vexiona",
	[9] = "Ra-den the Despoiled",
	[10] = "Il'gynoth, Corruption Reborn",
	[11] = "Carapace of N'Zoth",
	[12] = "N'Zoth the Corruptor",
};
local difficultyLex = {
	[14] = 2,
	[15] = 3,
	[16] = 4,
};
local IRT_BR_GUI = {};
local bonusRolls = 0;
local spent = 0;
local isLockMode = false;
local currentCurrencyID = 1580;
local currentSpellID = 259702;

IRT_BR_Settings = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
IRT_BR_Settings:SetPoint("CENTER");
IRT_BR_Settings:SetSize(270, 270);
IRT_BR_Settings:SetFrameStrata("TOOLTIP");
IRT_BR_Settings:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
IRT_BR_Settings:SetBackdropColor(0,0,0,1);
IRT_BR_Settings:SetMovable(false);
IRT_BR_Settings:EnableMouse(false);
IRT_BR_Settings:RegisterForDrag("LeftButton");
IRT_BR_Settings:SetScript("OnDragStart", IRT_BR_Settings.StartMoving);
IRT_BR_Settings:SetScript("OnDragStop", IRT_BR_Settings.StopMovingOrSizing);
IRT_BR_Settings:Hide();

local function initBLPText()
	local BLPText = BonusRollFrame.PromptFrame.InfoFrame:CreateFontString("IRT_BLPCountString", "ARTWORK", "GameFontNormal");
	BLPText:SetText("BLP: " .. IRT_BonusRollBLPCount .. "/6");
	BLPText:SetPoint("TOPLEFT", 65, -23);
	BLPText:SetTextColor(1, 1, 1);
end

f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("ZONE_CHANGED_NEW_AREA");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("LOOT_ITEM_ROLL_WON");
f:RegisterEvent("SPELL_CONFIRMATION_PROMPT");
f:RegisterEvent("CHAT_MSG_LOOT");
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "ZONE_CHANGED_NEW_AREA" and IRT_BonusRollEnabled) then
		if (GetZoneText() == IRT_BonusRollCurrentRaid) then
			bonusRolls = C_CurrencyInfo.GetCurrencyInfo(currentCurrencyID).quantity;
			if (bonusRolls > 0) then
				IRT_BR_Settings:Show();
			end
		end
	elseif (event == "ENCOUNTER_END" and IRT_BonusRollEnabled) then
		local eID, eName, dID, raidSize, outcome = ...;
		if (IRT_Contains2DValue(IRT_BonusRollBosses, 1, eID) and outcome == 1) then
			local difficulty = select(3,GetInstanceInfo());
			if (difficultyLex[difficulty] and IRT_BonusRollBosses[eName][difficultyLex[difficulty]] == 1) then
				IRT_PopupShow("\124TInterface\\Icons\\inv_misc_azsharacoin:16\124t \124cFFFFFF00 BONUS LOOT! \124TInterface\\Icons\\inv_misc_azsharacoin:16\124t", 10);
				IRT_BonusRollBosses[eName][difficultyLex[difficulty]] = 0;
				--BonusRollFrame.PromptFrame.InfoFrame.Cost
				--hook tooltip
				--AcceptSpellConfirmationPrompt(177539)
				--BONUS ROLL IT!!!!!!!!!!!!!!!!!! 177539 AcceptSpellConfirmationPrompt
				--[[
				/run local b = BonusRollButton or CreateFrame("Button", "BonusRollButton", nil, "SecureActionButtonTemplate") 
				b:SetAttribute("type", "click") 
				b:SetAttribute("clickbutton", BonusRollFrame.PromptFrame.RollButton)
				/click BonusRollButton
				]]
			end
		end
	elseif (event == "CHAT_MSG_LOOT") then
		local message, arg2, arg3, arg4, pl = ...;
		if (message:find("You receive bonus loot:") and GetZoneText() == IRT_BonusRollCurrentRaid) then
			IRT_BonusRollBLPCount = 0;
		end
	elseif (event == "SPELL_CONFIRMATION_PROMPT" and IRT_BonusRollEnabled) then
		local spellID, confirmType, text, duration, currencyID = ...;
		if (currentCurrencyID == currencyID) then
			if (IRT_BLPCountString == nil) then
				initBLPText();
			end
			IRT_BLPCountString:SetText("BLP: " .. IRT_BonusRollBLPCount .. "/6");
			IRT_BLPCountString:Show();
		end
	elseif (event == "PLAYER_LOGIN") then
		if (IRT_BonusRollBosses == nil) then IRT_BR_ArrayInit() end;
		if (IRT_BonusRollEnabled == nil) then IRT_BonusRollEnabled = true end;
		if (IRT_BonusRollCurrentRaid == nil) then IRT_BonusRollCurrentRaid = "Ny'alotha, the Waking City" end;
		if (IRT_BonusRollBLPCount == nil) then IRT_BonusRollBLPCount = 0 end;
		IRT_BR_CheckLatestRaid();
		IRT_BR_GUIInit();
	end
end)

function IRT_Contains2DValue(arr, index, value)
	if (value == nil or arr == nil or index == nil) then
		return false;
	end
	for k, v in pairs(arr) do
		if (v[index] == nil) then
			return false;
		else
			if (v[index] == value) then
				return k;
			end
		end
	end
	return false;
end

function IRT_BR_ArrayInit()
	--2032,2048,2036,2050,2037,2054,2052,2038,2051 ToS
	--2076,2074,2070,2064,2075,2082,2088,2069,2073,2063,2092 Antorus
	--2265,2263,2266,2271,2268,2272,2276,2280,2281 BoD
	--2329,2327,2334,2328,2333,2335,2343,2336,2331,2345,2337,2344 Nyalotha
	IRT_BonusRollBosses = {
		["Wrathion"] = {2329,0,0,0},
		["Maut"] = {2327,0,0,0},
		["Prophet Skitra"] = {2334,0,0,0},
		["Dark Inquisitor Xanesh"] = {2328,0,0,0},
		["The Hivemind"] = {2333,0,0,0},
		["Shad'har the Insatiable"] = {2335,0,0,0},
		["Drest'agath"] = {2343,0,0,0},
		["Vexiona"] = {2336,0,0,0},
		["Ra-den the Despoiled"] = {2331,0,0,0},
		["Il'gynoth, Corruption Reborn"] = {2345,0,0,0},
		["Carapace of N'Zoth"] = {2337,0,0,0},
		["N'Zoth the Corruptor"] = {2344,0,0,0},
	};
end
function IRT_BR_GUIInit()
	local diffs = {[1] = "N", [2] = "H", [3] = "M"};
	local title = IRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title:SetPoint("TOP", 0, -10);
	title:SetText(L.OPTIONS_TITLE);
	IRT_BR_GUI["title"] = title;
	for k,v in pairs(diffs) do
		local diffText = IRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
		diffText:SetPoint("TOPLEFT", 18+(30*(k-1)), -35);
		diffText:SetText(v);
		IRT_BR_GUI["diff"..v] = diffText;
	end
	local infoText = IRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	infoText:SetPoint("TOPLEFT", 100, -35);
	infoText:SetText(L.BONUSROLL_INFO);
	IRT_BR_GUI["infoText"] = info;
	for i = 1, #bossLex do
		local bossName = bossLex[i];
		data = IRT_BonusRollBosses[bossName];
		local bossText = IRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
		bossText:SetPoint("TOPLEFT", 100, -35-(20*i));
		bossText:SetText("|cFFFFFFFF"..bossName);
		IRT_BR_GUI[bossName] = bossText;
		for j = 1, 3 do
			local bossDifButton = CreateFrame("CheckButton", "IRT_BR_"..bossName..j, IRT_BR_Settings, "UICheckButtonTemplate");
			bossDifButton:SetPoint("TOPLEFT", bossText, "TOPLEFT", -90+(30*(j-1)),5);
			bossDifButton:SetSize(26,26);
			bossDifButton:HookScript("OnClick", function(self)
				if (self:GetChecked()) then
					IRT_BonusRollBosses[bossName][j+1] = 1;
					spent = spent + 1;
					if (spent >= bonusRolls and not isLockMode) then
						IRT_BR_Lock();
					end
					IRT_BR_UpdateCoinText();
				else
					IRT_BonusRollBosses[bossName][j+1] = 0;
					spent = spent - 1;
					if (spent < bonusRolls and isLockMode) then
						IRT_BR_Unlock();
					end
					if (isLockMode) then
						bossDifButton:Disable();
					end
					IRT_BR_UpdateCoinText();
				end
			end);
			IRT_BR_GUI[bossName..j] = bossDifButton;
		end
	end
	local coinText = IRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	coinText:SetPoint("BOTTOM", 0, 40);
	coinText:SetText("Remaining Coins: ".. bonusRolls - spent);
	coinText:SetTextColor(0, 1, 0);
	IRT_BR_GUI["coinText"] = coinText;
	local closeButton = CreateFrame("Button", "IRT_BR_CloseButton", IRT_BR_Settings, "UIPanelButtonTemplate");
	closeButton:SetText("Save");
	closeButton:SetSize(120, 25);
	closeButton:SetPoint("BOTTOM", 0, 10);
	closeButton:HookScript("OnClick", function(self)
		IRT_BR_Settings:Hide();
	end);
	IRT_BR_GUI["closeButton"] = closeButton;
	IRT_BR_CalculateSize();
end
IRT_BR_Settings:SetScript("OnShow", function(self)
	spent = 0;
	for bossName, data in pairs(IRT_BonusRollBosses) do
		for i = 1, 3 do
			if (data[i+1] == 1) then
				IRT_BR_GUI[bossName..i]:SetChecked(true);
				spent = spent + 1;
			else
				IRT_BR_GUI[bossName..i]:SetChecked(false);
			end
		end
	end
	IRT_BR_UpdateCoinText();
	if (spent >= bonusRolls) then
		IRT_BR_Lock();
	end
	IRT_BR_Settings:SetMovable(true);
	IRT_BR_Settings:EnableMouse(true);
end)
function IRT_BR_Lock()
	for bossName, data in pairs(IRT_BonusRollBosses) do
		for i = 1, 3 do
			if (data[i+1] == 0) then
				IRT_BR_GUI[bossName..i]:Disable();
			end
		end
	end
	isLockMode = true;
end
function IRT_BR_Unlock()
	for bossName, data in pairs(IRT_BonusRollBosses) do
		for i = 1, 3 do
			IRT_BR_GUI[bossName..i]:Enable();
		end
	end
	isLockMode = false;
end
function IRT_BR_UpdateCoinText()
	bonusRolls = C_CurrencyInfo.GetCurrencyInfo(currentCurrencyID).quantity;
	IRT_BR_GUI["coinText"]:SetText("Remaining Coins: "..bonusRolls-spent);
end
function IRT_BR_CheckLatestRaid()
	if (IRT_BonusRollBosses["N'Zoth the Corruptor"] == nil) then
		IRT_BR_ArrayInit();
	elseif (select(1, IRT_BonusRollBosses["Dark Inquisitor Xanesh"][1] == 2338)) then
		IRT_BR_ArrayInit();
	end
	if (IRT_BonusRollCurrentRaid ~= "Ny'alotha, the Waking City") then
		IRT_BonusRollCurrentRaid = "Ny'alotha, the Waking City";
		IRT_BR_ArrayInit();
	end
end
function IRT_BR_CalculateSize()
	local sum = 20 + 20 + (#bossLex*20) + 35 + 30; --Title + Difficulty + Bosses*20 + Coin Text + Save Button
	local longstr = 1;
	for boss, data in pairs(IRT_BR_GUI) do
		if (IRT_BR_GUI[boss]:GetObjectType() == "FontString") then
			local strw = IRT_BR_GUI[boss]:GetStringWidth();
			if (strw > longstr) then
				longstr = strw;
			end
		end
	end
	IRT_BR_Settings:SetSize(115+longstr, sum);
end

BonusRollFrame.PromptFrame.InfoFrame:HookScript("OnHide", function()
	if (IRT_BLPCountString) then
		IRT_BLPCountString:Hide();
	end
	IRT_BR_Settings:SetMovable(false);
	IRT_BR_Settings:EnableMouse(false);
end)
--[[
BonusRollFrame.PromptFrame.RollButton:HookScript("OnClick", function() 
	IRT_BonusRollBLPCount = IRT_BonusRollBLPCount + 1;
	IRT_BLPCountString:SetText("BLP: " .. IRT_BonusRollBLPCount .. "/7");
end)]]

hooksecurefunc("AcceptSpellConfirmationPrompt", function(...)
	local spellID = ...;
	if (GetZoneText() == IRT_BonusRollCurrentRaid) then
		IRT_BonusRollBLPCount = IRT_BonusRollBLPCount + 1;
		--IRT_BLPCountString:SetText("BLP: " .. IRT_BonusRollBLPCount .. "/6");
	end
end);

--257902 SPELLID for bonusroll in uldir

--SPELL_CONFIRMATION_PROMPT "SPELL_CONFIRMATION_PROMPT", spellID, confirmType, text, duration, currencyID
