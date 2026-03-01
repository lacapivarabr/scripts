--=== AUTO BUY VIP VERSÃO 03 (OFICIAL) - COM TIMER DE RESTOCK ===--
-- Abas: Compras e Extras (Anti-AFK + Pulo Alto)

-- Services
local rep = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local vu = game:GetService("VirtualUser")

-- Remove GUI anterior
if player.PlayerGui:FindFirstChild("AutoBuyVIP") then
    player.PlayerGui.AutoBuyVIP:Destroy()
end

-- Evento de compra (seu formato exato)
local BuyFood = rep:WaitForChild("Events"):WaitForChild("Shops"):WaitForChild("BuyFood")
local Stock = rep:WaitForChild("Stock")

-- CONFIGURAÇÕES
local INTERVALO = 1
local ATIVO = false
local MINIMIZADO = false
local ABA_ATIVA = "Compras"
local ANTI_AFK_ATIVO = false
local PULO_ALTO_ATIVO = false
local idleConnection = nil
local jumpConnection = nil
local jumpPowerOriginal = 50

-- ITENS (com fallback)
local itens = {
    OP = {
        nome = "⭐ STAR",
        objeto = Stock:FindFirstChild("Star") or Stock:FindFirstChild("OP") or Stock:FindFirstChild("star"),
        ativo = true,
        cor = Color3.fromRGB(255, 200, 0)
    },
    SECRET = {
        nome = "🥛🍪 MILK AND COOKIES",
        objeto = Stock:FindFirstChild("MilkAndCookies") or Stock:FindFirstChild("Milk") or Stock:FindFirstChild("Secret"),
        ativo = true,
        cor = Color3.fromRGB(255, 150, 100)
    }
}

-- Verifica itens
for tipo, item in pairs(itens) do
    if item.objeto then
        print("✅ Item encontrado:", tipo, "->", item.objeto.Name)
    else
        print("❌ Item NÃO encontrado:", tipo)
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoBuyVIP"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0.5, -150, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Bordas
local bordas = Instance.new("UICorner")
bordas.CornerRadius = UDim.new(0, 10)
bordas.Parent = frame

-- Título com abas e botão de minimizar
local tituloFrame = Instance.new("Frame")
tituloFrame.Size = UDim2.new(1, 0, 0, 40)
tituloFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tituloFrame.BorderSizePixel = 0
tituloFrame.Parent = frame

local tituloBorda = Instance.new("UICorner")
tituloBorda.CornerRadius = UDim.new(0, 10)
tituloBorda.Parent = tituloFrame

-- Texto do título (esquerda)
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(0, 120, 1, 0)
titulo.Position = UDim2.new(0, 10, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "⚡ AUTO VIP"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextSize = 16
titulo.Font = Enum.Font.GothamBold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = tituloFrame

-- Botões de aba
local abaCompras = Instance.new("TextButton")
abaCompras.Size = UDim2.new(0, 60, 0, 30)
abaCompras.Position = UDim2.new(0, 140, 0, 5)
abaCompras.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
abaCompras.Text = "Compras"
abaCompras.TextColor3 = Color3.fromRGB(255, 255, 255)
abaCompras.TextSize = 12
abaCompras.Font = Enum.Font.GothamBold
abaCompras.BorderSizePixel = 0
abaCompras.Parent = tituloFrame

local abaExtras = Instance.new("TextButton")
abaExtras.Size = UDim2.new(0, 60, 0, 30)
abaExtras.Position = UDim2.new(0, 205, 0, 5)
abaExtras.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
abaExtras.Text = "Extras"
abaExtras.TextColor3 = Color3.fromRGB(200, 200, 200)
abaExtras.TextSize = 12
abaExtras.Font = Enum.Font.GothamBold
abaExtras.BorderSizePixel = 0
abaExtras.Parent = tituloFrame

-- Botão MINIMIZAR
local minimizarBtn = Instance.new("TextButton")
minimizarBtn.Size = UDim2.new(0, 30, 0, 30)
minimizarBtn.Position = UDim2.new(1, -35, 0, 5)
minimizarBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizarBtn.Text = "−"
minimizarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizarBtn.TextSize = 20
minimizarBtn.Font = Enum.Font.GothamBold
minimizarBtn.BorderSizePixel = 0
minimizarBtn.Parent = tituloFrame

local minBorda = Instance.new("UICorner")
minBorda.CornerRadius = UDim.new(0, 6)
minBorda.Parent = minimizarBtn

-- ===== PÁGINA DE COMPRAS ===== --
local paginaCompras = Instance.new("Frame")
paginaCompras.Name = "PaginaCompras"
paginaCompras.Size = UDim2.new(1, 0, 1, -40)
paginaCompras.Position = UDim2.new(0, 0, 0, 40)
paginaCompras.BackgroundTransparency = 1
paginaCompras.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0, 10, 0, 5)
status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
status.Text = "⏸️ AUTO BUY: PAUSADO"
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.Parent = paginaCompras

local statusBorda = Instance.new("UICorner")
statusBorda.CornerRadius = UDim.new(0, 8)
statusBorda.Parent = status

-- Timer do Auto Buy (esquerda)
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.5, -5, 0, 25)
timerLabel.Position = UDim2.new(0, 10, 0, 45)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
timerLabel.Text = "⏱️ Auto: 1s"
timerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timerLabel.TextSize = 12
timerLabel.Font = Enum.Font.Gotham
timerLabel.Parent = paginaCompras

local timerBorda = Instance.new("UICorner")
timerBorda.CornerRadius = UDim.new(0, 8)
timerBorda.Parent = timerLabel

-- Timer do Restock (direita)
local restockTimer = Instance.new("TextLabel")
restockTimer.Size = UDim2.new(0.5, -5, 0, 25)
restockTimer.Position = UDim2.new(0.5, 5, 0, 45)
restockTimer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
restockTimer.Text = "🏪 Restock: ?"
restockTimer.TextColor3 = Color3.fromRGB(200, 200, 200)
restockTimer.TextSize = 12
restockTimer.Font = Enum.Font.Gotham
restockTimer.Parent = paginaCompras

local restockBorda = Instance.new("UICorner")
restockBorda.CornerRadius = UDim.new(0, 8)
restockBorda.Parent = restockTimer

-- Área dos itens VIP
local itensFrame = Instance.new("Frame")
itensFrame.Size = UDim2.new(1, -20, 0, 80)
itensFrame.Position = UDim2.new(0, 10, 0, 75)
itensFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
itensFrame.BorderSizePixel = 0
itensFrame.Parent = paginaCompras

local itensBorda = Instance.new("UICorner")
itensBorda.CornerRadius = UDim.new(0, 8)
itensBorda.Parent = itensFrame

local itensTitulo = Instance.new("TextLabel")
itensTitulo.Size = UDim2.new(1, -10, 0, 20)
itensTitulo.Position = UDim2.new(0, 5, 0, 5)
itensTitulo.BackgroundTransparency = 1
itensTitulo.Text = "ITENS VIP"
itensTitulo.TextColor3 = Color3.fromRGB(200, 200, 255)
itensTitulo.TextSize = 12
itensTitulo.Font = Enum.Font.GothamBold
itensTitulo.TextXAlignment = Enum.TextXAlignment.Left
itensTitulo.Parent = itensFrame

-- Botões dos itens
local botoesItens = {}
local yPos = 25

for tipo, item in pairs(itens) do
    local btnFrame = Instance.new("TextButton")
    btnFrame.Size = UDim2.new(1, -10, 0, 25)
    btnFrame.Position = UDim2.new(0, 5, 0, yPos)
    btnFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btnFrame.BorderSizePixel = 0
    btnFrame.AutoButtonColor = false
    btnFrame.Parent = itensFrame
    
    local btnBorda = Instance.new("UICorner")
    btnBorda.CornerRadius = UDim.new(0, 4)
    btnBorda.Parent = btnFrame
    
    local nomeLabel = Instance.new("TextLabel")
    nomeLabel.Size = UDim2.new(1, -25, 1, 0)
    nomeLabel.Position = UDim2.new(0, 5, 0, 0)
    nomeLabel.BackgroundTransparency = 1
    nomeLabel.Text = item.objeto and item.nome or item.nome .. " (❌)"
    nomeLabel.TextColor3 = item.objeto and item.cor or Color3.fromRGB(255, 100, 100)
    nomeLabel.TextSize = 12
    nomeLabel.Font = Enum.Font.GothamBold
    nomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    nomeLabel.Parent = btnFrame
    
    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(0, 20, 1, 0)
    check.Position = UDim2.new(1, -25, 0, 0)
    check.BackgroundTransparency = 1
    check.Text = item.objeto and (item.ativo and "✅" or "❌") or "🚫"
    check.TextColor3 = item.objeto and 
        (item.ativo and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) 
        or Color3.fromRGB(100, 100, 100)
    check.TextSize = 14
    check.Parent = btnFrame
    
    if item.objeto then
        btnFrame.MouseButton1Click:Connect(function()
            item.ativo = not item.ativo
            check.Text = item.ativo and "✅" or "❌"
            check.TextColor3 = item.ativo and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)
    end
    
    botoesItens[tipo] = {btn = btnFrame, check = check}
    yPos = yPos + 27
end

-- Log de ações
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 0, 60)
logFrame.Position = UDim2.new(0, 10, 0, 160)
logFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
logFrame.BorderSizePixel = 0
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.ScrollBarThickness = 5
logFrame.Parent = paginaCompras

local logBorda = Instance.new("UICorner")
logBorda.CornerRadius = UDim.new(0, 8)
logBorda.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logFrame

-- Botões de controle
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -20, 0, 35)
btnFrame.Position = UDim2.new(0, 10, 0, 225)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = paginaCompras

-- Botão AUTO BUY
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.48, -2, 1, 0)
autoBtn.Position = UDim2.new(0, 0, 0, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
autoBtn.Text = "⚡ AUTO BUY"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.GothamBold
autoBtn.BorderSizePixel = 0
autoBtn.Parent = btnFrame

local autoBorda = Instance.new("UICorner")
autoBorda.CornerRadius = UDim.new(0, 8)
autoBorda.Parent = autoBtn

-- Botão TELEPORT
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.48, -2, 1, 0)
teleportBtn.Position = UDim2.new(0.52, 2, 0, 0)
teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
teleportBtn.Text = "📍 TELEPORT"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.TextSize = 12
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = btnFrame

local teleportBorda = Instance.new("UICorner")
teleportBorda.CornerRadius = UDim.new(0, 8)
teleportBorda.Parent = teleportBtn

-- ===== PÁGINA EXTRAS (ANTI-AFK + PULO ALTO) ===== --
local paginaExtras = Instance.new("Frame")
paginaExtras.Name = "PaginaExtras"
paginaExtras.Size = UDim2.new(1, 0, 1, -40)
paginaExtras.Position = UDim2.new(0, 0, 0, 40)
paginaExtras.BackgroundTransparency = 1
paginaExtras.Visible = false
paginaExtras.Parent = frame

-- Título da página
local extrasTitulo = Instance.new("TextLabel")
extrasTitulo.Size = UDim2.new(1, -20, 0, 30)
extrasTitulo.Position = UDim2.new(0, 10, 0, 10)
extrasTitulo.BackgroundTransparency = 1
extrasTitulo.Text = "🛡️ EXTRAS"
extrasTitulo.TextColor3 = Color3.fromRGB(255, 255, 255)
extrasTitulo.TextSize = 16
extrasTitulo.Font = Enum.Font.GothamBold
extrasTitulo.Parent = paginaExtras

-- ===== ANTI-AFK ===== --
local antiAfkTitulo = Instance.new("TextLabel")
antiAfkTitulo.Size = UDim2.new(1, -20, 0, 20)
antiAfkTitulo.Position = UDim2.new(0, 10, 0, 40)
antiAfkTitulo.BackgroundTransparency = 1
antiAfkTitulo.Text = "▶ ANTI-AFK"
antiAfkTitulo.TextColor3 = Color3.fromRGB(200, 200, 255)
antiAfkTitulo.TextSize = 12
antiAfkTitulo.Font = Enum.Font.GothamBold
antiAfkTitulo.TextXAlignment = Enum.TextXAlignment.Left
antiAfkTitulo.Parent = paginaExtras

-- Botão Anti-AFK
local antiAfkBtn = Instance.new("TextButton")
antiAfkBtn.Size = UDim2.new(0.8, 0, 0, 30)
antiAfkBtn.Position = UDim2.new(0.1, 0, 0, 60)
antiAfkBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
antiAfkBtn.Text = "ATIVAR ANTI-AFK"
antiAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAfkBtn.TextSize = 11
antiAfkBtn.Font = Enum.Font.GothamBold
antiAfkBtn.BorderSizePixel = 0
antiAfkBtn.Parent = paginaExtras

local antiBorda = Instance.new("UICorner")
antiBorda.CornerRadius = UDim.new(0, 6)
antiBorda.Parent = antiAfkBtn

-- Status Anti-AFK
local antiStatus = Instance.new("TextLabel")
antiStatus.Size = UDim2.new(1, -20, 0, 20)
antiStatus.Position = UDim2.new(0, 10, 0, 95)
antiStatus.BackgroundTransparency = 1
antiStatus.Text = "Status: DESATIVADO"
antiStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
antiStatus.TextSize = 11
antiStatus.Font = Enum.Font.Gotham
antiStatus.TextXAlignment = Enum.TextXAlignment.Left
antiStatus.Parent = paginaExtras

-- ===== PULO ALTO ===== --
local puloAltoTitulo = Instance.new("TextLabel")
puloAltoTitulo.Size = UDim2.new(1, -20, 0, 20)
puloAltoTitulo.Position = UDim2.new(0, 10, 0, 125)
puloAltoTitulo.BackgroundTransparency = 1
puloAltoTitulo.Text = "▶ PULO ALTO"
puloAltoTitulo.TextColor3 = Color3.fromRGB(200, 200, 255)
puloAltoTitulo.TextSize = 12
puloAltoTitulo.Font = Enum.Font.GothamBold
puloAltoTitulo.TextXAlignment = Enum.TextXAlignment.Left
puloAltoTitulo.Parent = paginaExtras

-- Botão Pulo Alto
local puloAltoBtn = Instance.new("TextButton")
puloAltoBtn.Size = UDim2.new(0.6, 0, 0, 30)
puloAltoBtn.Position = UDim2.new(0.1, 0, 0, 145)
puloAltoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
puloAltoBtn.Text = "ATIVAR PULO ALTO"
puloAltoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
puloAltoBtn.TextSize = 11
puloAltoBtn.Font = Enum.Font.GothamBold
puloAltoBtn.BorderSizePixel = 0
puloAltoBtn.Parent = paginaExtras

local puloBorda = Instance.new("UICorner")
puloBorda.CornerRadius = UDim.new(0, 6)
puloBorda.Parent = puloAltoBtn

-- Slider/Input para altura do pulo
local alturaInput = Instance.new("TextBox")
alturaInput.Size = UDim2.new(0.2, -5, 0, 30)
alturaInput.Position = UDim2.new(0.72, 0, 0, 145)
alturaInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
alturaInput.Text = "100"
alturaInput.TextColor3 = Color3.fromRGB(255, 255, 255)
alturaInput.TextSize = 12
alturaInput.Font = Enum.Font.GothamBold
alturaInput.PlaceholderText = "altura"
alturaInput.BorderSizePixel = 0
alturaInput.Parent = paginaExtras

local inputBorda = Instance.new("UICorner")
inputBorda.CornerRadius = UDim.new(0, 6)
inputBorda.Parent = alturaInput

-- Status Pulo Alto
local puloStatus = Instance.new("TextLabel")
puloStatus.Size = UDim2.new(1, -20, 0, 20)
puloStatus.Position = UDim2.new(0, 10, 0, 180)
puloStatus.BackgroundTransparency = 1
puloStatus.Text = "Status: DESATIVADO"
puloStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
puloStatus.TextSize = 11
puloStatus.Font = Enum.Font.Gotham
puloStatus.TextXAlignment = Enum.TextXAlignment.Left
puloStatus.Parent = paginaExtras

-- ===== FUNÇÕES COMPARTILHADAS ===== --

-- Função de log (para página compras)
local function addLog(texto, tipo)
    local cor = tipo == "sucesso" and Color3.fromRGB(100, 255, 100) or
                tipo == "erro" and Color3.fromRGB(255, 100, 100) or
                Color3.fromRGB(200, 200, 255)
    
    local linha = Instance.new("TextLabel")
    linha.Size = UDim2.new(1, -10, 0, 18)
    linha.BackgroundTransparency = 1
    linha.Text = texto
    linha.TextColor3 = cor
    linha.TextSize = 11
    linha.Font = Enum.Font.Gotham
    linha.TextXAlignment = Enum.TextXAlignment.Left
    linha.Parent = logFrame
    
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
    logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
end

-- Função de compra
local function comprar(item)
    if not item.objeto then return false end
    local args = {item.objeto}
    local ok = pcall(function()
        return BuyFood:InvokeServer(unpack(args))
    end)
    return ok
end

-- Função para aplicar pulo alto no personagem
local function aplicarPuloAlto(personagem, altura)
    local humanoid = personagem:WaitForChild("Humanoid")
    if PULO_ALTO_ATIVO then
        jumpPowerOriginal = humanoid.JumpPower
        humanoid.JumpPower = altura
    else
        humanoid.JumpPower = jumpPowerOriginal
    end
end

-- Loop principal
local function loopCompra()
    ATIVO = true
    status.Text = "⚡ AUTO BUY: ATIVO"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    while ATIVO do
        local comprouAlgo = false
        
        for tipo, item in pairs(itens) do
            if ATIVO and item.ativo and item.objeto then
                local ok = comprar(item)
                if ok then
                    addLog("✅ " .. item.nome, "sucesso")
                    comprouAlgo = true
                else
                    addLog("⏳ " .. item.nome .. ": sem estoque", "info")
                end
                wait(0.2)
            end
        end
        
        if not comprouAlgo then
            addLog("⏳ Nenhum item disponível", "info")
        end
        
        -- Atualiza timer do restock
        local success, timerTexto = pcall(function()
            local timerObj = player.PlayerGui:FindFirstChild("BabyCatsGui"):FindFirstChild("Shop"):FindFirstChild("FoodShop"):FindFirstChild("Frame"):FindFirstChild("Topbar"):FindFirstChild("RestockTimer")
            if timerObj and timerObj:IsA("TextLabel") then
                return timerObj.Text
            end
            return "?"
        end)
        
        if success and timerTexto then
            restockTimer.Text = "🏪 " .. timerTexto
        else
            restockTimer.Text = "🏪 Restock: ?"
        end
        
        -- Timer do Auto Buy
        for i = INTERVALO, 1, -1 do
            if not ATIVO then break end
            timerLabel.Text = "⏱️ Auto: " .. i .. "s"
            wait(1)
        end
    end
end

-- Função para ativar/desativar Anti-AFK
local function toggleAntiAfk()
    ANTI_AFK_ATIVO = not ANTI_AFK_ATIVO
    if ANTI_AFK_ATIVO then
        idleConnection = player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        antiAfkBtn.Text = "DESATIVAR ANTI-AFK"
        antiStatus.Text = "Status: ATIVADO"
        antiStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        addLog("🛡️ Anti-AFK ativado", "sucesso")
    else
        if idleConnection then
            idleConnection:Disconnect()
            idleConnection = nil
        end
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        antiAfkBtn.Text = "ATIVAR ANTI-AFK"
        antiStatus.Text = "Status: DESATIVADO"
        antiStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        addLog("🛡️ Anti-AFK desativado", "info")
    end
end

-- Função para ativar/desativar Pulo Alto
local function togglePuloAlto()
    PULO_ALTO_ATIVO = not PULO_ALTO_ATIVO
    
    local altura = tonumber(alturaInput.Text) or 100
    if altura < 50 then altura = 50 end
    
    if PULO_ALTO_ATIVO then
        if player.Character then
            aplicarPuloAlto(player.Character, altura)
        end
        jumpConnection = player.CharacterAdded:Connect(function(char)
            aplicarPuloAlto(char, altura)
        end)
        
        puloAltoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        puloAltoBtn.Text = "DESATIVAR PULO"
        puloStatus.Text = "Status: ATIVADO (" .. altura .. ")"
        puloStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        addLog("🦘 Pulo alto ativado: " .. altura, "sucesso")
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
        puloAltoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        puloAltoBtn.Text = "ATIVAR PULO ALTO"
        puloStatus.Text = "Status: DESATIVADO"
        puloStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        addLog("🦘 Pulo alto desativado", "info")
    end
end

-- Conecta os botões da página Extras
antiAfkBtn.MouseButton1Click:Connect(toggleAntiAfk)
puloAltoBtn.MouseButton1Click:Connect(togglePuloAlto)

-- Efeito intermitente no botão AUTO BUY
spawn(function()
    while true do
        if ATIVO then
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, math.random(150, 255), 0)
            wait(0.2)
        else
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            wait(0.5)
        end
    end
end)

-- Função para trocar de aba
local function selecionarAba(aba)
    ABA_ATIVA = aba
    if aba == "Compras" then
        abaCompras.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        abaCompras.TextColor3 = Color3.fromRGB(255, 255, 255)
        abaExtras.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        abaExtras.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        abaExtras.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        abaExtras.TextColor3 = Color3.fromRGB(255, 255, 255)
        abaCompras.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        abaCompras.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    paginaCompras.Visible = (aba == "Compras")
    paginaExtras.Visible = (aba == "Extras")
end

-- Eventos das abas
abaCompras.MouseButton1Click:Connect(function()
    selecionarAba("Compras")
end)

abaExtras.MouseButton1Click:Connect(function()
    selecionarAba("Extras")
end)

-- Função minimizar
local function toggleMinimizar()
    MINIMIZADO = not MINIMIZADO
    
    if MINIMIZADO then
        frame.Size = UDim2.new(0, 300, 0, 40)
        paginaCompras.Visible = false
        paginaExtras.Visible = false
        minimizarBtn.Text = "□"
    else
        frame.Size = UDim2.new(0, 300, 0, 320)
        selecionarAba(ABA_ATIVA)
        minimizarBtn.Text = "−"
    end
end

minimizarBtn.MouseButton1Click:Connect(toggleMinimizar)

-- Eventos dos botões principais (Auto Buy e Teleport)
autoBtn.MouseButton1Click:Connect(function()
    if not ATIVO then
        task.spawn(loopCompra)
        autoBtn.Text = "⏸️ PAUSAR"
    else
        ATIVO = false
        autoBtn.Text = "⚡ AUTO BUY"
        status.Text = "⏸️ AUTO BUY: PAUSADO"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        timerLabel.Text = "⏱️ Auto: 1s"
        addLog("⏹ Auto Buy parado", "info")
    end
end)

teleportBtn.MouseButton1Click:Connect(function()
    local shop = workspace:FindFirstChild("Shops") and workspace.Shops:FindFirstChild("FoodShop")
    if shop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = shop.CFrame + Vector3.new(0, 5, 0)
        addLog("📍 Teleportado para loja", "sucesso")
    end
end)

-- Inicia com aba Compras
selecionarAba("Compras")

-- Mensagens iniciais no log
addLog("✅ VIP Auto Buy v03 (oficial)", "info")
addLog("🔽 Abas: Compras e Extras", "info")
if itens.OP.objeto then addLog("⭐ STAR: Disponível", "sucesso") end
if itens.SECRET.objeto then addLog("🥛🍪 Milk: Disponível", "sucesso") end

print("=== AUTO BUY VIP VERSÃO 03 (OFICIAL) ===")
print("✅ Anti-AFK e Pulo Alto incluídos")
print("✅ Timer de Restock adicionado na aba Compras")
