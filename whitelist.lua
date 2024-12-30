-- URL for the whitelist JSON hosted on GitHub
local whitelistURL = "https://raw.githubusercontent.com/ThuChhit-Chum/Fivem-Whitelist/main/whitelist.json"

-- Table to store the whitelisted Steam Hex IDs
local whitelistedSteamIDs = {}

-- Function to fetch the whitelist data from GitHub
function fetchWhitelist()
    PerformHttpRequest(whitelistURL, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data then
                whitelistedSteamIDs = data.steamHexIDs or {}
                print("Whitelist loaded successfully.")
            else
                print("Failed to decode JSON from GitHub.")
            end
        else
            print("Failed to fetch whitelist from GitHub. Status Code: " .. statusCode)
        end
    end, "GET")
end

-- Function to check if a player's Steam Hex ID is whitelisted
function isPlayerWhitelisted(steamHex)
    for _, id in ipairs(whitelistedSteamIDs) do
        if id == steamHex then
            return true
        end
    end
    return false
end

-- Event handler for when a player attempts to connect
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()  -- Delay the connection for checking

    local player = source
    local steamHex = nil

    -- Fetch the player's Steam Hex ID (Ensure correct format for steam identifier)
    for _, identifier in ipairs(GetPlayerIdentifiers(player)) do
        if string.sub(identifier, 1, 6) == "steam:" then
            steamHex = identifier  -- Found the Steam Hex ID
            break
        end
    end

    -- Debugging: Print Steam Hex ID of the player
    print("Player attempting to connect: " .. playerName)
    print("Player Steam Hex ID: " .. (steamHex or "None"))

    -- Check if the player is whitelisted
    if steamHex and isPlayerWhitelisted(steamHex) then
        deferrals.done()  -- Player is whitelisted, allow connection
    else
        setKickReason("You are not whitelisted on this server.")  -- Kick the player if not whitelisted
        deferrals.done("You are not whitelisted on this server.")  -- Inform the player why they were kicked
    end
end)

-- Fetch the whitelist when the server starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        fetchWhitelist()  -- Load the whitelist when the resource starts
    end
end)
