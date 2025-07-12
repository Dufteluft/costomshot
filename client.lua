ESX = exports['es_extended']:getSharedObject()

local npc = nil
local showHitbox = false
local hitboxSize = 0.1

RegisterCommand('hitboxmenu', function()
    lib.registerMenu({
        id = 'hitbox_menu',
        title = 'Hitbox-Konfiguration',
        options = {
            {
                title = 'Hitbox-Größe ändern',
                description = 'Ändere die Größe der Hitboxen.',
                action = function()
                    local input = lib.inputDialog('Hitbox-Größe', {'Größe (z.B. 0.1)'})
                    if input then
                        local size = tonumber(input[1])
                        if size then
                            hitboxSize = size
                            lib.notify({
                                title = 'Hitbox-Größe',
                                description = 'Größe auf ' .. size .. ' gesetzt.',
                                type = 'success'
                            })
                        else
                            lib.notify({
                                title = 'Hitbox-Größe',
                                description = 'Ungültige Größe.',
                                type = 'error'
                            })
                        end
                    end
                end
            }
        }
    })
    lib.showMenu('hitbox_menu')
end, false)

RegisterNetEvent('spawnNpcPlayer')
AddEventHandler('spawnNpcPlayer', function(npcNetId)
    lib.progressBar({
        duration = 2000,
        label = 'Spawne NPC...',
        canCancel = false,
    })
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
        lib.notify({
            title = 'Hitbox',
            description = 'Anzeige aktiviert.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Hitbox',
            description = 'Anzeige deaktiviert.',
            type = 'error'
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
    for boneName, boneData in pairs(Config.Bones) do
        local boneId = boneData.id
        local bonePos = GetPedBoneCoords(npc, boneId, 0.0, 0.0, 0.0)
        DrawBox(bonePos.x - hitboxSize, bonePos.y - hitboxSize, bonePos.z - hitboxSize, bonePos.x + hitboxSize, bonePos.y + hitboxSize, bonePos.z + hitboxSize, 255, 0, 0, 150)
    end
end

function DrawHealthBar()
    local health = GetEntityHealth(npc)
    local headPos = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.0)
    Draw3DText(headPos.x, headPos.y, headPos.z + 0.5, tostring(health), 255, 255, 255)
end

function CheckHits()
    for boneName, boneData in pairs(Config.Bones) do
        local boneId = boneData.id
        local damage = boneData.damage

        local shapeTest = StartShapeTestCapsule(GetPedBoneCoords(npc, boneId, 0.0, 0.0, -0.1), GetPedBoneCoords(npc, boneId, 0.0, 0.0, 0.1), hitboxSize, 16, npc, 4)
        local _, hit, endCoords, _, _ = GetShapeTestResult(shapeTest)

        if hit and endCoords then
            ApplyDamageToPed(npc, damage, true)
            LogHit(boneName, endCoords, damage)
        end
    end
end

local hitData = {}

function LogHit(bone, coords, damage)
    local playerPed = PlayerPedId()
    local weapon = exports.ox_inventory:GetSlotByItemId(GetPlayerInv(playerPed), 'weapon')
    local weaponName = weapon.label
    local distance = GetDistanceBetweenCoords(GetEntityCoords(playerPed), coords)
    local data = {
        bone = bone,
        coords = coords,
        weapon = weaponName,
        damage = damage,
        distance = distance,
        timestamp = os.time()
    }
    table.insert(hitData, data)
    print(string.format("Hit on %s at coords %s with weapon %s for %s damage at a distance of %s", bone, coords, weaponName, damage, distance))
end

RegisterCommand('exportstats', function()
    local file = io.open("hitdata.txt", "w")
    if file then
        for _, data in ipairs(hitData) do
            file:write(string.format("Timestamp: %s, Bone: %s, Coords: %s, Weapon: %s, Damage: %s, Distance: %s\n", data.timestamp, data.bone, data.coords, data.weapon, data.damage, data.distance))
        end
        io.close(file)
        lib.notify({
            title = 'Hit-Daten',
            description = 'Daten exportiert.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Hit-Daten',
            description = 'Fehler beim Exportieren.',
            type = 'error'
        })
    end
end, false)

RegisterCommand('showstats', function()
    for _, data in ipairs(hitData) do
        print(string.format("Timestamp: %s, Bone: %s, Coords: %s, Weapon: %s, Damage: %s, Distance: %s", data.timestamp, data.bone, data.coords, data.weapon, data.damage, data.distance))
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
        lib.notify({
            title = 'NPC',
            description = 'Wiederbelebt.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'NPC',
            description = 'Nicht gefunden oder nicht tot.',
            type = 'error'
        })
    end
end, false)
