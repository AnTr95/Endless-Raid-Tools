local L = IRTLocals;
local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local leader = "";
local hasAssigned = false;
local raid = nil;
local debuffed = {};
local hasDebuff = false;
local assignments = {};
local printDebug = false;
local testMode = false;
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
	["4"] = "TRIANGLE",
};

local COLORCODES = {
	["1"] = "|cFF00FF00",
 	["2"] = "|cFFFFFF00",
 	["S"] = "|cFFFF0000",
 }

local spellIDs = {
	["Miasma"] = GetSpellInfo(329298),
	["Sap"] = GetSpellInfo(344755),
};

local IRT_UnitDebuff = IRT_UnitDebuff;
local IRT_Contains = IRT_Contains;
local UnitIsVisible = UnitIsVisible;
local UnitIsUnit = UnitIsUnit;
local Ambiguate = Ambiguate;
local UnitIsConnected = UnitIsConnected;
local strsplit = strsplit;

C_ChatInfo.RegisterAddonMessagePrefix("IRT_HD");

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");

function IRT_HD_TestMode()
	if (testMode) then
		testMode = false;
		print("IRT: HD Test mode disabled");
	else
		testMode = true;
		print("IRT: HD Test mode enabled");
	end
end

function IRT_HD_Debug()
	if (printDebug) then
		printDebug = false;
	else
		printDebug = true;
	end
end

local function initRaid()
	if (printDebug) then
		print("initiating raid")
	end
	raid = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	};
	for i = 1, 40 do
		local name, rank, group, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (name and UnitIsConnected(name) and UnitIsVisible(name)) then
			if (raid[group]) then
				if (printDebug) then
					print(name .. " added to group " .. group)
				end
				table.insert(raid[group], name);
			end
		end
	end
end

local function compare(a, b)
	if (a[2] == b[2]) then
		return IRT_Contains(raid[a[2]], a[1]) > IRT_Contains(raid[b[2]], b[1]);
	end
	return a[2] < b[2];
end

local function printAssignments()
	local printText = "IRT Assignments:";
	local sortedArray = {};
	for debuffedPlayer, group in pairs(debuffed) do
		table.insert(sortedArray, {debuffedPlayer, group});
	end
	table.sort(sortedArray, compare);
	for i, data in pairs(sortedArray) do
		local debuffedPlayer = data[1];
		local group = data[2];
		local pl = Ambiguate(debuffedPlayer, "short");
		if (UnitIsConnected(debuffedPlayer)) then
			pl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, pl);
			pl = "|c296d98FF" .. pl .. "|r";
		else
			pl = "|c296d98FF" .. pl .. "|r";
		end
		printText = printText .. "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. group .. ":12\124t\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t" .. pl .. "\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t";
		for index, player in pairs(assignments[group]) do
			local playerText = Ambiguate(player, "short");
			if (UnitIsConnected(player)) then
				playerText = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(playerText))].colorStr, playerText);
			end
			if (index < 3) then
				printText = printText .. ", " .. COLORCODES[tostring(index)] .. index .. ". |r" .. playerText;
			else
				printText = printText .. ", |cFFFF0000S|r " .. playerText;
			end
		end
	end
	print(printText);
end

local function updateGroups()
	if (printDebug) then
		print("updating groups reseting data")
	end
	assignments = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	};
	local debuffedGroups = {
		[1] = 0, 
		[2] = 0, 
		[3] = 0, 
		[4] = 0,
	};
	--initial debuff fill
	for player, group in pairs(debuffed) do
		debuffedGroups[group] = debuffedGroups[group] + 1;
		if (printDebug) then
			print(player .. " is found in group " .. group .. " which now has " .. debuffedGroups[group] .. " debuffs")
		end
	end
	--sort grps to avoid players going from g1 to g4
	if (printDebug) then
		print("sorting groups")
	end
	local sortedDebuffed = {};
	for k, v in pairs(debuffed) do
		table.insert(sortedDebuffed, {k, v});
	end
	table.sort(sortedDebuffed, compare);
	--debuff spread
	if (printDebug) then
		print("spreading debuffs out")
	end
	for index, data in pairs(sortedDebuffed) do
		local player = data[1];
		local group = data[2];
		if (printDebug) then
			print("got player " .. player .. " in group " .. group .. " which has " .. debuffedGroups[group] .. " debuffs")
		end
		if (debuffedGroups[group] > 1) then
			for i = 1, 4 do
				if (printDebug) then
					print("group" .. i .. " has " .. debuffedGroups[i] .. " debuffs")
				end
				if (debuffedGroups[i] == 0) then
					debuffedGroups[group] = debuffedGroups[group] - 1;
					debuffedGroups[i] = 1;
					table.insert(raid[i], player);
					table.remove(raid[group], IRT_Contains(raid[group], player));
					debuffed[player] = i;
					if (printDebug) then
						print("new group found for " .. player .. ", moved from group " .. group .. " to " .. i .. " old group now has " .. debuffedGroups[group] .. " debuffs and new group has " .. debuffedGroups[i] .. " debuffs")
						print("marking with " .. groupIcons[tostring(i)] .. " and sending addon message to debuffed player " .. player)
					end
					C_ChatInfo.SendAddonMessage("IRT_HD", i, "WHISPER", player);
					SetRaidTarget(player, i);
					break;
				end
			end
		else
			if (printDebug) then
				print(group .. "group has 1 debuffs" .. "marking with " .. groupIcons[tostring(group)] .. " and sending addon message to debuffed player " .. player)
			end
			C_ChatInfo.SendAddonMessage("IRT_HD", group, "WHISPER", player);
			SetRaidTarget(player, group);
		end
	end
	--fill groups
	if (printDebug) then
		print("filling groups evenly")
	end
	for grp = 1, 4 do
		if (#raid[grp] > 5) then
			for i = #raid[grp], 1, -1 do --for each player reversed
				if (#raid[grp] > 5) then -- during each iteration make sure still more than 5
					local player = raid[grp][i];
					if (printDebug) then
						print(grp .. " has more than 5 players trying to move " .. player)
					end
					-- check if debuff is running out or low stacks
					if (not IRT_UnitDebuff(player, spellIDs["Sap"]) and debuffed[player] == nil and UnitGroupRolesAssigned(player) ~= "TANK") then --Dont swap debuffed players nor players that cant soak because still debuffed nor tanks
						if (printDebug) then
							print(player .. " does not have sap or miasma debuff and is not a tank, iterating new group for them")
						end
						for newGrp = 1, 4 do
							if (#raid[newGrp] < 5) then
								if (printDebug) then
									print(newGrp .. " has less than 5 players moving " .. player .. " from " .. grp .. " to " .. newGrp)
								end
								table.insert(raid[newGrp], player);
								table.remove(raid[grp], IRT_Contains(raid[grp], player));
								break;
							end
						end
					end
				else
					break;
				end
			end
			if (#raid[grp] > 5) then
				for i = #raid[grp], 1, -1 do --for each player reversed
					if (#raid[grp] > 5) then -- during each iteration make sure still more than 5
						local player = raid[grp][i];
						if (printDebug) then
							print(grp .. " has more than 5 players trying to move " .. player)
						end
						-- check if debuff is running out or low stacks
						local _, _, _, stacks, _, _, exp = IRT_UnitDebuff(player, spellIDs["Sap"]);
						if (stacks and exp and (math.floor(exp-GetTime()-3) <= 0 or stacks <=2) and debuffed[player] == nil and UnitGroupRolesAssigned(player) ~= "TANK") then --Dont swap debuffed players nor players that cant soak because still debuffed nor tanks
							if (printDebug) then
								print(player .. " does not have sap or miasma debuff and is not a tank, iterating new group for them")
							end
							for newGrp = 1, 4 do
								if (#raid[newGrp] < 5) then
									if (printDebug) then
										print(newGrp .. " has less than 5 players moving " .. player .. " from " .. grp .. " to " .. newGrp)
									end
									table.insert(raid[newGrp], player);
									table.remove(raid[grp], IRT_Contains(raid[grp], player));
									break;
								end
							end
						end
					else
						break;
					end
				end
			end
		end
	end
	for grp = 1, 4 do
		if (printDebug) then
			print("assigning group " .. grp)
			print("looking for undebuffed players")
		end
		count = 0;
		for index, player in pairs(raid[grp]) do --find undebuffed players
			if (UnitIsConnected(player) and debuffed[player] == nil) then
				if (not IRT_UnitDebuff(player, spellIDs["Sap"]) and count < 2) then
					if (printDebug) then
						print(player .. " is connected and does not have debuff, assigning " .. player .. " to group " .. grp .. " and count is " .. count)
					end
					if (count == 0) then
						C_ChatInfo.SendAddonMessage("IRT_HD", grp, "WHISPER", player);
						count = count + 1;
						assignments[grp][count] = player;
					elseif (count == 1) then
						C_ChatInfo.SendAddonMessage("IRT_HD", "soon " .. grp, "WHISPER", player);
						count = count + 1;
						assignments[grp][count] = player;
						for j, pl in pairs(raid[grp]) do
							if (not IRT_Contains(assignments[grp], pl) and debuffed[pl] == nil) then
								if (printDebug) then
									print(pl .. " soaks next debuff instead count is " .. count)
								end
								C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", pl);
								assignments[grp][#assignments[grp]+1] = pl;
							end
						end
						break;
					end
				elseif (count == 2) then
					if (printDebug) then
						print(player .. " is assigned to next soak as count is " .. count)
					end
					C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
					assignments[grp][#assignments[grp]+1] = player;
				end
			end
		end
		if (count == 0) then -- first check if their debuff is about to expire
			if (printDebug) then
				print("did not find any players without debuffs looking for exp timer")
			end
			for index, player in pairs(raid[grp]) do
				if (UnitIsConnected(player) and debuffed[player] == nil) then
					local exp = select(7, IRT_UnitDebuff(player, spellIDs["Sap"]));
					if (printDebug) then
						print(player .. " debuffs runs out in " .. math.floor(exp-GetTime()))
					end
					if (exp and math.floor(exp-GetTime()-3) <= 0) then
						if (printDebug) then
							print(player .. "'s debuff runs out in less than 2s assining to " .. grp .. " and count is " .. count)
						end
						C_ChatInfo.SendAddonMessage("IRT_HD", grp, "WHISPER", player);
						count = count + 1;
						assignments[grp][count] = player;
						break;
					end
				end
			end
		end
		if (count == 0) then -- if everyone has a long debuff check if anyone has low stacks
			if (printDebug) then
				print("did not find any players to assign looking for low stacks")
			end
			for index, player in pairs(raid[grp]) do
				if (UnitIsConnected(player) and debuffed[player] == nil) then
					local stacks = select(4, IRT_UnitDebuff(player, spellIDs["Sap"]));
					if (printDebug) then
						print(player .. " has " .. stacks .. " stacks")
					end
					if (stacks and stacks < 3) then
						if (printDebug) then
							print(player .. " has less than 3 stacks assigning to " .. grp .. " and count is " .. count)
						end
						C_ChatInfo.SendAddonMessage("IRT_HD", grp, "WHISPER", player);
						count = count + 1;
						assignments[grp][count] = player;
						break;
					end
				end
			end
		end
		if (count == 1) then -- check if someones debuff is about to expire
			if (printDebug) then
				print("still need 1 soaker for 2nd part of debuff")
			end
			for index, player in pairs(raid[grp]) do
				if (UnitIsConnected(player) and debuffed[player] == nil and not IRT_Contains(assignments[grp], player)) then
					if (count == 2) then
						if (printDebug) then
							print(player .. " soaks next debuff instead count is " .. count)
						end
						C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
						assignments[grp][#assignments[grp]+1] = player;
					else
						local exp = select(7, IRT_UnitDebuff(player, spellIDs["Sap"]));
						if (printDebug) then
							print(player .. " debuffs runs out in " .. math.floor(exp-GetTime()))
						end
						if (exp and math.floor(exp-GetTime()-13) <= 0) then
							if (printDebug) then
								print(player .. "'s debuff runs out in less than 12s assining to " .. grp .. " and count is " .. count)
							end
							C_ChatInfo.SendAddonMessage("IRT_HD", grp, "WHISPER", player);
							count = count + 1;
							assignments[grp][count] = player;
							for j, pl in pairs(raid[grp]) do
								if (not IRT_Contains(assignments[grp], pl) and debuffed[pl] == nil) then
									if (printDebug) then
										print(pl .. " soaks next debuff instead count is " .. count)
									end
									C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", pl);
									assignments[grp][#assignments[grp]+1] = pl;
								end
							end
							break;
						end
					end
				end
			end
		end
		if (count < 2) then -- last resort check who has less stacks
			if (printDebug) then
				print("need soakers, going to last resort who has less stacks")
			end
			local soaker = nil;
			for index, player in pairs(raid[grp]) do --assign each person
				if (UnitIsConnected(player) and debuffed[player] == nil and not IRT_Contains(assignments[grp], player)) then
					if (count < 2) then
						if (printDebug) then
							print("still need soakers checking stacks on " .. player)
						end
						local lowestDebuff1 = 100000;
						local lowestDebuff2 = 100000;
						local _, _, _, stacks, _, _, exp = IRT_UnitDebuff(player, spellIDs["Sap"]);
						if (printDebug) then
							print(player .. " has " .. stacks .. " and debuff runs out in " .. math.floor(exp-GetTime()) .. "s")
						end
						if (stacks) then
							lowestDebuff1 = stacks;
							lowestDebuff2 = stacks;
							if (printDebug) then
								print("comparing " .. player .. " with others in grp")
							end
							for idx, pl in pairs(raid[grp]) do -- check if current person is best suited or not
								local _, _, _, nextStacks, _, _, nextExp = IRT_UnitDebuff(player, spellIDs["Sap"]);
								if (printDebug) then
									print("comparing to " .. pl .. " which has " .. nextStacks .. " stacks and debuff runs out in " .. math.floor(nextExp-GetTime()) .. "s")
								end
								if (count == 0 and not UnitIsUnit(player, pl)) then
									if (nextStacks) then
										if (nextStacks < lowestDebuff1) then
											if (printDebug) then
												print(pl .. " has lower stacks but checking for 1 more player as count is " .. count)
											end
											lowestDebuff1 = -1;
											--1 better option palyer out of 2
										elseif (nextStacks < lowestDebuff2) then
											--2 better option player this player soaks later
											if (printDebug) then
												print(pl .. " has lower stacks as well " .. player .. " soaks next debuff instead")
											end
											lowestDebuff2 = -1;
											C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
											assignments[grp][2-count+#assignments[grp]+1] = player;
											break;
										end
									end
								elseif (count == 1 and not UnitIsUnit(player, pl)) then
									if (nextExp and math.floor(nextExp-GetTime()-13) <= 0 and not IRT_Contains(assignments[grp], pl)) then
										C_ChatInfo.SendAddonMessage("IRT_HD", "soon " .. grp, "WHISPER", pl);
										C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
										soaker = pl;
										count = count + 1;
										assignments[grp][count] = pl;
										assignments[grp][#assignments[grp]+1] = player;
										break;
									end
									if (nextStacks and not IRT_Contains(assignments[grp], pl)) then
										if (nextStacks < lowestDebuff1) then
											--better option player this player soaks later
											lowestDebuff1 = -1;
											C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
											assignments[grp][2-count+#assignments[grp]+1] = player;
											break;
										end
									end
								elseif (count == 2 and not UnitIsUnit(player, pl)) then
									C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
									assignments[grp][#assignments[grp]+1] = player;
									break;
								end
								-- best option player soak now
							end
							if ((count == 0 and lowestDebuff1 > -1 and lowestDebuff2 > -1) or (count == 1 and lowestDebuff1 > -1)) then
								C_ChatInfo.SendAddonMessage("IRT_HD", grp, "WHISPER", player);
								count = count + 1;
								assignments[grp][count] = player;
							end
						end
					elseif (count >= 2 and not IRT_Contains(assignments[grp], player)) then
						if (soaker) then
							if (not UnitIsUnit(player, soaker)) then
								if (printDebug) then
									print(player .. " soaks next debuff instead as count is " .. count)
								end
								C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
								assignments[grp][#assignments[grp]+1] = player;
							end
						else
							if (printDebug) then
								print(player .. " soaks next debuff instead as count is " .. count)
							end
							C_ChatInfo.SendAddonMessage("IRT_HD", "next " .. grp, "WHISPER", player);
							assignments[grp][#assignments[grp]+1] = player;
						end
					end
				end
			end
		end
	end
	printAssignments();
end

local function playerNotification(mark, duration)
	if (printDebug) then
		print("starting player notification")
	end
	local chatText = "{rt" .. mark .. "}";
	if (hasDebuff) then
		print("player has debuff")
		chatText = chatText .. " DEBUFFED " .. "{rt" .. mark .. "}";
		duration = 24;
	end
	SendChatMessage(chatText, "YELL");
	if (printDebug) then
		print("starting yell ticker")
	end
	local ticker = C_Timer.NewTicker(1.5, function()
		if (UnitIsDead("player")) then
			ticker:Cancel();
			ticker = nil;
		else
			SendChatMessage(chatText, "YELL");
		end
	end, math.floor(duration/1.5)-1);
	if (printDebug) then
		print("showing popup")
	end
	IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. " NOW " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration, L.BOSS_FILE);
	PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_HungeringDestroyerEnabled == nil) then IRT_HungeringDestroyerEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter and IRT_HungeringDestroyerEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(unitName, playerName)) then
			if (IRT_UnitDebuff(unitName, spellIDs["Miasma"])) then
				if (not hasDebuff) then
					if (printDebug) then
						print("player is debuffed setting hasDebuff to true")
					end
					hasDebuff = true;
				end
			else
				if (hasDebuff) then
					if (printDebug) then
						print("player lost debuff reseting hasDebuff to false")
					end
					hasDebuff = false;
				end
			end
		end
		if (UnitIsUnit(leader, playerName)) then
			if (IRT_UnitDebuff(unit, spellIDs["Miasma"])) then
				if (debuffed[unitName] == nil) then
					if (printDebug) then
						print("found new player with debuff not in db")
						print("finding which group " .. unitName .. " is in");
						print("itarting groups")
					end
					for i = 1, 4 do
						local group = IRT_Contains(raid[i], unitName)
						if (group) then
							if (printDebug) then
								print("found " .. unitName .. " in group " .. group)
							end
							debuffed[unitName] = group;
							break;
						end
					end
					C_Timer.After(0.1, function() 
						if (not hasAssigned) then 
							hasAssigned = true; 
							if (printDebug) then
								print("all debuffs are out starting assignments"); 
							end
							updateGroups(); 
						end
					end);
				end
			else
				if (debuffed[unitName]) then
					if (printDebug) then
						print(unitName .. " lost debuff removing data and mark")
					end
					assignments[debuffed[unitName]] = {};
					debuffed[unitName] = nil;
					SetRaidTarget(unitName, 0);
					if (next(debuffed) == nil) then
						hasAssigned = false;
					end
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and inEncounter and IRT_HungeringDestroyerEnabled) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_HD") then
			if (msg:match("soon")) then
				local soakTime = time() + 12;
				local text, mark = strsplit(" ", msg);
				if (printDebug) then
					print("recieved addon message soon preparing for 12s soak delay for mark " .. groupIcons[tostring(mark)])
					print("starting ticker and showing popup")
				end
				IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. ", SOAK IN: |cFFFFFFFF12|r" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", 1, L.BOSS_FILE);
				C_Timer.NewTicker(1, function()
					local timeLeft = math.floor(soakTime - time());
					IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. ", SOAK IN: |cFFFFFFFF" .. timeLeft .. "|r" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", 1, L.BOSS_FILE);
					if (timeLeft <= 3) then
						PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\CalendarNotification\\calnot"..timeLeft..".ogg", "Master");
					end
				end, 11);
				if (printDebug) then
					print("also starting 12s timer for player notification")
				end
				C_Timer.After(12, function()
					playerNotification(mark, 12);
				end);
			elseif (msg:match("next")) then
				local text, mark = strsplit(" ", msg);
				if (printDebug) then
					print("recieved addon message next for mark " .. groupIcons[tostring(mark)])
				end
				IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. ", |cFFFF0000DO NOT SOAK|cFFFFFFFF" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", 24, L.BOSS_FILE);
			else
				if (printDebug) then
					print("recieved addon message to soak starting player notification")
				end
				playerNotification(msg, 12);
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_HungeringDestroyerEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (testMode) then
			difficulty = 16;
		end
		if (eID == 2383 and difficulty == 16) then
			if (printDebug) then
				print("hungering destroyer mythic engaged")
			end
			assignments = {};
			inEncounter = true;
			raid = {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
			};
			leader = IRT_GetRaidLeader();
			hasDebuff = false;
			initRaid();
		end
	elseif (event == "ENCOUNTER_END" and IRT_HungeringDestroyerEnabled and inEncounter) then
		raid = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
		};
		assignments = {};
		inEncounter = false;
		debuffed = {};
		hasDebuff = false;
	end
end);

function HD_Test(p1, p2, p3, p4)
	inEncounter = true;
	if (raid == nil) then
		raid = {
			[1] = {"Antv", "Antt", "Fed", "Ala", "Dez"},
			[2] = {"Pred", "Nost", "Marie", "Cakk", "Sejuka"},
			[3] = {"Natu", "Moon", "Bram", "Cata", "Mvk"},
			[4] = {"Sloni", "Janga", "Sloxy", "Emnity", "Warlee"},
		};
	end
	debuffed = {};
	if(p1) then
		local group1 = math.ceil(p1/5);
		local pl1 = p1%5;
		if (pl1 == 0) then
			pl1=5;
		end
		local group2 = math.ceil(p2/5);
		local pl2 = p2%5;
		if (pl2 == 0) then
			pl2=5;
		end
		local group3 = math.ceil(p3/5);
		local pl3 = p3%5;
		if (pl3 == 0) then
			pl3=5;
		end
		local group4 = math.ceil(p4/5);
		local pl4 = p4%5;
		if (pl4 == 0) then
			pl4=5;
		end
		debuffed[raid[group1][pl1]] = group1;
		debuffed[raid[group2][pl2]] = group2;
		debuffed[raid[group3][pl3]] = group3;
		debuffed[raid[group4][pl4]] = group4;
		print(raid[group1][pl1]);
		print(raid[group2][pl2]);
		print(raid[group3][pl3]);
		print(raid[group4][pl4]);
	else
		local rngs = {};
		for i = 1, 4 do
			local rngGroup = math.random(1, 4);
			local rngPlayer = math.random(1, 5);
			while (IRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
				rngGroup = math.random(1, 4);
				rngPlayer = math.random(1, 5);
			end
			table.insert(rngs, ((rngGroup-1)*5)+rngPlayer);
			debuffed[raid[rngGroup][rngPlayer]] = rngGroup;
			print(raid[rngGroup][rngPlayer])
		end
	end
	updateGroups();
	inEncounter = false;
end

function HD_Test2(p1, p2, p3, p4)
	inEncounter = true;
	if (raid == nil) then
		initRaid();
	end
	debuffed = {};
	if(p1) then
		local group1 = math.ceil(p1/5);
		local pl1 = p1%5;
		if (pl1 == 0) then
			pl1=5;
		end
		local group2 = math.ceil(p2/5);
		local pl2 = p2%5;
		if (pl2 == 0) then
			pl2=5;
		end
		local group3 = math.ceil(p3/5);
		local pl3 = p3%5;
		if (pl3 == 0) then
			pl3=5;
		end
		local group4 = math.ceil(p4/5);
		local pl4 = p4%5;
		if (pl4 == 0) then
			pl4=5;
		end
		debuffed[raid[group1][pl1]] = group1;
		debuffed[raid[group2][pl2]] = group2;
		debuffed[raid[group3][pl3]] = group3;
		debuffed[raid[group4][pl4]] = group4;
		print(raid[group1][pl1]);
		print(raid[group2][pl2]);
		print(raid[group3][pl3]);
		print(raid[group4][pl4]);
	else

		local rngs = {};
		for i = 1, 4 do
			local rngGroup = math.random(1, 4);
			local rngPlayer = math.random(1, 5);
			while (IRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
				rngGroup = math.random(1, 4);
				rngPlayer = math.random(1, 5);
			end
			table.insert(rngs, ((rngGroup-1)*5)+rngPlayer);
			debuffed[raid[rngGroup][rngPlayer]] = rngGroup;
			print(raid[rngGroup][rngPlayer])
		end
	end
	updateGroups();
	inEncounter = false;
end