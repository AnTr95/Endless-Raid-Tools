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

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

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


f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_TheCouncilOfBloodEnabled == nil) then IRT_TheCouncilOfBloodEnabled = true; end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and IRT_TheCouncilOfBloodEnabled and inEncounter) then
		local _, logEvent, _, _, _, _, _, _, target, _, _, spellID = CombatLogGetCurrentEventInfo();
		if (logEvent == "SPELL_AURA_APPLIED") then
			if (spellID == 331637) then
				table.insert(debuffed1, target);
				if (not hasAssigned) then
					hasAssigned = true;
					C_Timer.After(0.1, function() notify(); end);
				end
			elseif (spellID == 331636) then --335294?
				table.insert(debuffed2, target);
			end
		elseif (logEvent == "SPELL_AURA_REMOVED" and UnitIsUnit(target, playerName)) then
			if (timer) then
				timer:Cancel();
				timer = nil;
			end
			debuffed1 = {};
			debuffed2 = {};
			partner = nil;
			f:SetScript("OnUpdate", nil);
		end
	elseif (event == "ENCOUNTER_START" and IRT_TheCouncilOfBloodEnabled) then
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
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_TheCouncilOfBloodEnabled) then
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