local Debug = require(game.ReplicatedStorage.debug)
local Line = Debug:addLine("Server",0)
for i = 1, 15, 1 do
    Line:Update(i)
    task.wait(2)
end
Line:Destroy()