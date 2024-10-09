local name, addon = ...;

local padding = 24

local frame = CreateFrame("FRAME", "WarPathSettingsFrame", UIParent);
frame:SetSize(300 + padding, 400 + padding)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.texture = frame:CreateTexture()
frame.texture:SetAllPoints(frame)
frame.texture:SetTexture("Interface/BUTTONS/WHITE8X8")
frame.texture:SetColorTexture(0, 0, 0, 0.75)
frame:Hide()

local title = addon.createLabel(frame, "WarPath", 24, "TOPLEFT", padding, -padding)

-- Main data alignment dropdown

local mainDataAlignmentY = 24

local mainDataAligmentDropDownLabel = addon.createLabel(frame, "Data Alignment", 10, "TOPLEFT", padding,
    -padding - mainDataAlignmentY - padding)

local mainDataAligmentDropDown = CreateFrame("Frame", "MainDataAlignmentDropdown", frame, "UIDropDownMenuTemplate")
mainDataAligmentDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", padding / 2,
    -padding - (mainDataAlignmentY + 14) - padding)

local function updateMainDataAligmentDropDownLabel()
    if MainDataDirection == nil or MainDataDirection == "HORIZONTAL" then
        UIDropDownMenu_SetText(mainDataAligmentDropDown, "Horizontal")
    elseif MainDataDirection == "VERTICAL" then
        UIDropDownMenu_SetText(mainDataAligmentDropDown, "Vertical")
    end
end

UIDropDownMenu_SetWidth(mainDataAligmentDropDown, 120)
UIDropDownMenu_Initialize(mainDataAligmentDropDown, function(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.func = function(self, arg1, arg2, checked)
        if arg1 == 1 then
            MainDataDirection = "HORIZONTAL"
        elseif arg1 == 2 then
            MainDataDirection = "VERTICAL"
        end
        addon.updateMainDataAlignment()
        updateMainDataAligmentDropDownLabel()
    end
    info.text, info.arg1, info.checked = "Horizontal", 1, MainDataDirection == "HORIZONTAL" or MainDataDirection == nil
    UIDropDownMenu_AddButton(info)
    info.text, info.arg1, info.checked = "Vertical", 2, MainDataDirection == "VERTICAL"
    UIDropDownMenu_AddButton(info)
    updateMainDataAligmentDropDownLabel()
end)

StaticPopupDialogs["CONFIRM_RESET_TOTAL_DISTANCE"] = {
    text = "Are you sure that you want to reset your all time distance?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        addon.setTotalDistanceTravelled(0)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local resetTotalDistanceButton = addon.createButton(frame, "Reset total distance", 150, 22, "BOTTOMLEFT", padding,
    padding)
resetTotalDistanceButton:SetScript("OnClick", function()
    StaticPopup_Show("CONFIRM_RESET_TOTAL_DISTANCE")
end)

local versionLabel = addon.createLabel(frame, "WarPath v" .. addon.config.version, 10, "BOTTOMRIGHT", -padding, padding)

addon.openSettings = function()
    frame:Show();
end

addon.closeSettings = function()
    frame:Hide();
end

local closeSettingsButton = addon.createCloseButton(frame, "TOPRIGHT", 0, 0)
closeSettingsButton:SetScript("OnClick", function()
    addon.closeSettings();
end)
