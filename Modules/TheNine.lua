local L = IRTLocals;
local f = CreateFrame("Frame");

--Addon vars
local debuffed = {};
local healers = {};
local raid = {};
local ticks = 0;
local inEncounter = false;
local focus = nil;
local difficulty = 0;
local isSafe = false;

local rangeList = {90175, 37727, 8149, 3, 2, 32321, 6450, 21519, 1, 1180, 33471, 32698};

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
local printdebug = false;

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

function IRT_TN_Debug()
	if (printdebug) then
		printdebug = false;
	else
		printdebug = true;
	end
end

local function initHealers()
	if (printdebug) then
		print("healers assigned")
	end
	for i = 1, GetNumGroupMembers() do
		local raider = "raid" .. i;
		if (UnitIsVisible(raider)) then
			local role = UnitGroupRolesAssigned(raider);
			if (role == "HEALER") then
				local raiderName = GetUnitName(raider, true);
				healers[raiderName] = false;
				if (printdebug) then
					print(raiderName .. " is a healer");
				end
			end
		end
	end
end

local function initRaid()
	--problem if ppl dont have it activated?
	if (printdebug) then
		print("raid initiated")
	end
	for i = 1, GetNumGroupMembers() do
		local raider = "raid" .. i;
		if (UnitIsVisible(raider)) then
			local raiderName = GetUnitName(raider, true);
			if (printdebug) then
				print(raiderName .. " is auto melee");
			end
			raid[raiderName] = "melee";
		end
	end
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

function IRT_TN_Force()
	inEncounter = true;
	initRaid();
	initHealers();
end

local function updateAssignments()
	local text = "|cFF00FFFFIRT:|r";
	if (printdebug) then
		print("updating assignments");
	end
	for i = 1, #assignments do
		local target = assignments[i];
		local healer = IRT_Contains(healers, target);
		local index = IRT_Contains(healers, assignments[i]);
		if (printdebug) then
			print(healer .. " is assigned to " .. target);
		end
		if (target and UnitIsConnected(target)) then
			target = Ambiguate(target, "short");
			target = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(target))].colorStr, target);
		end
		if (healer and UnitIsConnected(healer)) then
			healer = Ambiguate(healer, "short");
			healer = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(healer))].colorStr, healer);
		end
		if (isSafe) then
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
	for prio, role in pairs(rolePrio) do
		for i = 1, #debuffed do
			local player = debuffed[i];
			if (raid[player] == role) then
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
	isSafe = false;
	updateAssignments();
end


f:SetScript("OnUpdate", function(self, elapsed)
	ticks = ticks + elapsed;
	if (ticks > 0.05 and focus and UnitIsUnit(focus, "player") and inEncounter) then
		local safe = true;
		local partner = false;
		for range, check in ipairs(rangeList) do
			partner = false;
			safe = true;
			for j = 1, GetNumGroupMembers() do
				local raider = "raid" .. j;
				if (UnitIsVisible(raider) and not UnitIsUnit(raider, "player")) then
					if (check == 1 or check == 2 or check == 3) then
						if (CheckInteractDistance(raider, check)) then
							if (IRT_Contains(debuffed, GetUnitName(raider, true))) then
								partner = GetUnitName(raider);
							else
								safe = false;
								break;
							end
						end
					else
						if (IsItemInRange(check, raider)) then
							if (IRT_Contains(debuffed, GetUnitName(raider, true))) then
								partner = GetUnitName(raider);
							else
								safe = false;
								break;
							end
						end
					end
				end
			end
			if (safe and partner) then
				if (not currentStatus) then
					currentStatus = true;
					C_ChatInfo.SendAddonMessage("IRT_NINE", "safe", "RAID");
				end
				break;
			end
		end
		if (currentStatus and (safe == false or safe == false)) then
			currentStatus = false;
			C_ChatInfo.SendAddonMessage("IRT_NINE", "unsafe", "RAID");
		end
		ticks = 0;
	end
end);

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_TheNineEnabled == nil) then IRT_TheNineEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and inEncounter and IRT_TheNineEnabled) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_NINE") then
			sender = Ambiguate(sender, "short");
			if (msg == "safe") then
				isSafe = true;
				updateAssignments();
				for healer, target in pairs(healers) do
					if (target and UnitIsUnit(Ambiguate(target, "short"), sender)) then
						if (UnitIsUnit(Ambiguate(healer, "short"), "player")) then
							if (UnitIsConnected(target)) then
								target = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(target))].colorStr, Ambiguate(target, "short"));
							end
							IRT_PopupShow("\124cFF00FF00Dispel\124r " .. target, 60, L.BOSS_FILE);
						end
					end
				end
			elseif (msg == "unsafe") then
				isSafe = false;
				updateAssignments();
				for healer, target in pairs(healers) do
					if (target and UnitIsUnit(target, sender)) then
						if (UnitIsUnit(healer, "player")) then
							IRT_PopupHide(L.BOSS_FILE);
						end
					end
				end
			else
				raid[sender] = msg;
			end
		end
	elseif (event == "UNIT_AURA" and inEncounter and IRT_TheNineEnabled) then
		local unit = ...;
		local name = GetUnitName(unit, true);
		if (IRT_UnitDebuff(unit, GetSpellInfo(350542))) then
			if (not IRT_Contains(debuffed, name)) then
				if (printdebug) then
					print(name .. " is debuffed")
				end
				table.insert(debuffed, name);
				if (UnitIsUnit(unit, "player")) then
					currentStatus = false;
				end
				if (next(assignments)) then
					table.insert(assignments, name);
					for index, pl in pairs(debuffed) do
						if (not IRT_Contains(healers, pl)) then
							for k, v in pairs(healers) do
								if (v == false) then
									if (printdebug) then
										print(k .. " got assigned " .. pl);
									end
									healers[k] = pl;
									break;
								end
							end
						end
					end
					updateAssignments();
				else
					if (difficulty == 16) then
						if (#debuffed == 4) then 
							assignDispels();
						end
					else
						if (#debuffed == 3) then 
							assignDispels();
						end
					end
				end
			end
		elseif (IRT_Contains(debuffed, name)) then
			if (printdebug) then
				print(name .. " is no longer debuffed")
			end
			for k, v in pairs(healers) do
				if (v == name) then
					healers[k] = false;
					if (printdebug) then
						print(k .. " is now freed up");
					end
					break;
				end
			end
			if (UnitIsUnit(unit, "player")) then
				currentStatus = nil;
			end
			local containsDebuffed = IRT_Contains(debuffed, name);
			local containsAssignments = IRT_Contains(assignments, name);
			table.remove(assignments, containsAssignments);
			table.remove(debuffed, containsDebuffed);
			if (next(assignments)) then
				if (containsAssignments == 1) then
					isSafe = false;
					updateAssignments();
					focus = assignments[1];
					if (printdebug) then
						print("focus is now on " .. focus);
					end
				end
			else
				focus = nil;
				IRT_InfoBoxHide();
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_TheNineEnabled) then
		local eID = ...;
		if (eID == 2429) then
			if (printdebug) then
				print("in encounter");
			end
			difficulty = select(3, GetInstanceInfo());
			debuffed = {};
			healers = {};
			raid = {};
			focus = nil;
			assignments = {};
			currentStatus = nil;
			initRaid();
			initHealers();
			inEncounter = true;
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_TheNineEnabled) then
		debuffed = {};
		healers = {};
		raid = {};
		inEncounter = false;
		focus = nil;
		assignments = {};
		currentStatus = nil;
	end
end);

function TN_Test2()
	IRT_InfoBoxShow("\124cFF00FFFFIRT:\n\124r\124cFFFFFFFF1. \124cFF00FF00SAFE \124r\124cFFF48CBAhealer1\124r -> \124cFF3FC7EB debuffedPlayer1\n\124r\124cFFFFFFFF2. \124cFFFF0000UNSAFE \124r\124cFFFF7C0Ahealer2\124r -> \124cFFAAD372 debuffedPlayer2\n\124cFFFFFFFF2. \124cFFFF0000UNSAFE \124r\124cFF0070DDAhealer3\124r -> \124cFF8788EE debuffedPlayer3\n", 10)
end

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