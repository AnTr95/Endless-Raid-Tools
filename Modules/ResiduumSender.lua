local EnRT_Residuum = LibStub("AceAddon-3.0"):NewAddon("EnRT_Residuum","AceSerializer-3.0","AceTimer-3.0","AceComm-3.0");
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
end

function GatherInfo(self,msg)
	EnRT_Residuum:SendCommMessage("EnRT_Residuum","GatherInfo","RAID");
	EnRT_Residuum:ScheduleTimer("TimerFeedback", 5);
end
function EnRT_Residuum:TimerFeedback()
	--table.sort(ResiduumList.Cloth, function( a, b ) return a[1] > b[1] end )
	for amount,players in pairs(ResiduumList.Cloth) do
			SendTable.Cloth = SendTable.Cloth .. " "..amount.." "..players.." ";
	end
	for amount,players in pairs(ResiduumList.Leather) do
			SendTable.Leather = SendTable.Leather .. " "..amount.." "..players.." ";
	end
	for amount,players in pairs(ResiduumList.Mail) do
			SendTable.Mail = SendTable.Mail .. " "..amount.." "..players.." ";
	end
	for amount,players in pairs(ResiduumList.Plate) do
			SendTable.Plate = SendTable.Plate .. " "..amount.." "..players.." ";
	end
	SendChatMessage("CLOTH","RAID")
	SendChatMessage(SendTable.Cloth,"RAID")
	SendChatMessage("MAIL","RAID")
	SendChatMessage(SendTable.Mail,"RAID")
	self:ScheduleTimer("ChatDelay", 1)
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
--    /enrtresi
SlashCmdList["ENRTRESI"] = GatherInfo;
SLASH_ENRTRESI1 = "/enrtresi";

function EnRT_Residuum:OnCommReceived(prefix, Msg, distri, sender)
	if (prefix == "EnRT_Residuum" and Msg == "GatherInfo")  then
		local _,Residuum = GetCurrencyInfo(1718);
		local _,_,classIndex = UnitClass("player");
		if (classIndex == 5 or classIndex == 8 or classIndex == 9) then
				Gear = "Cloth";
			elseif (classIndex == 1 or classIndex == 2 or classIndex == 6) then
				Gear = "Plate";
			elseif (classIndex == 3 or classIndex == 7) then
				Gear = "Mail";
			elseif (classIndex == 4 or classIndex == 10 or classIndex == 11 or classIndex == 12) then
				Gear = "Leather";
		end
			self:SendCommMessage("EnRT_Residuum",self:Serialize(Residuum,Gear),"WHISPER",sender);

	elseif (prefix == "EnRT_Residuum") then
		check,Residuum,Gear =self:Deserialize(Msg)
		if (ResiduumList[Gear][Residuum] == nil) then
			ResiduumList[Gear][Residuum] = sender;
		else
			ResiduumList[Gear][Residuum] = ResiduumList[Gear][Residuum] .." "..sender;
		end
	end
end