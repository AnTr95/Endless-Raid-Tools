local f = CreateFrame("Frame");
local inEncounter = false;
local leader = "";
local debuffed = {};
local raid = nil;
local playerName = GetUnitName("player");
local assignment = "";
local printDebug = false;
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
	["4"] = "TRIANGLE",
};
local timer = nil;
local tankSoak = false;
local positions = {
	[1] = "BACK",
	[2] = "MID",
	[3] = "FRONT",
	[4] = "BACKUP",
	[5] = "ABORT",
};

local debuffsPerGroup = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
};
local soaksPerGroup = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
};

local positionsLex = {
	["FRONT"] = 1,
	["MID"] = 2,
	["BACK"] = 3,
	["5"] = 4,
	["BACKUP"] = 5,
	["ABORT"] = 6,
};

local assignments = {};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_HA");

local function compare(a, b)
	return tonumber(positionsLex[tostring(a[3])]) < tonumber(positionsLex[tostring(b[3])]);
end

local function initRaid()
	raid = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	};
	for i = 1, 20 do
		local name, rank, group, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (name and UnitIsConnected(name) and UnitIsVisible(name)) then
			if (raid[group]) then
				table.insert(raid[group], name);
			end
		end
	end
	resetAssignmentsData();
end

function EnRT_HA_Debug()
	if (printDebug) then
		printDebug = false;
	else
		printDebug = true;
	end
end

local function resetAssignmentsData()
	for i = 2, 4 do
		for index, player in pairs(raid[i]) do
			assignments[player] = {
				["mark"] = i-1,
				["pos"] = positions[index],
			};
		end
	end
	debuffsPerGroup = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	};
	soaksPerGroup = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	};
	C_ChatInfo.SendAddonMessage("EnRT_HA", "reset", "RAID");
end

local function printAssignments()
	--local starText = "EnRT Assignments:\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12\124t \124TInterface\\Icons\\ability_hunter_assassinate2:12\124t" .. Ambiguate(debuffed[1], "short") .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t,";
--	local circleText = "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:12\124t \124TInterface\\Icons\\ability_hunter_assassinate2:12\124t" .. Ambiguate(debuffed[2], "short") .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t,";
	--local diamondText = "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:12\124t \124TInterface\\Icons\\ability_hunter_assassinate2:12\124t" .. Ambiguate(debuffed[3], "short") .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t,";
	local printText = "EnRT Assignments:";
	local sortedTable = {
		[1] = {}, 
		[2] = {}, 
		[3] = {},
	};
	for pl, data in pairs(assignments) do
		table.insert(sortedTable[tonumber(data.mark)], {pl, data.mark, tostring(data.pos)});
	end
	table.sort(sortedTable[1], compare);
	table.sort(sortedTable[2], compare);
	table.sort(sortedTable[3], compare);
	--[[for k, v in pairs(sortedTable) do
		table.sort(v);
	end]]
	for i = 1, 3 do
		for idx, data in pairs(sortedTable[i]) do
			local pl = Ambiguate(data[1], "short");
			if (idx == 1) then
				printText = printText .. "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_".. i .. ":12\124t |cFF00FF00" .. pl .. "|cFFFFFFFF, ";
			elseif (idx == 4) then
				printText = printText .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t|c296d98FF" .. debuffed[i] .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t|cFFFFFFFF";
			elseif (idx > 1 and idx < 4) then
				printText = printText .. "|cFF00FF00" .. pl .. "|cFFFFFFFF, ";
			end
		end
	end
	print(printText);
	--[[
	for pl, data in pairs(assignments) do
		local pos = data.pos;
		local mark = data.mark;
		if (pos == positions[1] or pos == positions[2] or pos == positions[3]) then
			if (mark == 1) then
				starText = starText .. " " .. pl .. ",";
			elseif (mark == 2) then
				circleText = circleText .. " " .. pl .. ",";
			elseif (mark == 3) then
				diamondText = diamondText .. " " .. pl .. ",";
			end
		end
	end]]
	--print(starText .. circleText .. diamondText);
end

local function assignMarks()
	for mark = 1, #debuffed do
		if (printDebug) then
			print("assign round " .. mark)
		end
		local debuffsInGroup = debuffsPerGroup[mark+1];
		local requireBackup = 0;
		for index, player in pairs(raid[mark+1]) do
			if (printDebug) then
				print("itr group " .. mark+1)
			end
			if (index == 5) then
				break;
			end
			if (#debuffed < 3) then
				if (not EnRT_Contains(debuffed, player) and assignments[player].mark == mark) then
					if (printDebug) then
						print(player .. " passed " .. groupIcons[tostring(mark)] .. " " .. positions[index-requireBackup]);
					end
					assignments[player].mark = mark;
					assignments[player].pos = positions[index-requireBackup];
					if (UnitIsConnected(player)) then
						C_ChatInfo.SendAddonMessage("EnRT_HA", mark .. " " .. positions[index-requireBackup], "WHISPER", player);
					end
				else
					if (printDebug) then
						print(player .. " did not pass " .. groupIcons[tostring(mark)] .. " " .. positions[index-requireBackup]);
						print("player is debuffed or assigned to another group")
					end
					requireBackup = requireBackup + 1;
					local nextGroup = mark+1+(requireBackup);
					local backupPlayer = "";
					if (printDebug) then
						print("next group: " .. nextGroup);
					end
					if (nextGroup == 5) then
						nextGroup = 4;
						backupPlayer = raid[nextGroup][3];
						if (printDebug) then
							print("group was 5 so changed it to 4");
							print("and backup player was changed to " .. backupPlayer);
						end
					end
					if (backupPlayer == "") then
						backupPlayer = raid[nextGroup][4];
						if (printDebug) then
							print("backup player " .. backupPlayer);
						end
					end
					if (EnRT_Contains(debuffed, backupPlayer)) then
						if (printDebug) then
							print("backupPlayer " .. " is debuffed");
						end
						nextGroup = nextGroup + 1;
						if (printDebug) then
							print("taking from next group " .. nextGroup);
						end
						if (nextGroup == 5) then
							nextGroup = 4;
							backupPlayer = raid[nextGroup][3];
							if (printDebug) then
								print("there was no next group, taking from group " ..  nextGroup);
								print("new backup is " .. backupPlayer);
							end
						else
							backupPlayer = raid[nextGroup][4];
							if (printDebug) then
								print("new backup is " .. backupPlayer);
							end
						end
					end
					local backupPos = 4-debuffsInGroup+1;
					if (mark == 2 and debuffsInGroup > 0 and debuffsPerGroup[2] > 0 and not EnRT_Contains(debuffed, raid[mark+1][4]) and not EnRT_Contains(debuffed, raid[mark][4])) then --if debuffed player is only backup dont move position forward
						if (printDebug) then
							print("debuffs in grp 3 and in grp 2 has a backup player");
						end
						backupPos = 3;
					elseif (mark == 2 and debuffsInGroup == 0 and debuffsPerGroup[2] > 1) then
						backupPlayer = raid[nextGroup][3];
						if (printDebug) then
							print("backup player changed to " .. backupPlayer);
						end
					elseif (mark == 2 and EnRT_Contains(debuffed, raid[mark+1][4]) and EnRT_Contains(debuffed, raid[mark][4])) then
						backupPlayer = raid[nextGroup][3];
						if (printDebug) then
							print("backup player changed to " .. backupPlayer);
						end
					end
					if (backupPos == 5) then --nobody in the grp is debuffed but 1 party member was moved to another party and we still need a backup
						if (printDebug) then
							print("grp has no debuffs but is a player short");
						end
						backupPos = 4;
						if (printDebug) then
							print("new backup position " .. positions[backupPos]);
						end
					end
					assignments[backupPlayer].mark = mark;
					assignments[backupPlayer].pos = positions[backupPos];
					if (printDebug) then
						print("backup player assigned " .. groupIcons[tostring(mark)] .. " " .. positions[backupPos]);
					end
					if (UnitIsConnected(player)) then
						C_ChatInfo.SendAddonMessage("EnRT_HA", mark .. " " .. positions[backupPos], "WHISPER", backupPlayer);
					end
					debuffsInGroup = debuffsInGroup - 1;
				end
			else
				if (not EnRT_Contains(debuffed, player) and assignments[player].mark == mark and soaksPerGroup[mark+1] < 3) then
					if (printDebug) then
						print(player .. " passed " .. groupIcons[tostring(mark)] .. " " .. positions[index-requireBackup]);
					end
					assignments[player].mark = mark;
					assignments[player].pos = positions[soaksPerGroup[assignments[player].mark+1]+1];
					soaksPerGroup[mark+1] = soaksPerGroup[mark+1] + 1;
					if (UnitIsConnected(player)) then
						C_ChatInfo.SendAddonMessage("EnRT_HA", mark .. " " .. positions[index-requireBackup], "WHISPER", player);
					end
				elseif (EnRT_Contains(debuffed, player)) then
					if (printDebug) then
						print(player .. " did not pass " .. groupIcons[tostring(mark)] .. " " .. assignments[player].pos);
					end
					requireBackup = requireBackup + 1;
				elseif (assignments[player].mark ~= mark and soaksPerGroup[assignments[player].mark+1] < 3) then
					if (positionsLex[assignments[player].pos] == 5 and positionsLex[tostring(assignments[raid[mark+1][index+1]].pos)] <= 3 and assignments[player].mark == assignments[raid[mark+1][index+1]].mark) then
						local nextPlayer = raid[mark+1][index+1];
						if (printDebug) then
							print(nextPlayer .. " from grp " .. mark .. " skipped queue and is now confirmed to join " .. groupIcons[tostring(assignments[nextPlayer].mark)] .. " in position " .. assignments[nextPlayer].pos);
						end
						assignments[nextPlayer].pos = positions[soaksPerGroup[assignments[nextPlayer].mark+1]+1];
						if (printDebug) then
							print(nextPlayer .. " got new position " .. assignments[nextPlayer].pos .. " in " .. groupIcons[tostring(assignments[nextPlayer].mark)]);
						end
						soaksPerGroup[assignments[nextPlayer].mark+1] = soaksPerGroup[assignments[nextPlayer].mark+1] + 1;
						if (printDebug) then
							print(groupIcons[tostring(assignments[nextPlayer].mark)] .. " now has " .. soaksPerGroup[assignments[nextPlayer].mark+1] .. " soakers");
						end
						if (UnitIsConnected(nextPlayer)) then
							C_ChatInfo.SendAddonMessage("EnRT_HA", assignments[nextPlayer].mark .. " " .. assignments[nextPlayer].pos, "WHISPER", nextPlayer);
						end
						if (soaksPerGroup[assignments[player].mark+1] < 3) then
							if (printDebug) then
								print(player .. " from grp " .. mark .. " is now confirmed to join " .. groupIcons[tostring(assignments[player].mark)] .. " in position " .. assignments[player].pos);
							end
							assignments[player].pos = positions[soaksPerGroup[assignments[player].mark+1]+1];
							if (printDebug) then
								print(player .. " got new position " .. assignments[player].pos .. " in " .. groupIcons[tostring(assignments[player].mark)]);
							end
							soaksPerGroup[assignments[player].mark+1] = soaksPerGroup[assignments[player].mark+1] + 1;
							if (printDebug) then
								print(groupIcons[tostring(assignments[player].mark)] .. " now has " .. soaksPerGroup[assignments[player].mark+1] .. " soakers");
							end
							if (UnitIsConnected(player)) then
								C_ChatInfo.SendAddonMessage("EnRT_HA", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
							end
						end
					else
						if (printDebug) then
							print(player .. " from grp " .. mark .. " is now confirmed to join " .. groupIcons[tostring(assignments[player].mark)] .. " in position " .. assignments[player].pos);
						end
						assignments[player].pos = positions[soaksPerGroup[assignments[player].mark+1]+1];
						if (printDebug) then
							print(player .. " got new position " .. assignments[player].pos .. " in " .. groupIcons[tostring(assignments[player].mark)]);
						end
						soaksPerGroup[assignments[player].mark+1] = soaksPerGroup[assignments[player].mark+1] + 1;
						if (printDebug) then
							print(groupIcons[tostring(assignments[player].mark)] .. " now has " .. soaksPerGroup[assignments[player].mark+1] .. " soakers");
						end
						if (UnitIsConnected(player)) then
							C_ChatInfo.SendAddonMessage("EnRT_HA", assignments[player].mark .. " " .. assignments[player].pos, "WHISPER", player);
						end
					end
				end
			end
		end
	end
	if(#debuffed == 3) then
		for grp = 2, 4 do
			if (soaksPerGroup[grp] < 3) then
				if (printDebug) then
					print("group " .. grp .. " still missing soakers");
				end
				for nextGroup = 2, 4 do
					if (grp ~= nextGroup or grp == 4) then
						for index, player in pairs(raid[nextGroup]) do
							if (assignments[player].pos == positions[4]) then
								assignments[player].mark = grp-1;
								assignments[player].pos = positions[soaksPerGroup[grp]+1];
								soaksPerGroup[grp] = soaksPerGroup[grp] + 1;
								if (printDebug) then
									print(player .. " in grp " .. nextGroup .. " is now confirmed soaker of mark " .. groupIcons[tostring(grp-1)] .. " with position " .. assignments[player].pos);
									print(groupIcons[tostring(grp-1)] .. " now has " .. soaksPerGroup[grp] .. " soakers");
								end
								if (UnitIsConnected(player)) then
									C_ChatInfo.SendAddonMessage("EnRT_HA", grp-1 .. " " .. assignments[player].pos, "WHISPER", player);
								end
								if (soaksPerGroup[grp] >= 3) then
									break;
									--goto continue;
								end
							end
						end
					end
					if (soaksPerGroup[grp] >= 3) then
						break;
					end
				end
			end
			--::continue::
		end
		for grp = 2, 4 do
			for index, player in pairs(raid[grp]) do
				if (assignments[player].pos == positions[4]) then
					if (printDebug) then
						print(player .. " in " .. grp .. " with mark " .. groupIcons[tostring(assignments[player].mark)] .. " should not soak");
					end
					assignments[player].pos = positions[5];
					if (UnitIsConnected(player)) then
						C_ChatInfo.SendAddonMessage("EnRT_HA", grp-1 .. " " .. assignments[player].pos, "WHISPER", player);
					end
				end
			end
		end
		printAssignments();
	end
end

local function playerNotification(mark, pos, duration)
	local chatText = "";
	if (tonumber(pos)) then --debuffed
		chatText = "{rt" .. mark .. "} " .. math.ceil(pos-GetTime()) .. " {rt" .. mark .. "}";
		EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration);
	elseif (pos == positions[5]) then
		chatText = "DO NOT SOAK";
		EnRT_PopupShow("|cFFFF0000DO NOT SOAK!", duration);
	else
		--chatText = "{rt" .. mark .. "} " .. pos .. " {rt" .. mark .. "}";
		chatText = "{rt" .. mark .. "} " .. pos .. " {rt" .. mark .. "}";
		EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. ", POSITION: " .. pos .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration);
	end
	SendChatMessage(chatText, "YELL");
	timer = C_Timer.NewTicker(1, function()
		if (UnitIsDead("player")) then
			timer:Cancel();
			timer = nil;
		elseif (tonumber(pos)) then
			chatText = "{rt" .. mark .. "} " .. math.ceil(pos-GetTime()) .. " {rt" .. mark .. "}";
			SendChatMessage(chatText, "YELL");
		else
			SendChatMessage(chatText, "YELL");
		end
	end, math.floor(duration-1));
	PlaySoundFile("Interface\\AddOns\\EndlessRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_HuntsmanAltimornabled == nil) then EnRT_HuntsmanAltimorEnabled = true; end
		if (EnRT_HuntsmanAltimorPlayersPerLine == nil) then EnRT_HuntsmanAltimorPlayersPerLine = 4; end
	elseif (event == "UNIT_AURA" and EnRT_HuntsmanAltimorEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(leader, playerName)) then
			if (EnRT_UnitDebuff(unit, GetSpellInfo(335111)) or EnRT_UnitDebuff(unit, GetSpellInfo(335112)) or EnRT_UnitDebuff(unit, GetSpellInfo(335113))) then
				if (not EnRT_Contains(debuffed, unitName)) then
					debuffed[#debuffed+1] = unitName;
					SetRaidTarget(unitName, #debuffed);
					local expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335111)));
					if (not expTime) then
						expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335112)));
					end
					if (not expTime) then
						expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335113)));
					end
					if (UnitIsConnected(unitName)) then
						C_ChatInfo.SendAddonMessage("EnRT_HA", #debuffed .. " " .. expTime, "WHISPER", unitName);
					end
					local raidIndex = UnitInRaid(unitName);
					local name, rank, group, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex);
					debuffsPerGroup[group] = debuffsPerGroup[group] + 1;
					if (EnRT_ContainsKey(assignments, unitName)) then
						assignments[unitName].mark = #debuffed;
						assignments[unitName].pos = 5;
					end
					assignMarks();
				end
			else
				if (EnRT_Contains(debuffed, unitName)) then
					debuffed[EnRT_Contains(debuffed, unitName)] = nil;
					SetRaidTarget(unitName, 0);
					resetAssignmentsData();
					if (timer) then
						timer:Cancel();
						timer = nil;
					end
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_HuntsmanAltimorEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_HA") then
			if(msg == "reset") then
				assignment = "";
			else
				local mark, pos = strsplit(" ", msg);
				if (assignment and assignment ~= "" and assignment ~= msg) then
					--PlaySoundFile("Sound\\Interface\\RaidWarning.wav");
					PlaySoundFile(567397, "Master");
					if (timer) then
						timer:Cancel();
					end
					assignment = msg;
					playerNotification(mark, pos, 5);
				elseif (assignment == "") then
					assignment = msg;
					playerNotification(mark, pos, 5);
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_HuntsmanAltimorEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2418 and difficulty == 16) then
			inEncounter = true;
			leader = EnRT_GetRaidLeader();
			debuffed = {};
			assignment = "";
			initRaid();
			if (timer) then
				timer:Cancel();
				timer = nil;
			end
		end
	elseif (event == "ENCOUNTER_END" and EnRT_HuntsmanAltimorEnabled and inEncounter) then
		inEncounter = false;
		debuffed = {};
		assignment = "";
		if (timer) then
			timer:Cancel();
			timer = nil;
		end
	end
end);

function testResults(test)
	if (test == 0) then
		local printT = "Tested test 1 to 21\n";
		local count = 0;
		for i = 1, 21 do 
			C_Timer.After((i-1)*4, function() 
				local passed = testResults(i);
				if (not passed) then
					count = count + 1;
					printT = printT .. "Test " .. i .. " failed\n";
				end
			end);
		end
		C_Timer.After(21*4, function()
			printT = printT .. count .. "/21 tests failed";
			print(printT);
		end);
	elseif (test == 1) then
		HA_Test(1,2,3);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[5]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[5]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[5]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 2) then
		HA_Test(6,7,8);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 2 and assignments["Blink"].mark == 3 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 1
			and assignments["Ala"].pos == 5 and assignments["Ant"].pos == 5 and assignments["Blink"].pos == 5 and assignments["Fed"].pos == positions[1]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[2]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 3) then
		HA_Test(13,12,11);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 3 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 1 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 2 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == 5 and assignments["Cakk"].pos == 5 and assignments["Moon"].pos == 5 and assignments["Mvk"].pos == positions[1]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[2]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 4) then
		HA_Test(18,19,17);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 1 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[2]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[3]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == 5 and assignments["Sejuka"].pos == 5 and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 5) then
		HA_Test(1,7,2);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 2 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == 5 and assignments["Blink"].pos == positions[2] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[5]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[5]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 6) then
		HA_Test(8,6,14);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 2 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 1
			and assignments["Ala"].pos == 5 and assignments["Ant"].pos == positions[1] and assignments["Blink"].pos == 5 and assignments["Fed"].pos == positions[2]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 7) then
		HA_Test(8,12,16);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == 5 and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == 5 and assignments["Moon"].pos == positions[2] and assignments["Mvk"].pos == positions[2]
			and assignments["Sloni"].pos == 5 and assignments["Janga"].pos == positions[1] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" .. test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 8) then
		HA_Test(5,6,20);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 2 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == 5 and assignments["Ant"].pos == positions[1] and assignments["Blink"].pos == positions[2] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[5]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[5]) then
				print("TEST" ..test.. " PASS");
			else
				print("TEST" ..test.. " FAIL");
			end
		end)
	elseif (test == 9) then
		HA_Test(16,7,8);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 2 and assignments["Blink"].mark == 3 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 1 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == 5 and assignments["Blink"].pos == 5 and assignments["Fed"].pos == positions[2]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[3]
			and assignments["Sloni"].pos == 5 and assignments["Janga"].pos == positions[1] and assignments["Sejuka"].pos == positions[2] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 10) then
		HA_Test(17,14,6);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 3 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 1 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == 5 and assignments["Ant"].pos == positions[1] and assignments["Blink"].pos == positions[2] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == 5 and assignments["Sejuka"].pos == positions[2] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 11) then
		HA_Test(16,18,5);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 1 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 2 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[5]
			and assignments["Sloni"].pos == 5 and assignments["Janga"].pos == positions[1] and assignments["Sejuka"].pos == 5 and assignments["Emnity"].pos == positions[2]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 12) then
		HA_Test(16,18,9);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 1 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 2 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == positions[3]
			and assignments["Sloni"].pos == 5 and assignments["Janga"].pos == positions[1] and assignments["Sejuka"].pos == 5 and assignments["Emnity"].pos == positions[2]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 13) then
		HA_Test(11,12,19);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3
			and assignments["Natu"].mark == 1 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 2 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[3]
			and assignments["Natu"].pos == 5 and assignments["Cakk"].pos == 5 and assignments["Moon"].pos == positions[1] and assignments["Mvk"].pos == positions[2]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 14) then
		HA_Test(9,14,19);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 15) then
		HA_Test(2,12,13);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 3 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[5]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == 5 and assignments["Moon"].pos == 5 and assignments["Mvk"].pos == positions[2]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 16) then
		HA_Test(6,7,11);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 2 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1
			and assignments["Natu"].mark == 3 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 2 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == 5 and assignments["Ant"].pos == 5 and assignments["Blink"].pos == positions[1] and assignments["Fed"].pos == positions[2]
			and assignments["Natu"].pos == 5 and assignments["Cakk"].pos == positions[1] and assignments["Moon"].pos == positions[2] and assignments["Mvk"].pos == positions[3]
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[3]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 17) then
		HA_Test(14,19,9);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 18) then
		HA_Test(14,9,19);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 2 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 3
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 19) then
		HA_Test(19,9,14);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 2
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 1
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 20) then
		HA_Test(19,14,9);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 3 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 2
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 1
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == 5) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 21) then
		HA_Test(14,9,20);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 2 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 1
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 1
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == 5
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[5]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	elseif (test == 22) then
		HA_Test(5,19,14);
		C_Timer.After(3, function()
			if (assignments["Ala"].mark == 1 and assignments["Ant"].mark == 1 and assignments["Blink"].mark == 1 and assignments["Fed"].mark == 1 
			and assignments["Natu"].mark == 2 and assignments["Cakk"].mark == 2 and assignments["Moon"].mark == 2 and assignments["Mvk"].mark == 3
			and assignments["Sloni"].mark == 3 and assignments["Janga"].mark == 3 and assignments["Sejuka"].mark == 3 and assignments["Emnity"].mark == 2
			and assignments["Ala"].pos == positions[1] and assignments["Ant"].pos == positions[2] and assignments["Blink"].pos == positions[3] and assignments["Fed"].pos == positions[5]
			and assignments["Natu"].pos == positions[1] and assignments["Cakk"].pos == positions[2] and assignments["Moon"].pos == positions[3] and assignments["Mvk"].pos == 5
			and assignments["Sloni"].pos == positions[1] and assignments["Janga"].pos == positions[2] and assignments["Sejuka"].pos == positions[3] and assignments["Emnity"].pos == positions[5]) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				return false;
			end
		end)
	end
end

function HA_Test(p1, p2, p3)
	inEncounter = true;
	if (raid == nil) then
		raid = {
			[1] = {"Pred", "Nost", "Marie", "Bram", "Dez"},
			[2] = {"Ala", "Ant", "Blink", "Fed", "Sloxy"},
			[3] = {"Natu", "Cakk", "Moon", "Mvk", "Cata"},
			[4] = {"Sloni", "Janga", "Sejuka", "Emnity", "Warlee"},
		};
	end
	resetAssignmentsData();
	debuffed = {};
	if(p1) then
		local players = {p1,p2,p3};
		for i = 1, 3 do
			C_Timer.After(i-1*0.6, function()
				local rngGroup = math.ceil(players[i]/5);
				local rngPlayer = players[i]%5;
				if (rngPlayer == 0) then
					rngPlayer = 5;
				end
				debuffed[i] = raid[rngGroup][rngPlayer];
				print(raid[rngGroup][rngPlayer]);
				local unitName = raid[rngGroup][rngPlayer];
				SetRaidTarget(unitName, #debuffed);
				local expTime = GetTime()+5;
				if (not expTime) then
					expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335112)));
				end
				if (not expTime) then
					expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335113)));
				end
				if (UnitIsConnected(unitName)) then
					C_ChatInfo.SendAddonMessage("EnRT_HA", #debuffed .. " " .. expTime, "WHISPER", unitName);
				end
				debuffsPerGroup[rngGroup] = debuffsPerGroup[rngGroup] + 1;
				if (EnRT_ContainsKey(assignments, unitName)) then
					assignments[unitName].mark = #debuffed;
					assignments[unitName].pos = 5;
				end
				assignMarks();
			end);
		end
		resetAssignmentsData();
	else
		local rngs = {};
		for i = 1, 3 do
			C_Timer.After(i-1*0.6, function()
				local rngGroup = math.random(1, 4);
				local rngPlayer = math.random(1, 5);
				while (EnRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
					rngGroup = math.random(1, 4);
					rngPlayer = math.random(1, 5);
				end
				table.insert(rngs, ((rngGroup-1)*5)+rngPlayer);
				debuffed[i] = raid[rngGroup][rngPlayer];
				print(raid[rngGroup][rngPlayer]);
				local unitName = raid[rngGroup][rngPlayer];
				SetRaidTarget(unitName, #debuffed);
				local expTime = GetTime()+5;
				if (not expTime) then
					expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335112)));
				end
				if (not expTime) then
					expTime = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(335113)));
				end
				if (UnitIsConnected(unitName)) then
					C_ChatInfo.SendAddonMessage("EnRT_HA", #debuffed .. " " .. expTime, "WHISPER", unitName);
				end
				local raidIndex = UnitInRaid(unitName);
				debuffsPerGroup[rngGroup] = debuffsPerGroup[rngGroup] + 1;
				if (EnRT_ContainsKey(assignments, unitName)) then
					assignments[unitName].mark = #debuffed;
					assignments[unitName].pos = 5;
				end
				assignMarks();
			end);
		end
		resetAssignmentsData();
	end
end