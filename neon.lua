local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local effectEnabled = false


local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
local notificationLabel = Instance.new("TextLabel", screenGui)

notificationLabel.Size = UDim2.new(0, 100, 0, 50)
notificationLabel.Position = UDim2.new(0.5, -50, 0.1, 0)
notificationLabel.BackgroundTransparency = 0.5
notificationLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationLabel.Font = Enum.Font.SourceSansBold
notificationLabel.TextSize = 24
notificationLabel.Visible = false


local function showNotification(text)
    notificationLabel.Text = text
    notificationLabel.Visible = true
    

    local tween = TweenService:Create(notificationLabel, TweenInfo.new(1), {BackgroundTransparency = 1, TextTransparency = 1})
    tween:Play()
    

    tween.Completed:Connect(function()
        notificationLabel.Visible = false
        notificationLabel.BackgroundTransparency = 0.5
        notificationLabel.TextTransparency = 0
    end)
end


local processedCharacters = {}


local function processCharacter(character)
    if not character or processedCharacters[character] then
        return  -- Personagem é nulo ou já foi processado
    end


    local originalParts = {}

    local removedItems = {}


    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") then
            local clone = item:Clone()
            table.insert(removedItems, clone)
            item:Destroy()
        end
    end


    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Armazena Material e Cor originais
            originalParts[part] = {
                Material = part.Material,
                Color = part.Color
            }

            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 0, 0)  -- Cor roxa
        end
    end

    processedCharacters[character] = {
        originalParts = originalParts,
        removedItems = removedItems
    }
end


local function restoreCharacter(character)
    local data = processedCharacters[character]
    if not data then
        return  
    end


    for part, original in pairs(data.originalParts) do
        if part and part.Parent then  
            part.Material = original.Material
            part.Color = original.Color
        end
    end


    for _, item in ipairs(data.removedItems) do
        if item then
            item.Parent = character
        end
    end


    processedCharacters[character] = nil
end


local function processAllCharacters()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if player.Character then
                processCharacter(player.Character)
            end
        end
    end
end


local function restoreAllCharacters()
    for character, _ in pairs(processedCharacters) do
        restoreCharacter(character)
    end
end


local function onPlayerAdded(player)
    if player == localPlayer then
        return
    end


    player.CharacterAdded:Connect(function(character)
        -- Aguarda o personagem ser completamente carregado
        character:WaitForChild("HumanoidRootPart", 5)  
        if effectEnabled then
            processCharacter(character)
        end
    end)


    if player.Character then
        processCharacter(player.Character)
    end
end


Players.PlayerAdded:Connect(onPlayerAdded)


for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end


local function toggleEffect()
    effectEnabled = not effectEnabled
    if effectEnabled then
        processAllCharacters()
        showNotification("ON")
    else
        restoreAllCharacters()
        showNotification("OFF")
    end
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.Insert then  -- u can change the keybind here
        toggleEffect()
    end
end)
