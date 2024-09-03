local name, addon = ...;

local HUD = CreateFrame("Frame", "HUDFrame", UIParent)
HUD:SetSize(300, 75)
HUD:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
HUD:SetFrameStrata("MEDIUM")
HUD:SetMovable(true)
HUD:EnableMouse(true)
HUD:RegisterForDrag("LeftButton")
HUD:SetScript("OnDragStart", HUD.StartMoving)
HUD:SetScript("OnDragStop", HUD.StopMovingOrSizing)
if ShowHUD == false then
    HUD:Hide()
end

-- MAIN DATA
local _speed = 0
local mainDataFrameWidth = 100
local mainDataFrameHeight = 30

local mainDataFrame = CreateFrame("Frame", "MainDataFrame", HUD)
mainDataFrame:SetSize(mainDataFrameWidth, mainDataFrameHeight)
mainDataFrame:SetPoint("TOP")

local currentSpeedFrame = CreateFrame("Frame", "CurrentSpeedFrame", mainDataFrame)
currentSpeedFrame:SetSize(mainDataFrameWidth / 2, mainDataFrameHeight)
currentSpeedFrame:SetPoint("TOPLEFT")
local currentSpeedHeading = Utils.createLabel(currentSpeedFrame, "Speed", 10, "TOPLEFT", 0, 0)
local currentSpeedValue = Utils.createLabel(currentSpeedFrame, "", 12, "TOPLEFT", 0, -12)
currentSpeedValue:SetTextColor(1, 1, 1)

local function updateCurrentSpeed(speed)
    _speed = speed
    local formattedSpeed = Utils.ingameSpeedToMinutesPerKilometers(speed)
    currentSpeedValue:SetText(string.format("%s", formattedSpeed))
end

local totalDistanceFrame = CreateFrame("Frame", "TotalDistanceFrame", mainDataFrame)
totalDistanceFrame:SetSize(mainDataFrameWidth / 2, mainDataFrameHeight)
totalDistanceFrame:SetPoint("TOPRIGHT")
local totalDistanceHeading = Utils.createLabel(totalDistanceFrame, "Distance", 10, "TOPLEFT", 80, 0)
local totalDistanceValue = Utils.createLabel(totalDistanceFrame, "", 12, "TOPLEFT", 80, -12)
totalDistanceValue:SetTextColor(1, 1, 1)

local function setTotalDistanceTravelled(distanceInYards)
    TotalDistanceTravelled = distanceInYards or 0
    totalDistanceValue:SetText(string.format("%.2f km", addon.Utils.convertYardsToKilometres(distanceInYards)))
end
addon.setTotalDistanceTravelled = setTotalDistanceTravelled

-- SESSION DATA
local distanceTravelledThisSession = 0

local sessionDataFrame = CreateFrame("Frame", "SessionDataFrame", HUD)
sessionDataFrame:SetSize(300, 25)
sessionDataFrame:SetPoint("BOTTOM")

local startSessionButton = Utils.createButton(sessionDataFrame, "Start", 80, 22, "TOP", 0, 0)
startSessionButton:SetScript("OnClick", function()
    print("hej")
end)

addon.showSessionFrame = function()
    ShowTrackSession = true;
    sessionDataFrame:Show()
end
addon.hideSessionFrame = function()
    ShowTrackSession = false;
    sessionDataFrame:Hide()
end

HUD:RegisterEvent("ADDON_LOADED")
HUD:SetScript("OnEvent", function(self, event, arg1)
    -- On startup
    if event == "ADDON_LOADED" and arg1 == "WalkCraft" then
        if ShowHUD == false then
            HUD:Hide()
        end
        if ShowTrackSession == false then
            sessionDataFrame:Hide()
        end
        updateCurrentSpeed(0)
        setTotalDistanceTravelled(TotalDistanceTravelled or 0)
        -- setDistanceTravelledThisSession(0)
    end
end)

HUD:SetScript("OnUpdate", function(self, elapsed)
    -- Dont need to run anything if we are standing still
    local speed = GetUnitSpeed("player")
    if speed <= 0 then
        -- Make sure to reset the current speed once
        if _speed > 0 then
            updateCurrentSpeed(0)
        end
        return
    end

    if TotalDistanceTravelled == nil then
        TotalDistanceTravelled = 0
    end
    updateCurrentSpeed(speed)
    setTotalDistanceTravelled(TotalDistanceTravelled + speed * elapsed)
    -- setDistanceTravelledThisSession(distanceTravelledThisSession + speed * elapsed)
end)

local function toggleHUD()
    if HUD:IsVisible() then
        ShowHUD = false
        HUD:Hide()
    else
        ShowHUD = true
        HUD:Show()
    end
end

-- MINIMAP ICON
local iconAddon = LibStub("AceAddon-3.0"):NewAddon("WalkCraft")
local walkCraftLDB = LibStub("LibDataBroker-1.1"):NewDataObject("WalkCraft", {
    type = "data source",
    text = "WalkCraft",
    icon = "Interface\\Icons\\ability_rogue_sprint",
    OnClick = function(self, button)
        if button == "LeftButton" then
            toggleHUD()
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
