RegisterNetEvent(getScript()..":server:buyTicket", function(price, chargeType)
    local src = source
    chargePlayer(price, chargeType, src)

    if Config.General.societyAccount and Config.General.societyAccount ~= "" then
        fundSociety(Config.General.societyAccount, price)
    end
end)