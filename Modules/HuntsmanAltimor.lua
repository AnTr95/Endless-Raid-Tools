local L = IRTLocals;
local f = CreateFrame("Frame");
local inEncounter = false;
local leader = "";
local debuffed = {};
local raid = nil;
local assignments = {};
local playerName = GetUnitName("player");
local assignment = "";
local printDebug = true;
local testResultText = "";
local testResultsCount = 0;
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
	["4"] = "TRIANGLE",
};
local timer = nil;
local positions = {
	[1] = "BACK",
	[2] = "MID",
	[3] = "FRONT",
	[4] = "BACKUP",
	[5] = "ABORT",
};

local positionsLex = {
	["FRONT"] = 1,
	["MID"] = 2,
	["BACK"] = 3,
	["5"] = 4,
	["BACKUP"] = 5,
	["ABORT"] = 6,
};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_HA");

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
	resetAssignments();
end

local function resetAssignments()
	assignments = {};
	for mark = 1, 3 do
		assignments[mark] = {};
		local group = mark+1;
		for index, player in pairs(raid[group]) do
			if (index >= IRT_HuntsmanAltimorPlayersPerLine+1) then
				break;
			else
				assignments[mark][index] = {["name"] = player, ["mark"] = mark, ["pos"] = positions[index]};
			end
		end
	end
	C_ChatInfo.SendAddonMessage("IRT_HA", "reset", "RAID");
end

function IRT_HA_Debug()
	if (printDebug) then
		printDebug = false;
	else
		printDebug = true;
	end
end

local function printAssignments()
	local printText = "IRT Assignments:";
	for i = 1, 3 do
		printText = printText .. "\n\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_".. i .. ":12\124t"
		for idx = #assignments[i], 1, -1 do
			local pl = Ambiguate(assignments[i][idx].name, "short");
			if (UnitIsConnected(pl)) then
				pl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, pl);
			end
			if (idx > 1 and idx < IRT_HuntsmanAltimorPlayersPerLine) then
				printText = printText .. "|cFF00FF00" .. pl .. "|r|cFFFFFFFF, |r";
			elseif (idx == 1) then
				printText = printText .. "|cFF00FF00" .. pl .. "|r|cFFFFFFFF, |r" .. "\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t|c296d98FF" .. debuffed[i] .. "|r\124TInterface\\Icons\\ability_hunter_assassinate2:12\124t";
			end
		end
	end
	print(printText);
end

local function getGroup(player)
	for i = 1, 4 do 
		if (IRT_Contains(raid[i], player)) then
			return i;
		end
	end
end

local function getAssignment(player)
	for i = 1, 3 do
		for index, data in pairs(assignments[i]) do
			local pl = data.name;
			local mark = data.mark;
			local pos = data.pos;
			if (UnitIsUnit(pl, player)) then
				return index, mark, pos;
			end
		end
	end
end

local function playerNotification(mark, pos, duration)
	local chatText = "";
	if (tonumber(pos)) then --debuffed
		chatText = "{rt" .. mark .. "} " .. math.ceil(pos-GetTime()) .. " {rt" .. mark .. "}";
		IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration, L.BOSS_FILE);
	elseif (pos == positions[5]) then
		chatText = "DO NOT SOAK";
		IRT_PopupShow("|cFFFF0000DO NOT SOAK!|r", duration, L.BOSS_FILE);
	else
		chatText = "{rt" .. mark .. "} " .. pos .. " {rt" .. mark .. "}";
		IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. ", POSITION: " .. pos .. " \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration, L.BOSS_FILE);
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
	PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

local function assignMarks()
	local debuffedPlayer = debuffed[#debuffed];
	local grp = getGroup(debuffedPlayer);
	if (printDebug) then
		print(debuffedPlayer .. " in " .. grp .. " is debuffed");
	end
	if (grp ~= 1 and IRT_Contains(raid[grp], debuffedPlayer) <= IRT_HuntsmanAltimorPlayersPerLine) then --A soaker is debuffed
		if (printDebug) then
			print("a soaker is debuffed")
		end
		local index, mark, pos = getAssignment(debuffedPlayer);
		if (printDebug) then
			print("retrived data from " .. debuffedPlayer .. " mark: " .. groupIcons[tostring(mark)] .. " index: " .. index .. " position " .. pos);
		end
		table.remove(assignments[mark], index);
		if (printDebug) then
			print(debuffedPlayer .. " removed from mark " .. groupIcons[tostring(mark)] .." in index: " .. index);
		end
		for idx = index, #assignments[mark] do --decrease all positions by 1 of those after debuffed player
			assignments[mark][idx].pos = positions[idx];
			if (printDebug) then
				print(assignments[mark][idx].name .. " is moved to position " .. positions[idx] .. " on mark " .. groupIcons[tostring(mark)]);
			end
		end 
		if (#debuffed < IRT_HuntsmanAltimorPlayersPerLine-1 and grp ~= 4) then --give backup players to group 1 and 2
			local backupPlayer = table.remove(assignments[mark+1]);
			backupPlayer.mark = mark;
			backupPlayer.pos = positions[#assignments[mark]+1];
			table.insert(assignments[mark], backupPlayer);
			if (printDebug) then
				print("moving " .. backupPlayer.name .. " from mark " .. groupIcons[tostring(backupPlayer.mark+1)] .. " to mark " .. groupIcons[tostring(backupPlayer.mark)] .. " in last position" .. backupPlayer.pos);
			end
			if (mark == 1) then --give group 2 a new backup
				local backupPlayer2 = table.remove(assignments[mark+2]);
				backupPlayer2.mark = mark+1;
				backupPlayer2.pos = positions[#assignments[mark]+1];
				table.insert(assignments[mark+1], backupPlayer2);
				if (printDebug) then
					print("also moving " .. backupPlayer2.name .. " from mark " .. groupIcons[tostring(backupPlayer2.mark+1)] .. " to mark " .. groupIcons[tostring(backupPlayer2.mark)] .. " in last position" .. backupPlayer.pos);
				end
			end
		end
	end
	if (#debuffed == 3) then--make sure each group has 3 soakers
		for mark = 1, 3 do
			for otherGroup = mark+1, 3 do -- G2 iterates G3 then G4, G3 iterates G4, G4 no iteration
				if (#assignments[mark] < IRT_HuntsmanAltimorPlayersPerLine-1 and assignments[otherGroup][IRT_HuntsmanAltimorPlayersPerLine]) then
					if (printDebug) then
						print("G2 iterates G3 then G4, G3 iterates G4, G4 no iteration");
					end
					local backupPlayer = table.remove(assignments[otherGroup]);
					backupPlayer.mark = mark;
					backupPlayer.pos = positions[#assignments[mark]+1];
					table.insert(assignments[mark], backupPlayer);
					if (printDebug) then
						print("found available backup player. " .. backupPlayer.name .. " is moved from mark " .. groupIcons[tostring(otherGroup)] .. " to mark " .. groupIcons[tostring(mark)] .. " in position " .. backupPlayer.pos);
					end
				end
			end
		end
		for mark = 1, 3 do
			for otherGroup = mark-1, 1, -1 do -- G2 no iteration, G3 iterates G2, G4 iterates G3 then G2
				if (#assignments[mark] < IRT_HuntsmanAltimorPlayersPerLine-1 and assignments[otherGroup][IRT_HuntsmanAltimorPlayersPerLine]) then
					if (printDebug) then
						print("G2 no iteration, G3 iterates G2, G4 iterates G3 then G2");
					end
					local backupPlayer = table.remove(assignments[otherGroup]);
					backupPlayer.mark = mark;
					backupPlayer.pos = positions[#assignments[mark]+1];
					table.insert(assignments[mark], backupPlayer);
					if (printDebug) then
						print("found available backup player. " .. backupPlayer.name .. " is moved from mark " .. groupIcons[tostring(otherGroup)] .. " to mark " .. groupIcons[tostring(mark)] .. " in position " .. backupPlayer.pos);
					end
				end
			end
		end
		for i = 1, 3 do --remove backups
			if (assignments[i][IRT_HuntsmanAltimorPlayersPerLine] and assignments[i][IRT_HuntsmanAltimorPlayersPerLine].pos == positions[IRT_HuntsmanAltimorPlayersPerLine]) then
				if (printDebug) then
					print("dont need " .. assignments[i][IRT_HuntsmanAltimorPlayersPerLine].name .. " to soak their mark was " .. groupIcons[tostring(i)]);
				end
				assignments[i][IRT_HuntsmanAltimorPlayersPerLine].pos = positions[5];
			end
		end
		printAssignments();
	end
	for i = 1, #debuffed do
		for index, data in pairs(assignments[i]) do
			if (UnitIsConnected(data.name)) then
				C_ChatInfo.SendAddonMessage("IRT_HA", data.mark .. " ".. data.pos, "WHISPER", data.name);
			end
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (IRT_HuntsmanAltimorEnabled == nil) then IRT_HuntsmanAltimorEnabled = true; end
		if (IRT_HuntsmanAltimorPlayersPerLine == nil) then IRT_HuntsmanAltimorPlayersPerLine = 4; end
	elseif (event == "UNIT_AURA" and IRT_HuntsmanAltimorEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(leader, playerName)) then
			if (IRT_UnitDebuff(unit, GetSpellInfo(335111)) or IRT_UnitDebuff(unit, GetSpellInfo(335112)) or IRT_UnitDebuff(unit, GetSpellInfo(335113))) then
				if (not IRT_Contains(debuffed, unitName)) then
					debuffed[#debuffed+1] = unitName;
					SetRaidTarget(unitName, #debuffed);
					local expTime = math.floor(GetTime()+5);
					if (UnitIsConnected(unitName)) then
						C_ChatInfo.SendAddonMessage("IRT_HA", #debuffed .. " " .. math.floor(expTime), "WHISPER", unitName);
					end
					assignMarks();
				end
			else
				if (IRT_Contains(debuffed, unitName)) then
					debuffed[IRT_Contains(debuffed, unitName)] = nil;
					SetRaidTarget(unitName, 0);
					resetAssignments();
					if (timer) then
						timer:Cancel();
						timer = nil;
					end
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and IRT_HuntsmanAltimorEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_HA") then
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
	elseif (event == "ENCOUNTER_START" and IRT_HuntsmanAltimorEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2418 and difficulty == 16) then
			inEncounter = true;
			leader = IRT_GetRaidLeader();
			debuffed = {};
			assignment = "";
			assignments = {};
			raid = {};
			initRaid();
			if (timer) then
				timer:Cancel();
				timer = nil;
			end
		end
	elseif (event == "ENCOUNTER_END" and IRT_HuntsmanAltimorEnabled and inEncounter) then
		inEncounter = false;
		debuffed = {};
		assignments = {};
		raid = {};
		assignment = "";
		if (timer) then
			timer:Cancel();
			timer = nil;
		end
		IRT_PopupHide(L.BOSS_FILE);
	end
end);

function testResults(test)
	if (test == 0) then
		testResultsCount = 0;
		testResultText = "Tested test 1 to 25\n";
		for i = 1, 25 do 
			C_Timer.After((i-1)*4, function() 
				testResults(i);
			end);
		end
		C_Timer.After(25*4, function()
			testResultText = testResultText .. testResultsCount .. "/25 tests failed";
			print(testResultText);
		end);
	elseif (test == 1) then
		HA_Test(1,2,3);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[1][4].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[2][4].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[3][4].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3] and assignments[2][4].pos == positions[5]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3] and assignments[3][4].pos == positions[5]
			and #assignments[1] == 4 and #assignments[2] == 4 and #assignments[3] == 4) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 2) then
		HA_Test(6,7,8);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][2].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[1][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 3) then
		HA_Test(13,12,11);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Mvk" and assignments[2][2].name == "Emnity" and assignments[2][3].name == "Sejuka"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Fed"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 4) then
		HA_Test(18,19,17);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[3][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[3][2].name == "Mvk"
			and assignments[3][1].name == "Sloni"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 5) then
		HA_Test(1,7,2);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][4].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[2][4].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3] and assignments[2][4].pos == positions[5]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 4 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 6) then
		HA_Test(8,6,14);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][3].name == "Emnity"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 7) then
		HA_Test(8,12,16);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Moon" and assignments[3][3].name == "Mvk"
		    and assignments[3][1].name == "Janga" and assignments[3][2].name == "Sejuka" and assignments[2][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" .. test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 8) then
		HA_Test(5,6,20);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][4].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[2][4].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3] and assignments[2][4].pos == positions[5]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 4 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
			end
		end)
	elseif (test == 9) then
		HA_Test(16,7,8);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][3].name == "Mvk"
			and assignments[3][1].name == "Janga" and assignments[3][2].name == "Sejuka" and assignments[3][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 10) then
		HA_Test(17,14,6);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Sejuka" and assignments[3][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 11) then
		HA_Test(16,18,5);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[1][4].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[3][3].name == "Mvk"
			and assignments[3][1].name == "Janga" and assignments[3][2].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 12) then
		HA_Test(16,18,9);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[3][3].name == "Mvk"
			and assignments[3][1].name == "Janga" and assignments[3][2].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 13) then
		HA_Test(11,12,19);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[3][3].name == "Fed"
			and assignments[2][1].name == "Moon" and assignments[2][2].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[2][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 14) then
		HA_Test(9,14,19);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 15) then
		HA_Test(2,12,13);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[1][4].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[2][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 16) then
		HA_Test(6,7,11);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Blink" and assignments[1][2].name == "Fed"
			and assignments[2][1].name == "Cakk" and assignments[2][2].name == "Moon" and assignments[1][3].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[2][3].name == "Sejuka" and assignments[3][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 17) then
		HA_Test(14,19,9);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 18) then
		HA_Test(14,9,19);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 19) then
		HA_Test(19,9,14);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 20) then
		HA_Test(19,14,9);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 21) then
		HA_Test(14,9,20);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[1][4].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 22) then
		HA_Test(5,19,14);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ala" and assignments[1][2].name == "Ant" and assignments[1][3].name == "Blink" and assignments[1][4].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] ==3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 23) then
		HA_Test(6,11,1);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Cakk" and assignments[2][2].name == "Moon" and assignments[1][4].name == "Mvk"
			and assignments[3][1].name == "Sloni" and assignments[3][2].name == "Janga" and assignments[3][3].name == "Sejuka" and assignments[2][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 24) then
		HA_Test(16,19,6);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[3][3].name == "Mvk"
			and assignments[3][1].name == "Janga" and assignments[3][2].name == "Sejuka"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 3 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
				return false;
			end
		end)
	elseif (test == 25) then
		HA_Test(16,6,5);
		C_Timer.After(3, function()
			if (assignments[1][1].name == "Ant" and assignments[1][2].name == "Blink" and assignments[1][3].name == "Fed"
			and assignments[2][1].name == "Natu" and assignments[2][2].name == "Cakk" and assignments[2][3].name == "Moon" and assignments[1][4].name == "Mvk"
			and assignments[3][1].name == "Janga" and assignments[3][2].name == "Sejuka" and assignments[3][3].name == "Emnity"
			and assignments[1][1].pos == positions[1] and assignments[1][2].pos == positions[2] and assignments[1][3].pos == positions[3] and assignments[1][4].pos == positions[5]
			and assignments[2][1].pos == positions[1] and assignments[2][2].pos == positions[2] and assignments[2][3].pos == positions[3]
			and assignments[3][1].pos == positions[1] and assignments[3][2].pos == positions[2] and assignments[3][3].pos == positions[3]
			and #assignments[1] == 4 and #assignments[2] == 3 and #assignments[3] == 3) then
				print("TEST" ..test.. " PASS");
				return true;
			else
				print("TEST" ..test.. " FAIL");
				testResultsCount = testResultsCount + 1;
				testResultText = testResultText .. "TEST" .. test .. " FAIL\n";
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
	resetAssignments();
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
					expTime = select(7, IRT_UnitDebuff(unit, GetSpellInfo(335112)));
				end
				if (not expTime) then
					expTime = select(7, IRT_UnitDebuff(unit, GetSpellInfo(335113)));
				end
				if (UnitIsConnected(unitName)) then
					C_ChatInfo.SendAddonMessage("IRT_HA", #debuffed .. " " .. expTime, "WHISPER", unitName);
				end
				assignMarks();
			end);
		end
		resetAssignments();
	else
		local rngs = {};
		for i = 1, 3 do
			C_Timer.After(i-1*0.6, function()
				local rngGroup = math.random(1, 4);
				local rngPlayer = math.random(1, 5);
				while (IRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
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
					expTime = select(7, IRT_UnitDebuff(unit, GetSpellInfo(335112)));
				end
				if (not expTime) then
					expTime = select(7, IRT_UnitDebuff(unit, GetSpellInfo(335113)));
				end
				if (UnitIsConnected(unitName)) then
					C_ChatInfo.SendAddonMessage("IRT_HA", #debuffed .. " " .. expTime, "WHISPER", unitName);
				end
				assignMarks();
			end);
		end
		resetAssignments();
	end
end
