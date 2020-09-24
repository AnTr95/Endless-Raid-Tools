local f = CreateFrame("Frame");

local inEncounter = false;
local healers = {};
local debuffed = {};
local playerName = GetUnitName("player", true);
local assignments = {};
local countdown = -1;
local currentDispelled = {};

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("PLAYER_LOGIN");

local function initHealers()
	healers = {};
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		local raiderName = GetUnitName(raider, true);
		if (UnitIsVisible(raider) and UnitIsConnected(raider)) then
			local role = UnitGroupRolesAssigned(raider);
			if (role == "HEALER") then
				table.insert(healers, raiderName);
			end
		end
	end
end

local function assignDispels()
	assignments = {};
	for i, pl in pairs(debuffed) do -- ensure healers dont dispel themselves
		for j, healer in pairs(healers) do
			if (EnRT_Contains(healers, pl) and not UnitIsUnit(pl, healer)) then
				assignments[pl] = healer;
				break;
			end
		end
	end
	for i, pl in pairs(debuffed) do
		if (not EnRT_ContainsKey(assignments, pl)) then
			for j, healer in pairs(healers) do
				if (not EnRT_Contains(assignments, healer)) then
					assignments[pl] = healer;
					break;
				end
			end
		end
	end
	updateDispelText();
end

local function updateDispelText()
	local text = "|cFFFFFFFFHeart Rend|r";
	local count = 1;
	for pl, healer in pairs(assignments) do
		pl = Ambiguate(pl, "short");
		pl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, pl);
		if (UnitIsUnit(healer, playerName) and countdown == -1 and count == 1) then
			EnRT_PopupShow("Dispel " .. pl, 36);
		end
		healer = Ambiguate(healer, "short");
		healer = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(healer))].colorStr, healer);
		text = text .. "\n" .. count .. ". " .. healer .. " -> " .. pl;
		if (count == 1 and countdown ~= -1) then
			text = text .. " " .. countdown .. "s";
		end
		count = count + 1;
	end
	if (text == "|cFFFFFFFFHeart Rend|r") then
		EnRT_InfoBoxHide();
	else
		EnRT_InfoBoxShow(text, 36);
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_StoneLegionGeneralsEnabled == nil) then EnRT_StoneLegionGeneralsEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter and EnRT_StoneLegionGeneralsEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (EnRT_UnitDebuff(unit, GetSpellInfo(334675))) then
			if (not EnRT_Contains(debuffed, unitName)) then
				debuffed[#debuffed+1] = unitName;
				countdown = -1;
				assignDispels();
			end
		else
			if (EnRT_Contains(debuffed, unitName)) then
				debuffed[EnRT_Contains(debuffed, unitName)] = nil;
				if (UnitIsUnit(playerName, assignments[unitName])) then
					EnRT_PopupHide();
				end
				assignments[unitName] = nil;
				updateDispelText();
			end
		end
		if (EnRT_UnitDebuff(unit, GetSpellInfo(334771))) then
			if (not EnRT_Contains(currentDispelled, unitName)) then
				currentDispelled[#currentDispelled+1] = unitName;
				countdown = 6;
				updateDispelText();
				C_Timer.NewTicker(1, function()
					countdown = countdown - 1;
					updateDispelText();
				end, 7);
			end
		else
			if (EnRT_Contains(currentDispelled, unitName)) then
				currentDispelled[EnRT_Contains(currentDispelled, unitName)] = nil;
				updateDispelText();
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_StoneLegionGeneralsEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2337 and difficulty == 16) then
			inEncounter = false;
			healers = {};
			debuffed = {};
			assignments = {};
			countdown = -1;
			currentDispelled = {};
			initHealers();
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and EnRT_StoneLegionGeneralsEnabled) then
		inEncounter = false;
		healers = {};
		debuffed = {};
		assignments = {};
		countdown = -1;
		currentDispelled = {};
		EnRT_InfoBoxHide();
	end
end);