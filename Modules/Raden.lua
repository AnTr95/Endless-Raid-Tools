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
		if (subHP < tonumber(EnRT_RadenColors.RED)) then
			color = RED;
		elseif (subHP < tonumber(EnRT_RadenColors.YELLOW)) then
			color = YELLOW;
		else
			color = GREEN;
		end
		msg = msg .. color .. Ambiguate(pl, "short") .. " - " .. heals .. "\n";
	end
	EnRT_InfoBoxUpdate(msg);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if EnRT_RadenEnabled == nil then EnRT_RadenEnabled = true; end
		if EnRT_RadenColors == nil then EnRT_RadenColors = {}; end
		if EnRT_RadenColors.RED == nil then EnRT_RadenColors.RED = 50000; end
		if EnRT_RadenColors.YELLOW == nil then EnRT_RadenColors.YELLOW = 100000; end
	--[[
	elseif (event == "UNIT_TARGET" and EnRT_RadenEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (EnRT_Contains(healers, unitName)) then
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = healers[unitName];
				debuffed[pl] = debuffed[pl] -1; 
			end
			healers[unitName] = GetUnitName(unit.."target", true);
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = EnRT_ContainsKey(debuffed, healers[unitName]);
				debuffed[pl] = debuffed[pl] + 1; 
			end
		end
	]]
	elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" and EnRT_RadenEnabled and inEncounter) then
		local caster = ...;
		local unitName = GetUnitName(caster, true);
		if (EnRT_Contains(healers, unitName)) then
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
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = healers[unitName];
				debuffed[pl] = debuffed[pl] -1; 
			end
			healers[unitName] = GetUnitName(unit.."target", true);
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = EnRT_ContainsKey(debuffed, healers[unitName]);
				debuffed[pl] = debuffed[pl] + 1; 
			end]]
			updateTargetText();
		end
	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" and EnRT_RadenEnabled and inEncounter) then
		local caster = ...;
	elseif (event == "UNIT_AURA" and EnRT_RadenEnabled and inEncounter) then
		local unit = ...;
		if (EnRT_UnitDeBuff(unit, GetSpellInfo(316065)) and not EnRT_ContainsKey(debuffed, GetUnitName(unit, true))) then
			debuffed[GetUnitName(unit, true)] = checkInitTargets(unit);
			if (not EnRT_InfoBoxIsShown()) then
				EnRT_InfoBoxShow("Player - Incoming Heals (excl. yours):\n", 30);
			end
			updateTargetText();
		elseif (not EnRT_UnitDebuff(unit, GetSpellInfo(316065)) and EnRT_ContainsKey(debuffed, GetUnitName(unit, true))) then
			debuffed[GetUnitName(unit, true)] = nil;
			updateTargetText();
		end
	elseif (event == "ENCOUNTER_START" and EnRT_RadenEnabled) then
		local eID = ...;
		if (eID == 2331) then --difficulty
			inEncounter = true;
			debuffed = {};
			initHealers();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_RadenEnabled and inEncounter) then
		inEncounter = false;
		debuffed = {};
	end
end);