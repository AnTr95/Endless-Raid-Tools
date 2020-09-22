local addon = ...
local _G = _G;
local L = EnRTLocals;

local minimapButton = CreateFrame("Button", "EnRT_MinimapButton", Minimap);
minimapButton:SetPoint("TOPLEFT");
minimapButton:SetSize(33, 33); --img needs to be multiple of 2
minimapButton:SetMovable(true);
minimapButton:EnableMouse(true);
minimapButton:SetFrameStrata("HIGH");
minimapButton:SetFrameLevel(8);
minimapButton:SetClampedToScreen(true);
minimapButton:SetDontSavePosition();
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
minimapButton:RegisterForDrag("LeftButton", "RightButton");
minimapButton:EnableDrawLayer("BACKGROUND");
minimapButton:EnableDrawLayer("OVERLAY");

local normalTexture = minimapButton:CreateTexture("RAT_MinimapButton_BackgroundTexture", "BACKGROUND");
normalTexture:SetDrawLayer("BACKGROUND", 0);
normalTexture:SetTexture("Interface\\addons\\EndlessRaidTools\\Res\\minimap.tga");
normalTexture:SetSize(21,21);
normalTexture:SetPoint("TOPLEFT", 6, -5);

local highlightTexture = minimapButton:CreateTexture("RAT_MinimapButton_OverlayTexture", "OVERLAY");
highlightTexture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
highlightTexture:SetSize(56,56);
highlightTexture:SetPoint("TOPLEFT");

minimapButton:SetScript("OnClick", function(self)
	if (self.dragging) then
		self:SetScript("OnUpdate", nil);
	end
	InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralModules);
	InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions);
end);
minimapButton:SetScript("OnDragStart", function(self)
	self:LockHighlight();
	self.dragging = true;
	self:SetScript("OnUpdate", function(self)
		if (not IsMouseButtonDown()) then
			self:SetScript("OnUpdate", nil);
			self.dragging = false;
		end
		local xpos,ypos = GetCursorPosition();
		local xmin,xmax,ymin,ymax = Minimap:GetLeft(), Minimap:GetRight(), Minimap:GetBottom(), Minimap:GetTop();
		local xLen = xmax-xmin;
		local yLen = ymax-ymin;

		xpos = xmin-xpos/UIParent:GetScale()+(xLen/2); -- get coordinates as differences from the center of the minimap
		ypos = ypos/UIParent:GetScale()-ymin-(yLen/2);

		EnRT_MinimapDegree = math.deg(math.atan2(ypos,xpos)); -- save the degrees we are relative to the minimap center
		EnRT_SetMinimapPoint(EnRT_MinimapDegree);
	end);
end)
minimapButton:SetScript("OnDragStop", function(self)
	self:LockHighlight();
	self.dragging = false;
	self:SetScript("OnUpdate", nil);
end)
minimapButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetText("|cFFFFFFFF" .. L.OPTIONS_TITLE);
	GameTooltip:AddLine(L.OPTIONS_MINIMAP_CLICK);
	GameTooltip:Show();
	if (EnRT_MinimapMode == "On Hover") then
		minimapButton:Show();
	end
end);
minimapButton:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
	if (EnRT_MinimapMode == "On Hover" and not self.dragging) then
		if (not MouseIsOver(Minimap) and not MouseIsOver(minimapButton)) then
			minimapButton:Hide();
		end
	end
end);

Minimap:HookScript("OnEnter", function(self)
	if (EnRT_MinimapMode == "On Hover") then
		minimapButton:Show();
	end
end)

Minimap:HookScript("OnLeave", function(self)
	if (EnRT_MinimapMode == "On Hover") then
		if not (MouseIsOver(minimapButton)) then
			minimapButton:Hide();
		end
	end

end)

function EnRT_SetMinimapPoint(degree)
	minimapButton:ClearAllPoints();
	minimapButton:SetPoint("TOPLEFT", "Minimap","TOPLEFT",52-(80*cos(degree)),(80*sin(degree))-52);
end