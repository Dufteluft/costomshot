local npc = nil
local showHitbox = false

RegisterNetEvent('spawnNpcPlayer')
AddEventHandler('spawnNpcPlayer', function(npcNetId)
    npc = NetToPed(npcNetId)
    RequestModel(GetHashKey("mp_m_freemode_01"))
    while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do
        Citizen.Wait(1)
    end
    SetEntityAsMissionEntity(npc, true, true)
    SetPedSeeingRange(npc, 0.0)
    SetPedHearingRange(npc, 0.0)
    SetEntityInvincible(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)
    SetPedCanRagdoll(npc, false)
    SetPedDefaultComponentVariation(npc)
    SetEntityHealth(npc, 100)
end)

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

        if npc and DoesEntityExist(npc) and not IsPedDeadOrDying(npc, 1) then
            local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
            local health = GetEntityHealth(npc)
            Draw3DText(headPos.x, headPos.y, headPos.z + 0.5, tostring(health), 255, 255, 255)

            local shapeTest = StartShapeTestCapsule(headPos.x, headPos.y, headPos.z, headPos.x, headPos.y, headPos.z + 0.2, 0.2, 16, npc, 4)
            local _, hit, endCoords, _, _ = GetShapeTestResult(shapeTest)
            if hit and endCoords then
                local newHealth = health - 25
                if newHealth <= 0 then
                    SetEntityHealth(npc, 0)
                else
                    SetEntityHealth(npc, newHealth)
                end
            end
        end
    end
end)

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

RegisterCommand('revivenpc', function()
    if npc and DoesEntityExist(npc) and IsPedDeadOrDying(npc, 1) then
        local coords = GetEntityCoords(npc)
        ResurrectPed(npc)
        SetEntityHealth(npc, 100)
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
