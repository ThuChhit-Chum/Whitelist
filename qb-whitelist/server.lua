local whitelistURL = "https://github.com/ThuChhit-Chum/Fivem-Whitelist/blob/main/qb-whitelist/whitelist.json"

-- Function to fetch the whitelist from GitHub
function FetchWhitelist(cb)
    PerformHttpRequest(whitelistURL, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data and data.whitelisted then
                cb(data.whitelisted)
            else
                print("^1[Whitelist] Invalid whitelist format!^0")
                cb({})
            end
        else
            print("^1[Whitelist] Failed to fetch whitelist from GitHub!^0")
            cb({})
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

-- Event when player connects
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local steamHex = nil

    -- Get player's Steam Hex
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 6) == "steam:" then
            steamHex = id
            break
        end
    end

    if not steamHex then
        deferrals.done("You must have Steam open to join this server.")
        return
    end

    -- Check whitelist
    deferrals.defer()
    FetchWhitelist(function(whitelistedPlayers)
        local isWhitelisted = false
        local playerName = nil

        for _, playerData in ipairs(whitelistedPlayers) do
            if playerData.steam == steamHex then
                isWhitelisted = true
                playerName = playerData.name
                break
            end
        end

        if not isWhitelisted then
            deferrals.done("You are not whitelisted on this server. Please Register in Discord: https://discord.gg/WtPZWeuf8z")
        else
            print(("^2[Whitelist] Player %s (%s) has joined the server.^0"):format(playerName, steamHex))
            deferrals.done()
        end
    end)
end)
