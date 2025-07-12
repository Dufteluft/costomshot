--[[

    Custom Weapon Sync Script by Jules

    This script provides a custom weapon sync system for FiveM.
    It includes a spawnable NPC for testing purposes, a custom damage system,
    a hitbox system, and a health bar.

]]

--================================================================================================
-- Variables
--================================================================================================

local npcNetId = nil

--================================================================================================
-- Commands
--================================================================================================

-- Command to spawn the NPC
RegisterCommand('spawnnpc', function(source, args, rawCommand)
    if npcNetId then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'NPC ist bereits gespawnt.' }
        })
        return
    end

    local player = source
    local playerPed = GetPlayerPed(player)
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    -- Create the NPC
    local npc = CreatePed(4, `mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, true, true)
    npcNetId = NetworkGetNetworkIdFromEntity(npc)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(npc, true, true)
    SetEntityHealth(npc, 100)
    SetPedCanRagdoll(npc, false)

    TriggerClientEvent('spawnNpcPlayer', -1, npcNetId)

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 0, 255, 0 },
        multiline = true,
        args = { 'NPC gespawnt.' }
    })
end, false)

-- Command to delete the NPC
RegisterCommand('deletenpc', function(source, args, rawCommand)
    if not npcNetId then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Kein NPC zum Löschen vorhanden.' }
        })
        return
    end

    local npc = NetworkGetEntityFromNetworkId(npcNetId)
    if DoesEntityExist(npc) then
        DeleteEntity(npc)
    end
    npcNetId = nil

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 0, 255, 0 },
        multiline = true,
        args = { 'NPC gelöscht.' }
    })
end, false)

--================================================================================================
-- Events
--================================================================================================

-- Event to send the NPC network ID to the client
RegisterNetEvent('getNpcNetId')
AddEventHandler('getNpcNetId', function()
    TriggerClientEvent('npcNetId', source, npcNetId)
end)
