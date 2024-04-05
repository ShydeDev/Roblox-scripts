local client = game:GetService("Players").LocalPlayer
local energyPath = client.Character.Energy
local maxEnergy = string.split(client.PlayerGui.Main.Energy.TextLabel.Text, "/")[2]

energyPath.Changed:Connect(function()
    energyPath.Value = maxEnergy
end)
