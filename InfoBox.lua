local f = CreateFrame("Frame");
f:SetSize(120, 100);
f:SetPoint("RIGHT");
f:SetMovable(true);
f:EnableMouse(true);
f:RegisterForDrag("LeftButton");
f:SetFrameLevel(3);
f:SetScript("OnDragStart", f.StartMoving);
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
	EnRT_InfoBoxPosition = {};
	EnRT_InfoBoxPosition.point = point;
	EnRT_InfoBoxPosition.relativeTo = relativeTo;
	EnRT_InfoBoxPosition.relativePoint = relativePoint;
	EnRT_InfoBoxPosition.xOffset = xOffset;
	EnRT_InfoBoxPosition.yOffset = yOffset;
	self:StopMovingOrSizing();
end);
f:Hide();

local texture = f:CreateTexture();
texture:SetTexture(0.5, 0.5, 0.5, 0.5);
texture:SetAllPoints();

local text = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text:SetPoint("TOPLEFT", 0, -10);
text:SetJustifyV("TOP");
text:SetJustifyH("LEFT");
text:SetText("");



function EnRT_InfoBoxUpdateFontSize()
	text:SetFont("Fonts\\FRIZQT__.TTF", EnRT_InfoBoxTextFontSize);
end
--TO:DO Create instances of text so multiple texts can be shown at the same time (1 way would be to create an array and keep all visible texts there)
function EnRT_InfoBoxShow(message, sec)
	text:SetText(message);
	f:Show();
	local timer = C_Timer.NewTimer(sec, function()
		f:Hide();
	end);
	return timer;
end

function EnRT_InfoBoxUpdate(message)
	text:SetText(message);
end

function EnRT_InfoBoxMove()
	text:SetText("MOVE ME");
	f:SetMovable(true);
	f:EnableMouse(true);
	f:Show();
	C_Timer.After(7, function() 
		f:Hide();
		f:SetMovable(false);
		f:EnableMouse(false);
	end)
end

function EnRT_InfoBoxHide()
	f:Hide();
end

function EnRT_InfoBoxSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
end

function EnRT_InfoBoxIsShown()
	if f:IsShown() then
		return true;
	else
		return false;
	end
end

function EnRT_InfoBoxGetText()
	return text:GetText();
end