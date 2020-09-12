local f = CreateFrame("Frame")
local healers = {}
local dispeller = ""
local bestTime = 0
local slaves = {}
local player = UnitName("player")
local ticks = 0
local debuffed = false
local queue = {}
local master = ""
local inEncounter = false
f:RegisterEvent("ENCOUNTER_START")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("RAID_TARGET_UPDATE")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ENCOUNTER_END")
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_MOTHER")
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_MOTHERHEAL")
f:SetScript("OnUpdate",function(self, elapsed)
	if debuffed and EnRT_MOTHEREnabled then
		ticks = ticks + elapsed
		if ticks > 0.05 then
			local safe = false
			for i = 1, GetNumGroupMembers() do
				local raider = "raid"..i
				if UnitIsVisible(raider) and GetUnitName(raider, true) ~= player then
					if CheckInteractDistance(raider, 3) and UnitIsConnected(master) then
						safe = false
						break
					end
					if UnitIsConnected(master) then
						safe = true
					end
				end
			end
			if safe and UnitIsConnected(master) and EnRT_UnitDebuff(player, GetSpellInfo(279662)) and not GetRaidTargetIndex(player) then
				C_ChatInfo.SendAddonMessage("EnRT_MOTHER", "true", "WHISPER", master)
				C_ChatInfo.SendAddonMessage("EnRT_MOTHERHEAL", "SHOW", "RAID")
			elseif not safe and UnitIsConnected(master) and EnRT_UnitDebuff(player, GetSpellInfo(279662)) and GetRaidTargetIndex(player) then
				C_ChatInfo.SendAddonMessage("EnRT_MOTHER", "false", "WHISPER", master)
				C_ChatInfo.SendAddonMessage("EnRT_MOTHERHEAL", "HIDE", "RAID")
			end
			ticks = 0
		end
	end
end)
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" and EnRT_MOTHEREnabled then
		queue = {}
		local eID = ...
		if eID == 2141 and IsInRaid() then --needs fix
			master = EnRT_GetRaidLeader()
			inEncounter = true
		end
	elseif event == "ENCOUNTER_END" and inEncounter then
		inEncounter = false
	elseif event == "PLAYER_LOGIN" then
		if EnRT_MOTHEREnabled == nil then EnRT_MOTHEREnabled = true end
	elseif event == "RAID_TARGET_UPDATE" and EnRT_MOTHEREnabled then
		for k, v in pairs(queue) do
			if GetRaidTargetIndex(k) and v == "mark" then
				queue[k] = nil
			elseif not GetRaidTargetIndex(k) and v == "unmark" then
				queue[k] = nil
			end
		end
	elseif event == "CHAT_MSG_ADDON" and EnRT_MOTHEREnabled then
		local prefix, msg, channel, sender = ...
		if prefix == "EnRT_MOTHER" and player == master then
			sender = Ambiguate(sender, "short")
			if msg == "true" then
				if GetRaidTargetIndex(sender) == nil and EnRT_Contains(slaves, sender) and not EnRT_ContainsKey(queue, sender) then
					queue[sender] = "mark"
					SetRaidTarget(sender, EnRT_Contains(slaves, sender))
				end
			else
				if GetRaidTargetIndex(sender) and EnRT_Contains(slaves, sender) and not EnRT_ContainsKey(queue, sender) then
					queue[sender] = "unmark"
					SetRaidTarget(sender, 0)
				end
			end
		elseif prefix == "EnRT_MOTHERHEAL" then
			sender = Ambiguate(sender, "short")
			if UnitGroupRolesAssigned("player") == "HEALER" then
				if msg == "SHOW" then
					if not EnRT_PopupIsShown() or not EnRT_PopupGetText():match("DISPEL") then
						timer = EnRT_PopupShow("DISPEL " .. sender, 500)
					elseif EnRT_PopupIsShown() and EnRT_PopupGetText():match("DISPEL") and not EnRT_PopupGetText():match(sender) then
						local getText = EnRT_PopupGetText()
						timer:Cancel()
						timer = EnRT_PopupShow(getText .. " AND " .. sender, 500)
					end
				elseif msg == "HIDE" and EnRT_PopupGetText():match(sender) then
					if EnRT_PopupIsShown() and EnRT_PopupGetText():match("DISPEL") then
						EnRT_PopupHide()
						if timer ~= "" then
							timer:Cancel()
							timer = ""
						end
					end
				end
			end
		end
	elseif event == "UNIT_AURA" and EnRT_MOTHEREnabled and inEncounter then
		if player == master then
			local unit = ...
			local unitName = GetUnitName(unit, true)
			if EnRT_UnitDebuff(unit, GetSpellInfo(279662)) then --Endemic Virus
				if not EnRT_Contains(slaves, unitName) then
					slaves[#slaves+1] = unitName
				end
			else
				if EnRT_Contains(slaves, unitName) then
					slaves[EnRT_Contains(slaves, unitName)] = nil
					SetRaidTarget(unitName, 0)
				end
			end
		end
		if EnRT_UnitDebuff(player, GetSpellInfo(279662)) then
			debuffed = true
		else
			if debuffed then
				debuffed = false
				C_ChatInfo.SendAddonMessage("EnRT_MOTHERHEAL", "HIDE", "RAID")
				C_ChatInfo.SendAddonMessage("EnRT_ITSMove", "false", "RAID")
			end
		end
	end
end)
--[[
	Checking if a table PGF_Contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function EnRT_Contains(arr, value)
	if value == nil then
		return false
	end
	if arr == nil then
		return false
	end
	for k, v in pairs(arr) do
		if v == value then
			return k
		end
	end
	return false
end
--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if<< the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function EnRT_ContainsKey(arr, value)
	if value == nil then
		return false
	end
	if arr == nil then
		return false
	end
	for k, v in pairs(arr) do
		if k == value then
			return true
		end
	end
	return false
end