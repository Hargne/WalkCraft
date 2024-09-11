local addonName, addon = ...;

local updateInterval = 1.0
local timeSinceLastUpdate = 0
local currentSession = nil
local padding = 8
local width = addon.dataLabelWidth * 4
local height = 75

local frame = CreateFrame("Frame", "SessionWindowFrame", UIParent)
frame:SetSize(width, height)
frame:SetPoint("BOTTOM")
frame.texture = frame:CreateTexture()
frame.texture:SetAllPoints(frame)
frame.texture:SetTexture("Interface/BUTTONS/WHITE8X8")
frame.texture:SetColorTexture(0, 0, 0, 0)
frame:SetFrameStrata("MEDIUM")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:RegisterEvent("ADDON_LOADED")
addon.sessionWindow = frame

addon.sessions = {}

addon.showSessionWindow = function()
    ShowTrackSession = true;
    frame:Show()
end

addon.hideSessionWindow = function()
    ShowTrackSession = false;
    frame:Hide()
end

local newSessionButton = addon.createButton(frame, "Start", addon.dataLabelWidth, 22, "LEFT", padding, 0)

local distanceLabel = addon.createDataLabel(frame, "Distance", " ", "TOPLEFT",
    padding + (padding + addon.dataLabelWidth) * 0, -padding)
local averageSpeed = addon.createDataLabel(frame, "Avg Speed", " ", "TOPLEFT",
    padding + (padding + addon.dataLabelWidth) * 1, -padding)
local elapsedTimeLabel = addon.createDataLabel(frame, "Elapsed Time", " ", "TOPLEFT",
    padding + (padding + addon.dataLabelWidth) * 2, -padding)

local buttonContainer = CreateFrame("Frame", "SessionButtonContainer", frame)
buttonContainer:SetSize(addon.dataLabelWidth, frame:GetHeight())
buttonContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", padding + (padding + addon.dataLabelWidth) * 3, -padding)

local resumePauseSessionButton = addon.createButton(buttonContainer, "Pause", addon.dataLabelWidth, 22, "TOPLEFT", 0, 0)
local endSessionButton = addon.createButton(buttonContainer, "End", addon.dataLabelWidth, 22, "TOPLEFT", 0,
    -22 - padding)

local setDistance = function(distanceInYards)
    if currentSession == nil then
        return
    end
    currentSession.distance = distanceInYards or 0
    distanceLabel[3]:SetText(string.format("%.2f km", addon.convertYardsToKilometres(currentSession.distance)))
end

local addDistance = function(distanceInYards)
    if currentSession == nil then
        return
    end
    setDistance(currentSession.distance + distanceInYards)
end

local updateElapsedTime = function()
    if currentSession == nil then
        return
    end
    elapsedTimeLabel[3]:SetText(date("%M:%S", (time() - currentSession.startTime)))
end

local updateAverageSpeed = function()
    if currentSession == nil then
        return
    end
    averageSpeed[3]:SetText(addon.ingameSpeedToMinutesPerKilometers(currentSession.distance /
                                                                        (time() - currentSession.startTime)))
end

addon.newSession = function()
    if currentSession == nil then
        currentSession = {
            startTime = time(),
            elapsedTime = 0,
            distance = 0,
            active = true
        }
        setDistance(0)
        newSessionButton:Hide()
        resumePauseSessionButton:SetText("Pause")
        buttonContainer:Show()
        distanceLabel[1]:Show()
        averageSpeed[1]:Show()
        elapsedTimeLabel[1]:Show()
    end
end

addon.pauseSession = function()
    if currentSession == nil then
        return
    end
    currentSession.active = false
    resumePauseSessionButton:SetText("Resume")
end

addon.resumeSession = function()
    if currentSession == nil then
        return
    end
    currentSession.active = true
    resumePauseSessionButton:SetText("Pause")
end

addon.endSession = function()
    if currentSession == nil then
        return
    end
    addon.sessions[#addon.sessions + 1] = currentSession
    currentSession = nil
    newSessionButton:Show()
    buttonContainer:Hide()
    distanceLabel[1]:Hide()
    averageSpeed[1]:Hide()
    elapsedTimeLabel[1]:Hide()
end

newSessionButton:SetScript("OnClick", function()
    addon.newSession()
end)

resumePauseSessionButton:SetScript("OnClick", function()
    if currentSession == nil then
        return
    end
    if currentSession.active then
        addon.pauseSession()
    else
        addon.resumeSession()
    end
end)

endSessionButton:SetScript("OnClick", function()
    addon.endSession()
end)

frame:SetScript("OnEvent", function(self, event, arg1)
    -- On startup
    if event == "ADDON_LOADED" and arg1 == addonName then
        if ShowTrackSession == false then
            frame:Hide()
        end
        setDistance(0)
    end
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    if currentSession ~= nil and currentSession.active then
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed;
        if (timeSinceLastUpdate <= updateInterval) then
            return
        end
        updateElapsedTime()
        updateAverageSpeed()
        if GetUnitSpeed("player") > 0 then
            addDistance(GetUnitSpeed("player") * elapsed)
        end
    end
end)
