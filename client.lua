local npc = nil
local showHitbox = false
local hitboxSize = 0.1

RegisterCommand('sethitboxsize', function(source, args, rawCommand)
    local size = tonumber(args[1])
    if size then
        hitboxSize = size
        TriggerEvent('chat:addMessage', {
            color = { 0, 255, 0 },
            multiline = true,
            args = { 'Hitbox-Größe auf ' .. size .. ' gesetzt.' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Ungültige Größe.' }
        })
    end
end, false)

RegisterNetEvent('spawnNpcPlayer')
AddEventHandler('spawnNpcPlayer', function(npcNetId)
    npc = NetToPed(npcNetId)
    SetNetworkIdExistsOnAllMachines(npcNetId, true)
    RequestModel(GetHashKey("mp_m_freemode_01"))
    while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do
        Citizen.Wait(1)
    end
    SetEntityAsMissionEntity(npc, true, true)
    NetworkSetFriendlyFireOption(true)
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

--================================================================================================
-- Main Thread
--================================================================================================

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if npc and DoesEntityExist(npc) then
            if showHitbox then
                DrawHitboxes()
            end

            if not IsPedDeadOrDying(npc, 1) then
                DrawHealthBar()
                CheckHits()
            end
        end
    end
end)

--================================================================================================
-- Functions
--================================================================================================

function DrawHitboxes()
    -- Head
    local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
    DrawBox(headPos.x - hitboxSize, headPos.y - hitboxSize, headPos.z - hitboxSize, headPos.x + hitboxSize, headPos.y + hitboxSize, headPos.z + hitboxSize * 2, 255, 0, 0, 150)

    -- Torso
    local torsoPos = GetPedBoneCoords(npc, 11816, 0.0, 0.0, 0.0)
    DrawBox(torsoPos.x - (hitboxSize * 2), torsoPos.y - (hitboxSize * 1.5), torsoPos.z - (hitboxSize * 3), torsoPos.x + (hitboxSize * 2), torsoPos.y + (hitboxSize * 1.5), torsoPos.z + (hitboxSize * 3), 0, 255, 0, 150)

    -- Arms
    local leftArmPos = GetPedBoneCoords(npc, 45509, 0.0, 0.0, 0.0)
    DrawBox(leftArmPos.x - hitboxSize, leftArmPos.y - hitboxSize, leftArmPos.z - (hitboxSize * 2.5), leftArmPos.x + hitboxSize, leftArmPos.y + hitboxSize, leftArmPos.z + (hitboxSize * 2.5), 0, 0, 255, 150)
    local rightArmPos = GetPedBoneCoords(npc, 45510, 0.0, 0.0, 0.0)
    DrawBox(rightArmPos.x - hitboxSize, rightArmPos.y - hitboxSize, rightArmPos.z - (hitboxSize * 2.5), rightArmPos.x + hitboxSize, rightArmPos.y + hitboxSize, rightArmPos.z + (hitboxSize * 2.5), 0, 0, 255, 150)

    -- Legs
    local leftLegPos = GetPedBoneCoords(npc, 63931, 0.0, 0.0, 0.0)
    DrawBox(leftLegPos.x - hitboxSize, leftLegPos.y - hitboxSize, leftLegPos.z - (hitboxSize * 3), leftLegPos.x + hitboxSize, leftLegPos.y + hitboxSize, leftLegPos.z + (hitboxSize * 3), 255, 255, 0, 150)
    local rightLegPos = GetPedBoneCoords(npc, 51826, 0.0, 0.0, 0.0)
    DrawBox(rightLegPos.x - hitboxSize, rightLegPos.y - hitboxSize, rightLegPos.z - (hitboxSize * 3), rightLegPos.x + hitboxSize, rightLegPos.y + hitboxSize, rightLegPos.z + (hitboxSize * 3), 255, 255, 0, 150)
end

function DrawHealthBar()
    local health = GetEntityHealth(npc)
    local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
    Draw3DText(headPos.x, headPos.y, headPos.z + 0.5, tostring(health), 255, 255, 255)
end

function CheckHits()
    -- Head
    local shapeTestHead = StartShapeTestCapsule(GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0), GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.2), hitboxSize, 16, npc, 4)
    local _, hitHead, endCoordsHead, _, _ = GetShapeTestResult(shapeTestHead)
    if hitHead and endCoordsHead then
        ApplyDamageToPed(npc, 25, true)
        LogHit("Head", endCoordsHead)
    end

    -- Torso
    local shapeTestTorso = StartShapeTestCapsule(GetPedBoneCoords(npc, 11816, 0.0, 0.0, -0.3), GetPedBoneCoords(npc, 11816, 0.0, 0.0, 0.3), hitboxSize * 2, 16, npc, 4)
    local _, hitTorso, endCoordsTorso, _, _ = GetShapeTestResult(shapeTestTorso)
    if hitTorso and endCoordsTorso then
        ApplyDamageToPed(npc, 10, true)
        LogHit("Torso", endCoordsTorso)
    end

    -- Arms
    local shapeTestLeftArm = StartShapeTestCapsule(GetPedBoneCoords(npc, 45509, 0.0, 0.0, -0.25), GetPedBoneCoords(npc, 45509, 0.0, 0.0, 0.25), hitboxSize, 16, npc, 4)
    local _, hitLeftArm, endCoordsLeftArm, _, _ = GetShapeTestResult(shapeTestLeftArm)
    if hitLeftArm and endCoordsLeftArm then
        ApplyDamageToPed(npc, 5, true)
        LogHit("Left Arm", endCoordsLeftArm)
    end

    local shapeTestRightArm = StartShapeTestCapsule(GetPedBoneCoords(npc, 45510, 0.0, 0.0, -0.25), GetPedBoneCoords(npc, 45510, 0.0, 0.0, 0.25), hitboxSize, 16, npc, 4)
    local _, hitRightArm, endCoordsRightArm, _, _ = GetShapeTestResult(shapeTestRightArm)
    if hitRightArm and endCoordsRightArm then
        ApplyDamageToPed(npc, 5, true)
        LogHit("Right Arm", endCoordsRightArm)
    end

    -- Legs
    local shapeTestLeftLeg = StartShapeTestCapsule(GetPedBoneCoords(npc, 63931, 0.0, 0.0, -0.3), GetPedBoneCoords(npc, 63931, 0.0, 0.0, 0.3), hitboxSize, 16, npc, 4)
    local _, hitLeftLeg, endCoordsLeftLeg, _, _ = GetShapeTestResult(shapeTestLeftLeg)
    if hitLeftLeg and endCoordsLeftLeg then
        ApplyDamageToPed(npc, 5, true)
        LogHit("Left Leg", endCoordsLeftLeg)
    end

    local shapeTestRightLeg = StartShapeTestCapsule(GetPedBoneCoords(npc, 51826, 0.0, 0.0, -0.3), GetPedBoneCoords(npc, 51826, 0.0, 0.0, 0.3), hitboxSize, 16, npc, 4)
    local _, hitRightLeg, endCoordsRightLeg, _, _ = GetShapeTestResult(shapeTestRightLeg)
    if hitRightLeg and endCoordsRightLeg then
        ApplyDamageToPed(npc, 5, true)
        LogHit("Right Leg", endCoordsRightLeg)
    end
end

local hitData = {}

function LogHit(bone, coords)
    local playerPed = PlayerPedId()
    local weapon = GetSelectedPedWeapon(playerPed)
    local weaponName = GetLabelText(GetDisplayNameFromVehicleModel(weapon))
    local data = {
        bone = bone,
        coords = coords,
        weapon = weaponName,
        timestamp = os.time()
    }
    table.insert(hitData, data)
    print(string.format("Hit on %s at coords %s with weapon %s", bone, coords, weaponName))
end

RegisterCommand('exporthitdata', function()
    local file = io.open("hitdata.txt", "w")
    if file then
        for _, data in ipairs(hitData) do
            file:write(string.format("Timestamp: %s, Bone: %s, Coords: %s, Weapon: %s\n", data.timestamp, data.bone, data.coords, data.weapon))
        end
        io.close(file)
        TriggerEvent('chat:addMessage', {
            color = { 0, 255, 0 },
            multiline = true,
            args = { 'Trefferdaten exportiert.' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Fehler beim Exportieren der Trefferdaten.' }
        })
    end
end, false)

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
