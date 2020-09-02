local f2 = CreateFrame("Frame")--, nil, nil, BackdropTemplateMixin and "BackdropTemplate");
f2:SetMovable(false);
f2:EnableMouse(false);
f2:SetFrameLevel(3);
f2:SetFrameStrata("FULLSCREEN");
f2:SetHeight(25);
f2:SetWidth(250);
--[[
f2:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
f2:SetBackdropColor(0.3,0.3,0.3,0.6);
f2:Hide();

local texture = f2:CreateTexture();
texture:SetTexture(0.5, 0.5, 0.5, 0.5);
texture:SetAllPoints();

local point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameText:GetPoint();
ReadyCheckFrameText:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+13);
point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameYesButton:GetPoint();
ReadyCheckFrameYesButton:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs-10);
point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameNoButton:GetPoint();
ReadyCheckFrameNoButton:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs-10);
]]
local buffBackgroundTextureTop1 = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureTop1:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureTop1:SetWidth(250);
buffBackgroundTextureTop1:SetHeight(5);
buffBackgroundTextureTop1:SetTexCoord(0.12,0.59,0.07,0.12);
buffBackgroundTextureTop1:SetPoint("TOPLEFT", 0,-5);
local buffBackgroundTextureCenter = f2:CreateTexture(nil, "BACKGROUND");
buffBackgroundTextureCenter:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureCenter:SetSize(250, 20);
buffBackgroundTextureCenter:SetTexCoord(0.2,0.5,0.1,0.7);
buffBackgroundTextureCenter:SetPoint("TOPLEFT", 0, -10);
local buffBackgroundTextureBottom1 = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureBottom1:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureBottom1:SetWidth(250);
buffBackgroundTextureBottom1:SetHeight(5);
buffBackgroundTextureBottom1:SetTexCoord(0.05,0.6,0.66,0.71);
buffBackgroundTextureBottom1:SetPoint("BOTTOMLEFT", 0, -5);
local buffBackgroundTextureLeft = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureLeft:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureLeft:SetWidth(3);
buffBackgroundTextureLeft:SetHeight(22);
buffBackgroundTextureLeft:SetTexCoord(0.61,0.62,0.15,0.64);
buffBackgroundTextureLeft:SetPoint("TOPLEFT", -1, -8);
local buffBackgroundTextureRight = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureRight:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureRight:SetWidth(3);
buffBackgroundTextureRight:SetHeight(22);
buffBackgroundTextureRight:SetTexCoord(0.61,0.62,0.15,0.64);
buffBackgroundTextureRight:SetPoint("TOPRIGHT", 0, -8);

local rcText = f2:CreateFontString(nil, "ARTWORK", "GameFontNormal");
rcText:SetPoint("TOPLEFT", 0, -15);
rcText:SetJustifyV("TOP");
rcText:SetJustifyH("CENTER");
rcText:SetFont("Fonts\\FRIZQT__.TTF", 8.5);
rcText:SetText("");
rcText:SetSize(f2:GetWidth(), f2:GetHeight());

local text2 = ReadyCheckListenerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text2:SetPoint("TOP", ReadyCheckFrameText, "TOP", 0, -40);
text2:SetFont("Fonts\\FRIZQT__.TTF", 12);
text2:SetJustifyH("CENTER");
local text3 = ReadyCheckListenerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text3:SetPoint("BOTTOM", text2, "BOTTOM", 0, -18);
text3:SetFont("Fonts\\FRIZQT__.TTF", 12);
text3:SetJustifyH("CENTER");
ReadyCheckFrame:HookScript("OnHide", function() f2:Hide() end);



local f = CreateFrame("Frame");
local flasks = {307185,307187, 307166};
local oilsIDs = {6188, 6190, 6200};
local oilIconIDs = {
	[6188] = 463543, 
	[6190] = 463544, 
	[6200] = 3528422
}; --3528423
local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";
local CROSS = "\124TInterface\\addons\\EndlessRaidTools\\Res\\cross:16\124t";
local CHECK = "\124TInterface\\addons\\EndlessRaidTools\\Res\\check:16\124t";
local rcSender = "";
local raiders = {};

local armorKitSlots = {"ChestSlot", "LegsSlot", "HandsSlot", "FeetSlot"};
local buffSpellIDs = {
	["MAGE"] = 1459, 
	["PRIEST"] = 21562, 
	["WARRIOR"] = 6673,
};
local buffIconIDs = {
	["MAGE"] = 135932, 
	["PRIEST"] = 135987, 
	["WARRIOR"] = 132333,
};

local scanTooltip = CreateFrame("GameToolTip", "EnRT_TempToolTip", nil, "GameTooltipTemplate");
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
scanTooltip:AddFontStrings(
    scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
    scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);

function armorKit()
	local count = 0;
	local shortest = nil;
	for i = 1, #armorKitSlots do
		local slotID = select(1, GetInventorySlotInfo(armorKitSlots[i]));
		scanTooltip:ClearLines();
		local hasItem = scanTooltip:SetInventoryItem("player", slotID);
		if (hasItem) then
			local lines = {scanTooltip:GetRegions()};
			for index, region in pairs(lines) do
				if (region and region:GetObjectType() == "FontString") then
					local text = region:GetText() or "";
					if (text:match("Reinforced %(%+48 Stamina%)")) then
						count = count + 1;
						local timeUnit = text:reverse():match(".*%)"):reverse();
						local duration = tonumber(text:reverse():match("%d+"):reverse());
						if (timeUnit:match("hours")) then
							if (shortest == nil) then
								shortest = 61;
							end
						elseif(timeUnit:match("hour")) then
							if (shortest == nil) then
								shortest = 60;
							elseif (shortest > 60) then
								shortest = 60;
							end
						elseif(timeUnit:match("min")) then
							if (shortest == nil) then
								shortest = duration;
							elseif (shortest > duration) then
								shortest = duration;
							end
						else
							if (shortest == nil) then
								shortest = 61;
							end
						end
						--[[
						for number in text:gmatch("(%d+)") do
							if (tonumber(number) ~= 48) then
								if (shortest == nil) then
									shortest = tonumber(number);
								else
									if (shortest > tonumber(number)) then
										shortest = tonumber(number);
									end
								end
							end
						end
						if (shortest == nil) then
							shortest = 48;
						end
						]]
					end
				end
			end
		end
	end
	if (count < 4) then
		count = RED .. count .. "/4|r ";
	elseif (count == 4) then
		count = GREEN .. count .. "/4|r ";
	end
	if (shortest == nil) then
		shortest = "";
		count = CROSS;
	else
		if (shortest == 61) then
			shortest = GREEN .. "2hrs|r";
		elseif (shortest > 15) then
			shortest = GREEN .. shortest .. "min|r";
		elseif (shortest <= 15 and shortest > 8) then
			shortest = YELLOW .. shortest .. "min|r";
		elseif (shortest <= 8) then
			shortest = RED .. shortest .. "min|r";
		end
	end
	print(count)
	print(shortest)
	return count, shortest;
	--3528447
	--Reinforced (+48 Stamina)
end

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("READY_CHECK");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");

local function updateConsumables()
	local flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(307185));
	for i = 1, #flasks do
		flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(flasks[i]));
		if (flask) then
			break;
		end
	end
	local oil, oilTime, _, oilID = GetWeaponEnchantInfo();
	local oilIcon = nil;
	if (oil) then
		oilIcon = oilIconIDs[oilID];
	end
	local food, foodIcon, _, _, _, foodTime = EnRT_UnitBuff("player", GetSpellInfo(297039)); -- Random Well Fed Buff
	local rune, runeIcon, _, _, _, runeTime = EnRT_UnitBuff("player", GetSpellInfo(270058));
	local armorKitCount, armorKitTime = armorKit();
	local armorKitIcon = 3528447;
	flaskIcon = flaskIcon and flaskIcon or 2057568;
	oilIcon = oilIcon and oilIcon or 463543;
	foodIcon = foodIcon and foodIcon or 136000;
	runeIcon = runeIcon and runeIcon or 519379;

	local blizzText = ReadyCheckFrameText:GetText();
	if (blizzText:find("%-")) then
		local head, tail, name = blizzText:find("([^-]*)");
		blizzText = name .. " initiated a ready check";
	else
		local head, tail, name = blizzText:find("([^%s]*)");
		blizzText = name .. " initiated a ready check";
	end
	local currTime = GetTime();
	flaskTime = flaskTime and math.floor((tonumber(flaskTime)-currTime)/60) or nil;
	oilTime = oilTime and math.floor(tonumber(oilTime)/1000/60) or nil;
	if (flaskTime) then
		if (flaskTime > 15) then
			flaskTime = GREEN .. flaskTime .. "min|r";
		elseif (flaskTime <= 15 and flaskTime > 8) then
			flaskTime = YELLOW .. flaskTime .. "min|r";
		elseif (flaskTime <= 8) then
			flaskTime = RED .. flaskTime .. "min|r";
		end
	else
		flaskTime = CROSS;
	end
	if (oilTime) then
		if (oilTime > 15) then
			oilTime = GREEN .. oilTime .. "min|r";
		elseif (oilTime <= 15 and oilTime > 8) then
			oilTime = YELLOW .. oilTime .. "min|r";
		elseif (oilTime <= 8) then
			oilTime = RED .. oilTime .. "min|r";
		end
	else
		oilTime = CROSS;
	end
	local class = select(2, UnitClass("player"));
	if (class == "MAGE" or class == "PRIEST" or class == "WARRIOR") then
		local count = 0;
		local total = 0;
		local unit = nil;
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				unit = "raid"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers()-1 do
				unit = "party"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
			total = total + 1;
			if (EnRT_UnitBuff("player", GetSpellInfo(buffSpellIDs[class]))) then
				count = count + 1;
			end
		end
		if (ReadyCheckFrame.backdrop and ReadyCheckFrame.backdrop.backdropInfo and ReadyCheckFrame.backdrop.backdropInfo.bgFile and ReadyCheckFrame.backdrop.backdropInfo.bgFile:match("ElvUI")) then
			ReadyCheckFrameText:SetSize(320, 40);
			ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		else
			f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
			f2:Show();
			rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		end
		--ReadyCheckFrameText:SetText(blizzText);
		--text2:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. "  \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime);
		--text3:SetText("\124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		--rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
	else
		if (ReadyCheckFrame.backdrop and ReadyCheckFrame.backdrop.backdropInfo and ReadyCheckFrame.backdrop.backdropInfo.bgFile and ReadyCheckFrame.backdrop.backdropInfo.bgFile:match("ElvUI")) then
			ReadyCheckFrameText:SetSize(320, 40);
			ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
		else
			f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
			f2:Show();
			rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
		end
		--ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS)); 
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_ConsumableCheckEnabled == nil) then EnRT_ConsumableCheckEnabled = true; end
	elseif (event == "READY_CHECK" and EnRT_ConsumableCheckEnabled) then
		local sender = ...
		rcSender = sender;
		if (not UnitIsUnit(sender, UnitName("player"))) then
			updateConsumables();
		end
	elseif (event == "UNIT_AURA" and EnRT_ConsumableCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			updateConsumables();
		end
	elseif (event == "UNIT_INVENTORY_CHANGED" and EnRT_ConsumableCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			updateConsumables();
		end
	end
end);