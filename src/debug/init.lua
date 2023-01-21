-- Stonetr03

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Module = {}

if RunService:IsClient() then
	local Roact = require(script:WaitForChild("Roact"))
	local Config = require(script:WaitForChild("config"))

	local Visible = false
	local ClientLines = {}
	local ServerLines = {}

	local function ListComp()
		local Fragment = {}

		for _,o in pairs(ClientLines) do
			local Ui = Roact.createElement("TextLabel",{
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,0,20);
				TextSize = 18;
				Font = Enum.Font.SourceSans;
				Text = tostring(o.Name) .. " : " .. tostring(o.Value);
				TextXAlignment = Enum.TextXAlignment.Right;
				TextColor3 = Color3.new(1,1,1);
				TextStrokeColor3 = Color3.new(0,0,0);
				TextStrokeTransparency = 0;
			})
			table.insert(Fragment,Ui)
		end

		for _,o in pairs(ServerLines) do
			local Ui = Roact.createElement("TextLabel",{
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,0,20);
				TextSize = 18;
				Font = Enum.Font.SourceSans;
				Text = tostring(o.Name) .. " : " .. tostring(o.Value);
				TextXAlignment = Enum.TextXAlignment.Right;
				TextColor3 = Color3.new(1,1,1);
				TextStrokeColor3 = Color3.new(0,0,0);
				TextStrokeTransparency = 0;
			})
			table.insert(Fragment,Ui)
		end


		return Roact.createFragment(Fragment)
	end

	local ScreenGui = Roact.createElement("ScreenGui",{
		ResetOnSpawn = false;
		DisplayOrder = 1000000000;
		Enabled = Visible;
	},{
		Frame = Roact.createElement("Frame",{
			AnchorPoint = Vector2.new(1,0.5);
			Position = UDim2.new(1,-10,0.5,0);
			Size = UDim2.new(0,0,1,0);
			BackgroundTransparency = 1;
		},{
			UIListLayout = Roact.createElement("UIListLayout",{
				HorizontalAlignment = Enum.HorizontalAlignment.Right;
				VerticalAlignment = Enum.VerticalAlignment.Center;
				SortOrder = Enum.SortOrder.Name;
			});
			Fragment = Roact.createElement(ListComp);
		})
	})

	local Mount = Roact.mount(ScreenGui,game.Players.LocalPlayer.PlayerGui)

	local function Update()
		Roact.update(Mount,Roact.createElement("ScreenGui",
			{
				ResetOnSpawn = false;
				DisplayOrder = 1000000000;
				Enabled = Visible;
			},{
				Frame = Roact.createElement("Frame",{
					AnchorPoint = Vector2.new(1,0.5);
					Position = UDim2.new(1,-10,0.5,0);
					Size = UDim2.new(0,0,1,0);
					BackgroundTransparency = 1;
				},{
					UIListLayout = Roact.createElement("UIListLayout",{
						HorizontalAlignment = Enum.HorizontalAlignment.Right;
						VerticalAlignment = Enum.VerticalAlignment.Center;
						SortOrder = Enum.SortOrder.Name;
					});
					Fragment = Roact.createElement(ListComp);
				})
			})
		)
	end

	function Module:addLine(Text,Value)
		local ListTab = {Name = Text,Value = Value}
		table.insert(ClientLines,ListTab)
		Update()
		local ReturnTab = {}
		function ReturnTab:Destroy()
			local n = table.find(ClientLines,ListTab)
			if n then
				table.remove(ClientLines,n)
				Update()
			end
		end
		function ReturnTab:Update(Value)
			ListTab.Value = Value
			Update()
		end
		return ReturnTab
	end

	-- Client Remote Event
	script.RemoteEvent.OnClientEvent:Connect(function(Mode,h,t,v)
		if Mode == "create" then
			if ServerLines[h] == nil then
				ServerLines[h] = {Name = t,Value = v}
				Update()
			end
		elseif Mode == "destroy" then
			if ServerLines[h] then
				ServerLines[h] = nil
				Update()
			end
		elseif Mode == "update" then
			if ServerLines[h] then
				ServerLines[h].Value = v
				Update()
			end
		end
	end)
	local Tab = script.RemoteFunc:InvokeServer()
	for h,o in pairs(Tab) do
		if ServerLines[h] == nil then
			ServerLines[h] = {Name = o.Name,Value = o.Value}
			Update()
		end
	end

	-- Display
	local KeysPressed = {}

	local function CheckKeys()
		local Valid = true
		for _,k in pairs(Config.Keys) do
			if table.find(KeysPressed,k) == nil then
				Valid = false
			end
		end
		if Valid == true then
			Visible = not Visible
			Update()
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
	local PText = "\nFor Debug"
	for _,k in pairs(Config.Keys) do
		PText = PText .. " " .. string.sub(tostring(k),14)
	end
	PText = PText .. "\n"
	print(PText)
end

if RunService:IsServer() then
	local ServerLines = {}

	function Module:addLine(Text,Value)
		local Hash = HttpService:GenerateGUID(false)
		local ListTab = {Name = Text,Value = Value}
		ServerLines[Hash] = ListTab
		script.RemoteEvent:FireAllClients("create",Hash,Text,Value)
		local ReturnTab = {}
		function ReturnTab:Destroy()
			if ServerLines[Hash] then
				ServerLines[Hash] = nil
				script.RemoteEvent:FireAllClients("destroy",Hash)
			end
		end
		function ReturnTab:Update(NewValue)
			if ServerLines[Hash] then
				ServerLines[Hash].Value = NewValue
				script.RemoteEvent:FireAllClients("update",Hash,Text,NewValue)
			end
		end
		return ReturnTab
	end
	script.RemoteFunc.OnServerInvoke = function()
		return ServerLines
	end
end

return Module
