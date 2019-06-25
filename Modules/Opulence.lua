local f = CreateFrame("Frame");
f:SetSize(120, 100);
f:SetPoint("RIGHT");
f:SetMovable(true);
f:EnableMouse(true);
f:RegisterForDrag("LeftButton");
f:SetFrameLevel(3);
f:SetScript("OnDragStart", f.StartMoving);
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1)
	EnRT_OpulenceUIPosition = {}
	EnRT_OpulenceUIPosition.point = point
	EnRT_OpulenceUIPosition.relativeTo = relativeTo
	EnRT_OpulenceUIPosition.relativePoint = relativePoint
	EnRT_OpulenceUIPosition.xOffset = xOffset
	EnRT_OpulenceUIPosition.yOffset = yOffset
	self:StopMovingOrSizing()
end);
f:Hide();

local texture = f:CreateTexture();
texture:SetTexture(0.5, 0.5, 0.5, 0.5);
texture:SetAllPoints();

local textName = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
textName:SetPoint("TOPLEFT", 0, -10);
textName:SetJustifyV("TOP");
textName:SetJustifyH("LEFT");
textName:SetText("");

local textStack = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
textStack:SetPoint("TOPLEFT", 65, -10);
textStack:SetJustifyV("TOP");
textStack:SetJustifyH("LEFT");
textStack:SetText("");

local textCD = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
textCD:SetPoint("TOPLEFT", 105, -10);
textCD:SetJustifyV("TOP");
textCD:SetJustifyH("LEFT");
textCD:SetText("");

raid = {};
local ticks = 0;
local role = "";
local spellIDs = {
	[12472] = 180, -- Icy Veins
	[190319] = 120, -- Combustion
	[12042] = 90, -- Arcane Power
	[31884] = 120, -- Avenging Wrath
	[193530] = 120, -- Aspect of the Wild
	[288613] = 120, -- Trueshot
	[266779] = 120, -- Coordinatd Assault
	[267217] = 180, -- Nether Portal
	[1122] = 180, -- Summon Infernal
	[205180] = 180, -- Darkglare
	[102560] = 180, -- Incarn Boomy
	[194223] = 180, -- Incarn Boomy
	[102543] = 180, -- Incarn Feral
	[106951] = 180, -- Berserk
	[192249] = 150, -- Storm Elemental
	[198067] = 150, -- Fire Elemental
	[51533] = 120, -- Feral Spirit
	[152279] = 120,-- Breath of Sindragosa
	[275699] = 90, -- Apocalypse
	[191427] = 240, -- Metamorphis
	[79140] = 120, -- Vendetta
	[13750] = 180, -- Adrenaline Rush
	[121471] = 180,-- Shadow Blades
	[137639] = 90, -- Storm Earth Fire
	[152173] = 90, -- Serenity
};


local inEncounter = false;

f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_LOGIN");

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function setMainFramePosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end

local function updateCooldowns()
	local sbName = "Name:\n";
	local sbStacks = "Stacks:\n";
	local sbCD = "CD:\n";
	for raider, data in spairs(raid, function(t,a,b) return t[a].CD < t[b].CD end) do
		local cd = data.CD;
		local stacks = data.Stacks;
		if (cd == 0) then
			cd = "READY";
		end
		sbName = sbName .. raider .. "\n";
		sbStacks = sbStacks .. stacks .."\n";
		sbCD = sbCD .. cd.."\n";
	end
	textName:SetText(sbName);
	textStack:SetText(sbStacks);
	textCD:SetText(sbCD);
end

local function initRaid()
	local size = 25;
	if (role == "HEALER") then
		for i = 1, GetNumGroupMembers() do
			local raider = "raid" .. i;
			if (UnitIsVisible(raider) and UnitIsConnected(raider) and UnitGroupRolesAssigned(raider) == "DAMAGER") then
				size = size + 10;
				local raiderName = UnitName(raider);
				raid[raiderName] = {};
				raid[raiderName].CD = 0;
				raid[raiderName].Stacks = 0;
			end
		end
	end

	f:SetSize(120, size);
	f:Show();
end

f:SetScript("OnUpdate", function(self, elapsed, ...)
	if (inEncounter and role == "HEALER" and EnRT_OpulenceEnabled) then
		ticks = ticks + elapsed;
		if (ticks > 1) then
			for raider, data in pairs(raid) do
				if (data.CD > 0) then
					data.CD = data.CD - 1;
				end
			end
			updateCooldowns();
			ticks = 0;
		end
	end
end);

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_OpulenceEnabled == nil) then EnRT_OpulenceEnabled = true; end
		if (EnRT_OpulenceUIPosition) then setMainFramePosition(EnRT_OpulenceUIPosition.point, EnRT_OpulenceUIPosition.relativeTo, EnRT_OpulenceUIPosition.relativePoint, EnRT_OpulenceUIPosition.xOffset, EnRT_OpulenceUIPosition.yOffset); end
	elseif (event == "UNIT_AURA" and role == "HEALER" and inEncounter and EnRT_OpulenceEnabled) then
		local unit = ...;
		if (UnitIsPlayer(unit) and UnitGroupRolesAssigned(unit) == "DAMAGER") then
			local raider = UnitName(unit);
			local tailwinds, icon, stacks = EnRT_UnitDebuff(unit, GetSpellInfo(284573));
			local soothing = EnRT_UnitDebuff(unit, GetSpellInfo(290654));
			if (soothing) then
				if (raid[raider].Stacks ~= 5) then
					raid[raider].Stacks = 5;
				end
			elseif (tailwinds and stacks ~= raid[raider].Stacks) then
				raid[raider].Stacks = stacks;
			elseif (tailwinds == nil and soothing == nil and raid[raider].Stacks ~= 0) then
				raid[raider].Stacks = 0;
			end
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and role == "HEALER" and inEncounter and EnRT_OpulenceEnabled) then
		local unit, _, spellID = ...;
		local raider = UnitName(unit);
		if (EnRT_ContainsKey(spellIDs, spellID)) then
			raid[raider].CD = spellIDs[spellID];
			updateCooldowns();
		end
	elseif (event == "ENCOUNTER_START" and EnRT_OpulenceEnabled) then
		local eID = ...;
		role = UnitGroupRolesAssigned("player");
		if (eID == 2271 and role == "HEALER") then
			inEncounter = true;
			initRaid();
			f:Show();
		end
	elseif (event == "ENCOUNTER_END" and role == "HEALER" and inEncounter and EnRT_OpulenceEnabled) then
		inEncounter = false;
		f:Hide();
	end
end);
--Added some line