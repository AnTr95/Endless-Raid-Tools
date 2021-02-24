local L = IRTLocals;
local f = CreateFrame("Frame");

local inEncounter = false;
local healers = {};
local debuffed = {};
local playerName = GetUnitName("player", true);
local assignments = {};
local countdown = -1;
local currentDispelled = {};
local timer = nil;
local printDebug = false;

local IRT_UnitDebuff = IRT_UnitDebuff;
local IRT_Contains = IRT_Contains;
local UnitIsVisible = UnitIsVisible;
local UnitIsUnit = UnitIsUnit;
local Ambiguate = Ambiguate;
local UnitIsConnected = UnitIsConnected;

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("PLAYER_LOGIN");

function IRT_SLG_Debug()
	if (printDebug) then
		printDebug = false;
	else
		printDebug = true;
	end
end

local function initHealers()
	if (printDebug) then
		print("initating healers: ")
	end
	healers = {};
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		local raiderName = GetUnitName(raider, true);
		if (UnitIsVisible(raider) and UnitIsConnected(raider)) then
			local role = UnitGroupRolesAssigned(raider);
			if (role == "HEALER") then
				if (printDebug) then
					print("Healer found: " .. raiderName)
				end
				table.insert(healers, raiderName);
			end
		end
	end
end

local function updateDispelText()
	local text = "|cFF00FFFFIRT:|r |cFFFFFFFFHeart Rend|r";
	local count = 1;
	for pl, healer in pairs(assignments) do
		pl = Ambiguate(pl, "short");
		if (UnitIsConnected(pl)) then
			pl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, pl);
		end
		if (UnitIsUnit(healer, playerName) and countdown == -1 and count == 1) then
			IRT_PopupShow("Dispel " .. pl, 36, L.BOSS_FILE);
		end
		healer = Ambiguate(healer, "short");
		if (UnitIsConnected(healer)) then
			healer = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(healer))].colorStr, healer);
		end
		text = text .. "\n" .. count .. ". " .. healer .. " -> " .. pl;
		if (count == 1 and countdown ~= -1) then
			text = text .. " " .. countdown .. "s";
		end
		count = count + 1;
	end
	if (next(assignments)) then
		IRT_InfoBoxShow(text, 36);
	else
		IRT_InfoBoxHide();
		if (timer) then
			timer:Cancel();
			timer = nil;
			countdown = -1;
		end
	end
end

local function assignDispels()
	if (printDebug) then
		print("Assigning healers to debuffed healers: ");
	end
	assignments = {};
	for i, pl in pairs(debuffed) do -- ensure healers dont dispel themselves
		for j, healer in pairs(healers) do
			if (IRT_Contains(healers, pl) and not UnitIsUnit(pl, healer)) then
				if (printDebug) then
					print(healer .. " got assigned to dispel " .. pl)
				end
				assignments[pl] = healer;
				break;
			end
		end
	end
	if (printDebug) then
		print("assigning healers to debuffed dps")
	end
	for i, pl in pairs(debuffed) do
		if (not IRT_ContainsKey(assignments, pl)) then
			for j, healer in pairs(healers) do
				if (not IRT_Contains(assignments, healer)) then
					if (printDebug) then
						print(healer .. " got assigned to dispel " .. pl)
					end
					assignments[pl] = healer;
					break;
				end
			end
		end
	end
	updateDispelText();
end


f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_StoneLegionGeneralsEnabled == nil) then IRT_StoneLegionGeneralsEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter and IRT_StoneLegionGeneralsEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (IRT_UnitDebuff(unit, GetSpellInfo(334765))) then
			if (not IRT_Contains(debuffed, unitName)) then
				if (printDebug) then
					print(unitName .. " got debuffed")
				end
				debuffed[#debuffed+1] = unitName;
				countdown = -1;
				assignDispels();
			end
		else
			if (IRT_Contains(debuffed, unitName)) then
				if (printDebug) then
					print(unitName .. " got debuffed removed")
				end
				debuffed[IRT_Contains(debuffed, unitName)] = nil;
				if (UnitIsUnit(assignments[unitName], playerName)) then
					IRT_PopupHide(L.BOSS_FILE);
				end
				assignments[unitName] = nil;
				updateDispelText();
			end
		end
		if (IRT_UnitDebuff(unit, GetSpellInfo(334771))) then
			if (not IRT_Contains(currentDispelled, unitName)) then
				if (printDebug) then
					print(unitName .. " got 2nd debuff applied starting timer")
				end
				currentDispelled[#currentDispelled+1] = unitName;
				countdown = 6;
				updateDispelText();
				if (timer) then
					timer:Cancel();
					timer = nil;
				end
				timer = C_Timer.NewTicker(1, function()
					countdown = countdown - 1;
					updateDispelText();
				end, 7);
			end
		else
			if (IRT_Contains(currentDispelled, unitName)) then
				if (printDebug) then
					print(unitName .. " got 2nd debuff removed")
				end
				currentDispelled[IRT_Contains(currentDispelled, unitName)] = nil;
				updateDispelText();
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_StoneLegionGeneralsEnabled) then
		local eID = ...;
		if (eID == 2417) then
			if (printDebug) then
				print("mythic stone legion started")
			end
			inEncounter = true;
			healers = {};
			debuffed = {};
			assignments = {};
			countdown = -1;
			currentDispelled = {};
			timer = nil;
			initHealers();
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_StoneLegionGeneralsEnabled) then
		inEncounter = false;
		healers = {};
		debuffed = {};
		assignments = {};
		countdown = -1;
		currentDispelled = {};
		timer = nil;
		IRT_InfoBoxHide();
		IRT_PopupHide(L.BOSS_FILE);
	end
end);