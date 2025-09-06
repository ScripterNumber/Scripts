local uis = game:GetService('UserInputService')
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local CONFIG = {
    cameraSpeed = 0.25,
    disableStun = true,
    searchRadius = 150,
    cacheUpdateInterval = 0.1,
    instantAim = false
}

local state = {
    isAiming = false,
    cameraConnection = nil,
    trackingConnection = nil,
    lastCacheUpdate = 0,
    cachedParts = {},
    currentTarget = nil
}

local camera = workspace.CurrentCamera

local function disableStun()
    if not CONFIG.disableStun then return end
    
    local hookModule = require(localPlayer.PlayerScripts.HookSystem["PlayerHookSystem.u"])
    
    hookModule.Stun = function() return false end
    
    if hookModule._config and hookModule._config.gmplay and hookModule._config.gmplay.stun then
        hookModule._config.gmplay.stun.time = 0
    end
    
    spawn(function()
        while CONFIG.disableStun do
            if hookModule._vars and not hookModule._vars.hook.active then
                hookModule._vars.hook.active = true
                hookModule._vars.char.JumpActive = true
            end
            wait(0.1)
        end
    end)
end

local function getClosestPointOnPart(part, position)
    local cf = part.CFrame
    local size = part.Size / 2
    local localPos = cf:PointToObjectSpace(position)
    
    local closestLocal = Vector3.new(
        math.clamp(localPos.X, -size.X, size.X),
        math.clamp(localPos.Y, -size.Y, size.Y),
        math.clamp(localPos.Z, -size.Z, size.Z)
    )
    
    return cf:PointToWorldSpace(closestLocal)
end

local function updateCache(playerPos)
    local currentTime = tick()
    if currentTime - state.lastCacheUpdate < CONFIG.cacheUpdateInterval then
        return state.cachedParts
    end
    
    state.cachedParts = {}
    
    local region = Region3.new(
        playerPos - Vector3.new(CONFIG.searchRadius, CONFIG.searchRadius, CONFIG.searchRadius),
        playerPos + Vector3.new(CONFIG.searchRadius, CONFIG.searchRadius, CONFIG.searchRadius)
    )
    region = region:ExpandToGrid(4)
    
    local parts = workspace:FindPartsInRegion3(region, localPlayer.Character, 1000)
    
    for _, part in ipairs(parts) do
        if CollectionService:HasTag(part, "grab") and part:IsDescendantOf(workspace:FindFirstChild("World")) then
            table.insert(state.cachedParts, part)
        end
    end
    
    state.lastCacheUpdate = currentTime
    return state.cachedParts
end

local function findBestTarget()
    local character = localPlayer.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local playerPos = hrp.Position
    local parts = updateCache(playerPos)
    
    local nearest = nil
    local nearestDist = math.huge
    local nearestPoint = nil
    
    for _, part in ipairs(parts) do
        if part and part.Parent then
            local closestPoint = getClosestPointOnPart(part, playerPos)
            local distance = (closestPoint - playerPos).Magnitude
            
            if distance < nearestDist then
                nearestDist = distance
                nearest = part
                nearestPoint = closestPoint
            end
        end
    end
    
    return nearest, nearestDist, nearestPoint
end

local function startTracking()
    if state.trackingConnection then
        state.trackingConnection:Disconnect()
    end
    
    state.trackingConnection = RunService.RenderStepped:Connect(function()
        if not state.isAiming then
            if state.trackingConnection then
                state.trackingConnection:Disconnect()
                state.trackingConnection = nil
            end
            return
        end
        
        local targetPart, distance, closestPoint = findBestTarget()
        
        if targetPart then
            state.currentTarget = closestPoint or targetPart.Position
            

            local lookDir = (state.currentTarget - camera.CFrame.Position).Unit
            local targetCFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + lookDir)
            
            if CONFIG.instantAim then

                camera.CFrame = targetCFrame
            else

                camera.CFrame = camera.CFrame:Lerp(targetCFrame, CONFIG.cameraSpeed * 3)
            end
        end
    end)
end

uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessedEvent then
        state.isAiming = true
        
        disableStun()
        startTracking()
    end
end)

uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessedEvent then
        state.isAiming = false
        

        if state.cameraConnection then
            state.cameraConnection:Disconnect()
            state.cameraConnection = nil
        end
        
        if state.trackingConnection then
            state.trackingConnection:Disconnect()
            state.trackingConnection = nil
        end
        
        state.currentTarget = nil
        
        local hookModule = require(localPlayer.PlayerScripts.HookSystem["PlayerHookSystem.u"])
        if hookModule.InputDeactivation then
            hookModule.InputDeactivation()
        end
    end
end)
