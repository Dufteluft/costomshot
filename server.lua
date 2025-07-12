RegisterCommand('npcplayer', function(source, args, rawCommand)
    local player = source
    TriggerClientEvent('spawnNpcPlayer', player)
end, false)
