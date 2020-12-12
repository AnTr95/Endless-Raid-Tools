local L = IRTLocals;
local spellIDs = {
	[2139] = "",
	[147362] = "",
	[47528] = "",
	[47476] = "", 
	[78675] = "", 
	[96231] = "", 
	[15487] = "", 
	[1766] = "", 
	[57994] = "", 
	[6552] = "", 
	[116705] = "", 
	[106839] = "", 
	[183752] = "", 
	[187707] = "", 
	[171138] = "", 
	[119910] = "",
};
local fontStrings = {};
local namePlateIDs = {};
local inEncounter = false;
local trackedInterrupter = nil;
local timers = {};
local playerName = UnitName("player");
local inCombat = false;

local UnitIsUnit = UnitIsUnit;
local UnitGUID = UnitGUID;
local _G = _G;

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_REGEN_DISABLED");
f:RegisterEvent("PLAYER_REGEN_ENABLED");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_INTERRUPT");

local function getFontStringForGUID(guid)
	for fs, fsGUID in pairs(fontStrings) do
		if (guid == fsGUID) then
			return fs;
		end
	end
	return nil;
end

local function createFontString(guid, namePlate, interrupter)
	local fontString = getFontStringForGUID(guid);
	--if (namePlate and namePlate:IsShown()) then
	if (fontString) then
		if (UnitIsUnit(interrupter, playerName)) then
			fontString:SetText(L.INTERRUPT_NEXT);
		else
			interrupter = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(interrupter))].colorStr, interrupter);
			fontString:SetText(interrupter .. L.INTERRUPT_NEXT2);
		end
		fontString:SetFont("Fonts\\frizqt__.ttf", 16);
		fontString:ClearAllPoints();
		fontString:SetPoint("BOTTOM", namePlate, "TOP", 0, 2);
		fontStrings[fontString] = guid;
		fontString:Show();
		if (timers[fontString]) then
			timers[fontString]:Cancel();
		end
		timers[fontString] = C_Timer.NewTimer(30, function()
			fontString:Hide();
			fontString:ClearAllPoints();
			fontStrings[fontString] = "";
		end);
		return fontString;
	end
	for fs, fsGUID in pairs(fontStrings) do
		if (fsGUID == "") then
			if (UnitIsUnit(interrupter, playerName)) then
				fs:SetText(L.INTERRUPT_NEXT);
			else
				interrupter = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(interrupter))].colorStr, interrupter);
				fs:SetText(interrupter .. L.INTERRUPT_NEXT2);
			end
			fs:ClearAllPoints();
			fs:SetPoint("BOTTOM", namePlate, "TOP", 0, 2);
			fs:SetFont("Fonts\\frizqt__.ttf", 16);
			fs:Show();
			fontStrings[fs] = guid;
			if (timers[fs]) then
				timers[fs]:Cancel();
			end
			timers[fs] = C_Timer.NewTimer(30, function()
				fs:Hide();
				fs:ClearAllPoints();
				fontStrings[fs] = "";
			end);
			return fs;
		end
	end
	fontString = f:CreateFontString("IRT_INTERRUPT_"..(#fontStrings+1), "ARTWORK", "GameFontNormal");
	if (UnitIsUnit(interrupter, playerName)) then
		fontString:SetText(L.INTERRUPT_NEXT);
	else
		interrupter = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(interrupter))].colorStr, interrupter);
		fontString:SetText(interrupter .. L.INTERRUPT_NEXT2);
	end
	fontString:SetFont("Fonts\\frizqt__.ttf", 16);
	fontString:ClearAllPoints();
	fontString:SetPoint("BOTTOM", namePlate, "TOP", 0, 2);
	fontString:Show();
	fontStrings[fontString] = guid;
	if (timers[fontString]) then
		timers[fontString]:Cancel();
	end
	timers[fontString] = C_Timer.NewTimer(30, function()
		fontString:Hide();
		fontString:ClearAllPoints();
		fontStrings[fontString] = "";
	end);
	return fontString;
end

local function removeFontString(guid, fs)
	namePlateIDs[guid] = nil;
	if (fs) then
		fs:SetText("");
		fontStrings[fs] = "";
		fs:ClearAllPoints();
		fs:Hide();
		if (timers[fs]) then
			timers[fs]:Cancel();
		end
		return fs;
	end
	for fs, fsGUID in pairs(fontStrings) do
		if (fsGUID == guid) then
			fs:SetText("");
			fs:ClearAllPoints();
			fontStrings[fs] = "";
			fs:Hide();
			if (timers[fs]) then
				timers[fs]:Cancel();
			end
			return fs;
		end
	end
end


local function getNamePlateForGUID(guid)
	for i = 1, 40 do
		local npGUID = UnitGUID("nameplate"..i);
		if (npGUID and UnitIsUnit(npGUID, guid)) then
			local npID = "nameplate"..i;
			local namePlate = C_NamePlate.GetNamePlateForUnit(npID);
			namePlateIDs[guid] = namePlate;
			return namePlate;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_InterruptEnabled == nil) then IRT_InterruptEnabled = true; end
		if (IRT_NextInterrupt == nil) then IRT_NextInterrupt = {[1] = {bossID = 1}}; end
		if (type(IRT_NextInterrupt)) == "string" then IRT_NextInterrupt = {[1] = {bossID = 1}}; end-- convert people from older version
	elseif (event == "CHAT_MSG_ADDON" and IRT_InterruptEnabled and (inEncounter or inCombat)) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_INTERRUPT") then
			local guid, player, interrupted = strsplit(" ", msg);
			if (interrupted == "true") then
				C_Timer.After(0.1, function()	
					local fs = getFontStringForGUID(guid);
					if ((fs and fs:GetText():match(player)) or (fs and fs:GetText():match(L.INTERRUPT_NEXT) and UnitIsUnit(player, playerName))) then
						removeFontString(guid, fs);
					end
				end);
			else	
				if (namePlateIDs[guid]) then
					createFontString(guid, namePlateIDs[guid], player);
				else
					createFontString(guid, getNamePlateForGUID(guid), player);
				end
			end
		end
	elseif (event == "NAME_PLATE_UNIT_REMOVED" and IRT_InterruptEnabled and (inEncounter or inCombat)) then
		local unit = ...;
		local guid = UnitGUID(unit);
		local namePlate = getFontStringForGUID(guid);
		if (namePlate) then
			removeFontString(guid, namePlate);
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and IRT_InterruptEnabled and trackedInterrupter and (inEncounter or inCombat)) then
		local _, logEvent, _, _, caster, _, _, targetGUID, target, _, _, spellID = CombatLogGetCurrentEventInfo();
		if (logEvent == "SPELL_CAST_SUCCESS") then
			if (caster and UnitIsUnit(caster, trackedInterrupter) and spellIDs[spellID]) then
				local namePlate = namePlateIDs[targetGUID];
				if (namePlate) then
					C_ChatInfo.SendAddonMessage("IRT_INTERRUPT", targetGUID .. " " .. playerName .. " false", "RAID");
				else
					getNamePlateForGUID(targetGUID);
					C_ChatInfo.SendAddonMessage("IRT_INTERRUPT", targetGUID .. " " .. playerName .. " false", "RAID");
				end
				IRT_PopupShow(L.INTERRUPT_NEXT_POPUP, 8, L.INTERRUPT_FILE);
			elseif (UnitIsUnit(caster, playerName)) then
				if (spellIDs[spellID]) then
					IRT_PopupHide(L.INTERRUPT_FILE);
					C_ChatInfo.SendAddonMessage("IRT_INTERRUPT", targetGUID .. " " .. caster .. " true", "RAID");
				end
			end
		elseif (logEvent == "UNIT_DEAD") then
			local fontString = getFontStringForGUID(targetGUID);
			if (fontString) then
				removeFontString(targetGUID, fontString);
			else
				removeFontString(targetGUID);
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_InterruptEnabled) then
		inEncounter = true;
		local eID = ...;
		for i = 1, #IRT_NextInterrupt do
			if (eID == IRT_NextInterrupt[i].bossID) then
				trackedInterrupter = IRT_NextInterrupt[i].NextInterrupter;
				break;
			end
		end
		if (trackedInterrupter and (not UnitExists(trackedInterrupter) or not UnitIsConnected(trackedInterrupter)) and select(2, GetInstanceInfo()) == "raid") then
			print(L.INTERRUPT_ERROR1 .. "|cFFFFFFFF" .. trackedInterrupter .. "|r" .. L.INTERRUPT_ERROR2);
			trackedInterrupter = nil;
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_InterruptEnabled) then
		inEncounter = false;
		trackedInterrupter = nil;
		namePlateIDs = {};
		for fs, guid in pairs(fontStrings) do
			fs:SetText("");
			fontStrings[fs] = "";
			fs:ClearAllPoints();
			fs:Hide();
			if (timers[fs]) then
				timers[fs]:Cancel();
			end
		end
		IRT_PopupHide(L.INTERRUPT_FILE);
	elseif (event == "PLAYER_REGEN_DISABLED" and IRT_InterruptEnabled and not inCombat) then
		if (select(2, GetInstanceInfo()) ~= "raid") then
			inCombat = true;
			for i = 1, #IRT_NextInterrupt do
				if (-1 == IRT_NextInterrupt[i].bossID) then
					trackedInterrupter = IRT_NextInterrupt[i].NextInterrupter;
					break;
				end
			end
		end
	elseif (event == "PLAYER_REGEN_ENABLED" and inCombat and IRT_InterruptEnabled) then
		inCombat = false;
		trackedInterrupter = nil;
		namePlateIDs = {};
		for fs, guid in pairs(fontStrings) do
			fs:SetText("");
			fontStrings[fs] = "";
			fs:ClearAllPoints();
			fs:Hide();
			if (timers[fs]) then
				timers[fs]:Cancel();
			end
		end
		IRT_PopupHide(L.INTERRUPT_FILE);
	end
end)