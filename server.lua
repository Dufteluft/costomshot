--[[
--================================================================================================
-- Main
--================================================================================================

local npcNetId = nil

--================================================================================================
-- Commands
--================================================================================================

RegisterCommand('spawnnpc', function(source, args, rawCommand)
    if npcNetId then
        SendMessage(source, "NPC ist bereits gespawnt.", { 255, 0, 0 })
        return
    end

    local player = source
    local playerPed = GetPlayerPed(player)
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local npc = CreatePed(4, `mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, true, true)
    npcNetId = NetworkGetNetworkIdFromEntity(npc)
    SetCanAttackFriendly(npc, true, true)
    SetEntityHealth(npc, 100)
    SetPedCanRagdoll(npc, false)

    TriggerClientEvent('spawnNpcPlayer', -1, npcNetId)
    SendMessage(-1, "NPC gespawnt.", { 0, 255, 0 })
end, false)

RegisterCommand('deletenpc', function(source, args, rawCommand)
    if not npcNetId then
        SendMessage(source, "Kein NPC zum Löschen vorhanden.", { 255, 0, 0 })
        return
    end

    local npc = NetworkGetEntityFromNetworkId(npcNetId)
    if DoesEntityExist(npc) then
        DeleteEntity(npc)
    end
    npcNetId = nil

    SendMessage(-1, "NPC gelöscht.", { 0, 255, 0 })
end, false)

--================================================================================================
-- Events
--================================================================================================

RegisterNetEvent('getNpcNetId')
AddEventHandler('getNpcNetId', function()
    TriggerClientEvent('npcNetId', source, npcNetId)
end)

--================================================================================================
-- Functions
--================================================================================================

function SendMessage(target, message, color)
    TriggerClientEvent('chat:addMessage', target, {
        color = color,
        multiline = true,
        args = { message }
    })
end
