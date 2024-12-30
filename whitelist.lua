-- GitHub URL for your whitelist.json file
local githubUrl = "https://raw.githubusercontent.com/ThuChhit-Chum/Fivem-Whitelist/main/whitelist.json"

-- Function to check if the player's Steam Hex ID is in the whitelist
function isPlayerWhitelisted(steamHex)
    PerformHttpRequest(githubUrl, function(errorCode, responseData, headers)
        if errorCode == 200 then
            -- Decode the JSON response into a Lua table
            local whitelist = json.decode(responseData)

            -- Check if the player's Steam Hex ID is in the whitelist
            for _, id in ipairs(whitelist.steam_ids) do
                if id == steamHex then
                    return true  -- Player is whitelisted
                end
            end
            return false  -- Player is not whitelisted
        else
            print("Error fetching whitelist from GitHub: " .. errorCode)
            return false
        end
    end, 'GET')

    -- Default to false until the request completes (asynchronous)
    return false
end

-- Event handler for when a player tries to connect
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()  -- Delay the player's connection until the whitelist check is done

    local player = source
    local steamHex = GetPlayerIdentifiers(player)[1]  -- Get the player's Steam Hex ID

    -- Check if the player is whitelisted
    if isPlayerWhitelisted(steamHex) then
        deferrals.done()  -- Allow the player to connect if they are whitelisted
    else
        setKickReason("You are not whitelisted on this server.")  -- Kick the player if they are not whitelisted
        deferrals.done("You are not whitelisted on this server.")  -- Inform the player why they were kicked
    end
end)
