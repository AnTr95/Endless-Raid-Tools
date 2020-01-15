local f = CreateFrame("Frame");

local inEncounter = false;
local debuffed = {};
local healers = {};
local WHITE = "\124cFFFFFFFF";
local GREEN = "\124cFF00FF00";
local YELLOW = "\124cFFFFFF00";
local RED = "\124cFFFF0000";
local colorIndex = {
	[0] = WHITE,
	[1] = GREEN,
	[2] = YELLOW,
	[3] = RED,
	[4] = RED,
	[5] = RED,
	[6] = RED,
	[7] = RED,
	[8] = RED,
	[9] = RED,
	[10] = RED,
};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_TARGET");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");

local function initHealers()
	healers = {};
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		local healer = GetUnitName(raider, true);
		if (UnitIsConnected(raider) and UnitIsVisible(raider)) then
			if (UnitGroupRolesAssigned(raider) == "HEALER") then
				healers[healer] = "";
			end
		end
	end
end

local function checkInitTargets(unit)
	local pl = GetUnitName(unit, true);
	local count = 0;
	for healer, target in pairs(healers) do
		if (target == pl) then
			count = count + 1;
		end
	end
	return count;
end

local function compare (a, b)
	return a < b;
end

local function updateTargetText()
	local array = {};
	local msg = "AMOUNT OF HEALERS TARGETING DEBUFFED PLAYERS:\n";
	for player, targeted in pairs(debuffed) do
  		array[#array+1] = player;
	end
	table.sort(array, compare);
	for i = 1, #array do
		local pl = array[i];
		local targeted = debuffed[pl];
		msg = msg .. colorIndex[targeted] .. Ambiguate(pl, "short") .. " - " .. targeted .. "\n";
	end
	EnRT_InfoBoxUpdate(msg);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if EnRT_RadenEnabled == nil then EnRT_RadenEnabled = true end
	elseif (event == "UNIT_TARGET" and EnRT_RadenEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (EnRT_Contains(healers, unitName)) then
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = healers[unitName];
				debuffed[pl] = debuffed[pl] -1; 
			end
			healers[unitName] = GetUnitName(unit.."target", true));
			if (EnRT_ContainsKey(debuffed, healers[unitName])) then
				local pl = EnRT_ContainsKey(debuffed, healers[unitName]);
				debuffed[pl] = debuffed[pl] + 1; 
			end
		end
	elseif (event == "UNIT_AURA" and EnRT_RadenEnabled) then
		local unit = ...;
		if (EnRT_UnitDebuff(unit, GetSpellInfo(316065))) then
			debuffed[GetUnitName(unit, true)] = checkInitTargets(unit);
			if (not EnRT_InfoBoxIsShown()) then
				EnRT_InfoBoxShow("AMOUNT OF HEALERS TARGETING DEBUFFED PLAYERS:\n", 30);
			end
		elseif (EnRT_ContainsKey(debuffed, GetUnitName(unit, true))) then
			debuffed[GetUnitName(unit, true)] = nil;
		end
	elseif (event == "ENCOUNTER_START" and EnRT_RadenEnabled) then
		local eID = ...;
		if (eID == 2331) then --difficulty
			inEncounter = true;
			debuffed = {};
			initHealers();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_RadenEnabled) then
		inEncounter = false;
		debuffed = {};
	end
end);