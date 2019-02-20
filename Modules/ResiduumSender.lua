local EnRT_Residuum = LibStub("AceAddon-3.0"):NewAddon("EnRT_Residuum", "AceTimer-3.0","AceComm-3.0");
local _,_,classIndex = UnitClass("player");
local Gear = nil;
local ResiduumList = {
	Cloth = {},
	Plate = {},
	Mail = {},
	Leather = {},};
local SendTable =  {
	Cloth = "",
	Plate ="",
	Mail = "",
	Leather = "",};
function EnRT_Residuum:OnInitialize()
	self:RegisterComm("EnRT_Residuum")
	self:RegisterComm("EnRT_Resicloth")
	self:RegisterComm("EnRT_Resileather")
	self:RegisterComm("EnRT_Resiplate")
	self:RegisterComm("EnRT_Resimail")
	if classIndex == 5 or classIndex == 8 or classIndex == 9 then
			Gear = "Cloth"
		elseif classIndex == 1 or classIndex == 2 or classIndex == 6 then
			Gear = "Plate"
		elseif classIndex == 3 or classIndex == 7 then
			Gear = "Mail"
		elseif classIndex == 4 or classIndex == 10 or classIndex == 11 or classIndex == 12 then
			Gear = "Leather"
	end
end

function GatherInfo(self,msg)
	C_ChatInfo.SendAddonMessage("EnRT_Residuum","GatherInfo","RAID")
	EnRT_Residuum:ScheduleTimer("TimerFeedback", 5)
end
function EnRT_Residuum:TimerFeedback()
	for k,v in pairs(ResiduumList.Cloth) do
			SendTable.Cloth = SendTable.Cloth .. " "..k.." "..v.." "
	end
	for k,v in pairs(ResiduumList.Leather) do
			SendTable.Leather = SendTable.Leather .. " "..k.." "..v.." "
	end
	for k,v in pairs(ResiduumList.Mail) do
			SendTable.Mail = SendTable.Mail .. " "..k.." "..v.." "
	end
	for k,v in pairs(ResiduumList.Plate) do
			SendTable.Plate = SendTable.Plate .. " "..k.." "..v.." "
	end
	SendChatMessage("CLOTH","RAID")
	SendChatMessage(SendTable.Cloth,"RAID")
	SendChatMessage("MAIL","RAID")
	SendChatMessage(SendTable.Mail,"RAID")
	self:ScheduleTimer("ChatDelay", 2)
end
function EnRT_Residuum:ChatDelay()
	SendChatMessage("LEATHER","RAID")
	SendChatMessage(SendTable.Leather,"RAID")
	SendChatMessage("PLATE","RAID")
	SendChatMessage(SendTable.Plate,"RAID")
	SendTable =  {
	Cloth = "",
	Plate ="",
	Mail = "",
	Leather = "",};
	ResiduumList = {
	Cloth = {},
	Plate = {},
	Mail = {},
	Leather = {},};
end
--    /endlessresiduum

SlashCmdList["ENDLESRESIDUUM"] = GatherInfo
SLASH_ENDLESRESIDUUM1 = "/endlessresiduum"

function EnRT_Residuum:OnCommReceived(prefix, Msg, distri, sender)
	if prefix == "EnRT_Residuum" and Msg == "GatherInfo"  then
		local _,Residuum = GetCurrencyInfo(1718)
		if Gear == "Cloth" then
				C_ChatInfo.SendAddonMessage("EnRT_Resicloth",Residuum,"WHISPER",sender)
			elseif Gear == "Leather" then
				C_ChatInfo.SendAddonMessage("EnRT_Resileather",Residuum,"WHISPER",sender)
			elseif Gear == "Mail" then
				C_ChatInfo.SendAddonMessage("EnRT_Resimail",Residuum,"WHISPER",sender)
			elseif Gear == "Plate" then
				C_ChatInfo.SendAddonMessage("EnRT_Resiplate",Residuum,"WHISPER",sender)
		end
	elseif prefix == "EnRT_Resicloth" then
		if ResiduumList.Cloth[Msg] == nil then
			ResiduumList.Cloth[Msg] = sender
		else
			ResiduumList.Cloth[Msg] = ResiduumList.Cloth[Msg] .." "..sender
		end
	elseif prefix == "EnRT_Resileather" then
		if ResiduumList.Leather[Msg] == nil then
			ResiduumList.Leather[Msg] = sender
		else
			ResiduumList.Leather[Msg] = ResiduumList.Leather[Msg] .." "..sender
		end
	elseif prefix == "EnRT_Resiplate" then
		if ResiduumList.Plate[Msg] == nil then
				ResiduumList.Plate[Msg] = sender
			else
				ResiduumList.Plate[Msg] = ResiduumList.Plate[Msg] .." "..sender
			end
	elseif prefix == "EnRT_Resimail" then
		if ResiduumList.Mail[Msg] == nil then
			ResiduumList.Mail[Msg] = sender
		else
			ResiduumList.Mail[Msg] = ResiduumList.Mail[Msg] .." "..sender
		end
	end
end