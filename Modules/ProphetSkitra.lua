local f = CreateFrame("Frame");
local inEncounter = false;
local master = "";
local cloudedID = GetSpellInfo(307784);
local twistedID = GetSpellInfo(307785);
local plMind = "";
local player = GetUnitName("player");
local raid = {};
local guids = {};
local timer = nil;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_Skitra");

local function EnRT_FindBoss(user)
    if (player == master) then
        for i = 1, GetNumGroupMembers() do
            local raider = "raid"..i;
            local reciever = user and user or raider;
            if (raid[GetUnitName(raider, true)] ~= raid[player]) then
                C_ChatInfo.SendAddonMessage("EnRT_Skitra", "scan", "WHISPER", reciever);
            end
        end  
    end
end

local function EnRT_PSMark()
    local maxDistance = GetCVar("nameplateMaxDistance");
    SetCVar("nameplateMaxDistance", 100);
    for i = 1, 40 do
        local unit = "nameplate"..i;
        if (UnitExists(unit)) then
            local guid = UnitGUID(unit);
            local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
            print(npcID);
            if (npcID == 157620) then
                if(not EnRT_Contains(guids, guid)) then
                    guids[#guids+1] = guid;
                end
            end
        end
    end
    SetCVar("nameplateMaxDistance", maxDistance);
    EnRT_FindBoss();
end

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_LOGIN") then
        if (EnRT_ProphetSkitraEnabled == nil) then EnRT_ProphetSkitraEnabled = true; end
    elseif (event == "UNIT_AURA" and inEncounter and EnRT_ProphetSkitraEnabled) then
        local unit = ...;
        local playerName = GetUnitName(unit, true);
        --[[
        if (player == GetUnitName(unit)) then
            if (EnRT_UnitDebuff(unit, cloudedID) and plMind ~= "clouded") then
                plMind = "clouded";
            elseif (EnRT_UnitDebuff(unit, twistedID) and plMind ~= "twisted") then
                plMind = "twisted";
            end
        end]]
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
                local maxDistance = GetCVar("nameplateMaxDistance");
                SetCVar("nameplateMaxDistance", 100);
                for i = 1, 40 do
                    local unit = "nameplate"..i;
                    if (UnitExists(unit)) then
                        local guid = UnitGUID(unit);
                        local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
                        print(npcID);
                        if (npcID == 157620) then
                            C_ChatInfo.SendAddonMessage("EnRT_Skitra", guid, "WHISPER", master);
                        end
                    end
                end
                SetCVar("nameplateMaxDistance", maxDistance);
            else
                if(raid[GetUnitName(sender, true)] == raid[player]) then
                    if(not EnRT_Contains(guids, msg)) then
                        guids[#guids+1] = msg;
                    end
                elseif(raid[GetUnitName(sender, true)] ~= raid[player]) then
                    if (EnRT_Contains(guids, msg)) then
                        SendChatMessage("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:24\124t" .. "EnRT: BOSS FOUND" .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:24\124t", "RAID_WARNING");
                        local maxDistance = GetCVar("nameplateMaxDistance");
                        SetCVar("nameplateMaxDistance", 100);
                        for i = 1, 40 do
                            local unit = "nameplate"..i;
                            if (UnitExists(unit)) then
                                local guid = UnitGUID(unit);
                                local type, zero, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-",guid);
                                print(npcID);
                                if (npcID == 157620 and msg == guid) then
                                    SetRaidTarget(unit, 8);
                                    guids = {};
                                    if (timer) then
                                        timer:Cancel();
                                        timer = nil;
                                    end
                                end
                            end
                        end
                        SetCVar("nameplateMaxDistance", maxDistance);
                    end
                end
            end
        end
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and inEncounter and EnRT_ProphetSkitraEnabled) then
        local target, guid, spellID = ...;
        if (spellID == 307725 and player == master) then
            timer = C_Timer.NewTicker(0.5, function() 
                EnRT_PSMark() 
            end);
            C_Timer.After(10, function()
                if (timer) then
                    timer:Cancel();
                    timer = nil;
                end
            end);
        end
    elseif (event == "ENCOUNTER_START" and EnRT_ProphetSkitraEnabled) then
        local eID = ...;
        if (eID == 2334 and EnRT_ProphetSkitraEnabled) then
            inEncounter = true;
            master = EnRT_GetRaidLeader();
            for i = 1, GetNumGroupMembers() do
                local raider = "raid"..i;
                raid[GetUnitName(raider, true)] = "";
            end
        end
    elseif (event == "ENCOUNTER_END" and inEncounter and EnRT_ProphetSkitraEnabled) then
         inEncounter = false;
         raid = {};
    end
end);