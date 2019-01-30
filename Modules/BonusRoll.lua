--Todo, hook blizzards bonus roll button and make it show until either button is pressed / times out by copying the bonus roll timer
local L = EnRTLocals;
local f = CreateFrame("Frame")
local bossLex = {
	[1] = "Champion of the Light",
	[2] = "Grong",
	[3] = "Jadefire Masters",
	[4] = "Opulence",
	[5] = "Conclave of the Chosen",
	[6] = "King Rastakhan",
	[7] = "Mekkatorque",
	[8] = "Stormwall Blockade",
	[9] = "Lady Jaina Proudmoore",
};
local difficultyLex = {
	[14] = 2,
	[15] = 3,
	[16] = 4,
};
local EnRT_BR_GUI = {};
local bonusRolls = 0;
local spent = 0;
local isLockMode = false;
local currentCurrencyID = 1580;
local currentSpellID = 257902;

EnRT_BR_Settings = CreateFrame("Frame");
EnRT_BR_Settings:SetPoint("CENTER");
EnRT_BR_Settings:SetSize(270, 270);
EnRT_BR_Settings:SetFrameStrata("TOOLTIP");
EnRT_BR_Settings:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
EnRT_BR_Settings:SetBackdropColor(0,0,0,1);
EnRT_BR_Settings:Hide();

local function initBLPText()
	local BLPText = BonusRollFrame.PromptFrame.InfoFrame:CreateFontString("EnRT_BLPCountString", "ARTWORK", "GameFontNormal");
	BLPText:SetText("BLP: " .. EnRT_BonusRollBLPCount .. "/6");
	BLPText:SetPoint("TOPLEFT", 65, -23);
	BLPText:SetTextColor(1,1,1);
end

f:RegisterEvent("ENCOUNTER_END")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("LOOT_ITEM_ROLL_WON")
f:RegisterEvent("SPELL_CONFIRMATION_PROMPT");
f:RegisterEvent("CHAT_MSG_LOOT");
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" and EnRT_BonusRollEnabled then
		if GetZoneText() == EnRT_BonusRollCurrentRaid then
			bonusRolls = select(2,GetCurrencyInfo(currentCurrencyID))
			if bonusRolls > 0 then
				EnRT_BR_Settings:Show()
			end
		end
	elseif event == "ENCOUNTER_END" and EnRT_BonusRollEnabled then
		local eID, eName, dID, raidSize, outcome = ...
		if EnRT_Contains2DValue(EnRT_BonusRollBosses, 1, eID) and outcome == 1 then
			local difficulty = select(3,GetInstanceInfo())
			if difficultyLex[difficulty] and EnRT_BonusRollBosses[eName][difficultyLex[difficulty]] == 1 then
				EnRT_PopupShow("\124TInterface\\Icons\\inv_misc_azsharacoin:16\124t \124cFFFFFF00 BONUS LOOT! \124TInterface\\Icons\\inv_misc_azsharacoin:16\124t", 10)
				EnRT_BonusRollBosses[eName][difficultyLex[difficulty]] = 0
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
	elseif event == "CHAT_MSG_LOOT" then
		local message, arg2, arg3, arg4, pl = ...
		if (message:find("You receive bonus loot:") and GetZoneText() == EnRT_BonusRollCurrentRaid) then
			EnRT_BonusRollBLPCount = 0;
		end
	elseif event == "SPELL_CONFIRMATION_PROMPT" and EnRT_BonusRollEnabled then
		local spellID, confirmType, text, duration, currencyID = ...;
		if (currentCurrencyID == currencyID) then
			if (EnRT_BLPCountString == nil) then
				initBLPText();
			end
			EnRT_BLPCountString:SetText("BLP: " .. EnRT_BonusRollBLPCount .. "/6");
			EnRT_BLPCountString:Show();
		end
	elseif event == "PLAYER_LOGIN" then
		if EnRT_BonusRollBosses == nil then EnRT_BR_ArrayInit() end
		if EnRT_BonusRollEnabled == nil then EnRT_BonusRollEnabled = true end
		if EnRT_BonusRollCurrentRaid == nil then EnRT_BonusRollCurrentRaid = "Battle of Dazar'alor" end
		if EnRT_BonusRollBLPCount == nil then EnRT_BonusRollBLPCount = 0 end;
		EnRT_BR_CheckLatestRaid()
		EnRT_BR_GUIInit()
		if (UnitFactionGroup("player") == "Alliance") then
			bossLex[2] = "Jadefire Masters";
			bossLex[3] = "Grong";
		end
	end
end)

function EnRT_Contains2DValue(arr, index, value)
	if value == nil or arr == nil or index == nil then
		return false
	end
	for k, v in pairs(arr) do
		if v[index] == nil then
			return false
		else
			if v[index] == value then
				return k
			end
		end
	end
	return false
end

function EnRT_BR_ArrayInit()
	--2032,2048,2036,2050,2037,2054,2052,2038,2051 ToS
	--2076,2074,2070,2064,2075,2082,2088,2069,2073,2063,2092 Antorus
	--2265,2263,2266,2271,2268,2272,2276,2280,2281 BoD
	EnRT_BonusRollBosses = {
		["Champion of the Light"] = {2265,0,0,0},
		["Grong"] = {2263,0,0,0},
		["Jadefire Masters"] = {2266,0,0,0},
		["Opulence"] = {2271,0,0,0},
		["Conclave of the Chosen"] = {2268,0,0,0},
		["King Rastakhan"] = {2272,0,0,0},
		["High Tinker Mekkatorque"] = {2276,0,0,0},
		["Stormwall Blockade"] = {2280,0,0,0},
		["Lady Jaina Proudmoore"] = {2281,0,0,0},
	}

end
function EnRT_BR_GUIInit()
	EnRT_BR_CalculateSize()
	local diffs = {[1] = "N", [2] = "H", [3] = "M"}
	local title = EnRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -10)
	title:SetText(L.OPTIONS_TITLE)
	EnRT_BR_GUI["title"] = title
	for k,v in pairs(diffs) do
		local diffText = EnRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		diffText:SetPoint("TOPLEFT", 18+(30*(k-1)), -35)
		diffText:SetText(v)
		EnRT_BR_GUI["diff"..v] = diffText
	end
	local infoText = EnRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	infoText:SetPoint("TOPLEFT", 100, -35)
	infoText:SetText(L.BONUSROLL_INFO)
	EnRT_BR_GUI["infoText"] = info
	for i = 1, #bossLex do
		local bossName = bossLex[i]
		data = EnRT_BonusRollBosses[bossName]
		local bossText = EnRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		bossText:SetPoint("TOPLEFT", 100, -35-(20*i))
		bossText:SetText("|cFFFFFFFF"..bossName)
		EnRT_BR_GUI[bossName] = bossText
		for j = 1, 3 do
			local bossDifButton = CreateFrame("CheckButton", "EnRT_BR_"..bossName..j, EnRT_BR_Settings, "UICheckButtonTemplate")
			bossDifButton:SetPoint("TOPLEFT", bossText, "TOPLEFT", -90+(30*(j-1)),5)
			bossDifButton:SetSize(26,26)
			bossDifButton:HookScript("OnClick", function(self)
				if self:GetChecked() then
					EnRT_BonusRollBosses[bossName][j+1] = 1
					spent = spent + 1
					if spent >= bonusRolls and not isLockMode then
						EnRT_BR_Lock()
					end
					EnRT_BR_UpdateCoinText()
				else
					EnRT_BonusRollBosses[bossName][j+1] = 0
					spent = spent - 1
					if spent < bonusRolls and isLockMode then
						EnRT_BR_Unlock()
					end
					if isLockMode then
						bossDifButton:Disable()
					end
					EnRT_BR_UpdateCoinText()
				end
			end)
			EnRT_BR_GUI[bossName..j] = bossDifButton
		end
	end
	local coinText = EnRT_BR_Settings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	coinText:SetPoint("BOTTOM", 0, 40)
	coinText:SetText("Remaining Coins: "..bonusRolls-spent)
	coinText:SetTextColor(0,1,0)
	EnRT_BR_GUI["coinText"] = coinText
	local closeButton = CreateFrame("Button", "EnRT_BR_CloseButton", EnRT_BR_Settings, "UIPanelButtonTemplate")
	closeButton:SetText("Save")
	closeButton:SetSize(120, 25)
	closeButton:SetPoint("BOTTOM", 0, 10)
	closeButton:HookScript("OnClick", function(self)
		EnRT_BR_Settings:Hide()
	end)
	EnRT_BR_GUI["closeButton"] = closeButton
end
EnRT_BR_Settings:SetScript("OnShow", function(self)
	spent = 0
	for bossName, data in pairs(EnRT_BonusRollBosses) do
		for i = 1, 3 do
			if data[i+1] == 1 then
				EnRT_BR_GUI[bossName..i]:SetChecked(true)
				spent = spent + 1
			else
				EnRT_BR_GUI[bossName..i]:SetChecked(false)
			end
		end
	end
	EnRT_BR_UpdateCoinText()
	if spent >= bonusRolls then
		EnRT_BR_Lock()
	end
end)
function EnRT_BR_Lock()
	for bossName, data in pairs(EnRT_BonusRollBosses) do
		for i = 1, 3 do
			if data[i+1] == 0 then
				EnRT_BR_GUI[bossName..i]:Disable()
			end
		end
	end
	isLockMode = true
end
function EnRT_BR_Unlock()
	for bossName, data in pairs(EnRT_BonusRollBosses) do
		for i = 1, 3 do
			EnRT_BR_GUI[bossName..i]:Enable()
		end
	end
	isLockMode = false
end
function EnRT_BR_UpdateCoinText()
	bonusRolls = select(2,GetCurrencyInfo(currentCurrencyID))
	EnRT_BR_GUI["coinText"]:SetText("Remaining Coins: "..bonusRolls-spent);
end
function EnRT_BR_CheckLatestRaid()
	if (EnRT_BonusRollCurrentRaid ~= "Battle of Dazar'alor") then
		EnRT_BonusRollCurrentRaid = "Battle of Dazar'alor"
		EnRT_BR_ArrayInit()
	end
end
function EnRT_BR_CalculateSize()
	local sum = 20 + 20 + (#bossLex*20) + 35 + 30 --Title + Difficulty + Bosses*20 + Coin Text + Save Button
	EnRT_BR_Settings:SetSize(270, sum)
end

BonusRollFrame.PromptFrame.InfoFrame:HookScript("OnHide", function()
	if (EnRT_BLPCountString) then
		EnRT_BLPCountString:Hide();
	end
end)
--[[
BonusRollFrame.PromptFrame.RollButton:HookScript("OnClick", function() 
	EnRT_BonusRollBLPCount = EnRT_BonusRollBLPCount + 1;
	EnRT_BLPCountString:SetText("BLP: " .. EnRT_BonusRollBLPCount .. "/7");
end)]]

hooksecurefunc("AcceptSpellConfirmationPrompt", function(...)
	local spellID = ...;
	if (GetZoneText() == EnRT_BonusRollCurrentRaid) then
		EnRT_BonusRollBLPCount = EnRT_BonusRollBLPCount + 1;
		--EnRT_BLPCountString:SetText("BLP: " .. EnRT_BonusRollBLPCount .. "/6");
	end
end);

--257902 SPELLID for bonusroll in uldir

--SPELL_CONFIRMATION_PROMPT "SPELL_CONFIRMATION_PROMPT", spellID, confirmType, text, duration, currencyID
