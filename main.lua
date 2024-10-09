local addonName, addon = ...;

local padding = 8
local current = {
    speed = 0
}
local total = {
    distance = TotalDistanceTravelled or 0
}
addon.sessions = {}

-- HUD FRAME
local HUDFrame = CreateFrame("Frame", "HUDFrame", UIParent)
HUDFrame:SetSize(300, 35)
HUDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
HUDFrame:SetFrameStrata("MEDIUM")
HUDFrame:SetMovable(true)
HUDFrame:EnableMouse(true)
HUDFrame:RegisterForDrag("LeftButton")
HUDFrame:SetScript("OnDragStart", HUDFrame.StartMoving)
HUDFrame:SetScript("OnDragStop", HUDFrame.StopMovingOrSizing)
HUDFrame:RegisterEvent("ADDON_LOADED")

addon.toggleHUD = function()
    if HUDFrame:IsVisible() then
        ShowHUD = false
        HUDFrame:Hide()
    else
        ShowHUD = true
        HUDFrame:Show()
    end
end

local mainDataFrame = CreateFrame("Frame", "MainDataFrame", HUDFrame)
mainDataFrame:SetSize(HUDFrame:GetWidth(), HUDFrame:GetHeight() / 2)
mainDataFrame:SetPoint("TOPLEFT")
mainDataFrame.texture = mainDataFrame:CreateTexture()
mainDataFrame.texture:SetAllPoints(mainDataFrame)
mainDataFrame.texture:SetTexture("Interface/BUTTONS/WHITE8X8")
mainDataFrame.texture:SetColorTexture(0, 0, 0, 0)

local mainDataEntryWidth = mainDataFrame:GetWidth() / 3

-- Total Distance
local totalDistanceLabel = addon.createDataLabel(mainDataFrame, "Distance", " ", "TOPLEFT", 0, 0)

local setTotalDistance = function(distanceInYards)
    total.distance = distanceInYards or 0
    TotalDistanceTravelled = distanceInYards
    totalDistanceLabel[3]:SetText(string.format("%.2f km", addon.convertYardsToKilometres(distanceInYards)))
end

local addToTotalDistance = function(distanceInYards)
    setTotalDistance(total.distance + distanceInYards)
end

-- Current Speed
local currentSpeedLabel = addon.createDataLabel(mainDataFrame, "Speed", " ", "TOPLEFT", 0, 0)

local function setCurrentSpeed(inputSpeed)
    current.speed = inputSpeed
    currentSpeedLabel[3]:SetText(string.format("%s", addon.ingameSpeedToMinutesPerKilometers(inputSpeed)))
end

local newSessionButton = CreateFrame("Button", "NewSessionButton", mainDataFrame)
newSessionButton:SetPushedTexture("Interface/TimeManager/ResetButton")
newSessionButton:SetHighlightTexture("Interface/TimeManager/ResetButton")
newSessionButton:SetNormalTexture("Interface/TimeManager/ResetButton")
newSessionButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self);
    GameTooltip:ClearLines();
    GameTooltip:SetText("Start new session")
    GameTooltip:Show()
end)
newSessionButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
newSessionButton:SetScript("OnClick", function()
    addon.newSession()
end)
addon.newSessionButton = newSessionButton

-- Content
local allFrames = {
    totalDistanceLabel[1],
    currentSpeedLabel[1],
    newSessionButton
}

addon.updateMainDataAlignment = function()
    for k, v in pairs(allFrames) do
        local x = 0
        local y = 0
        if MainDataDirection == nil or MainDataDirection == "HORIZONTAL" then
            x = (k - 1) * (addon.dataLabelWidth - padding)
        else
            y = (k - 1) * ((addon.dataLabelHeight + padding) * -1)
        end
        v:SetPoint("TOPLEFT", mainDataFrame, "TOPLEFT", x, y)
    end
end

HUDFrame:SetScript("OnEvent", function(self, event, arg1)
    -- On startup
    if event == "ADDON_LOADED" and arg1 == addonName then
        if ShowHUD == false then
            mainDataFrame:Hide()
        end
        setCurrentSpeed(0)
        setTotalDistance(TotalDistanceTravelled or 0)

        addon.updateMainDataAlignment()
    end
end)

HUDFrame:SetScript("OnUpdate", function(self, elapsed)
    -- Dont need to run anything if we are standing still
    local speed = GetUnitSpeed("player")
    if speed <= 0 then
        -- Make sure to reset the current speed once
        if current.speed > 0 then
            setCurrentSpeed(0)
        end
        return
    end
    setCurrentSpeed(speed)
    addToTotalDistance(speed * elapsed)
end)

-- MINIMAP ICON
local iconAddon = LibStub("AceAddon-3.0"):NewAddon("WarPath")
local warpathLDB = LibStub("LibDataBroker-1.1"):NewDataObject("WarPath", {
    type = "data source",
    text = "WarPath",
    icon = "Interface\\Icons\\ability_rogue_sprint",
    OnClick = function(self, button)
        if button == "LeftButton" then
            addon.toggleHUD()
        elseif button == "RightButton" then
            addon.openSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("WarPath")
        tooltip:AddLine("Left-click to toggle", 1, 1, 1)
        tooltip:AddLine("Right-click to open settings", 1, 1, 1)
    end
})
local icon = LibStub("LibDBIcon-1.0")

function iconAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WarPathDB", {
        profile = {
            minimap = {
                hide = false
            }
        }
    })
    icon:Register("WarPath", warpathLDB, self.db.profile.minimap)
end
