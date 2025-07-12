local showHitbox = false
local npc = nil

RegisterCommand('hitbox', function()
    showHitbox = not showHitbox
    if showHitbox then
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showHitbox then
            local playerPed = PlayerPedId()
            local headPos = GetPedBoneCoords(playerPed, 31086, 0.0, 0.0, 0.0)
            DrawBox(headPos.x - 0.1, headPos.y - 0.1, headPos.z - 0.1, headPos.x + 0.1, headPos.y + 0.1, headPos.z + 0.2, 255, 0, 0, 150)

            if npc and DoesEntityExist(npc) then
                local npcHeadPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
                DrawBox(npcHeadPos.x - 0.1, npcHeadPos.y - 0.1, npcHeadPos.z - 0.1, npcHeadPos.x + 0.1, npcHeadPos.y + 0.1, npcHeadPos.z + 0.2, 0, 255, 0, 150)
            end
        end
    end
end)

RegisterNetEvent('spawnNpcPlayer')
AddEventHandler('spawnNpcPlayer', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    RequestModel(`mp_m_freemode_01`)
    while not HasModelLoaded(`mp_m_freemode_01`) do
        Citizen.Wait(1)
    end

    npc = CreatePed(4, `mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedSeeingRange(npc, 0.0)
    SetPedHearingRange(npc, 0.0)
    SetEntityInvincible(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDefaultComponentVariation(npc)
end)

RegisterCommand('revivenpc', function()
    if npc and DoesEntityExist(npc) and IsPedDeadOrDying(npc, 1) then
        local coords = GetEntityCoords(npc)
        ResurrectPed(npc)
        SetEntityHealth(npc, GetPedMaxHealth(npc))
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        DisplayDamage(false)

        if npc and DoesEntityExist(npc) and not IsPedDeadOrDying(npc, 1) then
            local npcPos = GetEntityCoords(npc)
            local playerPos = GetEntityCoords(PlayerPedId())

            if #(npcPos - playerPos) < 50.0 then
                local hit, _, endCoords, _, _ = GetProjectileImpact(npcPos, 50.0, PlayerPedId())
                if hit then
                    local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
                    if #(endCoords - headPos) < 0.2 then
                        local health = GetEntityHealth(npc)
                        local newHealth = health - 25
                        if newHealth <= 0 then
                            SetEntityHealth(npc, 0)
                        else
                            SetEntityHealth(npc, newHealth)
                        end
                    end
                end
            end
        end
    end
end)
