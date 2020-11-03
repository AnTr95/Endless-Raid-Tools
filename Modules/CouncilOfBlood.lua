local L = IRTLocals;

local f = CreateFrame("Frame");
local inEncounter = false;
local partner = nil;
local debuffed1 = {};
local debuffed2 = {}
local playerName = UnitName("player");
local timer = nil;
local ticks = 0;
local expTime = 0;
local dfDebuffs = {};
local leader = nil;

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_TCOB");

local function onUpdate(self, elapsed) 
	if (IRT_TheCouncilOfBloodEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			if (partner) then
				if (IsItemInRange(63427, partner)) then
					f:SetScript("OnUpdate", nil);
					local moveTime = math.floor(expTime - GetTime())%4;
					if (moveTime == 0) then
						moveTime = 4;
					end
					IRT_PopupShow("MOVE IN " .. moveTime, 1, L.BOSS_FILE);
					timer = C_Timer.NewTicker(1, function()
						local moveTime = math.floor(expTime - GetTime())%4;
						if (moveTime == 0) then
							IRT_PopupShow("MOVE NOW!", 1, L.BOSS_FILE);
						else
							IRT_PopupShow("MOVE IN " .. moveTime, 1, L.BOSS_FILE);
						end
					end, math.floor(expTime-GetTime()));
				end
			end
			ticks = 0;
		end
	else
		f:SetScript("OnUpdate", nil);
	end
end

local function getPartner()
	for i = 1, #debuffed1 do
		if (UnitIsUnit(playerName, debuffed1[i])) then
			return debuffed2[i];
		elseif (UnitIsUnit(playerName, debuffed2[i])) then
			return debuffed1[i];
		end
	end
end

local function notify()
	partner = getPartner();
	if (partner) then
		if (UnitIsConnected(partner)) then
			local partnerColor = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(partner))].colorStr, partner);
			IRT_PopupShow("MOVE TO " .. partnerColor, 8, L.BOSS_FILE);
		else
			IRT_PopupShow("MOVE TO " .. partner, 8, L.BOSS_FILE);
		end
		expTime = math.ceil(GetTime()+8);
		f:SetScript("OnUpdate", onUpdate);
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
	local addonText = "";
	local sortedArray = {};
	for pl, stacks in pairs(dfDebuffs) do
		local role = UnitGroupRolesAssigned(pl);
		if (role == "TANK") then
			role = "DAMAGER";
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
			jumpText = jumpText .. "\n|cFFFFFFFF" .. math.ceil(math.ceil(i/4)) .. ".|r ";
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
		if (IRT_TCOB_DFEnabled == nil) then IRT_TCOB_DFEnabled = true; end
		if (IRT_TCOB_DREnabled == nil) then IRT_TCOB_DREnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and IRT_TCOB_DFEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_TCOB") then
			if (msg == "hide") then
				IRT_InfoBoxHide();
			else
				convertMsgToInfoBox(msg);
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and inEncounter) then
		local _, logEvent, _, _, _, _, _, _, target, _, _, spellID, _, _, _, stacks = CombatLogGetCurrentEventInfo();
		if (logEvent == "SPELL_AURA_APPLIED") then
			if (IRT_TCOB_DREnabled) then
				if (spellID == 331637) then
					table.insert(debuffed1, target);
					if (not hasAssigned) then
						hasAssigned = true;
						C_Timer.After(0.1, function() notify(); end);
					end
				elseif (spellID == 331636) then --335294?
					table.insert(debuffed2, target);
				end
			end
			if (IRT_TCOB_DFEnabled and UnitIsUnit(leader, playerName) and spellID == 347350) then
				if (dfDebuffs[target] == nil) then
					dfDebuffs[target] = 3;
					updateDF();
				end
			end
		elseif (logEvent == "SPELL_AURA_REMOVED") then
			if (UnitIsUnit(target, playerName) and (spellID == 331637 or spellID == 331636) and IRT_TCOB_DREnabled) then
				if (timer) then
					timer:Cancel();
					timer = nil;
				end
				debuffed1 = {};
				debuffed2 = {};
				partner = nil;
				f:SetScript("OnUpdate", nil);
			elseif (UnitIsUnit(playerName, leader) and spellID == 347350 and IRT_TCOB_DFEnabled) then
				dfDebuffs[target] = nil;
				if (#dfDebuffs > 0) then
					updateDF();
				else
					C_ChatInfo.SendAddonMessage("IRT_TCOB", "hide", "RAID");
				end
			end
		elseif (UnitIsUnit(playerName, leader) and logEvent == "SPELL_AURA_REMOVED_DOSE" and spellID == 347350 and IRT_TCOB_DFEnabled) then
			dfDebuffs[target] = stacks;
			updateDF();
		end
	elseif (event == "ENCOUNTER_START" and (IRT_TCOB_DFEnabled or IRT_TCOB_DREnabled)) then
		local eID = ...;
		if (eID == 2412) then
			inEncounter = true;
			if (timer) then
				timer:Cancel();
				timer = nil;
			end
			f:SetScript("OnUpdate", nil);
			debuffed1 = {};
			debuffed2 = {};
			partner = nil;
			expTime = 0;
			leader = IRT_GetRaidLeader();
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and (IRT_TCOB_DREnabled or IRT_TCOB_DFEnabled)) then
		inEncounter = false;
		if (timer) then
			timer:Cancel();
			timer = nil;
		end
		f:SetScript("OnUpdate", nil);
		debuffed1 = {};
		debuffed2 = {};
		partner = nil;
		expTime = 0;
	end 
end);