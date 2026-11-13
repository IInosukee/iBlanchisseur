local ESX = nil
local npc = nil
local menuOuvert = false

Citizen.CreateThread(function()
    -- ESX Legacy expose un export, les anciennes versions passent par l'event
    local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
    if ok then ESX = obj end
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(o) ESX = o end)
        Wait(100)
    end
end)

local function GetBlackMoney()
    local data = ESX.GetPlayerData()
    for _, account in ipairs(data.accounts or {}) do
        if account.name == 'black_money' then
            return account.money
        end
    end
    return 0
end

local function KeyboardInput(textEntry, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', '', '', '', '', maxLength)
    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() == 1 then
        return GetOnscreenKeyboardResult()
    end
    return nil
end

local function TexteBas(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

local function CreateNPC()
    local model = GetHashKey(Config.PNJ)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local pos = Config.PositionBlanchisseur.pos
    npc = CreatePed(4, model, pos.x, pos.y, pos.z, Config.PositionBlanchisseur.heading, false, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
    if Config.PortArme then
        GiveWeaponToPed(npc, GetHashKey(Config.Arme), 1, false, true)
    end
end

local function Blanchir(montant)
    montant = tonumber(montant)
    if not montant or montant < Config.MinAmount or montant ~= math.floor(montant) then
        return ESX.ShowNotification('Veuillez entrer une valeur ~r~correcte')
    end
    if montant > GetBlackMoney() then
        return ESX.ShowNotification("Tu n'as pas assez d'argent ~r~sale")
    end
    TriggerServerEvent('iBlanchisseur:blanchir', montant)
end

RMenu.Add('iBlanchisseur_menu', 'main', RageUI.CreateMenu('Blanchisseur', 'Que voulez-vous faire ?'))
RMenu:Get('iBlanchisseur_menu', 'main').Closed = function()
    menuOuvert = false
end

local function OpenMenuBlanchisseur()
    if menuOuvert then return end
    menuOuvert = true
    local menu = RMenu:Get('iBlanchisseur_menu', 'main')
    RageUI.Visible(menu, true)

    Citizen.CreateThread(function()
        local taux = math.floor(Config.Taxes * 100)
        while menuOuvert do
            Wait(0)
            RageUI.IsVisible(menu, true, true, true, function()
                local argentSale = GetBlackMoney()
                RageUI.Separator('Argent Sale : ~r~' .. ESX.Math.GroupDigits(argentSale) .. '$')
                RageUI.Separator('Taux de retour : ~g~' .. taux .. '%')

                RageUI.ButtonWithStyle('Blanchir', 'Choisir le montant à blanchir', {RightLabel = '→→→'}, true, function(_, _, selected)
                    if selected then
                        Blanchir(KeyboardInput('Combien veux-tu blanchir ?', 12))
                    end
                end)

                RageUI.ButtonWithStyle('Tout blanchir', ('Tu recevras ~g~%s$'):format(ESX.Math.GroupDigits(math.floor(argentSale * Config.Taxes))), {RightLabel = '→→→'}, argentSale >= Config.MinAmount, function(_, _, selected)
                    if selected then
                        Blanchir(argentSale)
                    end
                end)
            end)
        end
    end)
end

local function CloseMenuBlanchisseur()
    if not menuOuvert then return end
    menuOuvert = false
    RageUI.CloseAll()
end

Citizen.CreateThread(function()
    while ESX == nil do Wait(100) end
    CreateNPC()

    local pos = Config.PositionBlanchisseur.pos
    while true do
        local interval = 500
        local distance = #(GetEntityCoords(PlayerPedId()) - pos)

        if distance < Config.Distance then
            interval = 0
            if not menuOuvert then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour parler à ~r~' .. Config.Name)
                if IsControlJustPressed(0, 51) then
                    if Config.Dialog then
                        TexteBas("~b~[Vous]~s~ Salut, c'est toi pour le blanchiment ?", 2500)
                        Wait(2500)
                        TexteBas('~r~[' .. Config.Name .. "]~s~ Ouais c'est moi, tu veux blanchir combien ?", 2500)
                        Wait(2500)
                    end
                    OpenMenuBlanchisseur()
                end
            end
        elseif menuOuvert then
            CloseMenuBlanchisseur()
        end

        Wait(interval)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    CloseMenuBlanchisseur()
    if npc and DoesEntityExist(npc) then
        DeleteEntity(npc)
    end
end)
