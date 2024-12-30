-- Example of a simple whitelist script
local githubUrl = "https://raw.githubusercontent.com/ThuChhit-Chum/Fivem-Whitelist/main/whitelist.json"

function isPlayerWhitelisted(steamHex)
    PerformHttpRequest(githubUrl, function(errorCode, responseData, headers)
        if errorCode == 200 then
            local whitelist = json.decode(responseData)
            for _, id in ipairs(whitelist.steam_ids) do
                if id == steamHex then
                    return true
                end
            end
            return false
        else
            print("Error fetching whitelist from GitHub: " .. errorCode)
            return false
        end
    end, 'GET')

    return false  -- Default return before fetching completes
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()

    local player = source
    local steamHex = GetPlayerIdentifiers(player)[1]

    if isPlayerWhitelisted(steamHex) then
        deferrals.done()
    else
        setKickReason("You are not whitelisted.")
        deferrals.done("You are not whitelisted on this server.")
    end
end)
