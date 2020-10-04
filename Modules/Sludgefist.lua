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
local plPos = nil;
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

local compareLex = {
	["LARGE AND SMALL"] = 1,
	["small"] = 2,
};

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_SLUDGEFIST");

local function compare(a, b)
	if (a[2] == b[2]) then
		return compareLex[a[3]] < compareLex[b[3]]
	else
		return a[2] < b[2];
	end
end

local function initRaid()
	for i = 1, GetNumGroupMembers() do
		local raider = raid .. i;
		local raiderName = GetUnitName(raider, true);
		if (UnitIsVisible(raiderName)) then
			local class = select(2, UnitClass(raiderName));
			local role = UnitGroupRolesAssigned(raiderName);
			if (role == "TANK") then
				table.insert(raid[role], raiderName);
			elseif (role == "HEALER") then
				table.insert(raid[role], raiderName);
			elseif (class == "WARRIOR" or class == "ROGUE" or class == "MONK" or class == "DEATHKNIGHT" or class == "DEMONHUNTER" or class == "PALADIN") then
				table.insert(raid["MELEE"], raiderName);
			elseif (class == "MAGE" or class == "WARLOCK" or class == "PRIEST") then
				table.insert(raid["RANGED"], raiderName);
			else
				if (UnitIsConnected(raiderName)) then
					C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", "spec", "WHISPER", raiderName);
				end
			end
		end
	end
end

local function printAssignments()
	local printText = "EnRT Assignments: Fractured Boulder Soaks";
	local sortedTable = {};
	for player, data in pairs(assignments) do
		table.insert(sortedTable, {player, data.mark, data.pos});
	end
	table.sort(sortedTable, compare);
	for i, data in pairs(sortedTable) do
		local mark = data[2];
		local pl = Ambiguate(data[1], "short");
		if (i%2 == 1) then
			printText = printText .. "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_".. mark .. ":12\124t";
		end
		printText = printText .. "|cFF00FF00" .. pl .. "|r|cFFFFFFFF, |r";
	end
	print(printText);
end

local function playerNotification(mark, pos, duration)
	local chatText = "{rt" .. mark .. "} " .. pos .. " {rt" .. mark .. "}";
	EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. ", " .. pos:upper() .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration);
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
	PlaySoundFile("Interface\\AddOns\\EndlessRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

local function assignMarks()
	assignments = {};
	count = 1;
	for i = 1, 10 do
		local pl1 = Ambiguate(targetedPlayers[i], "short");
		local pl2 = Ambiguate(hookedPlayers[i], "short");
		if (UnitIsConnected(pl1)) then
			C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", pl2, "WHISPER", pl1);
		end
		if (UnitIsConnected(pl2)) then
			C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", pl1, "WHISPER", pl2);
		end
	end
	for i = 1, 3 do -- assign any non melee pait without crushed
		for index, player in pairs(raid[priorityLex[i]]) do
			if (not EnRT_ContainsKey(assignments, player)) then
				local idx = EnRT_Contains(targetedPlayers, player) or EnRT_Contains(hookedPlayers, player);
				local isHooked = EnRT_Contains(hookedPlayers, player);
				local chainedTo = nil;
				if (idx) then
					if (isHooked) then
						chainedTo = targetedPlayers[idx];
					else
						chainedTo = hookedPlayers[idx];
					end
					if (chainedTo and not EnRT_Contains(raid["MELEE"], chainedTo)) then
						if (not EnRT_UnitDebuff(player, GetSpellInfo(342410)) and not EnRT_UnitDebuff(chainedTo, GetSpellInfo(342410))) then
							assignments[player] = {};
							assignments[player].mark = count;
							assignments[player].pos = "LARGE AND SMALL";
							assignments[chainedTo] = {};
							assignments[chainedTo].mark = count;
							assignments[chainedTo].pos = "small";
							if (UnitIsConnected(player)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
							end
							if (UnitIsConnected(chainedTo)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[chainedTo].mark .. " " .. assignments[chainedTo].pos, "WHISPER", chainedTo);
							end
							count = count + 1;
							if (count == 5) then
								printAssignments();
								return;
							end
						end
					end
				end
			end
		end
	end
	if (count < 5) then -- there is no pair with both players undebuffed, assign any non melee pair with 1 debuff
		for i = 1, 3 do 
			for index, player in pairs(raid[priorityLex[i]]) do
				if (not EnRT_ContainsKey(assignments, player)) then
					local idx = EnRT_Contains(targetedPlayers, player) or EnRT_Contains(hookedPlayers, player);
					local isHooked = EnRT_Contains(hookedPlayers, player);
					local chainedTo = nil;
					if (idx) then
						if (isHooked) then
							chainedTo = targetedPlayers[idx];
						else
							chainedTo = hookedPlayers[idx];
						end
						if (chainedTo and not EnRT_Contains(raid["MELEE"], chainedTo)) then
							if (not EnRT_UnitDebuff(player, GetSpellInfo(342410)) or not EnRT_UnitDebuff(chainedTo, GetSpellInfo(342410))) then
								if (not EnRT_UnitDebuff(player, GetSpellInfo(342410))) then
									assignments[player] = {};
									assignments[player].mark = count;
									assignments[player].pos = "LARGE AND SMALL";
									assignments[chainedTo] = {};
									assignments[chainedTo].mark = count;
									assignments[chainedTo].pos = "small";
								else
									assignments[chainedTo] = {};
									assignments[chainedTo].mark = count;
									assignments[chainedTo].pos = "LARGE AND SMALL";
									assignments[player] = {};
									assignments[player].mark = count;
									assignments[player].pos = "small";
								end
								if (UnitIsConnected(player)) then
									C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
								end
								if (UnitIsConnected(chainedTo)) then
									C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[chainedTo].mark .. " " .. assignments[chainedTo].pos, "WHISPER", chainedTo);
								end
								count = count + 1;
								if (count == 5) then
									printAssignments();
									return;
								end
							end
						end
					end
				end
			end
		end
	end
	if (count < 5) then
		for i = 1, 4 do --fill with anyone
			for index, player in pairs(raid[priorityLex[i]]) do
				if (not EnRT_ContainsKey(assignments, player)) then
					local idx = EnRT_Contains(targetedPlayers, player) or EnRT_Contains(hookedPlayers, player);
					local isHooked = EnRT_Contains(hookedPlayers, player);
					if (idx) then
						if (isHooked) then
							local chainedTo = targetedPlayers[idx];
						else
							chainedTo = hookedPlayers[idx];
						end
						if (not EnRT_UnitDebuff(player, GetSpellInfo(342410)) or not EnRT_UnitDebuff(chainedTo, GetSpellInfo(342410))) then
							if (not EnRT_UnitDebuff(player, GetSpellInfo(342410))) then
								assignments[player] = {};
								assignments[player].mark = count;
								assignments[player].pos = "LARGE AND SMALL";
								assignments[chainedTo] = {};
								assignments[chainedTo].mark = count;
								assignments[chainedTo].pos = "small";
							else
								assignments[chainedTo] = {};
								assignments[chainedTo].mark = count;
								assignments[chainedTo].pos = "LARGE AND SMALL";
								assignments[player] = {};
								assignments[player].mark = count;
								assignments[player].pos = "small";
							end
							if (UnitIsConnected(player)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
							end
							if (UnitIsConnected(chainedTo)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[chainedTo].mark .. " " .. assignments[chainedTo].pos, "WHISPER", chainedTo);
							end
							count = count + 1;
							if (count == 5) then
								printAssignments();
								return;
							end
						end
					end
				end
			end
		end
	end
	if (count < 5) then
		for i = 1, 4 do -- assign any pair without crushed
			for index, player in pairs(raid[priorityLex[i]]) do
				if (not EnRT_ContainsKey(assignments, player)) then
					local idx = EnRT_Contains(targetedPlayers, player) or EnRT_Contains(hookedPlayers, player);
					local isHooked = EnRT_Contains(hookedPlayers, player);
					local chainedTo = nil;
					if (idx) then
						if (isHooked) then
							chainedTo = targetedPlayers[idx];
						else
							chainedTo = hookedPlayers[idx];
						end
						if (not EnRT_UnitDebuff(player, GetSpellInfo(342410)) and not EnRT_UnitDebuff(chainedTo, GetSpellInfo(342410))) then
							assignments[player] = {};
							assignments[player].mark = count;
							assignments[player].pos = "LARGE AND SMALL";
							assignments[chainedTo] = {};
							assignments[chainedTo].mark = count;
							assignments[chainedTo].pos = "small";
							if (UnitIsConnected(player)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
							end
							if (UnitIsConnected(chainedTo)) then
								C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", assignments[chainedTo].mark .. " " .. assignments[chainedTo].pos, "WHISPER", chainedTo);
							end
							count = count + 1;
							if (count == 5) then
								printAssignments();
								return;
							end
						end
					end
				end
			end
		end
	end
end

local function onUpdate(self, elapsed)
	if (debuffed and EnRT_SludgefistEnabled and pair and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			local safe = false;
			if (UnitIsConnected(pair) and UnitIsVisible(pair)) then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pair))].colorStr, Ambiguate(pair, "short"));
				if (not IsItemInRange(37727, pair)) then
					if (plMark and plPos) then
						local tempPos = plPos:lower();
						tempPos = tempPos:sub(1,1):upper() .. tempPos:sub(2);
						EnRT_InfoBoxShow("|cFFFF0000WARNING|r " .. name .. "|r |cFFFF0000> 6 yards|r\nYour soak: |cFFFFFFFF" .. tempPos .. "|r\nYour mark: " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. plMark .. ":20\124t", 56);
					else
						EnRT_InfoBoxShow("|cFFFF0000WARNING|r " .. name .. "|r |cFFFF0000> 6 yards|r", 56);
					end
				else
					if(plMark and plPos) then
						EnRT_InfoBoxShow("|cFF00FF00SAFE|r " .. name .. "|r |cFF00FF00< 6 yards|r\nYour soak: |cFFFFFFFF" .. tempPos .. "|r\nYour mark: " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. plMark .. ":20\124t", 56);
					else
						EnRT_InfoBoxShow("|cFF00FF00SAFE|r " .. name .. "|r |cFF00FF00< 6 yards|r", 56);
					end
				end
			end
			ticks = 0;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...) 
	if (event == "PLAYER_LOGIN") then
		if (EnRT_SludgefistEnabled == nil) then EnRT_SludgefistEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_SludgefistEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_SLUDGEFIST") then
			if (msg == "spec") then
				local spec = GetSpecialization();
				local specName = select(2, GetSpecializationInfo(spec));
				if (UnitIsConnected(leader)) then
					C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", specName, "WHISPER", leader);
				end
			elseif (msg == "notify" and plMark and plPos) then
				playerNotification(plMark, plPos, 10);
			elseif (tonumber(msg)) then
				msg = tonumber(msg);
				if (EnRT_Contains(meleeLex, msg)) then
					sender = GetUnitName(sender, true);
					table.insert(raid["MELEE"], sender);
				else
					sender = GetUnitName(sender, true);
					table.insert(raid["RANGED"], sender);
				end
			elseif (not msg:find(" ")) then
				pair = msg;
			else
				plMark, plPos = strsplit(" ", msg, 2);
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and EnRT_SludgefistEnabled and inEncounter) then
		local _, logEvent, _, _, _, _, _, _, target, _, _, spellID = CombatLogGetCurrentEventInfo();
		if (UnitIsUnit(playerName, leader)) then
			if (logEvent == "SPELL_AURA_APPLIED") then
				if (spellID == 335293) then
					table.insert(targetedPlayers, target);
					if (not hasAssigned) then
						hasAssigned = true;
						C_Timer.After(0.1, function() assignMarks(); end);
					end
				elseif (spellID == 335468) then --335294?
					table.insert(hookedPlayers, target);
				end
			elseif (logEvent == "SPELL_AURA_REMOVED" and (spellID == 335468 or spellID == 335293)) then
				local index = EnRT_Contains(targetedPlayers, target);
				if (not index) then
					index = EnRT_Contains(hookedPlayers, target);
				end
				if (index) then
					table.remove(hookedPlayers, index);
					table.remove(targetedPlayers, index);
				end
			elseif (logEvent == "SPELL_AURA_APPLIED" and spellID == 331209) then
				C_ChatInfo.SendAddonMessage("EnRT_SLUDGEFIST", "notify", "RAID");
			elseif (logEvent == "SPELL_AURA_APPLIED" and spellID == 342420) then
				hasAssigned = false;
			--elseif (logEvent == "SPELL_CAST_START" and spellID == 331209) then
			end
		end
		if (target and UnitIsUnit(playerName, target)) then
			if (logEvent == "SPELL_AURA_APPLIED") then
				if (spellID == 335293) then
					debuffed = true;
					f:SetScript("OnUpdate", onUpdate);
				elseif (spellID == 335468) then --335294?
					debuffed = true;
					f:SetScript("OnUpdate", onUpdate);
				end
			elseif (logEvent == "SPELL_AURA_REMOVED" and (spellID == 335468 or spellID == 335293)) then
				f:SetScript("OnUpdate", nil);
				debuffed = false;
				pair = nil;
				plMark = nil;
				plPos = nil;
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_SludgefistEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2399 and difficulty == 16) then
			inEncounter = true;
			pair = nil;
			assignments = {};
			debuffed = false;
			targetedPlayers = {};
			hookedPlayers = {};
			raid = {};
			count = 1;
			plMark = nil;
			plPos = nil;
			hasAssigned = false;
			leader = EnRT_GetRaidLeader();
			initRaid();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_SludgefistEnabled and inEncounter) then
		inEncounter = false;
		pair = nil;
		assignments = {};
		debuffed = false;
		targetedPlayers = {};
		hookedPlayers = {};
		raid = {};
		count = 1;
		plMark = nil;
		plPos = nil;
		hasAssigned = false;
	end
end);

function SF_Test()
	raid = {
		["TANK"] = {"Pred", "Nost"},
		["HEALER"] = {"Marie", "Natu", "Janga", "Warlee"},
		["RANGED"] = {"Ala", "Antr", "Blink", "Fed", "Cakk", "Moon", "Mvk", "Sloni", "Sejuka", "Emnity"},
		["MELEE"] = {"Bram", "Dez", "Sloxy", "Cata"},
	};
	assignments = {};
	targetedPlayers = {[1] = "Pred"};
	hookedPlayers = {[1] = "Nost"};
	for i = 1, 18 do
		local rngGroup = math.random(1, 4);
		local rngPlayer = math.random(1, #raid[priorityLex[rngGroup]]);
		local player = raid[priorityLex[rngGroup]][rngPlayer];
		while (player == nil or EnRT_Contains(targetedPlayers, player) or EnRT_Contains(hookedPlayers, player)) do
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