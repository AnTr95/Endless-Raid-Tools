local L = IRTLocals;
local f = CreateFrame("Frame");
local inEncounter = false;
local assignments = {};
local targetedPlayers = {};
local hookedPlayers = {};
local leader = "";
local playerName = GetUnitName("player");
local count = 1;
local ticks = 0;
local debuffed = false;
local pair = nil;
local plMark = nil;
local hasAssigned = false;
local raid = {
	["TANK"] = {},
	["HEALER"] = {},
	["RANGED"] = {},
	["MELEE"] = {},
};

local priorityLex = {
	[1] = "TANK",
	[2] = "HEALER",
	[3] = "RANGED",
	[4] = "MELEE",
};

local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
	["4"] = "TRIANGLE",
};


local meleeLex = {
	103,
	255,
	263,
};

local IRT_UnitDebuff = IRT_UnitDebuff;
local IRT_Contains = IRT_Contains;
local UnitIsVisible = UnitIsVisible;
local UnitIsUnit = UnitIsUnit;
local Ambiguate = Ambiguate;
local UnitIsConnected = UnitIsConnected;
local strsplit = strsplit;
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo;

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_SLUDGEFIST");

local function compare(a, b)
	return a[2] < b[2];
end

local function initRaid()
	print("initating raid")
	for i = 1, GetNumGroupMembers() do
		local raider = "raid" .. i;
		local raiderName = GetUnitName(raider, true);
		if (UnitIsVisible(raiderName)) then
			local class = select(2, UnitClass(raiderName));
			local role = UnitGroupRolesAssigned(raiderName);
			if (role == "TANK") then
				print(raiderName .. " is a tank")
				table.insert(raid[role], raiderName);
			elseif (role == "HEALER") then
				print(raiderName .. " is a healer")
				table.insert(raid[role], raiderName);
			elseif (class == "WARRIOR" or class == "ROGUE" or class == "MONK" or class == "DEATHKNIGHT" or class == "DEMONHUNTER" or class == "PALADIN") then
				print(raiderName .. " is a melee dps")
				table.insert(raid["MELEE"], raiderName);
			elseif (class == "MAGE" or class == "WARLOCK" or class == "PRIEST") then
				print(raiderName .. " is a ranged dps")
				table.insert(raid["RANGED"], raiderName);
			else
				if (UnitIsConnected(raiderName)) then
					print(raiderName .. " is a hybrid dps class asking for spec")
					C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "spec", "WHISPER", raiderName);
					C_Timer.After(1, function()
						if (not IRT_Contains(raid["RANGED"], raiderName) or not IRT_Contains(raid["MELEE"], raiderName)) then
							print(raiderName .. " got no answer from " .. raiderName .. " putting them as melee")
							table.insert(raid["MELEE"], raiderName);
						end
					end);
				end
			end
		end
	end
end

local function printAssignments()
	local printText = "IRT Assignments: Fractured Boulder Soaks";
	local sortedTable = {};
	for player, mark in pairs(assignments) do
		table.insert(sortedTable, {player, mark});
	end
	table.sort(sortedTable, compare);
	for i, data in pairs(sortedTable) do
		local mark = data[2];
		local pl = Ambiguate(data[1], "short");
		if (UnitIsConnected(pl)) then
			pl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, pl);
		end
		if (i%2 == 1) then
			printText = printText .. "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_".. mark .. ":12\124t";
		end
		printText = printText .. "|cFF00FF00" .. pl .. "|r|cFFFFFFFF, |r";
	end
	print(printText);
end

local function playerNotification(mark, duration)
	print("starting player yell with mark " .. mark .. " and duration " .. duration)
	local chatText = "{rt" .. mark .. "}";
	IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration, L.BOSS_FILE);
	SendChatMessage(chatText, "YELL");
	duration = math.ceil(duration/1.5)-1;
	timer = C_Timer.NewTicker(1.5, function()
		if (UnitIsDead("player")) then
			timer:Cancel();
			timer = nil;
		else
			SendChatMessage(chatText, "YELL");
		end
	end, duration);
	PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

local function assignMarks()
	print("starting and reseting assignments")
	assignments = {};
	count = 1;
	print("messaging everyone their partner")
	for i = 1, 10 do
		if(targetedPlayers[i] and hookedPlayers[i]) then
			local pl1 = Ambiguate(targetedPlayers[i], "short");
			local pl2 = Ambiguate(hookedPlayers[i], "short");
			print(pl1 .. " is linked to " .. pl2);
			if (UnitIsConnected(pl1)) then
				C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "pair: " .. pl2, "WHISPER", pl1);
			end
			if (UnitIsConnected(pl2)) then
				C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "pair: " .. pl1, "WHISPER", pl2);
			end
		end
	end
	for i = 1, 3 do -- do not assign melee
		print("assigning " .. priorityLex[i])
		for index, player in pairs(raid[priorityLex[i]]) do
			if (not IRT_ContainsKey(assignments, player)) then
				print(player .. " found and is unassigned")
				local idx = IRT_Contains(targetedPlayers, player) or IRT_Contains(hookedPlayers, player);
				local isHooked = IRT_Contains(hookedPlayers, player);
				local chainedTo = nil;
				if (idx) then
					if (isHooked) then
						chainedTo = targetedPlayers[idx];
					else
						chainedTo = hookedPlayers[idx];
					end
					print(player .. " is linked to " .. chainedTo);
					if (chainedTo and not IRT_Contains(raid["MELEE"], chainedTo)) then
						print(chainedTo .. " is not a melee assigning them to " .. count)
						assignments[player] = count;
						assignments[chainedTo] = count;
						if (UnitIsConnected(player)) then
							C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "mark: " .. count, "WHISPER", player);
						end
						if (UnitIsConnected(chainedTo)) then
							C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "mark: " .. count, "WHISPER", chainedTo);
						end
						count = count + 1;
						if (count == 5) then
							print("all marks assigned")
							printAssignments();
							return;
						end
					end
				end
			end
		end
	end
	if (count < 5) then
		print("need to assign melee to fill")
		for i = 1, 4 do --fill with anyone
			print("assigning " .. priorityLex[i])
			for index, player in pairs(raid[priorityLex[i]]) do
				if (not IRT_ContainsKey(assignments, player)) then
					print(player .. " found and is unassigned")
					local idx = IRT_Contains(targetedPlayers, player) or IRT_Contains(hookedPlayers, player);
					local isHooked = IRT_Contains(hookedPlayers, player);
					if (idx) then
						if (isHooked) then
							local chainedTo = targetedPlayers[idx];
						else
							chainedTo = hookedPlayers[idx];
						end
						print(player .. " is linked to " .. chainedTo .. " assigning them to " .. count);
						assignments[player] = count;
						assignments[chainedTo] = count;
						if (UnitIsConnected(player)) then
							C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "mark: " .. count, "WHISPER", player);
						end
						if (UnitIsConnected(chainedTo)) then
							C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "mark: " .. count, "WHISPER", chainedTo);
						end
						count = count + 1;
						if (count == 5) then
							print("all marks assigned")
							printAssignments();
							return;
						end
					end
				end
			end
		end
	end
end

local function onUpdate(self, elapsed)
	if (debuffed and IRT_SludgefistEnabled and pair and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			local safe = false;
			if (UnitIsConnected(pair) and UnitIsVisible(pair)) then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pair))].colorStr, Ambiguate(pair, "short"));
				if (not IsItemInRange(63427, pair)) then
					if (plMark) then
						IRT_InfoBoxShow("|cFF00FFFFIRT:|r |cFFFFFFFFChain Link + Assignment:|r\n|cFFFF0000WARNING|r " .. name .. "|r |cFFFF0000> 8 yards|r\nYour mark: " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. plMark .. ":20\124t", 56);
					else
						IRT_InfoBoxShow("|cFF00FFFFIRT:|r |cFFFFFFFFChain Link + Assignment:|r\n|cFFFF0000WARNING|r " .. name .. "|r |cFFFF0000> 8 yards|r", 56);
					end
				else
					if(plMark) then
						IRT_InfoBoxShow("|cFF00FFFFIRT:|r |cFFFFFFFFChain Link + Assignment:|r\n|cFF00FF00SAFE|r " .. name .. "|r |cFF00FF00< 8 yards|r\nYour mark: " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. plMark .. ":20\124t", 56);
					else
						IRT_InfoBoxShow("|cFF00FFFFIRT:|r |cFFFFFFFFChain Link + Assignment:|r\n|cFF00FF00SAFE|r " .. name .. "|r |cFF00FF00< 8 yards|r", 56);
					end
				end
			end
			ticks = 0;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...) 
	if (event == "PLAYER_LOGIN") then
		if (IRT_SludgefistEnabled == nil) then IRT_SludgefistEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and IRT_SludgefistEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_SLUDGEFIST") then
			if (msg == "spec") then
				local spec = GetSpecialization();
				local specName = select(2, GetSpecializationInfo(spec));
				if (UnitIsConnected(leader)) then
					C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", specName, "WHISPER", leader);
				end
			elseif (msg == "notify" and plMark) then
				print("addon message notify with mark "  .. plMark)
				playerNotification(plMark, 10);
			elseif (tonumber(msg)) then
				msg = tonumber(msg);
				if (IRT_Contains(meleeLex, msg)) then
					sender = GetUnitName(sender, true);
					table.insert(raid["MELEE"], sender);
				else
					sender = GetUnitName(sender, true);
					table.insert(raid["RANGED"], sender);
				end
			else
				k, v = strsplit(" ", msg, 2);
				if (k == "mark:") then
					plMark = v;
				elseif (k == "pair:") then
					pair = v;
				end
			--	print("recived data of mark " .. plMark .. " and partner " .. pair)
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and IRT_SludgefistEnabled and inEncounter) then
		local _, logEvent, _, _, _, _, _, _, target, _, _, spellID = CombatLogGetCurrentEventInfo();
		if (UnitIsUnit(playerName, leader)) then
			if (logEvent == "SPELL_AURA_APPLIED") then
				if (spellID == 342419) then
					print(target .. " was debuffed and put in targetedPlayers")
					table.insert(targetedPlayers, target);
					if (not hasAssigned) then
						hasAssigned = true;
						print("0.1s passed assigning marks")
						C_Timer.After(0.1, function() assignMarks(); end);
					end
				elseif (spellID == 342420) then --335294?
					print(target .. " was debuffed and put in hookedPlayers")
					table.insert(hookedPlayers, target);
				elseif (spellID == 331209) then
					C_ChatInfo.SendAddonMessage("IRT_SLUDGEFIST", "notify", "RAID");
				end
			elseif (logEvent == "SPELL_AURA_REMOVED" and (spellID == 335293)) then
				local index = IRT_Contains(targetedPlayers, target);
				print(target .. " lost debuff")
				if (not index) then
					index = IRT_Contains(hookedPlayers, target);
				end
				if (index) then
					print(index .. " index found removing from both arrays")
					table.remove(hookedPlayers, index);
					table.remove(targetedPlayers, index);
				end
				if (#targetedPlayers == 0) then
					print("pre chain debuffs are out reseting assignment")
					hasAssigned = false;
				end
			end
		end
		if (target and UnitIsUnit(playerName, target)) then
			if (logEvent == "SPELL_AURA_APPLIED") then
				if (spellID == 342420) then
					debuffed = true;
					f:SetScript("OnUpdate", onUpdate);
				elseif (spellID == 342419) then --335294?
					debuffed = true;
					f:SetScript("OnUpdate", onUpdate);
				end
			elseif (logEvent == "SPELL_AURA_REMOVED" and (spellID == 335293)) then
				print("player lost debuff and resting personal data");
				f:SetScript("OnUpdate", nil);
				debuffed = false;
				pair = nil;
				plMark = nil;
				IRT_InfoBoxHide();
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_SludgefistEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2399 and difficulty == 16) then
			print("sludgefist mythic engaged")
			inEncounter = true;
			pair = nil;
			assignments = {};
			debuffed = false;
			targetedPlayers = {};
			hookedPlayers = {};
			local raid = {
				["TANK"] = {},
				["HEALER"] = {},
				["RANGED"] = {},
				["MELEE"] = {},
			};
			count = 1;
			plMark = nil;
			hasAssigned = false;
			leader = IRT_GetRaidLeader();
			initRaid();
		end
	elseif (event == "ENCOUNTER_END" and IRT_SludgefistEnabled and inEncounter) then
		inEncounter = false;
		pair = nil;
		assignments = {};
		debuffed = false;
		targetedPlayers = {};
		hookedPlayers = {};
		local raid = {
			["TANK"] = {},
			["HEALER"] = {},
			["RANGED"] = {},
			["MELEE"] = {},
		};
		count = 1;
		plMark = nil;
		hasAssigned = false;
		IRT_InfoBoxHide();
		IRT_PopupHide(L.BOSS_FILE);
	end
end);

function SF_Test()
	raid = {
		["TANK"] = {"Pred", "Nost"},
		["HEALER"] = {"Marie", "Natu", "Janga", "Warlee"},
		["RANGED"] = {"Ala", "Antv", "Blink", "Fed", "Cakk", "Antt", "Mvk", "Sloni", "Sejuka", "Emnity"},
		["MELEE"] = {"Bram", "Dez", "Sloxy", "Cata"},
	};
	assignments = {};
	targetedPlayers = {[1] = "Pred"};
	hookedPlayers = {[1] = "Nost"};
	for i = 1, 18 do
		local rngGroup = math.random(1, 4);
		local rngPlayer = math.random(1, #raid[priorityLex[rngGroup]]);
		local player = raid[priorityLex[rngGroup]][rngPlayer];
		while (player == nil or IRT_Contains(targetedPlayers, player) or IRT_Contains(hookedPlayers, player)) do
			rngGroup = math.random(1, 4);
			rngPlayer = math.random(1, #raid[priorityLex[rngGroup]]);
			player = raid[priorityLex[rngGroup]][rngPlayer];
		end
		if (i%2 == 1) then
			table.insert(targetedPlayers, player);
		else
			table.insert(hookedPlayers, player);
		end
	end
	assignMarks();
end