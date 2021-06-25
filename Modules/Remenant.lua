local L = IRTLocals;

local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = UnitName("player");
local dfDebuffs = {};
local leader = nil;
local printDebug = false;

local IRT_UnitDebuff = IRT_UnitDebuff;
local UnitIsUnit = UnitIsUnit;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local Ambiguate = Ambiguate;
local UnitIsConnected = UnitIsConnected;
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo;
local strsplit = strsplit;

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_TCOB");

function IRT_TCOB_Debug()
	if (printDebug) then
		printDebug = false;
	else
		printDebug = true;
	end
end

local function compare(a, b)
	if (a[3] == b[3]) then
		return a[2] < b[2];
	else
		return a[3] < b[3];
	end
end

local function updateDF()
	if (printDebug) then
		print("updating df list")
	end
	local addonText = "";
	local sortedArray = {};
	for pl, stacks in pairs(dfDebuffs) do
		local role = UnitGroupRolesAssigned(pl);
		if (role == "TANK") then
			role = "DAMAGER";
		end
		if (printDebug) then
			print(pl .. " has " .. stacks .. " stacks and is a " .. role)
		end
		local tbl = {Ambiguate(pl, "short"), stacks, role};
		table.insert(sortedArray, tbl);
	end
	table.sort(sortedArray, compare);
	for i, data in ipairs(sortedArray) do
		if (i < #sortedArray) then
			addonText = addonText .. data[1] .. " " .. data[2] .. " ";
		else
			addonText = addonText .. data[1] .. " " .. data[2];
		end
	end
	C_ChatInfo.SendAddonMessage("IRT_TCOB", addonText, "RAID");
end

local function convertMsgToInfoBox(msg)
	local splitText = {strsplit(" ", msg)};
	local jumpText = "Player - Stacks:";
	for i = 1, #splitText do
		if (i%2==1) then
			jumpText = jumpText .. "\n|cFFFFFFFF" .. math.ceil(math.ceil(i/2)) .. ".|r ";
		end
		if (UnitIsConnected(splitText[i])) then
			local colorPl = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(splitText[i]))].colorStr, splitText[i]);
			jumpText = jumpText .. colorPl .. " - ";
		else
			jumpText = jumpText .. splitText[i];
		end
	end
	IRT_InfoBoxShow(jumpText, 30);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_TheCouncilOfBloodEnabled == nil) then IRT_TheCouncilOfBloodEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and IRT_TheCouncilOfBloodEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_TCOB") then
			if (msg == "hide") then
				IRT_InfoBoxHide();
			else
				if (printDebug) then
					print("converting data")
					print(msg)
				end
				convertMsgToInfoBox(msg);
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and inEncounter and IRT_TheCouncilOfBloodEnabled) then
		local _, logEvent, _, _, _, _, _, _, target, _, _, spellID, _, _, _, stacks = CombatLogGetCurrentEventInfo();
		if (logEvent == "SPELL_AURA_APPLIED") then
			if (UnitIsUnit(leader, playerName) and spellID == 350469) then
				if (dfDebuffs[target] == nil) then
					if (printDebug) then
						print(target .. " got df debuff 3 stacks applied")
					end
					dfDebuffs[target] = 3;
					updateDF();
				end
			end
		elseif (logEvent == "SPELL_AURA_REMOVED") then
			if (UnitIsUnit(playerName, leader) and spellID == 350469) then
				dfDebuffs[target] = nil;
				if (next(dfDebuffs)) then
					if (printDebug) then
						print(target .. " got debuff removed still " ..#dfDebuffs .. " debuffs")
					end
					updateDF();
				else
					if (printDebug) then
						print("hiding infobox 0 debuffs")
					end
					C_ChatInfo.SendAddonMessage("IRT_TCOB", "hide", "RAID");
				end
			end
		elseif (UnitIsUnit(playerName, leader) and logEvent == "SPELL_AURA_REMOVED_DOSE" and spellID == 350469) then
			if (printDebug) then
				print(target .. " lost a stack now at " .. stacks .. " stacks")
			end
			dfDebuffs[target] = stacks;
			updateDF();
		end
	elseif (event == "ENCOUNTER_START" and IRT_TheCouncilOfBloodEnabled) then
		local eID = ...;
		if (eID == 2444) then
			if (printDebug) then
				print("council engaged")
			end
			inEncounter = true;
			leader = IRT_GetRaidLeader();
			dfDebuffs = {};
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_TheCouncilOfBloodEnabled) then
		inEncounter = false;
		dfDebuffs = {};
		IRT_InfoBoxHide();
	end 
end);

function DF_Test()
	inEncounter = true;
	leader = playerName
	local raid = {
		[1] = {"Ant", "Ala", "Fed", "Blink", "Dez"},
		[2] = {"Pred", "Nost", "Marie", "Cakk", "Sejuka"},
		[3] = {"Natu", "Moon", "Bram", "Cata", "Mvk"},
		[4] = {"Sloni", "Janga", "Sloxy", "Emnity", "Warlee"},
	};
	dfDebuffs = {};
	for i = 1, 5 do
		local rngGroup = math.random(1, 4);
		local rngPlayer = math.random(1, 5);
		while (dfDebuffs[raid[rngGroup][rngPlayer]]) do
			rngGroup = math.random(1, 4);
			rngPlayer = math.random(1, 5);
		end
		dfDebuffs[raid[rngGroup][rngPlayer]] = 3;
		if (printDebug) then
			print(raid[rngGroup][rngPlayer])
		end
	end
	updateDF();
end