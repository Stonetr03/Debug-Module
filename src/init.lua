-- Stonetr03

local RunService = game:GetService("RunService");
local HttpService = game:GetService("HttpService");
local Types = require(script:WaitForChild("types"));
local UserInputService = game:GetService("UserInputService");

local Module = {}

if RunService:IsClient() then
    local Fusion = require(script:WaitForChild("Packages"):WaitForChild("Fusion"))
    local Config = require(script:WaitForChild("config"))

    local New = Fusion.New
    local Value = Fusion.Value
    local Children = Fusion.Children

    -- Values
    local Visible = Value(false);
    local Rendering = Value({});
    local RenderingClient = {}
    local RenderingServer = {}

    -- Ui
    local ScreenGui = New "ScreenGui" {
        ResetOnSpawn = false;
        DisplayOrder = 1000000000;
        Enabled = Visible;
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui");
        Name = "__Debug_Module_Ui";
        [Children] = New "Frame" {
            AnchorPoint = Vector2.new(1,0.5);
            Position = UDim2.new(1,-10,0.5,0);
            Size = UDim2.new(0,0,1,0);
            BackgroundTransparency = 1;

            [Children] = {
                New "UIListLayout" {
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    SortOrder = Enum.SortOrder.Name;
                };
                Fusion.ForPairs(Rendering,function(i,o)
                    return i, New "TextLabel" {
                        Name = tostring(i);
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,20);
                        TextSize = 18;
                        Font = Enum.Font.SourceSans;
                        Text = tostring(o.Name) .. " : " .. tostring(o.Data:get());
                        TextXAlignment = Enum.TextXAlignment.Right;
                        TextColor3 = Color3.new(1,1,1);
                        TextStrokeColor3 = Color3.new(0,0,0);
                        TextStrokeTransparency = 0;
                    }
                end,Fusion.cleanup)
            }
        }
    }

    -- Functions
    function Update()
        local CompTable = {}
        for _,o in pairs(RenderingServer) do
            table.insert(CompTable,o);
        end
        for _,o in pairs(RenderingClient) do
            table.insert(CompTable,o);
        end
        Rendering:set(CompTable)
    end

    function Module:addLine(Text: string, Data: any): Types.returnTab
        local DataValue = Value(Data)
        local ListTab = {Name = Text,Data = DataValue}
        table.insert(RenderingClient,ListTab)
        Update()

        local ReturnTab = {}
        function ReturnTab:Destroy()
            local n = table.find(RenderingClient,ListTab)
            if n then
                table.remove(RenderingClient,n)
                Update()
            end
        end
        function ReturnTab:Update(NewData: any)
            DataValue:set(NewData)
        end
        return ReturnTab
    end

    -- Visible Settings
    local KeysPressed = {}

    local function CheckKeys()
        local Valid = true
        for _,k in pairs(Config.Keys) do
            if table.find(KeysPressed,k) == nil then
                Valid = false
            end
        end
        if Valid == true then
            Visible:set(not Visible:get())
        end
    end

    UserInputService.InputBegan:Connect(function(Input)
        if UserInputService:GetFocusedTextBox() == nil then
            if table.find(Config.Keys,Input.KeyCode) then
                if table.find(KeysPressed,Input.KeyCode) == nil then
                    table.insert(KeysPressed,Input.KeyCode)
                end
                CheckKeys()
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if table.find(KeysPressed,Input.KeyCode) then
            table.remove(KeysPressed,table.find(KeysPressed,Input.KeyCode))
        end
    end)

    -- Print Keys
    if Config.PrintOutput == true then
        local PText = "\nFor Debug"
        for _,k in pairs(Config.Keys) do
            PText = PText .. " " .. string.sub(tostring(k),14)
        end
        PText = PText .. "\n"
        print(PText)
    end

    -- Server Lines
    local RE
    local RF
    function Check()
        if RE then else
            if script:FindFirstChild("__Debug_RE") then
                RE = script:FindFirstChild("__Debug_RE")
                RE.OnClientEvent:Connect(function(t,Hash,Txt,Data)
                    if t == "create" then
                        RenderingServer[Hash] = {Name = Txt,Data = Value(Data)}
                        Update()
                    elseif t == "destroy" then
                        RenderingServer[Hash] = nil
                        Update()
                    elseif t == "update" then
                        if RenderingServer[Hash] and RenderingServer[Hash].Data then
                            RenderingServer[Hash].Data:set(Txt)
                        end
                    end
                end)
            end
        end
        if RF then else
            if script:FindFirstChild("__Debug_RF") then
                RF = script:FindFirstChild("__Debug_RF")
                local Slines = RF:InvokeServer()
                for Hash,o in pairs(Slines) do
                    RenderingServer[Hash] = {Name = o.Name,Data = Value(o.Data)}
                end
                Update()
            end
        end
    end
    script.ChildAdded:Connect(Check)
    Check()
end

-- Server
if RunService:IsServer() then
    local Lines = {}
    -- Remotes
    local RemoteEvent = Instance.new("RemoteEvent");
    RemoteEvent.Name = "__Debug_RE";
    RemoteEvent.Parent = script;
    local RemoteFunction = Instance.new("RemoteFunction");
    RemoteFunction.Name = "__Debug_RF";
    RemoteFunction.OnServerInvoke = function()
        return Lines
    end;
    RemoteFunction.Parent = script;

    -- Functions
    function Module:addLine(Text: string,Data: any): Types.returnTab
        local Hash = HttpService:GenerateGUID(true)
        local ListTab = {Name = Text,Data = Data}
        Lines[Hash] = ListTab
        RemoteEvent:FireAllClients("create",Hash,Text,Data)
        local ReturnTab = {}
        function ReturnTab:Destroy()
            if Lines[Hash] then
                Lines[Hash] = nil
                RemoteEvent:FireAllClients("destroy",Hash)
            end
        end
        function ReturnTab:Update(NewData: any)
            if Lines[Hash] then
                Lines[Hash].Data = NewData
                RemoteEvent:FireAllClients("update",Hash,NewData)
            end
        end
        return ReturnTab
    end
end

return Module
