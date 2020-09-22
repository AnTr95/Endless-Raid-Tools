local f = CreateFrame("Frame")
local timer = nil;
f:SetPoint("TOP", 0, -50)
f:SetSize(1000, 300)
f:SetMovable(false)
f:EnableMouse(false)
f:RegisterForDrag("LeftButton")
f:SetFrameLevel(3)
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1)
	EnRT_PopupTextPosition = {}
	EnRT_PopupTextPosition.point = point
	EnRT_PopupTextPosition.relativeTo = relativeTo
	EnRT_PopupTextPosition.relativePoint = relativePoint
	EnRT_PopupTextPosition.xOffset = xOffset
	EnRT_PopupTextPosition.yOffset = yOffset
	self:StopMovingOrSizing()
end)
f:Hide()
local text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
text:SetPoint("TOP")
text:SetJustifyH("CENTER");
text:SetJustifyV("TOP");
text:SetSize(1000,300);

function EnRT_PopupUpdateFontSize()
	text:SetFont("Fonts\\FRIZQT__.TTF", EnRT_PopupTextFontSize)
end
--TO:DO Create instances of text so multiple texts can be shown at the same time (1 way would be to create an array and keep all visible texts there)
function EnRT_PopupShow(message, sec)
	if (timer) then
		timer:Cancel();
		timer = nil;
	end
	text:SetText(message)
	f:Show()
	timer = C_Timer.NewTimer(sec, function()
		f:Hide()
	end)
	return timer
end
function EnRT_PopupUpdate(message)
	text:SetText(message)
end
function EnRT_PopupMove()
	text:SetText("MOVE ME")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:Show()
	C_Timer.After(7, function() 
		f:Hide()
		f:SetMovable(false)
		f:EnableMouse(false)
	end)
end
function EnRT_PopupHide()
	if (timer) then
		timer:Cancel();
		timer = nil;
	end
	f:Hide()
end
function EnRT_PopupSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end
function EnRT_PopupIsShown()
	if f:IsShown() then
		return true
	else
		return false
	end
end
function EnRT_PopupGetText()
	return text:GetText()
end