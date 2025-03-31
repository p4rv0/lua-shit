local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local teamcheck = false
local highlightMode = Enum.HighlightDepthMode.Occluded

local function aplicarHighlightNoPersonagem(character)
    if character and character:IsDescendantOf(workspace) then
        local highlight = character:FindFirstChildOfClass("Highlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 1
            highlight.Parent = character
        end
        highlight.DepthMode = highlightMode
    end
end

local function processarJogadores()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            if teamcheck then
                if player.Team ~= Players.LocalPlayer.Team then
                    aplicarHighlightNoPersonagem(character)
                end
            else
                aplicarHighlightNoPersonagem(character)
            end
        end
    end
end

local function alternarHighlightMode()
    if highlightMode == Enum.HighlightDepthMode.Occluded then
        highlightMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        highlightMode = Enum.HighlightDepthMode.Occluded
    end
    processarJogadores()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        alternarHighlightMode()
    end
end)

while true do
    processarJogadores()
    wait(0.2)
end
