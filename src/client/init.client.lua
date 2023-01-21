local RunService = game:GetService("RunService")

local Debug = require(game.ReplicatedStorage.debug)
Debug:addLine("Test","Test2")

local TimeLine = Debug:addLine("Time","")

RunService.RenderStepped:Connect(function(deltaTime)
    TimeLine:Update(os.date("%c",os.time()))
end)
