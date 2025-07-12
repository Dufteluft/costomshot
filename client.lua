local showHitbox = false

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

    local npc = CreatePed(4, `mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedSeeingRange(npc, 0.0)
    SetPedHearingRange(npc, 0.0)
    SetPedIsEnemy(npc, false)
    SetEntityInvincible(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDefaultComponentVariation(npc)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)

AddEventHandler('entityDamaged', function(entity, attacker, damage, weapon)
    if IsEntityAPed(entity) and GetPedType(entity) == 4 and not IsEntityPlayer(entity) then
        -- This is our NPC, let's do something
    end
end)
