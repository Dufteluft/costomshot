--[[

    Custom Weapon Sync Script by Jules

    This script provides a custom weapon sync system for FiveM.
    It includes a spawnable NPC for testing purposes, a custom damage system,
    a hitbox system, and a health bar.

]]

--================================================================================================
-- Variables
--================================================================================================

local npc = nil
local npcNetId = nil

--================================================================================================
-- Commands
--================================================================================================

-- Command to toggle the hitbox display
RegisterCommand('hitbox', function()
    Config.ShowHitbox = not Config.ShowHitbox
    if Config.ShowHitbox then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Hitbox-Anzeige aktiviert.' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Hitbox-Anzeige deaktiviert.' }
        })
    end
end, false)

-- Command to revive the NPC
RegisterCommand('revivenpc', function()
    if npc and DoesEntityExist(npc) and IsPedDeadOrDying(npc, 1) then
        local coords = GetEntityCoords(npc)
        ResurrectPed(npc)
        SetEntityHealth(npc, Config.NpcHealth)
        SetPedToRagdoll(npc, 1000, 1000, 0, 0, 0, 0)
        ClearPedTasksImmediately(npc)
        TriggerEvent('chat:addMessage', {
            color = { 0, 255, 0 },
            multiline = true,
            args = { 'NPC wiederbelebt.' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'NPC nicht gefunden oder nicht tot.' }
        })
    end
end, false)

--================================================================================================
-- Functions
--================================================================================================

-- Draw a 3D text in the world
function Draw3DText(x, y, z, text, r, g, b)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Draw a health bar
function DrawHealthBar(entity, x, y, z, width, height, color)
    local health = GetEntityHealth(entity)
    local maxHealth = GetEntityMaxHealth(entity)
    local healthPercentage = health / maxHealth

    DrawRect(x, y, width, height, 0, 0, 0, 150)
    DrawRect(x - (width / 2) * (1 - healthPercentage), y, width * healthPercentage, height, color.r, color.g, color.b, color.a)
end

--================================================================================================
-- Threads
--================================================================================================

-- Thread to handle NPC management
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if npcNetId and not npc then
            if NetworkDoesNetworkIdExist(npcNetId) then
                npc = NetToPed(npcNetId)
            end
        end

        if npc and not DoesEntityExist(npc) then
            npc = nil
            npcNetId = nil
        end
    end
end)

-- Thread to draw the hitbox
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Config.ShowHitbox and npc and DoesEntityExist(npc) then
            local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
            DrawBox(headPos.x - 0.1, headPos.y - 0.1, headPos.z - 0.1, headPos.x + 0.1, headPos.y + 0.1, headPos.z + 0.2, Config.HitboxColor.r, Config.HitboxColor.g, Config.HitboxColor.b, Config.HitboxColor.a)
        end
    end
end)

-- Thread to handle custom damage and health bar
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if npc and DoesEntityExist(npc) then
            SetEntityInvincible(npc, true)
            if not IsPedDeadOrDying(npc, 1) then
                local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
                DrawHealthBar(npc, headPos.x, headPos.y, headPos.z + 0.5, Config.HealthBarWidth, Config.HealthBarHeight, Config.HealthBarColor)
                local shapeTest = StartShapeTestCapsule(headPos.x, headPos.y, headPos.z, headPos.x, headPos.y, headPos.z + 0.2, 0.2, 16, npc, 4)
                local _, hit, endCoords, _, _ = GetShapeTestResult(shapeTest)
                if hit and endCoords then
                    local health = GetEntityHealth(npc)
                    local newHealth = health - Config.Damage
                    if newHealth <= 0 then
                        SetEntityHealth(npc, 0)
                    else
                        SetEntityHealth(npc, newHealth)
                    end
                end
            end
        end
    end
end)

--================================================================================================
-- Events
--================================================================================================

-- Event to receive the NPC network ID
RegisterNetEvent('npcNetId')
AddEventHandler('npcNetId', function(netId)
    npcNetId = netId
end)

-- Thread to request the NPC network ID periodically
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if not npcNetId then
            TriggerServerEvent('getNpcNetId')
        end
    end
end)
