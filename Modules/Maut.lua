local f = CreateFrame("Frame");

--MASTER LOCALS
local marks = {};
local debuffedPlayers = {};

--SLAVE LOCALS
local player = UnitName("player");
local master = "";
local inEncounter = false;
local debuffed = false;
local ticks = 0;
local RED = "\124cFFFF0000";
local GREEN = "\124cFF00FF00";
local assignmentComplete = false;
local state = "";
local healers = {};

for i = 1, 8 do
	local t = {};
	if (i == 1) then
		t.mark = "star";
		t.unused = true;
	elseif (i == 2) then
		t.mark = "circle";
		t.unused = true;
	elseif (i == 3) then
		t.mark = "diamond";
		t.unused = true;
	elseif (i == 4) then 
		t.mark = "triangle";
		t.unused = true;
	elseif (i == 5) then 
		t.mark = "moon";
		t.unused = true;
	elseif(i == 6) then
		t.mark = "square";
		t.unused = true;
	elseif (i == 7) then
		t.mark =  "cross";
		t.unused = false;
	elseif (i == 8)then
		t.mark = "skull";
		t.unused = false;
	end
	table.insert(marks, t);
end

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_Maut");

local function initHealers()
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		local healer = GetUnitName(raider, true);
		if (UnitIsConnected(raider) and UnitIsVisible(raider)) then
			if (UnitGroupRolesAssigned(raider) == "HEALER") then
				healers[healer] = true;
			end
		end
	end
end

local function initAssignments()
	--Healers dispels themselves
	for pl, data in pairs(debuffedPlayers) do
		if (EnRT_Contains(healers, pl)) then
			debuffedPlayers[pl].healer = pl;
			healers[pl] = false;
		end
	end
	for pl, data in pairs(debuffedPlayers) do
		for healer, available in pairs(healers) do
			if (available) then
				debuffedPlayers[pl].healer = healer;
				healers[healer] = false;
			end
		end
	end
	assignmentComplete = true;
	updateText();
end

local function updateText()
	if (assignmentComplete) then
		local text = "";
		for pl, data in pairs(debuffedPlayers) do
			text = text .. data.state .. data.healer .. " -> " .. pl .. "\n";
		end
		C_ChatInfo.SendAddonMessage("EnRT_Maut", text, "RAID");
	end
end

local function mautRangeCheck(self, elapsed)
	if (debuffed and EnRT_MautEnabled) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			local safe = false;
			for i = 1, GetNumGroupMembers() do
				local raider = "raid"..i;
				if (UnitIsVisible(raider) and GetUnitName(raider, true) ~= player) then
					if (IsItemInRange(63427, raider) and UnitIsConnected(master)) then
						safe = false;
						break;
					end
					if (UnitIsConnected(master)) then
						safe = true;
					end
				end
			end
			if (safe and UnitIsConnected(master) and EnRT_UnitDebuff(player, GetSpellInfo(314992)) and state ~= "GREEN") then
				state = "GREEN";
				C_ChatInfo.SendAddonMessage("EnRT_Maut", "true", "WHISPER", master);
			elseif (not safe and UnitIsConnected(master) and EnRT_UnitDebuff(player, GetSpellInfo(314992)) and state ~= "RED") then
				state = "RED";
				C_ChatInfo.SendAddonMessage("EnRT_Maut", "false", "WHISPER", master);
			end
			ticks = 0;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_MautEnabled == nil) then EnRT_MautEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_MautEnabled and player == master) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (EnRT_UnitDebuff(unit, GetSpellInfo(314992))) then
			if (not EnRT_ContainsKey(debuffedPlayers, unitName)) then
				debuffedPlayers[unitName] = {};
				debuffedPlayers[unitName].state = RED;
				debuffedPlayers[unitName].healer = "";
				for i = 1, #marks do
					if (marks[i].unused) then
						marks[i].unused = false;
						debuffedPlayers[unitName].mark = i;
						SetRaidTarget(unit, i)
						break
					end
				end
			end
		elseif (EnRT_ContainsKey(debuffedPlayers, unitName)) then
			healers[debuffedPlayers[unitName].healer] = true;
			marks[debuffedPlayers[unitName].mark].unused = true;
			debuffedPlayers[unitName] = nil;
			SetRaidTarget(unit, 0);
			updateText();
		end
		if (EnRT_UnitDebuff(player, GetSpellInfo(314992))) then
			debuffed = true;
			f:SetScript("OnUpdate", mautRangeCheck);
		else
			debuffed = false;
			f:SetScript("OnUpdate", nil);
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and EnRT_MautEnabled and inEncounter) then
		local target, guid, spellID = ...;
		if (player == master and spellID == 314992) then
			C_Timer.After(0.2, function()
				initAssignments();
			end);
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_MautEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_Maut" and player == master) then
			sender = Ambiguate(sender, "short");
			if (msg == "true") then
				if (EnRT_ContainsKey(debuffedPlayers, sender) and debuffedPlayers[sender].state == RED) then
					debuffedPlayers[sender].state = GREEN;
					updateText();
				end
			elseif (msg == "false") then
				if (EnRT_ContainsKey(debuffedPlayers, sender) and debuffedPlayers[sender].state == GREEN) then
					debuffedPlayers[sender].state = RED;
					updateText();
				end
			else
				EnRT_InfoBoxHide();
				if (msg ~= "") then
					EnRT_InfoBoxShow(msg, 10);
				else
					assignmentComplete = false;
				end
			end
		end
	elseif (event == "ENCOUNTER_START") then
		local eID = ...;
		if (eID == 2327 and EnRT_MautEnabled) then
			inEncounter = true;
			initHealers();
			master = EnRT_GetRaidLeader();
			assignmentComplete = false;
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and EnRT_MautEnabled) then
		inEncounter = false;
		healers = {};
		debuffedPlayers = {};
		assignmentComplete = false;
	end
end);
