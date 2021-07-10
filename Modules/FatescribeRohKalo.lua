local L = IRTLocals;

local f = CreateFrame("Frame");
local debuffed = {};
local inEncounter = false;
local leader = "";
local difficulty = nil;
local raidSize = nil;
local ringConfig = {
	[15] = {
		[10] = {
			[1] = "INNER",
			[2] = "INNER",
			[3] = "OUTER",
			[4] = "OUTER",
			[5] = "BACKUP",
			[6] = "BACKUP",
			[7] = "BACKUP",
			[8] = "BACKUP",
		},
		[20] = {
			[1] = "INNER",
			[2] = "INNER",
			[3] = "MIDDLE",
			[4] = "MIDDLE",
			[5] = "OUTER",
			[6] = "OUTER",
			[7] = "BACKUP",
			[8] = "BACKUP",
			[9] = "BACKUP",
			[10] = "BACKUP",
		},
		[30] = {
			[1] = "MOST INNER",
			[2] = "MOST INNER",
			[3] = "2nd MOST INNER",
			[4] = "2nd MOST INNER",
			[5] = "2nd MOST OUTER",
			[6] = "2nd MOST OUTER",
			[7] = "MOST OUTER",
			[8] = "MOST OUTER",
			[9] = "BACKUP",
			[10] = "BACKUP",
			[11] = "BACKUP",
			[12] = "BACKUP",
		},
	},
	[16] = {
		[20] = {
			[1] = "MOST INNER",
			[2] = "MOST INNER",
			[3] = "2nd MOST INNER",
			[4] = "2nd MOST INNER",
			[5] = "2nd MOST OUTER",
			[6] = "2nd MOST OUTER",
			[7] = "MOST OUTER",
			[8] = "MOST OUTER",
			[9] = "MIDDLE",
			[10] = "MIDDLE",
			[11] = "BACKUP",
			[12] = "BACKUP",
		}
	},
};

--Player vars
local playerName = GetUnitName("player");
local timer = nil;
local plDebuffed = false;

f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_FRH");

local function updateInfoBox(text, player)
	if (UnitIsConnected(player)) then
		player = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(player))].colorStr, player);
	end
	if (text:match(":") == nil) then
		text = "|cFFFFFFFF" .. text .. "|r";
	end
	if (text:match("BACKUP") == nil) then
		if (IRT_InfoBoxIsShown()) then
			IRT_InfoBoxShow(IRT_InfoBoxGetText() .. "\n" .. text .. " - " .. player, 60);
		else
			IRT_InfoBoxShow("|cFF00FFFFIRT:|r\n" .. text .. " - " .. player, 60);
		end
	end
end

local function playerNotification(text)
	SendChatMessage(text, "YELL");
	IRT_PopupShow(text, 30, L.BOSS_FILE);
	if (text:match("BACKUP") == nil) then
		timer = C_Timer.NewTicker(1.5, function()
			if (UnitIsDead("player")) then
				timer:Cancel();
				timer = nil;
			else
				SendChatMessage(text, "YELL");
			end
		end, math.floor(19));
	end
end

local function assignRings()
	if (raidSize >= 30) then
		for i = 1, #debuffed do
			if (i%2 == 1) then
				C_ChatInfo.SendAddonMessage("IRT_FRH", "Lead: " .. ringConfig[difficulty][30][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			else
				C_ChatInfo.SendAddonMessage("IRT_FRH", ringConfig[difficulty][30][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			end
		end
	elseif (raidSize >= 20) then
		for i = 1, #debuffed do
			if (i%2 == 1) then
				C_ChatInfo.SendAddonMessage("IRT_FRH", "Lead: " .. ringConfig[difficulty][20][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			else
				C_ChatInfo.SendAddonMessage("IRT_FRH", ringConfig[difficulty][20][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			end
		end
	else
		for i = 1, #debuffed do
			if (i%2 == 1) then
				C_ChatInfo.SendAddonMessage("IRT_FRH", "Lead: " .. ringConfig[difficulty][10][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			else
				C_ChatInfo.SendAddonMessage("IRT_FRH", ringConfig[difficulty][10][i] .. "," .. Ambiguate(debuffed[i], "short"), "RAID");
			end
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_FatescribeRohKaloEnabled == nil) then IRT_FatescribeRohKaloEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and IRT_FatescribeRohKaloEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_FRH") then
			if (msg == "hide") then
				IRT_InfoBoxHide();
			else
				local text, player = strsplit(",", msg);
				updateInfoBox(text, player);
				if (UnitIsUnit(player, playerName)) then
					playerNotification(text);
				end
			end
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and IRT_FatescribeRohKaloEnabled and inEncounter) then
		local target, castGUID, spellID = ...;
		if (spellID == 351969) then
			C_Timer.After(0.5, function()
				assignRings();
			end);
		end
	elseif (event == "UNIT_AURA" and IRT_FatescribeRohKaloEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (IRT_UnitDebuff(unit, GetSpellInfo(354964))) then
			if (UnitIsUnit(leader, playerName)) then
				if (not IRT_Contains(debuffed, unitName)) then
					debuffed[#debuffed+1] = unitName;
				end
			end
			if (UnitIsUnit(unitName, playerName) and not plDebuffed) then
				plDebuffed = true;
			end
		else
			if (UnitIsUnit(leader, playerName)) then
				if (IRT_Contains(debuffed, unitName)) then
					debuffed[IRT_Contains(debuffed, unitName)] = nil;
					if (#debuffed == 0) then
						C_ChatInfo.SendAddonMessage("IRT_FRH", "hide", "RAID");
					end
				end
			end
			if (UnitIsUnit(unitName, playerName) and plDebuffed) then
				plDebuffed = false;
				IRT_PopupHide(L.BOSS_FILE);
				if (timer) then
					timer:Cancel();
					timer = nil;
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_FatescribeRohKaloEnabled) then
		local eID = ...;
		difficulty = select(3, GetInstanceInfo());
		if (eID == 2431 and (difficulty == 16 or difficulty == 15)) then
			if (difficulty == 16) then
				raidSize = 20;
			else
				raidSize = select(9, GetInstanceInfo());
			end
			leader = IRT_GetRaidLeader();
			debuffed = {};
			inEncounter = true;
			timer = nil;
		end
	elseif (event == "ENCOUNTER_END" and IRT_FatescribeRohKaloEnabled and inEncounter) then
		debuffed = {};
		inEncounter = false;
		difficulty = nil;
		raidSize = nil;
		leader = "";
		if (timer) then
			timer:Cancel();
			timer = nil;
		end
		plDebuffed = false;
		IRT_PopupHide(L.BOSS_FILE);
		IRT_InfoBoxHide();
	end
end);

--Infobox Main, Support