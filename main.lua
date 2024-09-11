local addonName, addon = ...;

local padding = 8
local current = {
    speed = 0
}
local total = {
    distance = TotalDistanceTravelled or 0
}
local heading = {
    size = 8,
    color = {
        1,
        1,
        0
    }
}
local valueLabel = {
    size = 12,
    color = {
        1,
        1,
        1
    }
}

-- HUD FRAME
local HUDFrame = CreateFrame("Frame", "HUDFrame", UIParent)
HUDFrame:SetSize(300, 75)
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

--
-- MAIN DATA
--
local mainDataFrame = CreateFrame("Frame", "MainDataFrame", HUDFrame)
mainDataFrame:SetSize(HUDFrame:GetWidth(), HUDFrame:GetHeight() / 2)
mainDataFrame:SetPoint("TOPLEFT")
mainDataFrame.texture = mainDataFrame:CreateTexture()
mainDataFrame.texture:SetAllPoints(mainDataFrame)
mainDataFrame.texture:SetTexture("Interface/BUTTONS/WHITE8X8")
mainDataFrame.texture:SetColorTexture(0, 0, 0, 0)

local mainDataEntryWidth = mainDataFrame:GetWidth() / 3

-- Total Distance
local totalDistanceFrame = CreateFrame("Frame", "TotalDistanceFrame", mainDataFrame)
totalDistanceFrame:SetSize(mainDataEntryWidth, mainDataFrame:GetHeight())
totalDistanceFrame:SetPoint("TOPLEFT", mainDataFrame, "TOPLEFT", padding, -padding)
local totalDistanceHeading = addon.createLabel(totalDistanceFrame, "Distance", heading.size, "TOPLEFT", 0, 0)
totalDistanceHeading:SetTextColor(heading.color[1], heading.color[2], heading.color[3])
local totalDistanceValue = addon.createLabel(totalDistanceFrame, "", valueLabel.size, "TOPLEFT", 0, -valueLabel.size)
totalDistanceValue:SetTextColor(valueLabel.color[1], valueLabel.color[2], valueLabel.color[3])

local setTotalDistance = function(distanceInYards)
    total.distance = distanceInYards or 0
    TotalDistanceTravelled = distanceInYards
    totalDistanceValue:SetText(string.format("%.2f km", addon.convertYardsToKilometres(distanceInYards)))
end

local addToTotalDistance = function(distanceInYards)
    setTotalDistance(total.distance + distanceInYards)
end

-- Current Speed
local currentSpeedFrame = CreateFrame("Frame", "CurrentSpeedFrame", mainDataFrame)
currentSpeedFrame:SetSize(mainDataEntryWidth, mainDataFrame:GetHeight())
currentSpeedFrame:SetPoint("TOPLEFT", mainDataFrame, "TOPLEFT", padding + mainDataEntryWidth + padding, -padding)
local currentSpeedHeading = addon.createLabel(currentSpeedFrame, "Speed", heading.size, "TOPLEFT", 0, 0)
currentSpeedHeading:SetTextColor(heading.color[1], heading.color[2], heading.color[3])
local currentSpeedValue = addon.createLabel(currentSpeedFrame, "", valueLabel.size, "TOPLEFT", 0, -valueLabel.size)
currentSpeedValue:SetTextColor(valueLabel.color[1], valueLabel.color[2], valueLabel.color[3])

local function setCurrentSpeed(inputSpeed)
    current.speed = inputSpeed
    currentSpeedValue:SetText(string.format("%s", addon.ingameSpeedToMinutesPerKilometers(inputSpeed)))
end

HUDFrame:SetScript("OnEvent", function(self, event, arg1)
    -- On startup
    if event == "ADDON_LOADED" and arg1 == addonName then
        if ShowHUD == false then
            mainDataFrame:Hide()
        end
        setCurrentSpeed(0)
        setTotalDistance(TotalDistanceTravelled or 0)
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
local iconAddon = LibStub("AceAddon-3.0"):NewAddon("WalkCraft")
local walkCraftLDB = LibStub("LibDataBroker-1.1"):NewDataObject("WalkCraft", {
    type = "data source",
    text = "WalkCraft",
    icon = "Interface\\Icons\\ability_rogue_sprint",
    OnClick = function(self, button)
        if button == "LeftButton" then
            addon.toggleHUD()
        elseif button == "RightButton" then
            addon.openSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("WalkCraft")
        tooltip:AddLine("Left-click to toggle", 1, 1, 1)
        tooltip:AddLine("Right-click to open settings", 1, 1, 1)
    end
})
local icon = LibStub("LibDBIcon-1.0")

function iconAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WalkCraftDB", {
        profile = {
            minimap = {
                hide = false
            }
        }
    })
    icon:Register("WalkCraft", walkCraftLDB, self.db.profile.minimap)
end
