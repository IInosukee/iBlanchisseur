local ESX = nil

-- ESX Legacy expose un export, les anciennes versions passent par l'event
if GetResourceState('es_extended') ~= 'missing' then
    local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
    if ok then ESX = obj end
end
if not ESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local enCours = {} -- Joueurs ayant un blanchiment en cours

local function Notify(src, msg)
    TriggerClientEvent('esx:showAdvancedNotification', src, Config.Name, 'Blanchiment', msg, 'CHAR_LESTER_DEATHWISH', 1)
end

local function IsNearLaunderer(src)
    local ped = GetPlayerPed(src)
    if ped == 0 then return true end -- Sans OneSync, la position n'est pas connue côté serveur
    return #(GetEntityCoords(ped) - Config.PositionBlanchisseur.pos) <= Config.Distance + 3.0
end

local function GetBlackMoney(xPlayer)
    local account = xPlayer.getAccount('black_money')
    return account and account.money or 0
end

RegisterNetEvent('iBlanchisseur:blanchir', function(montant)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or enCours[src] then return end

    montant = tonumber(montant)
    if not montant or montant ~= montant or montant == math.huge then return end
    montant = math.floor(montant)

    if montant < Config.MinAmount then
        return Notify(src, ('Le minimum est de ~r~%s$'):format(ESX.Math.GroupDigits(Config.MinAmount)))
    end
    if not IsNearLaunderer(src) then return end
    if GetBlackMoney(xPlayer) < montant then
        return Notify(src, "Reviens me voir quand tu auras assez d'argent !")
    end

    enCours[src] = true
    Notify(src, ('Ça sera blanchi dans ~r~%d~s~ secondes'):format(math.floor(Config.Time / 1000)))
    Wait(Config.Time)

    -- On revérifie après l'attente : le joueur a pu se déconnecter ou dépenser son argent entre-temps
    xPlayer = ESX.GetPlayerFromId(src)
    if not enCours[src] or not xPlayer then return end
    enCours[src] = nil

    if GetBlackMoney(xPlayer) < montant then
        return Notify(src, "Tu n'as plus assez d'argent sale, l'affaire est annulée.")
    end

    local total = math.floor(montant * Config.Taxes)
    xPlayer.removeAccountMoney('black_money', montant)
    xPlayer.addMoney(total)
    Notify(src, ('Tu as reçu ~g~%s$'):format(ESX.Math.GroupDigits(total)))
end)

AddEventHandler('playerDropped', function()
    enCours[source] = nil
end)
