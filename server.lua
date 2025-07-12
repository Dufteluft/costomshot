--[[
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local npcNetId = nil

RegisterCommand('spawnhitboxnpc', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == Config.AdminGroup or table.contains(Config.JobPermissions, xPlayer.getJob().name) then
        if npcNetId then
            xPlayer.showNotification("NPC ist bereits gespawnt.")
            return
        end

        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)

        local npc = CreatePed(4, Config.NpcModel, coords.x, coords.y, coords.z, heading, true, true)
        npcNetId = NetworkGetNetworkIdFromEntity(npc)
        SetCanAttackFriendly(npc, true, true)
        SetEntityHealth(npc, Config.NpcHealth)
        SetPedCanRagdoll(npc, false)

        TriggerClientEvent('spawnNpcPlayer', -1, npcNetId)
        xPlayer.showNotification("NPC gespawnt.")
    else
        xPlayer.showNotification("Du hast keine Berechtigung, diesen Befehl auszuführen.")
    end
end, false)

RegisterCommand('deletenpc', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        if not npcNetId then
            xPlayer.showNotification("Kein NPC zum Löschen vorhanden.")
            return
        end

        local npc = NetworkGetEntityFromNetworkId(npcNetId)
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
        npcNetId = nil

        xPlayer.showNotification("NPC gelöscht.")
    else
        xPlayer.showNotification("Du hast keine Berechtigung, diesen Befehl auszuführen.")
    end
end, false)

RegisterNetEvent('getNpcNetId')
AddEventHandler('getNpcNetId', function()
    TriggerClientEvent('npcNetId', source, npcNetId)
end)
