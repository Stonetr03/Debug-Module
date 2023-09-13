local Debug = require(game.ReplicatedStorage.debug);
local Line = Debug:addLine("Time",0)
for i = 1, 25, 1 do
    Line:Update(i);
    task.wait(1)
end
Line:Destroy()