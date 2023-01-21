local RunService = game:GetService("RunService")

local Debug = require(game.ReplicatedStorage.debug)
Debug:addLine("ServerTest","yes")

local TimeLine = Debug:addLine("ServerTime","")

RunService.Heartbeat:Connect(function(deltaTime)
    TimeLine:Update(os.date("%c",os.time()))
end)
