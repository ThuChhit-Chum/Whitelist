local whitelistURL = "https://thuchhit-chum.github.io/Whitelist/qb-whitelist/whitelist.json"

-- Function to fetch and return the whitelist
local function FetchWhitelist(callback)
    PerformHttpRequest(whitelistURL, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data and data.whitelisted then
                local whitelist = {}
                for _, player in pairs(data.whitelisted) do
                    whitelist[player.steam] = player.name
                end
                callback(whitelist)
            else
                print("^1[QB-Whitelist] ERROR: Invalid JSON structure!^0")
                callback(nil)
            end
        else
            print("^1[QB-Whitelist] ERROR: Failed to fetch whitelist! HTTP Code: " .. err .. "^0")
            callback(nil)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

-- Check if a player is whitelisted
AddEventHandler("playerConnecting", function(name, setCallback, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local steamIdentifier = nil

    -- Get the Steam identifier
    for _, v in pairs(identifiers) do
        if string.sub(v, 1, 6) == "steam:" then
            steamIdentifier = v
            break
        end
    end

    deferrals.defer()
    Wait(100) -- Give some time for the deferral message

    if not steamIdentifier then
        deferrals.done("🚫 [QB-Whitelist] You must have Steam open to join this server.")
        return
    end

    -- Fetch the latest whitelist before allowing the player in
    FetchWhitelist(function(whitelistedPlayers)
        if whitelistedPlayers and whitelistedPlayers[steamIdentifier] then
            print("^2[QB-Whitelist] Access granted: " .. name .. " (" .. steamIdentifier .. ")^0")
            deferrals.done()
        else
            print("^1[QB-Whitelist] Access denied: " .. name .. " (" .. steamIdentifier .. ")^0")
            deferrals.done("🚫 You are not whitelisted on this server. Please Register in Discord: https://discord.gg/WtPZWeuf8z and Contact an admin.")
        end
    end)
end)
