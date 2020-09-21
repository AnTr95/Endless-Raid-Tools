local f = CreateFrame("Frame");

local marks = {};
local debuffedPlayers = {};

local player = UnitName("player");
local ticks = 0;
local debuffed = false;
local master = "";
local inEncounter = false;
local colorDB = {
	["RED"] = "\124cFFFF0000",
	["GREEN"] = "\124cFF00FF00",
};
local plState = "";
local raidFrames = {
    [1] = "Vd1", -- vuhdo
    [2] = "Healbot", -- healbot
    [3] = "GridLayout", -- grid
    [4] = "Grid2Layout", -- grid2
    [5] = "ElvUF_RaidGroup", -- elv
    [6] = "oUF_bdGrid", -- bdgrid
    [7] = "oUF.*raid", -- generic oUF
    [8] = "LimeGroup", -- lime
    [9] = "SUFHeaderraid", -- suf
    [10] = "CompactRaid", -- blizz
};
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
C_ChatInfo.RegisterAddonMessagePrefix("IRT_Maut");

local function mautRangeCheck(self, elapsed)
	if (debuffed and IRT_MautEnabled) then
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
			if (safe and UnitIsConnected(master) and IRT_UnitDebuff(player, GetSpellInfo(314992)) and plState ~= "GREEN") then
				plState = "GREEN";
				C_ChatInfo.SendAddonMessage("IRT_Maut", "GREEN", "RAID");
			elseif (not safe and UnitIsConnected(master) and IRT_UnitDebuff(player, GetSpellInfo(314992)) and plState ~= "RED") then
				plState = "RED";
				C_ChatInfo.SendAddonMessage("IRT_Maut", "RED", "RAID");
			end
			ticks = 0;
		end
	end
end

local function updateDebuffText()
	local text = "Drain Essence:\n";
	for pl, data in pairs(debuffedPlayers) do
		local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(pl))].colorStr, Ambiguate(pl, "short"));
		text = text .. name .. " - " .. colorDB[data.state];
		if (data.state == "RED") then
			text = text .. "NOT SAFE\n";
			--[[
			if (data.frame) then
				ActionButton_ShowOverlayGlow(data.frame);
			end
			]]
		elseif (data.state == "GREEN") then
			text = text .. "SAFE\n";
			--[[
			if (data.frame) then
				ActionButton_ShowOverlayGlow(data.frame);
			end
			]]
		end
	end
	if (text ~= "Drain Essence:\n") then
		IRT_InfoBoxShow(text, 10);
	else
		IRT_InfoBoxHide();
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_MautEnabled == nil) then IRT_MautEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and IRT_MautEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_Maut") then
			sender = Ambiguate(sender, "none");
			if (msg == "GREEN" or msg == "RED") then
				if (IRT_ContainsKey(debuffedPlayers, sender) and debuffedPlayers[sender].state ~= msg) then
					debuffedPlayers[sender].state = msg;
				end
				updateDebuffText();
			end
		end
	elseif (event == "UNIT_AURA" and IRT_MautEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (IRT_UnitDebuff(unit, GetSpellInfo(314992))) then
			if (not IRT_ContainsKey(debuffedPlayers, unitName)) then
				debuffedPlayers[unitName] = {};
				debuffedPlayers[unitName].state = "RED";
				if (UnitIsUnit(player, master)) then
					for i = 1, #marks do
						if (marks[i].unused) then
							marks[i].unused = false;
							debuffedPlayers[unitName].mark = i;
							SetRaidTarget(unit, i);
							break;
						end
					end
				end
				--[[
				for grp = 1, 8 do
					for member = 1, 5 do
						if (_G["CompactRaidGroup"..tostring(grp).."Member"..tostring(member)].unit and UnitIsUnit(_G["CompactRaidGroup"..tostring(grp).."Member"..tostring(member)].unit, unit)) then
							debuffedPlayers[unitName].frame = _G["CompactRaidGroup"..grp.."Member"..member];
							break;
						end
					end
				end
				]]
				updateDebuffText();
			end
		elseif (IRT_ContainsKey(debuffedPlayers, unitName)) then
			if (UnitIsUnit(player, master)) then
				marks[debuffedPlayers[unitName].mark].unused = true;
				SetRaidTarget(unitName, 0);
			end
			debuffedPlayers[unitName] = nil;
			updateDebuffText();
		end
		if (UnitIsUnit(player, unitName)) then
			if (IRT_UnitDebuff(player, GetSpellInfo(314992)) and not debuffed) then
				debuffed = true;
				f:SetScript("OnUpdate", mautRangeCheck);
			elseif (not IRT_UnitDebuff(player, GetSpellInfo(314992)) and debuffed) then
				debuffed = false;
				f:SetScript("OnUpdate", nil);
				plState = "";
			end
		end
	elseif (event == "ENCOUNTER_START") then
		local eID = ...;
		if (eID == 2327 and IRT_MautEnabled) then
			debuffedPlayers = {};
			inEncounter = true;
			master = IRT_GetRaidLeader();
			plState = "";
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_MautEnabled) then
		inEncounter = false;
		debuffedPlayers = {};
		plState = "";
	end
end);