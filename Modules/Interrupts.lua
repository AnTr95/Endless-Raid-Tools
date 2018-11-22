local spellNames = {
	2139,
	147362,
	47528,
	47476, 
	78675, 
	96231, 
	15487, 
	1766, 
	57994, 
	6552, 
	116705, 
	106839, 
	183752, 
	187707, 
	171138, 
	119910,
}
local f = CreateFrame("Frame")
--SLASH_ENDLESSINTERRUPT1 = "/endlessinterrupt"
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
C_ChatInfo.RegisterAddonMessagePrefix("EndlessInterrupt")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_LOGIN")
local interruptNext = false
--[[
local function handler(msg, editbox)
	if EnRT_InterruptEnabled then
		if msg == "toggle" then
			EnRT_PopupMove()
		elseif not msg:match(";") then
			RunScript("EnRT_InterruptList = " .. msg)
		end
	end
end]]
SlashCmdList["ENDLESSINTERRUPT"] = handler
f:SetScript("OnEvent", function(self, event, ...)
	if EnRT_InterruptEnabled and EnRT_NextInterrupt then
		if event == "UNIT_SPELLCAST_SUCCEEDED" then
			local unit, _, spell = ...
			if unit == "player" then
				if Endless_Contains(spellNames, spell) then
					if interruptNext then
						EnRT_PopupHide()
						interruptNext = false
					end
					if UnitIsConnected(EnRT_NextInterrupt) and IsInGroup() and ((UnitInParty(EnRT_NextInterrupt) or UnitInRaid(EnRT_NextInterrupt))) then
						C_ChatInfo.SendAddonMessage("EndlessInterrupt", UnitName("player"), "WHISPER", EnRT_NextInterrupt)
					end
				end
			end
		elseif event == "CHAT_MSG_ADDON" then
			local prefix, msg, channel, sender = ...
			sender = Ambiguate(sender, "short")
			if prefix == "EndlessInterrupt" and ((UnitInParty(sender) or UnitInRaid(sender))) then
				EnRT_PopupShow("NEXT INTERRUPT IS YOURS!", 7)
				interruptNext = true
			end
		end
	end
	if event == "PLAYER_LOGIN" then
		if EnRT_InterruptEnabled == nil then EnRT_InterruptEnabled = true end
	end
end)
--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function Endless_Contains(arr, value)
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