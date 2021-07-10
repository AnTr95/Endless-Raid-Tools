local L = IRTLocals;
local f = CreateFrame("Frame");
local inEncounter = false;
local leader = "";
local debuffed = {};
local playerName = GetUnitName("player");
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
};
local difficulty = 0;

local IRT_UnitDebuff = IRT_UnitDebuff;
local IRT_Contains = IRT_Contains;
local UnitIsUnit = UnitIsUnit;
local UnitIsVisible = UnitIsVisible;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_RON");

local function assignMarks()
	local count = 1;
	for i = GetNumGroupMembers(), 1, -1 do
		local raider = "raid" ..i;
		local raiderName = GetUnitName(raider, true);
		--assign by group order
		if (UnitIsVisible(raiderName) and IRT_Contains(debuffed, raiderName)) then
			SetRaidTarget(raiderName, count);
			C_ChatInfo.SendAddonMessage("IRT_RON", count, "WHISPER", raiderName);
			count = count + 1;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (IRT_RemnantOfNerzhulEnabled == nil) then IRT_RemnantOfNerzhulEnabled = true; end
	elseif (event == "UNIT_AURA" and IRT_RemnantOfNerzhulEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(leader, playerName)) then
			if (IRT_UnitDebuff(unit, GetSpellInfo(350469))) then
				if (not IRT_Contains(debuffed, unitName)) then
					debuffed[#debuffed+1] = unitName;
					if (difficulty == 16) then
						if (#debuffed == 3) then
							assignMarks();
						end
					else
						if (#debuffed == 2) then
							assignMarks();
						end
					end
				end
			else
				if (IRT_Contains(debuffed, unitName)) then
					debuffed[IRT_Contains(debuffed, unitName)] = nil;
					SetRaidTarget(unitName, 0);
				end
			end
		end
		if(UnitIsUnit(unit, playerName)) then
			if (IRT_PopupIsShown(L.BOSS_FILE) and not IRT_UnitDebuff(unit, GetSpellInfo(350469))) then
				IRT_PopupHide(L.BOSS_FILE);
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and IRT_RemnantOfNerzhulEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_RON") then
			IRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..msg..":30\124t".." MOVE TO " .. groupIcons[msg] .. " NOW " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..msg..":30\124t", 60, L.BOSS_FILE);
			PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\"..groupIcons[msg]..".ogg", "Master");
		end
	elseif (event == "ENCOUNTER_START" and IRT_RemnantOfNerzhulEnabled) then
		local eID = ...;
		if (eID == 2432) then
			difficulty = select(3, GetInstanceInfo());
			inEncounter = true;
			leader = IRT_GetRaidLeader();
			debuffed = {};
		end
	elseif (event == "ENCOUNTER_END" and IRT_RemnantOfNerzhulEnabled) then
		inEncounter = false;
		debuffed = {};
		IRT_PopupHide(L.BOSS_FILE);
	end
end);