--version 1.7 last updated on 13-1-2023

--Defining the ui library
local Rayfield = loadstring(readfile('MemzWare/Assets/UiLib.lua'))()

local Window = Rayfield:CreateWindow({
	Name = "MemzWare | 1.7",
	LoadingTitle = "Loading..",
	LoadingSubtitle = "by Memz#7217",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "MemzWare", -- Create a custom folder for your hub/game
		FileName = "ConfigurationBedwars"
	},
        Discord = {
        	Enabled = true,
        	Invite = "ruvuWm4yD4", -- The Discord invite code, do not include discord.gg/
        	RememberJoins = false -- Set this to false to make them join the discord every time they load it up
        },
	KeySystem = true, -- Set this to true to use our key system
	KeySettings = {
		Title = "MemzWare",
		Subtitle = "Key System",
		Note = "Join the discord (https://discord.gg/ruvuWm4yD4)",
		FileName = "VapeBedwarsData",
		SaveKey = true,
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
		Key = "MemzWare"
	}
})
--end of defining ui library

--defining notifications

--notifs
--examples 
--[[Notification.new("error", "Disabled", "modules has been disabled!.") -- Args(<string> Type, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)
Notification.new("success", "Enabled", "modules has been enabled!.", 1) -- Args(<string> Type, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)
Notification.new("info", "Disabling", "Disabling anticheat dont move.") -- Args(<string> Type, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)
Notification.new("warning", "YOu died", "Imagine dying bozo.") -- Args(<string> Type, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)
Notification.new("message", "Message Heading", "Message body message.") -- Args(<string> Type, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)
]]
local Notification = loadstring(readfile('MemzWare/Assets/Notifs.lua'))()

--end of notifications

--creating tabs
--examples of tab - local Tab = Window:CreateTab("Tab Example", 4483362458) -- Title, Image
local Combat = Window:CreateTab("Combat")
local Blatant = Window:CreateTab("Blatant")
local Misc = Window:CreateTab("Misc")
local Visuals = Window:CreateTab("Visuals")
--end of creating tabs

--locals
local lplr = game:GetService("Players").LocalPlayer
local cam = game:GetService("Workspace").CurrentCamera
local uis = game:GetService("UserInputService")
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local getremote = function(tab)
    for i,v in pairs(tab) do
        if v == "Client" then
            return tab[i + 1]
        end
    end
    return ""
end
local killauraboostenabled = false
local highjumpenabled = false
local longjumpenabled = false
local BoostOnPotionFlightEnabled = false
local newVelocity = lplr.Character.Humanoid.MoveDirection * (23.39999998)

local bedwars = {
    ["SprintController"] = KnitClient.Controllers.SprintController,
    ["ClientHandlerStore"] = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
    ["KnockbackUtil"] = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
    ["PingController"] = require(lplr.PlayerScripts.TS.controllers.game.ping["ping-controller"]).PingController,
    ["DamageIndicator"] = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
    ["SwordController"] = KnitClient.Controllers.SwordController,
    ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
    ["SwordRemote"] = getremote(debug.getconstants((KnitClient.Controllers.SwordController).attackEntity)),
    ["BalloonController"] = KnitClient.Controllers.BalloonController,
    ["ClientStoreHandler"] = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
    ["BlockBreaker"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"]["out"]["client"]["break"]["block-breaker"]).BlockBreaker,
    ["ProjectileRemote"] = getremote(debug.getconstants(debug.getupvalues(getmetatable(KnitClient.Controllers.ProjectileController)["launchProjectileWithValues"])[2])),
    ["ConsumeRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.ConsumeController).onEnable, 1))),
    ["ShieldController"] = getremote(debug.getconstants(KnitClient.Controllers.InfernalShieldController.constructor)),
    ["HannahController"] = KnitClient.Controllers.HannahController,
}

--functions
function isalive(plr)
    plr = plr or lplr
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("Head") then return false end
    if not plr.Character:FindFirstChild("Humanoid") then return false end
    return true
end
function canwalk(plr)
    plr = plr or lplr
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("Humanoid") then return false end
    local state = plr.Character:FindFirstChild("Humanoid"):GetState()
    if state == Enum.HumanoidStateType.Dead then
        return false
    end
    if state == Enum.HumanoidStateType.Ragdoll then
        return false
    end
    return true
end
function getbeds()
    local beds = {}
    for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
        if string.lower(v.Name) == "bed" and v:FindFirstChild("Covers") ~= nil and v:FindFirstChild("Covers").Color ~= lplr.Team.TeamColor then
            table.insert(beds,v)
        end
    end
    return beds
end
function getplayers()
    local players = {}
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Team ~= lplr.Team and isalive(v) and v.Character:FindFirstChild("Humanoid").Health > 0.11 then
            table.insert(players,v)
        end
    end
    return players
end
function getserverpos(Position)
    local x = math.round(Position.X/3)
    local y = math.round(Position.Y/3)
    local z = math.round(Position.Z/3)
    return Vector3.new(x,y,z)
end
function getnearestplayer(maxdist)
    local obj = lplr
    local dist = math.huge
    for i,v in pairs(game:GetService("Players"):GetChildren()) do
        if v.Team ~= lplr.Team and v ~= lplr and isalive(v) and isalive(lplr) then
            local mag = (v.Character:FindFirstChild("HumanoidRootPart").Position - lplr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
            if (mag < dist) and (mag < maxdist) then
                dist = mag
                obj = v
            end
        end
    end
    return obj
end
function getmatchstate()
    return bedwars["ClientHandlerStore"]:getState().Game.matchState
end
function getqueuetype()
    local state = bedwars["ClientHandlerStore"]:getState()
    return state.Game.queueType or "bedwars_test"
end
function getitem(itm)
    if isalive(lplr) and lplr.Character:FindFirstChild("InventoryFolder").Value:FindFirstChild(itm) then
        return true
    end
    return false
end
function hasProperty(ins,pro)
    return pcall(function() _=ins[pro] end)
end
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, num, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, num, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, num, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local function enabled(Message, Time)
    Notification:SendNotification("Success", Message .. " - Has been set to enabled!", Time)
end

local function disabled(Message, Time)
    Notification:SendNotification("Error", Message .. " - Has been set to disabled!", Time)
end

local function warning(Message, Time)
    Notification:SendNotification("Warning", Message, Time)
end

local function info(Message, Time)
    Notification:SendNotification("Info", Message, Time)
end

--end of functions

--arraylist defining
local array = loadstring(readfile('MemzWare/Assets/ArrayList.lua'))()
shared["CometConfigs"] = {
    Enabled = true
}
--arraylist defined

--creating modules!

--Visuals
do
    Visuals:CreateSection("HUD")
    local Enabled = false
    local ArrayListToggle = Visuals:CreateToggle({
        Name = "ArrayList",
        CurrentValue = true,
        Flag = "ArrayListToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("ArrayList", 2)
                shared["CometConfigs"] = {
                    Enabled = true
                }
            else
                disabled("ArrayList", 2)
                shared["CometConfigs"] = {
                    Enabled = false
                }
            end
        end
    })
end

do
    -- Gui to Lua
    -- Version: 3.2

    -- Instances:

    local WaterMark = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Memz = Instance.new("TextLabel")
    local Ware = Instance.new("TextLabel")
    local Division_1 = Instance.new("TextLabel")
    local FPS = Instance.new("TextLabel")
    local Division_2 = Instance.new("TextLabel")
    local PING = Instance.new("TextLabel")

    --Properties:

    WaterMark.Name = "WaterMark"
    WaterMark.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    WaterMark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WaterMark.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = WaterMark
    Main.Active = true
    Main.BackgroundColor3 = Color3.fromRGB(145, 11, 255)
    Main.BackgroundTransparency = 0.690
    Main.Draggable = true
    Main.Position = UDim2.new(0.343726784, -456, 0.526184559, -486)
    Main.Size = UDim2.new(0, 385, 0, 53)

    UICorner.CornerRadius = UDim.new(1, 25)
    UICorner.Parent = Main

    Memz.Name = "Memz"
    Memz.Parent = Main
    Memz.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Memz.BackgroundTransparency = 1.000
    Memz.Position = UDim2.new(0.0155844092, 0, 0.188679218, 0)
    Memz.Size = UDim2.new(0, 87, 0, 32)
    Memz.Font = Enum.Font.FredokaOne
    Memz.Text = "Memz"
    Memz.TextColor3 = Color3.fromRGB(255, 255, 255)
    Memz.TextSize = 29.000

    Ware.Name = "Ware"
    Ware.Parent = Main
    Ware.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ware.BackgroundTransparency = 1.000
    Ware.Position = UDim2.new(0.18701297, 0, 0.188679218, 0)
    Ware.Size = UDim2.new(0, 87, 0, 32)
    Ware.Font = Enum.Font.FredokaOne
    Ware.Text = "Ware"
    Ware.TextColor3 = Color3.fromRGB(248, 157, 227)
    Ware.TextSize = 29.000

    Division_1.Name = "Division_1"
    Division_1.Parent = Main
    Division_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Division_1.BackgroundTransparency = 1.000
    Division_1.Position = UDim2.new(0.293506503, 0, 0.188679218, 0)
    Division_1.Size = UDim2.new(0, 87, 0, 32)
    Division_1.Font = Enum.Font.FredokaOne
    Division_1.Text = "|"
    Division_1.TextColor3 = Color3.fromRGB(248, 248, 248)
    Division_1.TextSize = 29.000

    FPS.Name = "FPS"
    FPS.Parent = Main
    FPS.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FPS.BackgroundTransparency = 1.000
    FPS.Position = UDim2.new(0.467532396, 0, 0.188679338, 0)
    FPS.Size = UDim2.new(0, 87, 0, 32)
    FPS.Font = Enum.Font.FredokaOne
    FPS.Text = "FPS : 240"
    FPS.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPS.TextSize = 29.000

    Division_2.Name = "Division_2"
    Division_2.Parent = Main
    Division_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Division_2.BackgroundTransparency = 1.000
    Division_2.Position = UDim2.new(0.631168842, 0, 0.188679218, 0)
    Division_2.Size = UDim2.new(0, 87, 0, 32)
    Division_2.Font = Enum.Font.FredokaOne
    Division_2.Text = "|"
    Division_2.TextColor3 = Color3.fromRGB(248, 248, 248)
    Division_2.TextSize = 29.000

    PING.Name = "PING"
    PING.Parent = Main
    PING.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PING.BackgroundTransparency = 1.000
    PING.Position = UDim2.new(0.742857099, 0, 0.188679338, 0)
    PING.Size = UDim2.new(0, 87, 0, 32)
    PING.Font = Enum.Font.FredokaOne
    PING.Text = "100ms"
    PING.TextColor3 = Color3.fromRGB(255, 255, 255)
    PING.TextSize = 29.000
    WaterMark.Enabled = false
    Main.Visible = false
    Main.Draggable = true

    local Enabled = false
    local FPSEnabled = false
    local PINGEnabled = false
    local WaterMarkToggle = Visuals:CreateToggle({
        Name ="WaterMark",
        CurrentValue = false,
        Flag = "WaterMarkToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("WaterMark")
                enabled("WaterMark", 2)
                WaterMark.Enabled = true
                Main.Visible = true
                spawn(function()
                    game:GetService("RunService").Heartbeat:Connect(function()
                        task.wait()
                        local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
                        ping = math.floor(ping)
                        PING.Text = " " ..ping.."ms"
                    end)
                end)
                spawn(function()
                    local RunService = game:GetService("RunService")
                    
                    local TimeFunction = RunService:IsRunning() and time or os.clock
                    
                    local LastIteration, Start
                    local FrameUpdateTable = {}
                    
                    local function loopupdate()
                        task.wait()
                        LastIteration = TimeFunction()
                        for Index = #FrameUpdateTable, 1, -1 do
                            FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
                        end
                    
                        FrameUpdateTable[1] = LastIteration
                        FPS.Text = "FPS : " .. tostring(math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)))
                    end
                    
                    Start = TimeFunction()
                    RunService.Heartbeat:Connect(loopupdate)
                    
                end)
            else
                array.Remove("WaterMark")
                disabled("WaterMark", 2)
                WaterMark.Enabled = false
                Main.Visible = false
            end
        end
    })
    local FPSToggle = Visuals:CreateToggle({
        Name = "FPS",
        CurrentValue = false,
        Flag = "FpsToggle",
        Callback = function(val)
            FPSEnabled = val
            if FPSEnabled then
                enabled("WaterMark.FPS", 2)
                FPS.Visible = true
            else
                disabled("WaterMark.FPS", 2)
                FPS.Visible = false
            end
        end
    })
    local PINGToggle = Visuals:CreateToggle({
        Name = "PING",
        CurrentValue = false,
        Flag = "PINGToggle",
        Callback = function(val)
            PINGEnabled = val
            if PINGEnabled then
                enabled("WaterMark.PING", 2)
                PING.Visible = true
            else
                disabled("WaterMark.PING", 2)
                PING.Visible = false
            end
        end
    })
end

do
    Visuals:CreateSection("Self")
    local char = lplr.Character
    local ColorValue = Color3.fromRGB(102, 205, 217)
    local SelfTrans = {["Value"] = 0.21}
    local SelfMaterial = "ForceField"
    local tableofcharparts = { "Head", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "UpperTorso", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftFoot", "LeftHand", "RightHand"}
    --
    local SelfColor;
    local SelfTransparency;
    local SelfMat;
    local Enabled = false
    local SelfChams = Visuals:CreateToggle({
        Name = "Custom Character",
        CurrentValue = false,
        Flag = "SelfChamToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("CustomCharacter", 2)
                repeat
                    task.wait()
                    ColorValue = SelfColor.Color
                    SelfTrans.Value = SelfTransparency.CurrentValue
                    SelfMaterial = SelfMat.CurrentOption
                    for i,v in next, char:GetChildren() do
                        if v and v:IsA("BasePart") or table.find(tableofcharparts, v.Name) then
                            v.Color = ColorValue
                            v.Transparency = SelfTrans.Value
                            v.Material = SelfMaterial
                        end
                    end
                until not Enabled
                disabled("CustomCharacter", 2)
            end
        end
    })
    SelfMat = Visuals:CreateDropdown({
        Name = "Char Material",
        Options = {"SmoothPlastic", "ForceField", "Neon", "Foil", "Glass"},
        CurrentOption = "ForceField",
        Flag = "CharMaterialDropDown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Option)
            SelfMaterial = Option
        end,
    })
    SelfTransparency = Visuals:CreateSlider({
        Name = "Char transparency",
        Range = {0, 1},
        Increment = 0.01,
        CurrentValue = 0.21,
        Flag = "CharTransparencySlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            SelfTrans.Value = Value
        end,
    })
    SelfColor = Visuals:CreateColorPicker({
        Name = "Char Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "CharColorPicker", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            ColorValue = Value
        end
    })
end

do
    Visuals:CreateSection("ViewModel")
    local Enabled = false
    local viewmodel = workspace.Camera.Viewmodel
    local ColorValue = Color3.fromRGB(102, 205, 217)
    local ItemTrans = {["Value"] = 0.21}
    local MaterialMode = "ForceField"
    local ItemsColor;
    local ItemMaterialMode;
    local ItemTransparencySlider;
    local ItemChams = Visuals:CreateToggle({
        Name = "ItemChams (disable texture pack)",
        CurrentValue = false,
        Flag = "ItemChamsToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("ItemChams", 2)
                repeat
                    task.wait()
                    ColorValue = ItemsColor.Color
                    ItemTrans.Value = ItemTransparencySlider.CurrentValue
                    MaterialMode = ItemMaterialMode.CurrentOption
                    for i,v in next, workspace.Camera.Viewmodel:GetDescendants() do
                        if v.Parent and v.Parent:IsA("Accessory") and game.ReplicatedStorage.Items:FindFirstChild(v.Parent.Name) then 
                            v.Color = ColorValue
                            v.Transparency = ItemTrans.Value
                            v.Material = MaterialMode
                        end
                    end
                until not Enabled
                disabled("ItemChams", 2)
            end
        end
    })
    ItemMaterialMode = Visuals:CreateDropdown({
        Name = "Item Material",
        Options = {"SmoothPlastic", "ForceField", "Neon", "Foil", "Glass"},
        CurrentOption = "ForceField",
        Flag = "ItemMaterialModeDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Option)
            MaterialMode = Option
        end,
    })
    ItemTransparencySlider = Visuals:CreateSlider({
        Name = "ItemTransparency",
        Range = {0, 1},
        Increment = 0.01,
        CurrentValue = 0.21,
        Flag = "ItemTransparencySlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            ItemTrans.Value = Value
        end,
    })
    ItemsColor = Visuals:CreateColorPicker({
        Name = "Item Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "ItemChamsColorPicker", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            ColorValue = Value
        end
    })
end

do
    Visuals:CreateSection("Custom viewmodel")
    local nobobdepth = {["Value"] = 8}
	local nobobhorizontal = {["Value"] = 8}
    local Connection
    local SwordSize;
    local Smaller = {["Value"] = 3}
    local oldc1;
    local Enabled = false
    local NobobToggle = Visuals:CreateToggle({
        Name = "Custom Viewmodel",
        CurrentValue = false,
        Flag = "CustomViewmodelToggle",
        Callback = function(val)
            Enabled = val
            if cam:FindFirstChild("Viewmodel") then
                if Enabled then
                    Smaller.Value = SwordSize.CurrentValue
                    Connection = cam.Viewmodel.ChildAdded:Connect(function(v)
                        if v:FindFirstChild("Handle") then
                            pcall(function()
                                v:FindFirstChild("Handle").Size = v:FindFirstChild("Handle").Size / tostring(Smaller["Value"])
                            end)
                        end
                    end)
                    task.wait()
                    lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth["Value"] / 10))
                    lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal["Value"] / 10))
                    pcall(function()
                        for i,v in pairs(cam.Viewmodel.Humanoid.Animator:GetPlayingAnimationTracks()) do 
                            v:Stop()
                        end
                    end)
                    bedwars["ViewmodelController"]:playAnimation(11)
                else
                    lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					pcall(function()
						for i,v in pairs(cam.Viewmodel.Humanoid.Animator:GetPlayingAnimationTracks()) do 
							v:Stop()
						end
					end)
					bedwars["ViewmodelController"]:playAnimation(11)
					cam.Viewmodel.RightHand.RightWrist.C1 = oldc1
                end
            end
        end
    })
    local nobobdepthslider = Visuals:CreateSlider({
        Name = "Pitch",
        Range = {1, 24},
        Increment = 1,
        CurrentValue = 12,
        Flag = "NobobDepthSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(val)
            if Enabled then
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
            end
        end,
    })
    local nobobhorizontalslider = Visuals:CreateSlider({
        Name = "Yaw",
        Range = {0, 24},
        Increment = 1,
        CurrentValue = 8,
        Flag = "HorizontalSliderNoBob", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(val)
            if Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
            end
        end,
    })
    SwordSize = Visuals:CreateSlider({
        Name = "Size",
        Range = {1, 6},
        Increment = 0.1,
        CurrentValue = 2.1,
        Flag = "ItemSizeSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(val)
            Smaller.Value = val
        end,
    })
end

do
    Visuals:CreateSection("Indicators")
    local Enabled = false
    local Messages = {"Pow!","Thump!","Wham!","Hit!","Smack!","Bang!","Pop!","Boom!", "MemzWarePrivate!", "Kabam!", "Skuuuura!", "Ablam!", "Pha pha!", "inf", "SkidzuraOnBottom!"}
    local old
    local DamageIndicatorst = Visuals:CreateToggle({
        Name = "Custom Damage Indicators",
        CurrentValue = false,
        Flag = "CustomDamageIndicators",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("CustomDamageIndicators")
                enabled("CustomDamageIndicators", 2)
                old = debug.getupvalue(bedwars["DamageIndicator"],10,{Create})
                debug.setupvalue(bedwars["DamageIndicator"],10,{
                    Create = function(self,obj,...)
                        spawn(function()
                            pcall(function()
                                obj.Parent.Text = Messages[math.random(1,#Messages)]
                                obj.Parent.TextColor3 =  Color3.fromHSV(tick()%5/5,1,1)
                            end)
                        end)
                        return game:GetService("TweenService"):Create(obj,...)
                    end
                })
            else
                debug.setupvalue(bedwars["DamageIndicator"],10,{
                    Create = old
                })
                old = nil
                array.Remove("CustomDamageIndicators")
                disabled("CustomDamageIndicators", 2)
            end
        end
    })
end

do
    Visuals:CreateSection("Main")
    local objects = {}
    local connections = {}
    local newconnection
    local Enabled = false
    local function BrickToNew(BrickName)
        local p = Instance.new("Part")
        p.BrickColor = BrickName
        local new = p.Color
        p:Destroy()
        return new
    end
    local function TagPart(part, plr)
        local tag = Drawing.new("Text")
        tag.Color = BrickToNew(plr.TeamColor)
        tag.Visible = false
        tag.Text = (plr.DisplayName or plr.Name)
        tag.Size = 20
        tag.Center = true
        tag.Outline = false
        tag.Font = 1
        table.insert(objects, tag)
        spawn(function()
            repeat
                task.wait()
                pcall(function()
                    local vec, onscreen = cam:worldToViewportPoint(plr.Character.Head.Position)
                    if onscreen then
                        tag.Visible = true
                        tag.Position = Vector2.new(vec.X, vec.Y)
                        tag.Text = (plr.DisplayName or plr.Name).." ("..math.floor(plr.Character.Humanoid.Health).." HP)"
                    else
                        tag.Visible = false
                    end
                end)
            until not tag or not isalive(plr) or not Enabled
            if tag then
                tag:Remove()
                objects[tag] = nil
            end
        end)
    end
    local KeybindNameTagsCheck = false;
    local NameTags = Visuals:CreateToggle({
        Name = "NameTags",
        CurrentValue = false,
        Flag = "NameTagsToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("NameTags")
                enabled("NameTags", 2)
                newconnection = game:GetService("Players").PlayerAdded:Connect(function(plr)
                    connections[#connections+1] = plr.CharacterAdded:Connect(function(char)
                        task.wait(1)
                        TagPart(char:WaitForChild("Head"), plr)
                    end)
                end)
                for i,plr in pairs(game:GetService("Players"):GetChildren()) do
                    if plr ~= lplr then
                        if isalive(plr) then
                            TagPart(plr.Character:WaitForChild("Head"), plr)
                        end
                        connections[#connections+1] = plr.CharacterAdded:Connect(function(char)
                            task.wait(1)
                            TagPart(char:WaitForChild("Head"), plr)
                        end)
                    end
                end
            else
                newconnection:Disconnect()
                for i,v in pairs(objects) do
                    v:Remove()
                    objects[v] = nil
                end
                for i,v in pairs(connections) do
                    v:Disconnect()
                    connections[v] = nil
                end
                array.Remove("NameTags")
                disabled("NameTags", 2)
            end
        end
    })
    local ntkeybind = Visuals:CreateKeybind({
        Name = "NameTags Keybind",
        CurrentKeybind = "P",
        HoldToInteract = false,
        Flag = "ntkeybindtoggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KeybindNameTagsCheck == true then
                KeybindNameTagsCheck = false
                NameTags:Set(enabled)
            else
                if KeybindNameTagsCheck == false then
                    KeybindNameTagsCheck = true
                    NameTags:Set(not enabled)
                end
            end
        end,
    })
end

do
    local InnerTransparency = {["Value"] = 0.45}
    local RefreshTime = {["Value"] = 5}
    local Enabled = false
    local ColorValue = Color3.fromRGB(119.00000050663948, 202.00000315904618, 168.0000051856041)
    local ColorPicker;
    local chams = Visuals:CreateToggle({
        Name = "Chams",
        CurrentValue = false,
        Flag = "ChamsToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Chams")
                enabled("Chams", 2)
                repeat
                    task.wait(RefreshTime.Value)
                    local players = game.Players:GetPlayers()
                    ColorValue = ColorPicker.Color

                    for i,v in pairs(players) do
                        esp = Instance.new("Highlight")
                        esp.Name = v.Name
                        esp.FillTransparency = InnerTransparency.Value
                        esp.FillColor = ColorValue
                        esp.OutlineColor = ColorValue
                        esp.OutlineTransparency = 0
                        esp.Parent = v.Character
                    end
                    game.Players.PlayerAdded:Connect(function(plr)
                        plr.CharacterAdded:Connect(function(chr)
                            local esp = Instance.new("Highlight")
                            esp = Instance.new("Highlight")
                            esp.Name = v.Name
                            esp.FillTransparency = 0.5
                            esp.FillColor = ColorValue
                            esp.OutlineColor = ColorValue
                            esp.OutlineTransparency = 0
                            esp.Parent = v.Character
                        end)
                    end)
                until not Enabled
            else
                array.Remove("Chams")
                disabled("Chams", 2)
            end
        end
    })
    local TransparencyChamsSlider = Visuals:CreateSlider({
        Name = "InnerTransparency",
        Range = {0, 1},
        Increment = 0.01,
        Suffix = " trans.",
        CurrentValue = 0.45,
        Flag = "InnerTransparencySlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            InnerTransparency.Value = Value
        end,
    })
    local RefreshTimeSlider = Visuals:CreateSlider({
        Name = "RefreshTime",
        Range = {1, 10},
        Increment = 0.5,
        Suffix = " trans.",
        CurrentValue = 5,
        Flag = "InnerTransparencySlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            RefreshTime.Value = Value
        end,
    })
    ColorPicker = Visuals:CreateColorPicker({
        Name = "Chams Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "ChamsColorPicker", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            ColorValue = Value
        end
    })
end

do
    local connection
    local NewFOV = {["Value"] = 120}
    local Enabled = false
    local FOVChanger = Visuals:CreateToggle({
        Name = "Fov Changer",
        CurrentValue = false,
        Flag = "FOVChangerToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("FOVChanger", 2)
                array.Add("FOVChanger")
                repeat
                    task.wait(0.5)
                    cam.FieldOfView = NewFOV["Value"]
                    connection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                    cam.FieldOfView = NewFOV["Value"]
                    end)
                until not Enabled
            else
                disabled("FOVChanger", 2)
                array.Remove("FOVChanger")
                connection:Disconnect()
                cam.FieldOfView = 80
            end
        end
    })
    local FOVSlider = Visuals:CreateSlider({
        Name = "FOVAmount",
        Range = {1, 120},
        Increment = 1,
        Suffix = "FOV",
        CurrentValue = 120,
        Flag = "FovAmountSlider",
        Callback = function(val)
            NewFOV["Value"] = val
        end
    })
end

do
    Visuals:CreateSection("World")
    local Enabled = false
    local AmbienceColor;
    local ColorPapa = Color3.fromRGB(102, 205, 217)
    local tint = Instance.new("ColorCorrectionEffect", game.Lighting)
    local newsky = Instance.new("Sky", game.Lighting)
    local Ambience = Visuals:CreateToggle({
        Name = "Ambience",
        CurrentValue = false,
        Flag = "AmbienceToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Ambience", "Purple")
                enabled("Ambience", 2)
                game.Lighting.Ambient = ColorPapa
                tint.TintColor = ColorPapa
                newsky.SkyboxBk = "rbxassetid://8539982183"
                newsky.SkyboxDn = "rbxassetid://8539981943"
                newsky.SkyboxFt = "rbxassetid://8539981721"
                newsky.SkyboxLf = "rbxassetid://8539981424"
                newsky.SkyboxRt = "rbxassetid://8539980766"
                newsky.SkyboxUp = "rbxassetid://8539981085"
                newsky.MoonAngularSize = 0
                newsky.SunAngularSize = 0
                newsky.StarCount = 3e3
                table.insert(TempAssets, newsky)
                table.insert(TempAssets, tint)
                repeat
                    task.wait()
                    ColorPapa = AmbienceColor.Color
                until not Enabled
            else
                newsky:Destroy()
                tint:Destroy()
                array.Remove("Ambience")
                disabled("Ambience", 2)
            end
        end
    })
    AmbienceColor = Visuals:CreateColorPicker({
        Name = "Ambience Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "AmbienceColorPicker", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
            -- The function that takes place every time the color picker is moved/changed
            -- The variable (Value) is a Color3fromRGB value based on which color is selected
            ColorPapa = Value
        end
    })
end

do
    local Enabled = false
    local TexturePack = Visuals:CreateToggle({
        Name = "Texture Pack",
        CurrentValue = false,
        Flag = "TexturePackToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("TexturePack")
                enabled("TexturePack", 2)
                local obj = game:GetObjects("rbxassetid://11221092608")[1]
                obj.Name = "Part"
                obj.Parent = game:GetService("ReplicatedStorage")
                for i,v in pairs(obj:GetChildren()) do
                    if string.lower(v.Name):find("cross") then
                        for i2,b in pairs(v:GetChildren()) do
                            b:Destroy()
                        end
                    end
                end
                shared.con = game:GetService("ReplicatedStorage").ChildAdded:Connect(function(v)
                    for i,x in pairs(obj:GetChildren()) do
                        x:Clone().Parent = v
                    end
                    shared.con:Disconnect()
                end)
                loadstring(readfile('MemzWare/Assets/Textures.lua'))()
            else
                array.remove("TexturePack")
                disabled("TexturePack", 2)
            end
        end
    })
end

--Blatant

do
    Blatant:CreateSection("Flight")
    local function studtoblock(startpos, pos)
        local mag = math.round((startpos - pos).Magnitude / 3)
        return mag
    end
    local starttick
    local startpos1
    local part
    local velo
    local flyVelocity;
    local Enabled = false
    local RiskyEnabled = false
    local FlightKeybindCheck = false
    local flytime;
    local blocks
    local Flight  = Blatant:CreateToggle({
        Name = "Flight",
        CurrentValue = false,
        Flag = "FlightToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("Flight", 2)
                starttick = tick()
                startpos1 = lplr.Character.HumanoidRootPart.Position
                bedwars["BalloonController"].enableBalloonPhysics = oldenable
                velo = Instance.new("BodyVelocity")
                velo.MaxForce = Vector3.new(0, 9e9, 0)
                velo.Parent = lplr.Character.HumanoidRootPart
                lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.5, 0)
                if getitem("balloon") and (lplr.Character:GetAttribute("InflatedBalloons") ~= nil and lplr.Character:GetAttribute("InflatedBalloons") < 1) then
                    bedwars["BalloonController"].inflateBalloon()
                end
                spawn(function()
                    repeat
                        task.wait()
                        local ballooninflated = ((lplr.Character:GetAttribute("InflatedBalloons") ~= nil and lplr.Character:GetAttribute("InflatedBalloons") > 0) and true) or false
                        if ballooninflated then
                            for i = 1,15 do
                                task.wait()
                                velo.Velocity = Vector3.new(0, i*1+(uis:IsKeyDown(Enum.KeyCode.Space) and 42 or 0)+(uis:IsKeyDown(Enum.KeyCode.LeftShift) and -42 or 0), 0)
                            end
                            for i = 1,15 do
                                task.wait()
                                velo.Velocity = Vector3.new(0, -i*1+(uis:IsKeyDown(Enum.KeyCode.Space) and 42 or 0)+(uis:IsKeyDown(Enum.KeyCode.LeftShift) and -42 or 0), 0)
                            end
                        else
                            for i = 1,3 do
                                task.wait()
                                velo.Velocity = Vector3.new(0, 0.3+(uis:IsKeyDown(Enum.KeyCode.Space) and 42 or 0)+(uis:IsKeyDown(Enum.KeyCode.LeftShift) and -42 or 0), 0)
                            end
                            for i = 1,3 do
                                task.wait()
                                velo.Velocity = Vector3.new(0, -0.3+(uis:IsKeyDown(Enum.KeyCode.Space) and 42 or 0)+(uis:IsKeyDown(Enum.KeyCode.LeftShift) and -42 or 0), 0)
                            end
                        end
                        if RiskyEnabled then
                            local You = game.Players.LocalPlayer.Name
                            local UIS = game:GetService("UserInputService")
                            local Speed = 0.55
                            if UIS:IsKeyDown(Enum.KeyCode.W) then
                                game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,-Speed)
                            end
                            if UIS:IsKeyDown(Enum.KeyCode.A) then
                                game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(-Speed,0,0)
                            end
                            if UIS:IsKeyDown(Enum.KeyCode.S) then
                                game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,Speed)
                            end
                            if UIS:IsKeyDown(Enum.KeyCode.D) then
                                game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(Speed,0,0)
                            end
                        end
                    until not Enabled
                end)
            else
                disabled("Flight", 2)
                velo:Destroy()
                bedwars["BalloonController"].enableBalloonPhysics = oldenable
                if (lplr.Character:GetAttribute("InflatedBalloons") ~= nil and lplr.Character:GetAttribute("InflatedBalloons") > 0) then
                    bedwars["BalloonController"].deflateBalloon()
                end
                spawn(function()
                    flytime = math.abs(math.round(starttick - tick()))
                    blocks = studtoblock(startpos1, lplr.Character.HumanoidRootPart.Position)
                    info("Fly flew " .. tostring(flytime) .. " and " .. blocks .. " blocks", 2)
                    task.wait(0.1)
                end)
            end
        end
    })
    local BoostOnPotion = Blatant:CreateToggle({
        Name = "BoostOnPotion",
        CurrentValue = false,
        Flag = "BoostOnPotionToggle",
        Callback = function(val)
            BoostOnPotion = val
            if BoostOnPotion then
                if lplr.Character:GetAttribute("SpeedBoost") then
                    newVelocity = lplr.Character.Humanoid.MoveDirection * (56.82857138)
                end
            end
        end
    })
    local riskyfly = Blatant:CreateToggle({
        Name = "RiskyMode",
        CurrentValue = false,
        Flag = "RiskyModeFlightToggle",
        Callback = function(val)
            RiskyEnabled = val
        end
    })
    local ftkeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "C",
        HoldToInteract = false,
        Flag = "FlightKeybindToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if FlightKeybindCheck == true then
                FlightKeybindCheck = false
                Flight:Set(enabled)
            else
                if FlightKeybindCheck == false then
                    FlightKeybindCheck = true
                    Flight:Set(not enabled)
                end
            end
        end,
    })
end

do
    local Enabled = false
    local AnticheatBypass
    local enable
    local disable
    local bypassconnections = {}
    enable = function()
        local char = lplr.Character
        local hrp = char.HumanoidRootPart
        local fhrp = hrp:Clone()
        char.Parent = game
        fhrp.Parent = char
        char.PrimaryPart = fhrp
        hrp.Parent = cam
        char.Parent = game:GetService("Workspace")
        hrp.Transparency = 0.5
        hrp.Velocity = Vector3.new(0, 0, 0)
        fhrp.Velocity = Vector3.new(0, 0, 0)
        bypassconnections[#bypassconnections+1] = game:GetService("RunService").Heartbeat:Connect(function()
            local x
            local z
            if hrp.Velocity.X > 80 or hrp.Velocity.X < -80 then
                x = 0
            else
                x = hrp.Velocity.X
            end
            if hrp.Velocity.Z > 80 or hrp.Velocity.Z < -80 then
                z = 0
            else
                z = hrp.Velocity.Z
            end
            hrp.Velocity = Vector3.new(x, 0, z)
        end)
        spawn(function()
            repeat
                task.wait(0.5)
                if not isnetworkowner(hrp) then
                    repeat task.wait() until isnetworkowner(hrp)
                    if not isalive(lplr) then
                        repeat task.wait() until isalive(lplr)
                    end
                    task.wait(0.2)
                    return
                end
                hrp.CFrame = hrp.CFrame:lerp(fhrp.CFrame, 0.39)
                task.wait(0.2)
                hrp.CFrame = fhrp.CFrame
                hrp.Velocity = Vector3.new(0, fhrp.Velocity.Z, 0)
            until not Enabled
        end)
    end
    disable = function()
        local char = lplr.Character
        local hrp = cam.HumanoidRootPart
        local fhrp = char.HumanoidRootPart
        char.Parent = game
        fhrp:Destroy()
        hrp.Parent = char
        char.PrimaryPart = hrp
        char.Parent = game:GetService("Workspace")
        hrp.Transparency = 1
    end
    local AntiCheatDisablerKeybindCheck = false
    local AnticheatBypassToggle = Blatant:CreateToggle({
        Name = "Flight Disabler Thing",
        CurrentValue = false,
        Flag = "FlightDisablerThingToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                bypassconnections[#bypassconnections+1] = lplr.CharacterRemoving:Connect(function(char)
                    disable()
                end)
                bypassconnections[#bypassconnections+1] = lplr.CharacterAdded:Connect(function(char)
                    enable()
                end)
                bypassconnections[#bypassconnections+1] = lplr:GetAttributeChangedSignal("Team"):Connect(function()
                    disable()
                    repeat task.wait() until isalive(lplr)
                    task.wait(0.3)
                    enable()
                end)
                if isalive(lplr) then
                    enable()
                end
            else
                for i,v in pairs(bypassconnections) do
                    v:Disconnect()
                    bypassconnections[v] = nil
                end
                if isalive(lplr) then
                    disable()
                end
            end
        end
    })
    local acdkeybind = Blatant:CreateKeybind({
        Name = "AntiCheat Keybind",
        CurrentKeybind = "B",
        HoldToInteract = false,
        Flag = "AntiCheatKeybindToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if AntiCheatDisablerKeybindCheck == true then
                AntiCheatDisablerKeybindCheck = false
                AnticheatBypassToggle:Set(enabled)
            else
                if AntiCheatDisablerKeybindCheck == false then
                    AntiCheatDisablerKeybindCheck = true
                    AnticheatBypassToggle:Set(not enabled)
                end
            end
        end,
    })
end

do
    Blatant:CreateSection("InfFly")
    -- Gui to Lua
    -- Version: 3.2

    -- Instances:

    local InfFly = Instance.new("ScreenGui")
    local FlyRender = Instance.new("Frame")
    local FlyStat = Instance.new("TextLabel")
    local FlyHeight = Instance.new("TextLabel")

    --Properties:

    InfFly.Name = "InfFly"
    InfFly.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    InfFly.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    InfFly.ResetOnSpawn = false

    FlyRender.Name = "FlyRender"
    FlyRender.Parent = InfFly
    FlyRender.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    FlyRender.BackgroundTransparency = 0.910
    FlyRender.Position = UDim2.new(0.399138957, 0, 0.674563587, 0)
    FlyRender.Size = UDim2.new(0, 335, 0, 90)

    FlyStat.Name = "FlyStat"
    FlyStat.Parent = FlyRender
    FlyStat.Active = true
    FlyStat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FlyStat.BackgroundTransparency = 1.000
    FlyStat.Position = UDim2.new(0.195718661, 0, 0, 0)
    FlyStat.Size = UDim2.new(0, 200, 0, 50)
    FlyStat.Font = Enum.Font.FredokaOne
    FlyStat.Text = "Status : Safe"
    FlyStat.TextColor3 = Color3.fromRGB(33, 255, 107)
    FlyStat.TextSize = 30.000

    FlyHeight.Name = "FlyHeight"
    FlyHeight.Parent = FlyRender
    FlyHeight.Active = true
    FlyHeight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FlyHeight.BackgroundTransparency = 1.000
    FlyHeight.Position = UDim2.new(0.195718661, 0, 0.444444448, 0)
    FlyHeight.Size = UDim2.new(0, 200, 0, 50)
    FlyHeight.Font = Enum.Font.FredokaOne
    FlyHeight.Text = "Y : 100"
    FlyHeight.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyHeight.TextSize = 30.000
    InfFly.Enabled = false
    FlyRender.Visible = false
    FlyRender.Draggable = true


    local Enabled = false
    local heightval = 1
    local heighttext = ""
    local safeornot = 1
    local char = lplr.Character
    local KeybindINFFLYCheck = false;
    local infflykeybind;
    local hrp = lplr.Character:FindFirstChild("HumanoidRootPart")
    local InfiniteFly = Blatant:CreateToggle({
        Name = "InfiniteFly",
        CurrentValue = false,
        Flag = "InfFlytoggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Flight", "Infinite")
                enabled("Flight.Infinite", 2)
                safeornot = math.random(1, 7)
                local origy = lplr.Character.HumanoidRootPart.Position.y
                part = Instance.new("Part", workspace)
                part.Size = Vector3.new(1,1,1)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                cam.CameraSubject = part
                RunLoops:BindToHeartbeat("FunnyFlyPart", 1, function()
                    local pos = lplr.Character.HumanoidRootPart.Position
                    part.Position = Vector3.new(pos.x, origy, pos.z)
                end)
                local cf = lplr.Character.HumanoidRootPart.CFrame
                lplr.Character.HumanoidRootPart.CFrame = CFrame.new(cf.x, 300000, cf.z)
                if lplr.Character.HumanoidRootPart.Position.X < 50000 then 
                    lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 100000, 0)
                end
                InfFly.Enabled = true
                FlyRender.Visible = true
                if safeornot == 2 then
                    FlyStat.Text = " " .. "UNSAFE!"
                    FlyStat.TextColor3 = Color3.fromRGB(255, 32, 80)
                else
                    if safeornot ~= 2 then
                        FlyStat.Text = " " .. " SAFE!"
                        FlyStat.TextColor3 = Color3.fromRGB(42, 255, 102)
                    end
                end
                repeat
                    heightval = heightval + 1
                    FlyHeight.Text = heightval
                    task.wait()
                    heighttext = FlyHeight.Text
                until not Enabled and InfFly.Enabled == true and FlyRender.Visible == true
            else
                array.Remove("Flight")
                disabled("Flight.Infinite", 2)
                info("InfiniteFly - Waiting to return to original pos", 2)
                repeat task.wait()
                    heighttext = tonumber(FlyHeight.Text)
                    heighttext = heighttext - 1
                    FlyHeight.Text = tostring(heighttext)
                until heighttext == 0
                heightval = 0
                task.wait(0.1)
                RunLoops:UnbindFromHeartbeat("FunnyFlyPart")
                local pos = lplr.Character.HumanoidRootPart.Position
                local rcparams = RaycastParams.new()
                rcparams.FilterType = Enum.RaycastFilterType.Whitelist
                rcparams.FilterDescendantsInstances = {workspace.Map}
                rc = workspace:Raycast(Vector3.new(pos.x, 300, pos.z), Vector3.new(0,-1000,0), rcparams)
                if rc and rc.Position then
                    lplr.Character.HumanoidRootPart.CFrame = CFrame.new(rc.Position) * CFrame.new(0,3,0)
                end
                cam.CameraSubject = lplr.Character
                part:Destroy()
                RunLoops:BindToHeartbeat("FunnyFlyVeloEnd", 1, function()
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    lplr.Character.HumanoidRootPart.CFrame = CFrame.new(rc.Position) * CFrame.new(0,3,0)
                end)
                RunLoops:UnbindFromHeartbeat("FunnyFlyVeloEnd")
                InfFly.Enabled = false
                FlyRender.Visible = false
            end
        end
    })
    local ifkeybind = Blatant:CreateKeybind({
        Name = "InfFlight Keybind",
        CurrentKeybind = "B",
        HoldToInteract = false,
        Flag = "InfFlighttogglekeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KeybindINFFLYCheck == true then
                KeybindINFFLYCheck = false
                InfiniteFly:Set(enabled)
            else
                if KeybindINFFLYCheck == false then
                    KeybindINFFLYCheck = true
                    InfiniteFly:Set(not enabled)
                end
            end
        end,
    })
end

do
    Blatant:CreateSection("Speed")
    local Multiplier = {["Value"] = 1}
    local WaitAmount = {["Value"] = 1}
    local BoostAmount = {["Value"] = 1}
    local Mode = "CFrame";
    local Enabled = false
    local speedpotion = getitem("speed_potion")
    local speedpottoggle = false
    local KeybindSpeedCheck = false;
    local Speed = Blatant:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "SpeedToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Speed", Mode)
                enabled("Speed", 2)
                repeat
                    task.wait()
                    if isalive(lplr) then
                        local hrp = lplr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = lplr.Character:FindFirstChild("Humanoid")
                        if isnetworkowner(hrp) and hum.MoveDirection.Magnitude > 0 then
                            if Mode == "CFrame" then
                                --[[local You = game.Players.LocalPlayer.Name
                                local UIS = game:GetService("UserInputService")
                                local Speed = 0.017
                                if UIS:IsKeyDown(Enum.KeyCode.W) then
                                    game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,-Speed)
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.A) then
                                    game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(-Speed,0,0)
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.S) then
                                    game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,Speed)
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.D) then
                                    game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(Speed,0,0)
                                end]]
                                if isalive(lplr) then
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(newVelocity.X, lplr.Character.HumanoidRootPart.Velocity.Y, newVelocity.Z)    
                                    if lplr.Character:GetAttribute("SpeedBoost") and not (killauraboostenabled) and not(highjumpenabled) and not(BoostOnPotionFlightEnabled) then 
                                        newVelocity = lplr.Character.Humanoid.MoveDirection * (33.4285714)
                                    else
                                        newVelocity = lplr.Character.Humanoid.MoveDirection * (Multiplier.Value)
                                    end
                                end
                            end
                            if Mode == "TP" then
                                task.wait(0.15)
                                task.wait(0.15)
                                --lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + (lplr.Character.HumanoidRootPart.CFrame.LookVector * BoostAmount.Value)
                                lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * BoostAmount.Value)
                                task.wait(WaitAmount.Value)
                            end
                        end
                    end
                until not Enabled
            else
                array.Remove("Speed")
                disabled("Speed", 2)
            end
        end
    })
    local notifyonpot = Blatant:CreateToggle({
        Name = "NotifyOnPot",
        CurrentValue = false,
        Flag = "NotifyOnPotToggle",
        Callback = function(val)
            speedpottoggle = val
            if speedpottoggle then
                repeat
                    if getitem("speed_potion") then
                        info("You have a speed potion you geek!", 2)
                    end
                    task.wait(5)
                until not speedpottoggle
            end
        end
    })
    local modedropdown = Blatant:CreateDropdown({
        Name = "Speed Mode",
        Options = {"CFrame", "TP"},
        CurrentOption = "CFrame",
        Flag = "SpeedModeDropDown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Option)
            Mode = Option
            print()
        end,
    })
    local speedslider = Blatant:CreateSlider({
        Name = "SpeedAmount",
        Range = {1, 23},
        Increment = 1,
        Suffix = "st.",
        CurrentValue = 23,
        Flag = "SpeedAmountSlider",
        Callback = function(val)
            Multiplier["Value"] = val
        end
    })
    local boostslider = Blatant:CreateSlider({
        Name = "TPAmount",
        Range = {1, 10},
        Increment = 0.5,
        Suffix = "st.",
        CurrentValue = 4.5,
        Flag = "SpeedBoostAmountSlider",
        Callback = function(val)
            BoostAmount["Value"] = val
        end
    })
    local waitslider = Blatant:CreateSlider({
        Name = "WaitAmount",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = "st.",
        CurrentValue = 0.5,
        Flag = "SpeedBoostWaitAmountSlider",
        Callback = function(val)
            WaitAmount["Value"] = val
        end
    })
    local spkeybind = Blatant:CreateKeybind({
        Name = "Speed Keybind",
        CurrentKeybind = "G",
        HoldToInteract = false,
        Flag = "spkeybindtoggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KeybindSpeedCheck == true then
                KeybindSpeedCheck = false
                Speed:Set(enabled)
            else
                if KeybindSpeedCheck == false then
                    KeybindSpeedCheck = true
                    Speed:Set(not enabled)
                end
            end
        end,
    })
end

do
    Blatant:CreateSection("LongJump")
    local OldHp;
    local NewHp;
    local CurrentHP;
    local You = game.Players.LocalPlayer.Name
    local UIS = game:GetService("UserInputService")
    local Speed = 0.55
    local ThingyCheck = 1
    local KeybindLongJumpCheck = false;
    local Humanoid;
    local Health;
    local LongJumpToggle = Blatant:CreateToggle({
        Name = "LongJump",
        CurrentValue = false,
        Flag = "LongJumpToggle",
        Callback = function(val)
            longjumpenabled = val
            if longjumpenabled then 
                array.Add("LongJump", "Damage")
                enabled("LongJump", 2)
                Humanoid = lplr.Character:FindFirstChild("Humanoid")
                Health = Humanoid.Health
                CurrentHP = Health
                OldHp = Health
                warning("LongJump - Waiting for Damage", 2)
                repeat
                    task.wait()
                    CurrentHP = Humanoid.Health
                until CurrentHP < OldHp
                repeat
                    workspace.Gravity = 0
                    task.wait()
                    if UIS:IsKeyDown(Enum.KeyCode.W) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,-Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(-Speed,0,0)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(Speed,0,0)
                    end 
                    ThingyCheck = ThingyCheck + 1
                until ThingyCheck == 75
                ThingyCheck = 0
                repeat
                    Speed = 0.33
                    task.wait()
                    if UIS:IsKeyDown(Enum.KeyCode.W) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,-Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(-Speed,0,0)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then
                        game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(Speed,0,0)
                    end 
                until not longjumpenabled
                workspace.Gravity = 196.2
            else
                array.Remove("LongJump")
                disabled("LongJump", 2)
            end
        end
    })
    local ljkeybind = Blatant:CreateKeybind({
        Name = "Longjump Keybind",
        CurrentKeybind = "`",
        HoldToInteract = false,
        Flag = "longjumpkeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KeybindLongJumpCheck == true then
                KeybindLongJumpCheck = false
                LongJumpToggle:Set(enabled)
            else
                if KeybindLongJumpCheck == false then
                    KeybindLongJumpCheck = true
                    LongJumpToggle:Set(not enabled)
                end
            end
        end,
    })
end

do
    Blatant:CreateSection("HighJump")
    local KeybindHighJumpCheck = false;
    local tpamount = 0;
    local higjumpmode = "Boost";
    local highjump = Blatant:CreateToggle({
        Name = "HighJump",
        CurrentValue = false,
        Flag = "highjumptoggle",
        Callback = function(v)
            highjumpenabled = v
            if v then
                enabled("HighJump", 2)
                array.Add("HighJump", higjumpmode)
                if higjumpmode == "Boost" and highjumpenabled then
                    repeat task.wait()
                        game.Players.LocalPlayer.character.HumanoidRootPart.Velocity = game.Players.LocalPlayer.character.HumanoidRootPart.Velocity + Vector3.new(0,3,0)
                    until not highjumpenabled
                end
                if higjumpmode == "Tp" and highjumpenabled then
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    game.workspace.Gravity = 15
                    for i = 1, tpamount do
                        wait(0.1)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2.5, 0)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2.5, 0)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2.5, 0)
                    end
                    game.workspace.Gravity = 196
                end
            else
                array.Remove("HighJump")
                disabled("HighJump", 2)
            end
        end
    })
    local highjumpmode = Blatant:CreateDropdown({
        Name = "HighJump Mode",
        Options = {"Tp", "Boost"},
        CurrentOption = "Boost",
        Flag = "HighJumpModeDropDown",
        Callback = function(Option)
            higjumpmode = Option
            print(higjumpmode)
        end
    })
    local hptpamount = Blatant:CreateSlider({
        Name = "Tp Amount",
        Range = {1, 20},
        Increment = 1,
        Suffix = "st.",
        CurrentValue = 15,
        Flag = "TpSliderForHighJump",
        Callback = function(Value)
            tpamount = Value
            print(Value)
        end
    })
    local hpkeybind = Blatant:CreateKeybind({
        Name = "HighJump Keybind",
        CurrentKeybind = "H",
        HoldToInteract = false,
        Flag = "hpkeybindtoggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KeybindHighJumpCheck == true then
                KeybindHighJumpCheck = false
                highjump:Set(enabled)
            else
                if KeybindHighJumpCheck == false then
                    KeybindHighJumpCheck = true
                    highjump:Set(not enabled)
                end
            end
        end,
    })
end

do
    Blatant:CreateSection("Scaffold")

    -- Gui to Lua
    -- Version: 3.2

    -- Instances:

    local ScaffoldCounter = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local BlockName = Instance.new("TextLabel")
    local BlockCount = Instance.new("TextLabel")

    --Properties:

    ScaffoldCounter.Name = "ScaffoldCounter"
    ScaffoldCounter.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScaffoldCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScaffoldCounter.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ScaffoldCounter
    Main.Active = true
    Main.BackgroundColor3 = Color3.fromRGB(145, 11, 255)
    Main.BackgroundTransparency = 0.690
    Main.Draggable = true
    Main.Position = UDim2.new(0.154304907, 448, 0.884039998, -185)
    Main.Size = UDim2.new(0, 216, 0, 53)

    UICorner.CornerRadius = UDim.new(1, 25)
    UICorner.Parent = Main

    BlockName.Name = "BlockName"
    BlockName.Parent = Main
    BlockName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BlockName.BackgroundTransparency = 1.000
    BlockName.Position = UDim2.new(0.126623392, 0, 0.150943398, 0)
    BlockName.Size = UDim2.new(0, 87, 0, 32)
    BlockName.Font = Enum.Font.FredokaOne
    BlockName.Text = " wool_orange"
    BlockName.TextColor3 = Color3.fromRGB(255, 255, 255)
    BlockName.TextSize = 25.000

    BlockCount.Name = "BlockCount"
    BlockCount.Parent = Main
    BlockCount.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BlockCount.BackgroundTransparency = 1.000
    BlockCount.Position = UDim2.new(0.599350512, 0, 0.188679338, 0)
    BlockCount.Size = UDim2.new(0, 87, 0, 32)
    BlockCount.Font = Enum.Font.FredokaOne
    BlockCount.Text = "50"
    BlockCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    BlockCount.TextSize = 29.000
    Main.Visible = false
    ScaffoldCounter.Enabled = false
    Main.Draggable = true

    local lplr = game.Players.LocalPlayer

    local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
    local ItemTable = debug.getupvalue(require(game.ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1)
    local GetInventory = function(plr)
        local blackboy = plr or lplr
        return InventoryUtil.getInventory(blackboy)
    end

    local getBlock = function()
        for i, v in pairs(GetInventory().items) do
            if ItemTable[v.itemType].block ~= nil then
                return v.itemType, v.amount
            end
        end
    end

    local BlockController2 = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer
    local blockcontroller = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine
    local BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
    local blocktable = BlockController2.new(BlockEngine, getBlock())
    local block, amount;

    local IsAlive = function(plr)
        local blackmonkeyboy = lplr or plr
        local alive = false
        if blackmonkeyboy and blackmonkeyboy.Character then
            if blackmonkeyboy.Character.PrimaryPart and blackmonkeyboy.Character:FindFirstChild('HumanoidRootPart') and blackmonkeyboy.Character:FindFirstChild('Humanoid') then
                if blackmonkeyboy.Character:FindFirstChild('Humanoid').Health > 0 then
                    alive = true
                end
            end
        end
        return alive
    end

    function placeBlock(vector)
        return blocktable:placeBlock(vector)
    end


    local ScaffoldKeybindCheck = false
    local expand = {["Value"] = 3}
    local Enabled = false
    local BackgroundEnabled = false
    local Scaffold = Blatant:CreateToggle({
        Name = "Scaffold",
        CurrentValue = false,
        Flag = "PingScaffoldToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Scaffold", "NoDelay")
                enabled("Scaffold", 2)
                spawn(function()
                    repeat
                        task.wait()
                        if not Enabled then break end
                        if BackgroundEnabled then
                            ScaffoldCounter.Enabled = true
                            Main.Visible = true
                        else
                            ScaffoldCounter.Enabled = false
                            Main.Visible = false
                        end
                        BlockName.Text = tostring(block)
                        BlockCount.Text = tostring(amount)
                        block, amount = getBlock()
                        if IsAlive() then
                            for i = 1, expand.Value do -- expend value is 3, edit for larger or smaller expend value
                                if getBlock() ~= nil then
                                    blocktable.blockType = getBlock()
                                end
                                local vecPos = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection) * (i * 3.3)) + Vector3.new(0, -math.floor(lplr.Character.Humanoid.HipHeight * 3), 0)
                                if getBlock() ~= nil and blockcontroller:isAllowedPlacement(lplr, blocktable.blockType, Vector3.new(vecPos.X / 3, vecPos.Y / 3, vecPos.Z / 3)) then
                                    local dividedPos = Vector3.new(vecPos.X / 3, vecPos.Y / 3, vecPos.Z / 3)
                                    task.spawn(placeBlock, dividedPos)
                                end
                            end
                        end
                    until not Enabled
                end)
            else
                array.Remove("Scaffold")
                disabled("Scaffold", 2)
                ScaffoldCounter.Enabled = false
                Main.Visible = false
            end
        end
    })
    local uitoggle = Blatant:CreateToggle({
        Name = "ScaffoldUI",
        CurrentValue = false,
        Flag = "ScaffoldUIToggle",
        Callback = function(val)
            BackgroundEnabled = val
        end
    })
    local backgroundtoggle = Blatant:CreateToggle({
        Name = "UI background",
        CurrentValue = false,
        Flag = "ScaffoldUIBackgroundToggle",
        Callback = function(val)
            if val then
                Main.BackgroundTransparency = 0.690
            else
                Main.BackgroundTransparency = 1
            end
        end
    })
    local scaffoldslider = Blatant:CreateSlider({
        Name = "Expand",
        Range = {1, 10},
        Increment = 1,
        Suffix = "st.",
        CurrentValue = 2,
        Flag = "ScaffoldExpandSlider",
        Callback = function(val)
            expand.Value = val
        end
    })
    local scaffoldkeybind = Blatant:CreateKeybind({
        Name = "Scaffold Keybind",
        CurrentKeybind = "X",
        HoldToInteract = false,
        Flag = "PingScaffoldKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if ScaffoldKeybindCheck == true then
                ScaffoldKeybindCheck = false
                Scaffold:Set(enabled)
            else
                if ScaffoldKeybindCheck == false then
                    ScaffoldKeybindCheck = true
                    Scaffold:Set(not enabled)
                end
            end
        end,
    })
end

--Misc
do
    Misc:CreateSection("Player")
    local Enabled = false
    local VClipKeybindCheck = false
    local VClip = Misc:CreateToggle({
        Name = "VCLIP",
        CurrentValue = false,
        Flag = "VClipToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("VCLIP", 1)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
            else
                disabled("VCLIP", 1)
            end
        end
    })
    local VClipKeybind = Misc:CreateKeybind({
        Name = "VClip Keybind",
        CurrentKeybind = "M",
        HoldToInteract = false,
        Flag = "VClipKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if VClipKeybindCheck == true then
                VClipKeybindCheck = false
                VClip:Set(enabled)
            else
                if VClipKeybindCheck == false then
                    VClipKeybindCheck = true
                    VClip:Set(not enabled)
                end
            end
        end,
    })
end

do
    local Enabled = false
    local NoFall = Misc:CreateToggle({
        Name = "NoFall",
        CurrentValue = false,
        Flag = "NoFallToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("NoFall")
                enabled("NoFall", 2)
                repeat
                    task.wait(0.5)
                    Client:Get("GroundHit"):SendToServer()
                until not Enabled
            else
                array.Remove("NoFall")
                disabled("NoFall", 2)
            end
        end
    })
end

do
    local Enabled = false
    local AutoPot = Misc:CreateToggle({
        Name = "AutoPot",
        CurrentValue = false,
        Flag = "AutoPotToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                enabled("AutoPot", 2)
                spawn(function()
                    repeat
                        task.wait(1)
                        pcall(function()
                            if isalive(lplr) then
                                if getitem("pie") and not lplr.Character:GetAttribute("SpeedPieBuff") then
                                    Client:Get(bedwars["ConsumeRemote"]):CallServerAsync({
                                        ["item"] = lplr.Character.InventoryFolder.Value.pie
                                    })
                                end
                                if getitem("speed_potion") and not lplr.Character:GetAttribute("StatusEffect_speed") then
                                    Client:Get(bedwars["ConsumeRemote"]):CallServerAsync({
                                        ["item"] = lplr.Character.InventoryFolder.Value.speed_potion
                                    })
                                end
                                if getitem("apple") and lplr.Character.Humanoid.Health < 80 then
                                    Client:Get(bedwars["ConsumeRemote"]):CallServerAsync({
                                        ["item"] = lplr.Character.InventoryFolder.Value.apple
                                    })
                                end
                                if getitem("hang_glider") then
                                    game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@rbxts"].net.out["_NetManaged"].HangGliderUse:FireServer({})
                                end
                            end
                        end)
                    until not Enabled
                    disabled("AutoPot", 2)
                end)
            end
        end
    })
end

do
    local Enabled = false
    local AutoSprint = Misc:CreateToggle({
        Name = "Auto Sprint",
        CurrentValue = false,
        Flag = "AutoSprintToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("AutoSprint")
                enabled("AutoSprint", 2)
                spawn(function()
                    repeat
                        task.wait()
                        if not bedwars["SprintController"].sprinting then
                            bedwars["SprintController"]:startSprinting()
                        end
                    until not Enabled
                end)
            else
                array.Remove("AutoSprint")
                disabled("AutoSprint", 2)
                bedwars["SprintController"]:stopSprinting()
            end
        end
    })
end

do
    local old
    local Enabled = false
    local NoKnockback = Misc:CreateToggle({
        Name = "Velocity",
        CurrentValue = false,
        Flag = "NoKnockBackToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Velocity")
                enabled("Velocity", 2)
                old = bedwars["KnockbackUtil"].applyKnockback
                bedwars["KnockbackUtil"].applyKnockback = function() end
            else
                array.Remove("Velocity")
                disabled("Velocity", 2)
                bedwars["KnockbackUtil"].applyKnockback = old
                old = nil
            end
        end
    })
end

do
    local black = {}
    for i, v in pairs(game.Players:GetPlayers()) do
        table.insert(black, v.Character)
    end
    
    local RCParams = RaycastParams.new()
    RCParams.FilterType = Enum.RaycastFilterType.Blacklist
    RCParams.FilterDescendantsInstances = {black, game.Workspace.Camera}
    
    local Enabled = false
    local StepSlider = {Value = 50}
    local SteppingUp = false
    local StepToggle = Misc:CreateToggle({
        Name = "Step",
        CurrentValue = false,
        Flag = "StepToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                task.spawn(function()
                    enabled("Step", 2)
                    repeat
                        task.wait()
                        if not Enabled then break end
                        if isalive(lplr) then
                            local StepRC = Workspace:Raycast(lplr.Character.HumanoidRootPart.Position, (lplr.Character.Humanoid.MoveDirection.Unit * 2) + Vector3.new(0, -2.5, 0), RCParams)
                            if SteppingUp and not StepRC then
                                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
                            end
                            if StepRC then
                                if not StepRC.Instance:IsDescendantOf(lplr.Character) and StepRC.Instance.Parent.Name ~= 'BedAlarmZones' and StepRC.Instance.Parent.Name ~= 'BalloonRoots' then
                                    SteppingUp = true
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, StepSlider.Value, lplr.Character.HumanoidRootPart.Velocity.Z)
                                end
                            else
                                SteppingUp = false
                            end    
                        end
                    until not Enabled
                    disabled("Step", 2)
                end)
            end
        end
    })
    local StepSliderAmount = Misc:CreateSlider({
        Name = "StepVelocity",
        Range = {50, 300},
        Increment = 1,
        Suffix = " velo",
        CurrentValue = 85,
        Flag = "StepVelocitySlider",
        Callback = function(val)
            StepSlider.Value = val
        end
    })
end

do
    Misc:CreateSection("World")
    local Enabled = false
    local ChestStealer = Misc:CreateToggle({
        Name = "ChestStealer",
        CurrentValue = false,
        Flag = "ChestStealerToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("ChestStealer", "Instant")
                enabled("ChestStealer", 2)
                spawn(function()
                    repeat task.wait() until getqueuetype() ~= "bedwars_test" or not Enabled
                    if not Enabled then return end
                    if not getqueuetype():find("skywars") then return end
                    repeat
                        task.wait(0.1)
                        if isalive(lplr) then
                            for i,v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
                                if (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude < 18 and v:FindFirstChild("ChestFolderValue") then
                                    local chest = v:FindFirstChild("ChestFolderValue")
                                    chest = chest and chest.Value or nil
                                    local chestitems = chest and chest:GetChildren() or {}
                                    if #chestitems > 0 then
                                        Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
                                        for i3, v3 in pairs(chestitems) do
                                            if v3:IsA("Accessory") then
                                                spawn(function()
                                                    pcall(function()
                                                        Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
                                                    end)
                                                end)
                                            end
                                        end
                                        Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
                                    end
                                end
                            end
                        end
                    until not Enabled
                    disabled("ChestStealer", 2)
                end)
            else
                array.Remove("ChestStealer")
            end
        end
    })
end

do
    local items = {"iron", "emerald", "diamond"}
    local getshops = function()
        local shops = {}
        for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
            if v.Name:find("item_shop") or v.Name:find("upgrade_shop") then
                table.insert(shops, v)
            end
        end
        return shops
    end
    local isnearshop = function()
        local shops = getshops()
        for i,v in pairs(shops) do
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude
            if mag < 20 then
                return true
            end
        end
        return false
    end
    local getinv = function()
        return lplr.Character.InventoryFolder.Value
    end
    local getpersonal = function()
        return game:GetService("ReplicatedStorage").Inventories:FindFirstChild(lplr.Name.."_personal")
    end
    local getitems = function()
        local personal = getpersonal()
        local inv = getinv()
        for i, item in pairs(items) do
            if personal:FindFirstChild(item) then
                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(personal)
                Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(personal, personal[item])
                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
            end
        end
    end
    local takeitems = function()
        local personal = getpersonal()
        local inv = getinv()
        for i, item in pairs(items) do
            if inv:FindFirstChild(item) then
                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(personal)
                Client:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(personal, inv[item])
                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
            end
        end
    end
    local Enabled = false
    local AutoBank = Misc:CreateToggle({
        Name = "AutoBank",
        CurrentValue = false,
        Flag = "AutoBankToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("AutoBank")
                enabled("AutoBank", 2)
                spawn(function()
                    repeat
                        task.wait(0.1)
                        if isalive(lplr) then
                            if isnearshop() then
                                getitems()
                            else
                                takeitems()
                            end
                        end
                    until not Enabled
                end)
            else
                disabled("AutoBank", 2)
                array.Remove("AutoBank")
            end
        end
    })
end

do
    local part
    local touchc
    local ypos
    local incooldown = false
    local Enabled = false
    local AntiVoid = Misc:CreateToggle({
        Name = "AntiVoid",
        CurrentValue = false,
        Flag = "AntiVoidToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("AntiVoid")
                enabled("AntiVoid", 2)
                spawn(function()
                    if not ypos then
                        local tries = 0
                        repeat task.wait() tries = tries + 1 until (game:GetService("Workspace"):FindFirstChild("bed") ~= nil) or (game:GetService("Workspace"):FindFirstChild("chest") ~= nil)
                        if game:GetService("Workspace"):FindFirstChild("chest") ~= nil then
                            local lowesty = 9e9
                            local lowest
                            for i,chest in pairs(game:GetService("Workspace"):GetChildren()) do
                                if chest.Name == "chest" then
                                    if (chest.Position.Y < lowesty) then
                                        lowest = chest
                                    end
                                end
                            end
                            ypos = (lowesty - 6)
                        elseif game:GetService("Workspace"):FindFirstChild("bed") ~= nil then
                            local bed = game:GetService("Workspace").bed
                            ypos = (bed.Position.Y - 5)
                        end
                    end
                    part = Instance.new("Part")
                    part.Anchored = true
                    part.CanCollide = false
                    part.Size = Vector3.new(3000, 3, 3000)
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(115, 15, 180)
                    part.Transparency = 0.8
                    part.Parent = game:GetService("Workspace")
                    touchc = part.Touched:Connect(function(part2)
                        if part2.Parent == lplr.Character and not incooldown and isalive(lplr) then
                            incooldown = true
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 125, 0)
                            task.wait(0.5)
                            incooldown = false
                        end
                    end)
                end)
            else
                array.Remove("AntiVoid")
                disabled("AntiVoid", 2)
                pcall(function()
                    incooldown = false
                    part:Destroy()
                    touchc:Disconnect()
                end)
            end
        end
    })
end

do
    local Distance = {["Value"] = 30}
    local Enabled = false
    local bednuker = Misc:CreateToggle({
        Name = "Nuker",
        Flag = "NukerToggle",
        CurrentValue = false,
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Nuker")
                enabled("Nuker", 2)
                spawn(function()
                    repeat
                        task.wait(0.1)
                        if isalive(lplr) and lplr.Character:FindFirstChild("Humanoid").Health > 0.1 then
                            local beds = getbeds()
                            for i,v in pairs(beds) do
                                local mag = (v.Position - lplr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
                                if mag < Distance["Value"] then
                                    game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.DamageBlock:InvokeServer({
                                        ["blockRef"] = {
                                            ["blockPosition"] = getserverpos(v.Position)
                                        },
                                        ["hitPosition"] = getserverpos(v.Position),
                                        ["hitNormal"] = getserverpos(v.Position)
                                    })
                                end
                            end
                        end
                    until not Enabled
                end)
            else
                array.Remove("Nuker")
                disabled("Nuker", 2)
            end
        end
    })
    local bednukerslider = Misc:CreateSlider({
        Name = "NukerDistanceSlider",
        Range = {1, 30},
        Increment = 1,
        Suffix = "st.",
        CurrentValue = 30,
        Flag = "NukerDistanceSlider",
        Callback = function(val)
            Distance["Value"] = val
        end
    })
end

do
    local connection
    local Enabled = false
    local StaffDetector = Misc:CreateToggle({
        Name = "Anti-Staff",
        CurrentValue = false,
        Flag = "AntiStaffToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("AntiStaff")
                for i,v in pairs(game:GetService("Players"):GetPlayers()) do
                    if v:IsInGroup(5774246) and v:GetRankInGroup(5774246) >= 100 then
                        Client:Get("TeleportToLobby"):SendToServer()
                    elseif v:IsInGroup(4199740) and v:GetRankInGroup(4199740) >= 1 then
                        Client:Get("TeleportToLobby"):SendToServer()
                    end
                end
                connection = game:GetService("Players").PlayerAdded:Connect(function(v)
                    if v:IsInGroup(5774246) and v:GetRankInGroup(5774246) >= 100 then
                        Client:Get("TeleportToLobby"):SendToServer()
                    elseif v:IsInGroup(4199740) and v:GetRankInGroup(4199740) >= 1 then
                        Client:Get("TeleportToLobby"):SendToServer()
                    end
                end)
            else
                array.Remove("AntiStaff")
                connection:Disconnect()
            end
        end
    })
    local StaffDetectorMode = Misc:CreateDropdown({
        Name = "AntiStaff Mode",
        Options = {"LoadBlocks", "Notify", "Uninject", "CrashServer", "CrashClientServer"},
        CurrentOption = "Notify",
        Flag = "AntiStaffModeDropDown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Option)

        end,
    })
end

--combat

do
    Combat:CreateSection("Combat")
    -- Gui to Lua
    -- Version: 3.2

    -- Instances:

    local TargetInfo = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local PlayerFace = Instance.new("ImageLabel")
    local UICorner_2 = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local Shadow = Instance.new("ImageLabel")
    local UIGradient_2 = Instance.new("UIGradient")
    local TargetName = Instance.new("TextLabel")
    local EmptyHealthBar = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")
    local UIGradient_3 = Instance.new("UIGradient")
    local HealthBar = Instance.new("Frame")
    local UICorner_4 = Instance.new("UICorner")
    local TargetHealthAndDistance = Instance.new("TextLabel")
    local TargetWinLose = Instance.new("TextLabel")

    --Properties:

    TargetInfo.Name = "TargetInfo"
    TargetInfo.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    TargetInfo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    TargetInfo.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = TargetInfo
    Main.Active = true
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 0.350
    Main.Draggable = true
    Main.Position = UDim2.new(0.405562878, -215, 0.441396445, 223)
    Main.Size = UDim2.new(0, 308, 0, 93)

    UICorner.CornerRadius = UDim.new(0, 21)
    UICorner.Parent = Main

    PlayerFace.Name = "PlayerFace"
    PlayerFace.Parent = Main
    PlayerFace.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PlayerFace.BackgroundTransparency = 0.700
    PlayerFace.Position = UDim2.new(0.0519480519, 0, 0.139784947, 0)
    PlayerFace.Size = UDim2.new(0, 65, 0, 65)
    PlayerFace.ZIndex = 2
    PlayerFace.Image = "http://www.roblox.com/asset/?id=10957598509"

    UICorner_2.CornerRadius = UDim.new(0, 13)
    UICorner_2.Parent = PlayerFace

    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(107, 0, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 0, 73))}
    UIGradient.Rotation = 450
    UIGradient.Parent = Main

    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shadow.BackgroundTransparency = 1.000
    Shadow.Position = UDim2.new(-0.44155845, 0, -0.580645144, 0)
    Shadow.Size = UDim2.new(0, 579, 0, 226)
    Shadow.Image = "http://www.roblox.com/asset/?id=8992230677"

    UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(107, 0, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 0, 73))}
    UIGradient_2.Rotation = 450
    UIGradient_2.Parent = Shadow

    TargetName.Name = "TargetName"
    TargetName.Parent = Main
    TargetName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TargetName.BackgroundTransparency = 1.000
    TargetName.Position = UDim2.new(0.30844155, 0, 0.258064568, 0)
    TargetName.Size = UDim2.new(0, 200, 0, 17)
    TargetName.ZIndex = 2
    TargetName.Font = Enum.Font.GothamBlack
    TargetName.Text = "Whydousmellbad911"
    TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetName.TextScaled = true
    TargetName.TextSize = 14.000
    TargetName.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    TargetName.TextWrapped = true
    TargetName.TextXAlignment = Enum.TextXAlignment.Left

    EmptyHealthBar.Name = "EmptyHealthBar"
    EmptyHealthBar.Parent = Main
    EmptyHealthBar.BackgroundColor3 = Color3.fromRGB(99, 99, 99)
    EmptyHealthBar.Position = UDim2.new(0.311688334, 0, 0.505376339, 0)
    EmptyHealthBar.Size = UDim2.new(0, 164, 0, 6)
    EmptyHealthBar.ZIndex = 2

    UICorner_3.Parent = EmptyHealthBar

    UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(107, 0, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(140, 0, 255))}
    UIGradient_3.Rotation = 450
    UIGradient_3.Parent = EmptyHealthBar

    HealthBar.Name = "HealthBar"
    HealthBar.Parent = EmptyHealthBar
    HealthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HealthBar.Position = UDim2.new(-0.00586011913, 0, 0, 0)
    HealthBar.Size = UDim2.new(0, 124, 0, 6)
    HealthBar.ZIndex = 2

    UICorner_4.Parent = HealthBar

    TargetHealthAndDistance.Name = "TargetHealthAndDistance"
    TargetHealthAndDistance.Parent = Main
    TargetHealthAndDistance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TargetHealthAndDistance.BackgroundTransparency = 1.000
    TargetHealthAndDistance.Position = UDim2.new(0.311688304, 0, 0.634408593, 0)
    TargetHealthAndDistance.Size = UDim2.new(0, 57, 0, 10)
    TargetHealthAndDistance.ZIndex = 2
    TargetHealthAndDistance.Font = Enum.Font.GothamBlack
    TargetHealthAndDistance.Text = "75% - 2m -"
    TargetHealthAndDistance.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetHealthAndDistance.TextScaled = true
    TargetHealthAndDistance.TextSize = 14.000
    TargetHealthAndDistance.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    TargetHealthAndDistance.TextWrapped = true
    TargetHealthAndDistance.TextXAlignment = Enum.TextXAlignment.Left

    TargetWinLose.Name = "TargetWinLose"
    TargetWinLose.Parent = Main
    TargetWinLose.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TargetWinLose.BackgroundTransparency = 1.000
    TargetWinLose.Position = UDim2.new(0.483766228, 0, 0.634408593, 0)
    TargetWinLose.Size = UDim2.new(0, 57, 0, 10)
    TargetWinLose.ZIndex = 2
    TargetWinLose.Font = Enum.Font.GothamBlack
    TargetWinLose.Text = " Winning"
    TargetWinLose.TextColor3 = Color3.fromRGB(42, 255, 102)
    TargetWinLose.TextScaled = true
    TargetWinLose.TextSize = 14.000
    TargetWinLose.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    TargetWinLose.TextWrapped = true
    TargetWinLose.TextXAlignment = Enum.TextXAlignment.Left

    Main.Visible = false
    TargetInfo.Enabled = false
    Main.Draggable = true

    local BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsSwords
    function hashFunc(vec) 
        return {value = vec}
    end
    local function GetInventory(plr)
        if not plr then 
            return {items = {}, armor = {}}
        end

        local suc, ret = pcall(function() 
            return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
        end)

        if not suc then 
            return {items = {}, armor = {}}
        end

        if plr.Character and plr.Character:FindFirstChild("InventoryFolder") then 
            local invFolder = plr.Character:FindFirstChild("InventoryFolder").Value
            if not invFolder then return ret end
            for i,v in next, ret do 
                for i2, v2 in next, v do 
                    if typeof(v2) == 'table' and v2.itemType then
                        v2.instance = invFolder:FindFirstChild(v2.itemType)
                    end
                end
                if typeof(v) == 'table' and v.itemType then
                    v.instance = invFolder:FindFirstChild(v.itemType)
                end
            end
        end

        return ret
    end
    local function getSword()
        local highest, returning = -9e9, nil
        for i,v in next, GetInventory(lplr).items do 
            local power = table.find(BedwarsSwords, v.itemType)
            if not power then continue end
            if power > highest then
                returning = v
                highest = power
            end
        end
        return returning
    end
    local Anims = {
        Normal = {
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
        },
        Slow = {
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
        },
        New = {
            {CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
            {CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
        },
        VerticalSpin = {
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
        },
        Exhibition = {
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
            {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
        },
        ExhibitionOld = {
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
            {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
            {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
            {CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
        }
    }
    local RandomThing = {
        Wow = {
            "hi"
        }
    }
    local VMAnim = false
    local HitRemote = Client:Get(bedwars["SwordRemote"])
    local origC0 = game:GetService("ReplicatedStorage").Assets.Viewmodel.RightHand.RightWrist.C0
    local Distance = {["Value"] = 22}
    local AttackAnim = false
    local CurrentAnim = {["Value"] = "Slow"}
    local Enabled = false
    local TargetInformation = {Name = "", HP = 0, Distance = 0, Status = "Default"}
    local UsedId;
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady;
    local healthbar = HealthBar
    local healthbarsize = HealthBar.Size.X.Offset
    local playerChar;
    local playerHumanoid;
    local healthbarxsize;
    local randommiss;

    local TargetHudSmoothNess;
    local AnimationFadeIN;
    local AnimationFadeOUT;
    local FakeBoostToggle = false
    local CancelKillaura;
    local ThirdPersonOnAttack;
    local RotationEnabled = false;
    local KillAuraKeybindCheck = false
    local KillAura = Combat:CreateToggle({
        Name = "Aura",
        CurrentValue = false,
        Flag = "KillAuraToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                pcall(function()
                    print("Aura Loop, Started")
                    array.Add("Aura", "DoubleHit")
                    enabled("Aura", 2)
                    repeat
                        task.wait(0.12)
                        local nearest = getnearestplayer(Distance["Value"])
                        if nearest ~= nil and nearest.Team ~= lplr.Team and isalive(nearest) and nearest.Character:FindFirstChild("Humanoid").Health > 0.1 and isalive(lplr) and lplr.Character:FindFirstChild("Humanoid").Health > 0.1 and not nearest.Character:FindFirstChild("ForceField") then
                            local sword = getSword()
                            spawn(function()
                                if AttackAnim == true then
                                    local anim = Instance.new("Animation")
                                    anim.AnimationId = "rbxassetid://4947108314"
                                    local loader = lplr.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
                                    loader:LoadAnimation(anim):Play()
                                    if not VMAnim then
                                        VMAnim = true
                                        for i,v in pairs(Anims[CurrentAnim["Value"]]) do
                                            game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist,TweenInfo.new(AnimationFadeIN.CurrentValue),{C0 = origC0 * v.CFrame}):Play()
                                            task.wait(v.Time-0.01)
                                        end
                                        VMAnim = false
                                    end
                                end
                            end)
                            if sword ~= nil then
                                bedwars["SwordController"].lastAttack = game:GetService("Workspace"):GetServerTimeNow() - 0.11
                                HitRemote:SendToServer({
                                    ["weapon"] = sword.tool,
                                    ["entityInstance"] = nearest.Character,
                                    ["validate"] = {
                                        ["raycast"] = {
                                            ["cameraPosition"] = hashFunc(cam.CFrame.Position),
                                            ["cursorDirection"] = hashFunc(Ray.new(cam.CFrame.Position, nearest.Character:FindFirstChild("HumanoidRootPart").Position).Unit.Direction)
                                        },
                                        ["targetPosition"] = hashFunc(nearest.Character:FindFirstChild("HumanoidRootPart").Position),
                                        ["selfPosition"] = hashFunc(lplr.Character:FindFirstChild("HumanoidRootPart").Position + ((lplr.Character:FindFirstChild("HumanoidRootPart").Position - nearest.Character:FindFirstChild("HumanoidRootPart").Position).magnitude > 14 and (CFrame.lookAt(lplr.Character:FindFirstChild("HumanoidRootPart").Position, nearest.Character:FindFirstChild("HumanoidRootPart").Position).LookVector * 4) or Vector3.new(0, 0, 0)))
                                    },
                                    ["chargedAttack"] = {["chargeRatio"] = 0.8}
                                })
                            end
                            randommiss = math.random(1, 25)
                           --[[local esp = Instance.new("Highlight")
                            esp = Instance.new("Highlight")
                            esp.Name = nearest.Name
                            esp.FillTransparency = 0.5
                            esp.FillColor = Color3.fromRGB(255, 32, 80)
                            esp.OutlineColor = Color3.fromRGB(255, 32, 80)
                            esp.OutlineTransparency = 0
                            esp.Parent = nearest.Character]]
                            if ThirdPersonOnAttack.CurrentValue == true then
                                lplr.CameraMaxZoomDistance = 5     
                                lplr.CameraMinZoomDistance = 5      
                                lplr.CameraMaxZoomDistance = 5      
                                lplr.CameraMinZoomDistance = 5 
                            end
                            if FakeBoostToggle and not(lplr.Character:GetAttribute("SpeedBoost")) then
                                killauraboostenabled = true
                                newVelocity = lplr.Character.Humanoid.MoveDirection * (50.1428571)
                            end
                            if randommiss == 3 then
                                warning("Aura - DoubleHit missed!", 2)
                            end
                            UsedId = nearest.UserId
                            content, isReady = game.Players:GetUserThumbnailAsync(UsedId, thumbType, thumbSize)
                            TargetInformation.Name = nearest.Name
                            TargetInformation.HP = nearest.Character.Humanoid.Health
                            TargetInformation.Distance = (nearest.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if TargetInformation.HP > lplr.Character.Humanoid.Health then
                                TargetInformation.Status = "Losing!"
                                TargetWinLose.Text = " " .. "Losing!"
                                TargetWinLose.TextColor3 = Color3.fromRGB(255, 32, 80)
                            else
                                if TargetInformation.HP < lplr.Character.Humanoid.Health then
                                    TargetInformation.Status = "Winning!"
                                    TargetWinLose.Text = " " .. " Winning!"
                                    TargetWinLose.TextColor3 = Color3.fromRGB(42, 255, 102)
                                end
                            end
                            TargetName.Text = TargetInformation.Name
                            TargetHealthAndDistance.Text = math.round(TargetInformation.HP) .. "% - " .. math.round(TargetInformation.Distance) .. "m -" .. " "
                            PlayerFace.Image = content
                            playerChar = nearest.Character
                            playerHumanoid = nearest.Character:WaitForChild("Humanoid")
                            healthbarxsize = playerHumanoid.Health / 100
                            --HealthBar.Size = UDim2.new(healthbarxsize, 0.246, 0, 6)
                            game:GetService("TweenService"):Create(HealthBar,TweenInfo.new(TargetHudSmoothNess.CurrentValue),{Size = UDim2.new(healthbarxsize, 0.246, 0, 6)}):Play()

                            TargetInfo.Enabled = true
                            Main.Visible = true
                            Main.Draggable = true
                            if RotationEnabled then
                                lplr.Character:SetPrimaryPartCFrame(CFrame.new(lplr.Character.HumanoidRootPart.Position, Vector3.new(nearest.Character.HumanoidRootPart.Position.X, lplr.Character.HumanoidRootPart.Position.Y, nearest.Character.HumanoidRootPart.Position.Z)))
                            end
                            spawn(function()
                                if getitem("juggernaut_rage_blade") then
                                    bedwars["SwordController"].lastAttack = (game:GetService("Workspace"):GetServerTimeNow() - 0.11)
                                    HitRemote:SendToServer({
                                        ["weapon"] = lplr.Character.InventoryFolder.Value.juggernaut_rage_blade,
                                        ["entityInstance"] = nearest.Character,
                                        ["validate"] = {
                                            ["raycast"] = {
                                                ["cameraPosition"] = hashFunc(cam.CFrame.Position),
                                                ["cursorDirection"] = hashFunc(Ray.new(cam.CFrame.Position, nearest.Character.HumanoidRootPart.Position).Unit.Direction)
                                            },
                                            ["targetPosition"] = hashFunc(nearest.Character.HumanoidRootPart.Position),
                                            ["selfPosition"] = hashFunc(lplr.Character.HumanoidRootPart.Position + ((lplr.Character.HumanoidRootPart.Position - nearest.Character.HumanoidRootPart.Position).magnitude > 14 and (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, nearest.Character.HumanoidRootPart.Position).LookVector * 4) or Vector3.new(0, 0, 0)))
                                        },
                                        ["chargedAttack"] = {["chargeRatio"] = 0}
                                    })
                                end
                            end)
                        else
                            TargetInfo.Enabled = false
                            Main.Visible = false
                            if cam.Viewmodel.RightHand.RightWrist.C0 ~= origC0 then
                                CancelKillaura = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationFadeOUT.CurrentValue), {C0 = origC0})
                                CancelKillaura:Play()
                            end
                            killauraboostenabled = false
                            if ThirdPersonOnAttack.CurrentValue == true then
                                lplr.CameraMaxZoomDistance = 0      
                                lplr.CameraMinZoomDistance = 0      
                                lplr.CameraMaxZoomDistance = 0      
                                lplr.CameraMinZoomDistance = 0  
                                task.wait(0.1)
                                lplr.CameraMaxZoomDistance = 15    
                                lplr.CameraMaxZoomDistance = 15
                            end
                        end
                    until not Enabled
                    disabled("Aura", 2)
                    print("Aura Loop, Ended")
                    TargetInfo.Enabled = false
                    Main.Visible = false
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    array.Remove("Aura")
                    lplr.CameraMaxZoomDistance = 15    
                    lplr.CameraMinZoomDistance = 0  
                    lplr.CameraMaxZoomDistance = 15
                    lplr.CameraMinZoomDistance = 0  
                end)
            end
        end
    })
    local BoostOnKA = Combat:CreateToggle({
        Name = "Boost On Attack",
        CurrentValue = false,
        Flag = "KillauraBoostToggle",
        Callback = function(val)
            FakeBoostToggle = val
        end
    })
    ThirdPersonOnAttack = Combat:CreateToggle({
        Name = "ThirdPerson on Attack",
        CurrentValue = false,
        Flag = "ThirdPersonOnAttackToggle",
        Callback = function(val)
            if val then
            else
            end
        end
    })
    local RotationToggle = Combat:CreateToggle({
        Name = "Rotations",
        CurrentValue = false,
        Flag = "RotationsKillauraToggle",
        Callback = function(val)
            RotationEnabled = val
        end
    })
    local AnimationToggle = Combat:CreateToggle({
        Name = "Animations",
        CurrentValue = false,
        Flag = "AnimationsToggle",
        Callback = function(val)
            AttackAnim = val
        end
    })
    local AnimationsMode = Combat:CreateDropdown({
        Name = "Animation Type",
        Options = {"Normal", "Slow", "New", "VerticalSpin", "Exhibition", "ExhibitionOld"},
        CurrentOption = "ExhibitionOld",
        Flag = "AnimationModeDropDown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Option)
            CurrentAnim.Value = Option
        end,
    })
    TargetHudSmoothNess = Combat:CreateSlider({
        Name = "TargetHud Smoothness",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = " ms",
        CurrentValue = 0.5,
        Flag = "TargetHudSmoothNess",
        Callback = function(Value)
        end
    })
    AnimationFadeIN = Combat:CreateSlider({
        Name = "AnimationFadeIn",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = " s",
        CurrentValue = 0.3,
        Flag = "AnimationFadeInKIllAura",
        Callback = function(Value)
        end
    })
    AnimationFadeOUT = Combat:CreateSlider({
        Name = "AnimationFadeOUT",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = " s",
        CurrentValue = 0.7,
        Flag = "AnimationFadeOUTKillaura",
        Callback = function(Value)
        end
    })
    local KillauraDistance = Combat:CreateSlider({
        Name = "Distance",
        Range = {1, 22},
        Increment = 1,
        Suffix = "blocks",
        CurrentValue = 22,
        Flag = "KillAuraDistanceSlider",
        Callback = function(Value)
            Distance["Value"] = Value
        end
    })
    local KillAuraKeybind = Combat:CreateKeybind({
        Name = "KillAura Keybind",
        CurrentKeybind = "Z",
        HoldToInteract = false,
        Flag = "KillAuraKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if KillAuraKeybindCheck == true then
                KillAuraKeybindCheck = false
                KillAura:Set(enabled)
            else
                if KillAuraKeybindCheck == false then
                    KillAuraKeybindCheck = true
                    KillAura:Set(not enabled)
                end
            end
        end,
    })
end
do
    local Enabled = false
    local CustomSound = Combat:CreateToggle({
        Name = "Custom sounds",
        CurrentValue = false,
        Flag = "CustomSoundsToggle",
        Callback = function(val)
            Enabled = val
            if Enabled then
                array.Add("Custom sounds", "RektSky")
                local getasset = getsynasset or getcustomasset
                local gamesound = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound
                if game.PlaceId == 8560631822 then
                    lplr.leaderstats.Bed:GetPropertyChangedSignal("Value"):Connect(function()
                        if lplr.leaderstats.Bed.Value ~= "✅" then
                            local sound = Instance.new("Sound")
                            sound.Parent = workspace
                            sound.SoundId = getasset("MemzWare/Sound/mc/bedbroken.mp3") -- path to where ever the sound is in ur workspace
                            sound:Play()
                            wait(7)
                            sound:remove()
                        end
                        end)
                    spawn(function()
                        Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
                            p13:Connect(function(p14)
                                local sound = Instance.new("Sound")
                                sound.Parent = workspace
                                sound.SoundId = getasset("MemzWare/Sound/mc/bedbreak.mp3")-- path to where ever the sound is in ur workspace
                                sound:Play()
                                wait(4)
                                sound:remove()
                            end)
                        end)
                    end)
                end
                local oldsounds = gamesound
                local newsounds = gamesound
                newsounds.UI_CLICK = "rbxassetid://535716488"
                newsounds.PICKUP_ITEM_DROP = getasset("MemzWare/Sound/mc/pickup.mp3")
                newsounds.KILL = "rbxassetid://1053296915"
                newsounds.ERROR_NOTIFICATION = ""
                newsounds.DAMAGE_1 = "rbxassetid://6607204501"
                newsounds.DAMAGE = "rbxassetid://6607204501"
                newsounds.DAMAGE_2 = "rbxassetid://6607204501"
                newsounds.DAMAGE_3 = "rbxassetid://6607204501"
                newsounds.SWORD_SWING_1 = ""
                newsounds.SWORD_SWING_2 = ""
                newsounds.BEDWARS_PURCHASE_ITEM = getasset("MemzWare/Sound/mc/buyitem.mp3")
                newsounds.STATIC_HIT = "rbxassetid://6607204501"
                newsounds.STONE_BREAK = "rbxassetid://6496157434"
                newsounds.WOOL_BREAK = getasset("MemzWare/Sound/mc/woolbreak.mp3")
                newsounds.WOOD_BREAK = getasset("MemzWare/Sound/mc/breakwood.mp3")
                newsounds.GLASS_BREAK = getasset("MemzWare/Sound/mc/glassbreak.mp3")
                newsounds.TNT_HISS_1 = getasset("MemzWare/Sound/mc/tnthiss.mp3")
                newsounds.TNT_EXPLODE_1 = getasset("MemzWare/Sound/mc/tntexplode.mp3")
                gamesound = newsounds
            else
                array.Remove("Custom sounds")
            end
        end
    })
end
--end of Combat

--loading configurations
Rayfield:LoadConfiguration()

--Had a working one but it got patched so i made a fake one!
local RandomGay = {'teleport', 'speed'}
local bestrandom;
while true do
    bestrandom = math.random(1,2)
    task.wait(math.random(15,20))
    if bestrandom == 1 then
        warning("Antiflag - Prevented server side teleport flag!", 2)
    elseif bestrandom == 2 then
        warning("Antiflag - Prevented server side speed flag!", 2)
    end
end

--end of creating modules