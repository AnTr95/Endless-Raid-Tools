local f = CreateFrame("Frame");
local inEncounter = false;
local master = "";
local cloudedID = GetSpellInfo(307784);
local twistedID = GetSpellInfo(307785);
local plMind = "";
local player = GetUnitName("player");
local raid = {};
local images = {};

local npcIDs = {
    [157620] = true,
    [157238] = true,
    [149890] = true,
    [1] = false,
    [1] = false,
    [1] = false,
    [1] = false,
    [1] = false,
};

local marksLex = {
    [1] = "STAR",
    [2] = "CIRCLE",
    [3] = "DIAMOND",
    [4] = "TRIANGLE",
    [5] = "MOON",
    [6] = "SQUARE",
    [7] = "CROSS",
    [8] = "SKULL",
};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_Skitra");

function EnRT_FindBoss(user)
    if (player == master) then
        for i = 1, GetNumGroupMembers() do
            local raider = "raid"..i;
            local reciever = user and user or raider;
            if (raid[GetUnitName(raider, true)] ~= plMind) then
                C_ChatInfo.SendAddonMessage("EnRT_Skitra", "scan", "WHISPER", reciever);
                break;
            end
        end  
    end
end

function EnRT_PSMark()
    local marks = 1;
    for i = 1, 40 do
        local unit = "nameplate"..i;
        if (UnitExists(unit)) then
            local guid = UnitGUID(unit);
            local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
            print(npcID);
            if (npcIDs[tonumber(npcID)]) then
                if (GetRaidTargetIndex(unit) == nil) then 
                    SetRaidTarget(unit, marks);
                    images[guid] = marks;
                    marks = marks + 1;
                end
            end
        end
    end
    EnRT_FindBoss();
end

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_LOGIN") then
        if (EnRT_ProphetSkitraEnabled == nil) then EnRT_ProphetSkitraEnabled = true; end
    elseif (event == "UNIT_AURA" and inEncounter and EnRT_ProphetSkitraEnabled) then
        local unit = ...;
        local playerName = GetUnitName(unit, true);
        if (player == GetUnitName(unit)) then
            if (EnRT_UnitDebuff(unit, cloudedID) and plMind ~= "clouded") then
                plMind = "clouded";
            elseif (EnRT_UnitDebuff(unit, twistedID) and plMind ~= "twisted") then
                plMind = "twisted";
            end
        end
        if (player == master) then
            if (EnRT_UnitDebuff(unit, cloudedID) and raid[playerName] ~= "clouded") then
                raid[playerName] = "clouded";
            elseif (EnRT_UnitDebuff(unit, twisted) and raid[playerName] ~= "twisted") then
                raid[playerName] = "twisted";
            end
        end
    elseif (event == "CHAT_MSG_ADDON" and inEncounter and EnRT_ProphetSkitraEnabled) then
        local prefix, msg, channel, sender = ...;
        if (prefix == "EnRT_Skitra") then
            if (msg == "scan") then
                for i = 1, 40 do
                    local unit = "nameplate"..i;
                    if (UnitExists(unit)) then
                        local guid = UnitGUID(unit);
                        local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
                        print(npcID);
                        if (npcIDs[tonumber(npcID)] and GetRaidTargetIndex(unit)) then
                            C_ChatInfo.SendAddonMessage("EnRT_Skitra", guid, "WHISPER", master);
                        end
                    end
                end
            else
                local mark = images[tonumber(msg)];
                SendChatMessage("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. mark .. ":24\124t" .. "BOSS FOUND" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. mark .. ":24\124t", "RAID_WARNING");
                for i = 1, 40 do
                    local unit = "nameplate"..i;
                    if (UnitExists(unit)) then
                        local guid = UnitGUID(unit);
                        local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
                        print(npcID);
                        if (npcIDs[tonumber(npcID)] and images[guid] ~= mark) then
                            SetRaidTarget(unit, 0);
                            images = {};
                        end
                    end
                end
            end
        end
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and inEncounter and EnRT_ProphetSkitraEnabled) then
        local target, guid, spellID = ...;
        if (spellID == 307725 and player == master) then
            EnRT_PSMark();
        end
    elseif (event == "ENCOUNTER_START" and EnRT_ProphetSkitraEnabled) then
        local eID = ...;
        if (eID == 2334 and EnRT_ProphetSkitraEnabled) then
            inEncounter = true;
            master = EnRT_GetRaidLeader();
        end
        for i = 1, GetNumGroupMembers() do
            local raider = "raid"..i;
            raid[GetUnitName(raider, true)] = "";
        end
    elseif (event == "ENCOUNTER_END" and inEncounter and EnRT_ProphetSkitraEnabled) then
         inEncounter = false;
         raid = {};
    end
end);