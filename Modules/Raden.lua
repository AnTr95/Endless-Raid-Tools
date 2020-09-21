local f = CreateFrame("Frame");

local inEncounter = false;
local debuffed = {};
local healers = {};
local WHITE = "\124cFFFFFFFF";
local GREEN = "\124cFF00FF00";
local YELLOW = "\124cFFFFFF00";
local RED = "\124cFFFF0000";

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_AURA");
--f:RegisterEvent("UNIT_TARGET");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
f:RegisterEvent("UNIT_SPELLCAST_START");
f:RegisterEvent("UNIT_SPELLCAST_STOP");
f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");

local function initHealers()
	healers = {};
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		local healer = GetUnitName(raider, true);
		if (UnitIsConnected(raider) and UnitIsVisible(raider)) then
			if (UnitGroupRolesAssigned(raider) == "HEALER") then
				healers[#healers+1] = healer;
			end
		end
	end
end

local function checkInitTargets(unit)
	local pl = GetUnitName(unit, true);
	local incHeal = 0;
	for i = 1, #healers do
		if (GetUnitName("player") == healers[i]) then
			incHeal = incHeal + UnitGetIncomingHeals(pl, healers[i]);
		end
	end
	return incHeal;
end

local function compare (a, b)
	return a < b;
end

local function updateTargetText()
	local array = {};
	local msg = "Player - Incoming Heals (excl. yours):\n";
	for player, heal in pairs(debuffed) do
  		array[#array+1] = player;
	end
	table.sort(array, compare);
	for i = 1, #array do
		local pl = array[i];
		local heals = debuffed[pl];
		local hp = UnitHealth(pl);
		local maxHP = UnitHealthMax(pl);
		local subHP = maxHP-hp;
		local color = "";
		if (subHP < tonumber(IRT_RadenColors.RED)) then
			color = RED;
		elseif (subHP < tonumber(IRT_RadenColors.YELLOW)) then
			color = YELLOW;
		else
			color = GREEN;
		end
		local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, Ambiguate(pl, "short"));
		msg = msg .. name .. WHITE .. " - " .. color .. heals .. "\n";
	end	
	IRT_InfoBoxUpdate(msg);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if IRT_RadenEnabled == nil then IRT_RadenEnabled = true; end
		if IRT_RadenColors == nil then IRT_RadenColors = {}; end
		if IRT_RadenColors.RED == nil then IRT_RadenColors.RED = 50000; end
		if IRT_RadenColors.YELLOW == nil then IRT_RadenColors.YELLOW = 100000; end
	--[[
	elseif (event == "UNIT_TARGET" and IRT_RadenEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (IRT_Contains(healers, unitName)) then
			if (IRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = healers[unitName];
				debuffed[pl] = debuffed[pl] -1; 
			end
			healers[unitName] = GetUnitName(unit.."target", true);
			if (IRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = IRT_ContainsKey(debuffed, healers[unitName]);
				debuffed[pl] = debuffed[pl] + 1; 
			end
		end
	]]
	elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" and IRT_RadenEnabled and inEncounter) then
		local caster = ...;
		local unitName = GetUnitName(caster, true);
		if (IRT_Contains(healers, unitName)) then
			for pl, heals in pairs(debuffed) do
				C_Timer.After(0.1, function()
					local incHeal = UnitGetIncomingHeals(pl);
					incHeal = incHeal - UnitGetIncomingHeals(pl, GetUnitName("player"));
					debuffed[pl] = incHeal;
					updateTargetText();
				end);
				--[[
				for i = 1, #healers do
					if (GetUnitName("player") ~= healers[i]) then
							incHeal = incHeal + UnitGetIncomingHeals(pl, healers[i]);
							debuffed[pl] = incHeal;
							updateTargetText();
						end)
					end
				end]]
			end
			--[[
			if (IRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = healers[unitName];
				debuffed[pl] = debuffed[pl] -1; 
			end
			healers[unitName] = GetUnitName(unit.."target", true);
			if (IRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = IRT_ContainsKey(debuffed, healers[unitName]);
				debuffed[pl] = debuffed[pl] + 1; 
			end]]
			updateTargetText();
		end
	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" and IRT_RadenEnabled and inEncounter) then
		local caster = ...;
	elseif (event == "UNIT_AURA" and IRT_RadenEnabled and inEncounter) then
		local unit = ...;
		if (IRT_UnitDebuff(unit, GetSpellInfo(316065)) and not IRT_ContainsKey(debuffed, GetUnitName(unit, true))) then
			debuffed[GetUnitName(unit, true)] = checkInitTargets(unit);
			if (not IRT_InfoBoxIsShown()) then
				IRT_InfoBoxShow("Player - Incoming Heals (excl. yours):\n", 30);
			end
			updateTargetText();
		elseif (not IRT_UnitDebuff(unit, GetSpellInfo(316065)) and IRT_ContainsKey(debuffed, GetUnitName(unit, true))) then
			debuffed[GetUnitName(unit, true)] = nil;
			updateTargetText();
		end
	elseif (event == "ENCOUNTER_START" and IRT_RadenEnabled) then
		local eID = ...;
		if (eID == 2331) then --difficulty
			inEncounter = true;
			debuffed = {};
			initHealers();
		end
	elseif (event == "ENCOUNTER_END" and IRT_RadenEnabled and inEncounter) then
		inEncounter = false;
		debuffed = {};
	end
end);