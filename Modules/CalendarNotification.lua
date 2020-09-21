local f = CreateFrame("Frame")
local CalendarGetNumPendingInvites = C_Calendar.GetNumPendingInvites
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if IRT_CalendarNotificationEnabled == nil then IRT_CalendarNotificationEnabled = true end
	elseif "CALENDAR_UPDATE_PENDING_INVITES" and IRT_CalendarNotificationEnabled then
		local invites = C_Calendar.GetNumPendingInvites()
		if invites > 0 then
			if invites > 10 then
				invites = 10 
			end
			C_Timer.After(1, function()
				PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\CalendarNotification\\calnotyouhave.ogg", "master")
				C_Timer.After(2, function()
					PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\CalendarNotification\\calnot" .. invites .. ".ogg", "master")
					C_Timer.After(2, function()
						PlaySoundFile("Interface\\AddOns\\InfiniteRaidTools\\Sound\\CalendarNotification\\calnotinvites.ogg", "master")
						f:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
					end)
				end)
			end)
		end
	end
end)