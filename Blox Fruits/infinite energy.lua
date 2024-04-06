local client = game:GetService("Players").LocalPlayer
local energyPath = client.Character.Energy
local maxEnergy = string.split(client.PlayerGui.Main.Energy.TextLabel.Text, "/")[2]

energyPath:GetPropertyChangedSignal("Value"):Connect(function()
    if energyPath.Value ~= maxEnergy then
        energyPath.Value = maxEnergy
    end
end)
