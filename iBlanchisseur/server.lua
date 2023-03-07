ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("blanchir_argent")
AddEventHandler("blanchir_argent", function(gain)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local taxes = Config.Taxes
    
    if gain > 0 and xPlayer.getAccount('black_money').money >= gain then
        total = gain*taxes
        xPlayer.removeAccountMoney("black_money", gain)
        TriggerClientEvent("esx:showAdvancedNotification", _src, "informations", "blanchiment", "Ça sera blanchi dans ~r~"..math.floor(Config.Time/1000).."~s~ secondes")
        Citizen.Wait(Config.Time)
        xPlayer.addMoney(total)
        TriggerClientEvent("esx:showAdvancedNotification", _src, "informations", "blanchiment", "Tu as reçu ~g~"..ESX.Math.Round(total).."$")
    else
        TriggerClientEvent("esx:showAdvancedNotification", _src, "informations", "blanchiment", "Reviens me voir quand tu aura assez d'argent !")
    end
end)
