local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local leader = "";
local hasAssigned = false;
local raid = nil;
local debuffed = {};
local hasDebuff = false;
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
	["4"] = "TRIANGLE",
};

local spellIDs = {
	["Miasma"] = GetSpellInfo(329298),
	["Sap"] = GetSpellInfo(344755),
};


C_ChatInfo.RegisterAddonMessagePrefix("EnRT_HD");

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");

local function initRaid()
	raid = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	};
	for i = 1, 40 do
		local name, rank, group, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (name) then
			if (raid[group]) then
				table.insert(raid[group], name);
			end
		end
	end
end

local function compare(a, b)
	if (a[2] == b[2]) then
		return EnRT_Contains(raid[a[2]], a[1]) > EnRT_Contains(raid[b[2]], b[1]);
	end
	return a[2] < b[2];
end

local function updateGroups()
	local debuffedGroups = {
		[1] = 0, 
		[2] = 0, 
		[3] = 0, 
		[4] = 0,
	};
	--initial debuff fill
	for player, group in pairs(debuffed) do
		debuffedGroups[group] = debuffedGroups[group] + 1;
	end
	--sort grps to avoid players going from g1 to g4
	local sortedDebuffed = {};
	for k, v in pairs(debuffed) do
		table.insert(sortedDebuffed, {k, v});
	end
	table.sort(sortedDebuffed, compare);
	--debuff spread
	for index, data in pairs(sortedDebuffed) do
		local group = data[2];
		local player = data[1];
		if (debuffedGroups[group] > 1) then
			for i = 1, 4 do
				if (debuffedGroups[i] == 0) then
					debuffedGroups[group] = debuffedGroups[group] - 1;
					debuffedGroups[i] = 1;
					table.insert(raid[i], player);
					table.remove(raid[group], EnRT_Contains(raid[group], player));
					SetRaidTarget(player, i);
					break;
				end
			end
		else
			SetRaidTarget(player, group);
		end
	end
	--fill groups
	for grp = 1, 4 do
		if (#raid[grp] > 5) then
			for i = 1, #raid[grp] do --for each player reversed
				if (#raid[grp] > 5) then -- during each iteration make sure still more than 5
					local player = raid[grp][#raid[grp]+1-i];
					if (not EnRT_UnitDebuff(player, spellIDs["Sap"]) and not EnRT_ContainsKey(debuffed, player) and UnitGroupRolesAssigned(player) ~= "TANK") then --Dont swap debuffed players nor players that cant soak because still debuffed nor tanks
						for newGrp = 1, 4 do
							if (#raid[newGrp] < 5) then
								table.insert(raid[newGrp], player);
								table.remove(raid[grp], EnRT_Contains(raid[grp], player));
								break;
							end
						end
					end
				else
					break;
				end
			end
		end
		--[[
		while (#raid[i] > 5) do
			print("grp " .. i .. " is more than 5")
			for index, player in pairs(raid[i]) do
				if (not EnRT_UnitDebuff(player, spellIDs["Sap"]) and not EnRT_ContainsKey(debuffed, player)) then
					for j = 1, 4 do
						if (#raid[j] < 5) then
							table.insert(raid[j], player);
							table.remove(raid[i], EnRT_Contains(raid[i], player));
							goto retry;
						end
					end
				end
			end
			::retry::
		end]]
	end
	local printText = "EnRT Assignments:\n";
	local count = 0;
	for grp = 1, 4 do
		count = 0;
		printText = printText .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. grp .. ":12\124t";
		for index, player in pairs(raid[grp]) do
			local playerShort = Ambiguate(player, "short");
			if (index > 1) then
				printText = printText .. ", ";
			else
				printText = printText .. " ";
			end
			if (UnitIsConnected(player)) then -- add icons for 1st and 2nd soak and debuff & CHECK DEBUFF DOESNT TIME OUT NEXT 2s
				if (EnRT_ContainsKey(debuffed, player)) then
					--spam icon over head
					C_ChatInfo.SendAddonMessage("EnRT_HD", grp, "WHISPER", player);
					printText = printText .. "|c296d98FF\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t" .. playerShort .. "\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t|cFFFFFFFF";
				elseif (not EnRT_UnitDebuff(player, spellIDs["Sap"]) and count < 2)then
					C_ChatInfo.SendAddonMessage("EnRT_HD", grp, "WHISPER", player);
					count = count + 1;
					printText = printText .. "|cFF00FF00" .. playerShort .. "|cFFFFFFFF";
				elseif (count == 2) then
					if (EnRT_UnitDebuff(player, spellIDs["Sap"])) then
						printText = printText .. "|cFFFF0000\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t" .. playerShort .. "\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t|cFFFFFFFF";
					else
						printText = printText .. "|cFFFF0000" .. playerShort .. "|cFFFFFFFF";
					end
					C_ChatInfo.SendAddonMessage("EnRT_HD", "next " .. grp, "WHISPER", player);
				else
					-- got debuff but count less than 2 atm
					local lowestDebuff1 = 100000;
					local lowestDebuff2 = 100000;
					if (EnRT_UnitDebuff(player, spellIDs["Sap"])) then
						local stacks = select(4, EnRT_UnitDebuff(player, spellIDs["Sap"]));
						lowestDebuff1 = stacks;
						lowestDebuff2 = stacks;
						for idx, pl in pairs(raid[grp]) do
							if (count == 0) then
								if (select(4, EnRT_UnitDebuff(pl, spellIDs["Sap"]))) then
									local nextStacks = select(4, EnRT_UnitDebuff(pl, spellIDs["Sap"]));
									if (nextStacks < lowestDebuff1) then
										lowestDebuff1 = -1;
										--1 better option palyer out of 2
									elseif (nextStacks < lowestDebuff2) then
										--2 better option player this player soaks later
										printText = printText .. "|cFFFF0000(\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t" .. playerShort .. "\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t)|cFFFFFFFF";
										C_ChatInfo.SendAddonMessage("EnRT_HD", "next " .. grp, "WHISPER", player);
										break;
									end
								end
							elseif (count == 1) then
								if (select(4, EnRT_UnitDebuff(pl, spellIDs["Sap"]))) then
									local nextStacks = select(4, EnRT_UnitDebuff(pl, spellIDs["Sap"]));
									if (nextStacks < lowestDebuff1) then
										--better option player this player soaks later
										printText = printText .. "|cFFFF0000\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t" .. playerShort .. "\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t|cFFFFFFFF";
										C_ChatInfo.SendAddonMessage("EnRT_HD", "next " .. grp, "WHISPER", player);
										break;
									end
								end
							end
							-- best option player soak now
							C_ChatInfo.SendAddonMessage("EnRT_HD", grp, "WHISPER", player);
							printText = printText .. "|cFF00FF00\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t" .. playerShort .. "\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t|cFFFFFFFF";
							count = count + 1;
						end
					end
				end
				--[[
				previous version tested and works
				if ((EnRT_UnitDebuff(player, spellIDs["Sap"]) and not EnRT_ContainsKey(debuffed, player)) or (count == 2 and not EnRT_ContainsKey(debuffed, player))) then
					if (EnRT_UnitDebuff(player, spellIDs["Sap"])) then
						printText = printText .. "|cFFFF0000(\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t" .. playerShort .. "\124TInterface\\Icons\\spell_shadow_focusedpower:12\124t)|cFFFFFFFF";
					else
						printText = printText .. "|cFFFF0000(" .. playerShort .. ")|cFFFFFFFF";
					end
					C_ChatInfo.SendAddonMessage("EnRT_HD", "soon " .. grp, "WHISPER", player);
				elseif (EnRT_ContainsKey(debuffed, player)) then
					C_ChatInfo.SendAddonMessage("EnRT_HD", grp, "WHISPER", player);
					printText = printText .. "|c296d98FF\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t" .. playerShort .. "\124TInterface\\Icons\\ability_deathknight_frozencenter:12\124t|cFFFFFFFF";
				else
					C_ChatInfo.SendAddonMessage("EnRT_HD", grp, "WHISPER", player);
					count = count + 1;
					printText = printText .. "|cFF00FF00" .. playerShort .. "|cFFFFFFFF";
				end]]
			end
		end
		if (grp < 4) then
			printText = printText .. "\n";
		end
	end
	print(printText);
end

local function playerNotification(mark, duration)
	local chatText = "{rt" .. mark .. "}";
	if (hasDebuff) then
		chatText = chatText .. " DEBUFFED " .. "{rt" .. mark .. "}";
		duration = 24;
	end
	SendChatMessage(chatText, "YELL");
	local ticker = C_Timer.NewTicker(1.5, function()
		if (UnitIsDead("player")) then
			ticker:Cancel();
		else
			SendChatMessage(chatText, "YELL");
		end
	end, math.floor(duration/1.5)-1);
	EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." SOAK " .. groupIcons[mark] .. " NOW " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", duration);
	PlaySoundFile("Interface\\AddOns\\EndlessRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_HungeringDestroyerEnabled == nil) then EnRT_HungeringDestroyerEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter and EnRT_HungeringDestroyerEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(unitName, playerName)) then
			if (EnRT_UnitDebuff(unitName, spellIDs["Miasma"])) then
				hasDebuff = true;
			elseif (hasDebuff) then
				hasDebuff = false;
			end
		end
		if (UnitIsUnit(leader, playerName)) then
			if (EnRT_UnitDebuff(unit, spellIDs["Miasma"])) then
				if (not EnRT_ContainsKey(debuffed, unitName)) then
					for i = 1, 4 do
						if (EnRT_Contains(raid[i], unitName)) then
							debuffed[unitName] = EnRT_Contains(raid, unitName);
							break;
						end
					end
					if (#debuffed == 4 and not hasAssigned) then
						hasAssigned = true;
						updateGroups();
					end
				end
			else
				if (EnRT_ContainsKey(debuffed, unitName)) then
					debuffed[unitName] = nil;
					SetRaidTarget(unitName, 0);
					hasAssigned = false;
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and inEncounter and EnRT_HungeringDestroyerEnabled) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_HD") then
			if (msg:match("next")) then
				local text, mark = strsplit(" ", msg);
				EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. ", |cFFFF0000DO NOT SOAK|cFFFFFFFF" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", 8);
			else
				playerNotification(msg, 24);
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_HungeringDestroyerEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2383 and difficulty == 16) then
			inEncounter = true;
			raid = {};
			leader = EnRT_GetRaidLeader();
			hasDebuff = false;
			initRaid();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_HungeringDestroyerEnabled and inEncounter) then
		raid = {};
		inEncounter = false;
		debuffed = {};
		hasDebuff = false;
	end
end);

function HD_Test(p1, p2, p3, p4)
	inEncounter = true;
	if (raid == nil) then
		raid = {
			[1] = {"Ant", "Ala", "Fed", "Blink", "Dez"},
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
			while (EnRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
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
			while (EnRT_Contains(rngs, ((rngGroup-1)*5)+rngPlayer)) do
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