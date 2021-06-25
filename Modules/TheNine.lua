local L = IRTLocals;
local f = CreateFrame("Frame");

--Addon vars
debuffed = {};
healers = {};
raid = {};
local ticks = 0;
local inEncounter = false;
focus = nil;

local rangeList = {
	[4] = 90175,
	[6] = 37727,
	[8] = 8149,
	[10] = 3, 
	[11] = 2, 
	[13] = 32321,
	[18] = 6450,
	[23] = 21519,
	[30] = 1, 
	[33] = 1180,
	[43] = 34471,
	[48] = 32698,
};

local meleeSpecIDs = {
	[103] = true,
	[255] = true,
	[263] = true,
};

local rolePrio = {
	[1] = "melee",
	[2] = "ranged",
	[3] = "healer",
};

local assignments = {};

--Player vars
local currentStatus = nil;
local playerName = GetUnitName("player", true);

--debug
local printdebug = true;

--Cache
local IRT_UnitDebuff = IRT_UnitDebuff;
local IRT_Contains = IRT_Contains;
local CheckInteractDistance = CheckInteractDistance;
local IsItemInRange = IsItemInRange;
local UnitIsUnit = UnitIsUnit;
local Ambiguate = Ambiguate;
local UnitIsConnected = UnitIsConnected;
local UnitIsVisible = UnitIsVisible;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_NINE");

local function initHealers()
	for i = 1, GetNumGroupMembers() do
		local raider = "raid" .. i;
		if (UnitIsVisible(raider)) then
			local role = UnitGroupRolesAssigned(raider);
			if (role == "HEALER") then
				local raiderName = GetUnitName(raider, true);
				healers[raiderName] = false;
			end
		end
	end
end

local function initRaid()
	local role = UnitGroupRolesAssigned("player");
	local class = select(2, UnitClass("player"));
	local spec = GetSpecialization();
	local specID = select(1, GetSpecializationInfo(spec));
	if (role == "TANK") then
		C_ChatInfo.SendAddonMessage("IRT_NINE", "tank", "RAID");
	elseif (role == "HEALER") then
		C_ChatInfo.SendAddonMessage("IRT_NINE", "tank", "RAID");
	else
		if (class == "MAGE" or class == "WARLOCK" or class == "PRIEST") then
			C_ChatInfo.SendAddonMessage("IRT_NINE", "ranged", "RAID");
		elseif (meleeSpecIDs[specID] == nil) then
			C_ChatInfo.SendAddonMessage("IRT_NINE", "ranged", "RAID");
		else
			C_ChatInfo.SendAddonMessage("IRT_NINE", "melee", "RAID");
		end
	end
end

local function updateAssignments(safe)
	local text = "|cFF00FFFFIRT:|r";
	for i = 1, #assignments do
		local target = assignments[i];
		local healer = IRT_Contains(healers, target);
		local index = IRT_Contains(healers, assignments[i]);
		if (UnitIsConnected(target)) then
			target = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(target))].colorStr, target);
		end
		if (UnitIsConnected(healer)) then
			healer = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(healer))].colorStr, healer);
		end
		if (safe) then
			text = text .. "\n|cFFFFFFFF" .. i .. ".|r |cFF00FF00SAFE|r " .. healer .. " -> " .. target;
		else
			text = text .. "\n|cFFFFFFFF" .. i .. ".|r |cFFFF0000UNSAFE|r " .. healer .. " -> " .. target;
		end
	end
	IRT_InfoBoxShow(text, 60);
end

local function assignDispels()
	--check if healer is debuffed 
	for k, v in pairs(healers) do
		local healer = k;
		if (IRT_Contains(debuffed, healer)) then
			if (printdebug) then
				print(healer .. " got assigned themselves");
			end
			healers[healer] = healer;
		end
	end
	for i = 1, #debuffed do
		if (not IRT_Contains(healers, debuffed[i])) then
			for k, v in pairs(healers) do
				if (v == false) then
					if (printdebug) then
						print(k .. " got assigned " .. debuffed[i]);
					end
					healers[k] = debuffed[i];
					break;
				end
			end
		end
	end
	for i = 1, 3 do
		for j = 1, #debuffed do
			local player = debuffed[j];
			if (raid[player] == rolePrio[i]) then
				if (focus == nil) then
					focus = player;
				end
				if (printdebug) then
					print(player .. " got priority " .. #assignments+1);
				end
				assignments[#assignments+1] = player;
			end
		end
	end
	updateAssignments(false);
end


f:SetScript("OnUpdate", function(self, elapsed)
	ticks = ticks + elapsed;
	if (ticks > 0.05 and focus and UnitIsUnit(focus, "player")) then
		local safe = true;
		local partner = false;
		for range, check in pairs(rangeList) do
			partner = false;
			safe = true;
			for j = 1, GetNumGroupMembers() do
				local raider = "raid" .. j;
				if (UnitIsVisible(raider)) then
					if (check == 1 or check == 2 or check == 3) then
						if (CheckInteractDistance(raider, check)) then
							if (IRT_Contains(debuffed, GetUnitName(raider, true))) then
								partner = true;
							else
								safe = false;
								break;
							end
						end
					else
						if (IsItemInRange(raider, check)) then
							if (IRT_Contains(debuffed, GetUnitName(raider, true))) then
								partner = true;
							else
								safe = false;
								break;
							end
						end
					end
				end
			end
			if (safe and partner and not currentStatus) then
				C_ChatInfo.SendAddonMessage("IRT_Nine", "safe", "RAID");
				break;
			end
		end
		if (currentStatus and (not safe or not partner)) then
			C_ChatInfo.SendAddonMessage("IRT_Nine", "unsafe", "RAID");
		end
		ticks = 0;
	end
end);

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_TheNineEnabled == nil) then IRT_TheNineEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON") then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_NINE") then
			if (msg == "safe") then
				updateAssignments(true);
				for healer, target in pairs(healers) do
					if (UnitIsUnit(target, sender)) then
						if (UnitIsUnit(healer, "player")) then
							if (UnitIsConnected(target)) then
								target = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(target))].colorStr, target);
							end
							IRT_PopupShow("\124cFF00FF00Dispel\124r " .. target);
						end
					end
				end
			elseif (msg == "unsafe") then
				updateAssignments(false);
				for healer, target in pairs(healers) do
					if (UnitIsUnit(target, sender)) then
						if (UnitIsUnit(healer, "player")) then
							IRT_PopupHide(L.BOSS_FILE);
						end
					end
				end
			else
				table.insert(raid[sender], msg);
			end
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
		unitTarget, castGUID, spellID = ...;
		if (spellID == 350542) then
			C_Timer.After(0.3, function() 
				assignDispels();
			end);
		end
	elseif (event == "UNIT_AURA") then
		local unit = ...;
		local name = GetUnitName(unit, true);
		if (IRT_UnitDebuff(unit, GetSpellInfo(350542))) then
			if (not IRT_Contains(debuffed, name)) then
				debuffed[#debuffed+1] = name;
				if (UnitIsUnit(unit, "player")) then
					currentStatus = false;
				end
			end
		elseif (IRT_Contains(debuffed, name)) then
			for k, v in pairs(healers) do
				if (v == name) then
					healers[k] = nil;
					break;
				end
			end
			if (UnitIsUnit(unit, "player")) then
				currentStatus = nil;
			end
			table.remove(assignments, 1);
			debuffed[name] = nil;
			if (#debuffed == 0) then
				focus = nil;
				IRT_InfoBoxHide();
			else
				focus = assignments[1];
			end
		end
	elseif (event == "ENCOUNTER_START") then
		difficulty = select(3, GetInstanceInfo());
		initHealers();
	elseif (event == "ENCOUNTER_END") then
	end
end);

function TN_Test()
	raid = {
		["Pred"] = "tank",
		["Nost"] = "tank",
		["Marie"] = "healer",
		["Natu"] = "healer",
		["Janga"] = "healer",
		["Warlee"] = "healer",
		["Ala"] = "ranged",
		["Ant"] = "ranged",
		["Blink"] = "ranged",
		["Fed"] = "ranged",
		["Cakk"] = "ranged",
		["Maev"] = "ranged",
		["Mvk"] = "ranged",
		["Sloni"] = "ranged",
		["Sejuka"] = "ranged",
		["Emnity"] = "ranged",
		["Bram"] = "melee",
		["Dez"] = "melee",
		["Sloxy"] = "melee",
		["Cata"] = "melee",		
	};
	healers = {
		["Marie"] = false,
		["Natu"] = false,
		["Janga"] = false,
		["Warlee"] = false,
	};
	assignments = {};
	debuffed = {};
	focus = nil;
	for i = 1, 4 do
		local player = nil;
		local rng = math.random(1, 20);
		local count = 1;
		for k, v in pairs(raid) do
			if (rng == count) then
				player = k;
			end
			count = count + 1;
		end
		while (IRT_Contains(debuffed, player)) do
			local rng = math.random(1, 20);
			local count = 1;
			for k, v in pairs(raid) do
				if (rng == count) then
					player = k;
				end
				count = count + 1;
			end
		end
		debuffed[#debuffed+1] = player;
	end
	print("debuffed:")
	for i = 1, #debuffed do
		print(debuffed[i]);
	end
	assignDispels();
end