local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
 
local LocalPlayer = game.Players.LocalPlayer
local PlayerName = LocalPlayer.Name

local Window = Library:CreateWindow{
    Title = `Die of Death`,
    SubTitle = "| by Creatysm",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    MainTab = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
	VisualsTab = Window:CreateTab{
        Title = "Visuals",
        Icon = "phosphor-users-bold"
    },
	AbilitiesTab = Window:CreateTab{
        Title = "Abilities",
        Icon = "phosphor-users-bold"
    },
}

local Options = Library.Options

local function IsFriend(playerName)
    local player = game.Players:FindFirstChild(playerName)
    if player then
        return LocalPlayer:IsFriendsWith(player.UserId)
    end
    return false
end

local function ESP(Target, colorRGB, roleText)
    colorRGB = colorRGB or Color3.fromRGB(255, 0, 0)
    roleText = roleText or "Killer"
    
    if IsFriend(Target.Name) then
        colorRGB = Color3.fromRGB(255, 255, 0)
    end

    local a = Instance.new("BoxHandleAdornment")
    a.Name = Target.Name.."_PESP"
    a.Parent = Target
    a.Adornee = Target
    a.AlwaysOnTop = true
    a.ZIndex = 0
    a.Color3 = colorRGB
    a.Transparency = 0.5
    a.Size = Vector3.new(2, 5, 1)
    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    local ESPholder = Instance.new("Folder")
    ESPholder.Name = Target.Name..'_ESP'
    ESPholder.Parent = game:GetService('CoreGui')
    BillboardGui.Adornee = Target
    BillboardGui.Name = Target.Name
    BillboardGui.Parent = ESPholder
    BillboardGui.Size = UDim2.new(0, 100, 0, 150)
    BillboardGui.StudsOffset = Vector3.new(0, -1, 0)
    BillboardGui.AlwaysOnTop = true
    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 0, 0, -50)
    TextLabel.Size = UDim2.new(0, 100, 0, 100)
    TextLabel.Font = Enum.Font.SourceSansSemibold
    TextLabel.TextSize = 20
    TextLabel.TextColor3 = colorRGB
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    TextLabel.Text = roleText..": "..Target.Name
    TextLabel.ZIndex = 10

end


local function UNESP(TargetName, Folder)
    if game:GetService('CoreGui'):FindFirstChild(TargetName..'_ESP') then
        game:GetService('CoreGui'):FindFirstChild(TargetName..'_ESP'):Destroy()
    end

    for i,v in pairs(Folder:GetChildren()) do
        if v.Name == TargetName then
            if v:FindFirstChild(TargetName..'_PESP') then
                v:FindFirstChild(TargetName..'_PESP'):Destroy()
            end
        end
    end

end

local function UpdateESPText(Target, roleText)
    if not Target or not Target.Parent then 
        return 
    end
    
    local ESPholder = game:GetService('CoreGui'):FindFirstChild(Target.Name..'_ESP')
    if ESPholder then
        local billboard = ESPholder:FindFirstChild(Target.Name)
        if billboard and billboard:IsA("BillboardGui") then
            local textLabel = billboard:FindFirstChild("TextLabel")
            if textLabel and Target:FindFirstChild("Humanoid") then
                local friendText = IsFriend(Target.Name) and " | FRIEND" or ""
                textLabel.Text = roleText..": "..Target.Name.." | HP: "..math.floor(Target.Humanoid.Health)..friendText
                
                if IsFriend(Target.Name) then
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                end
            end
        end
    end
end

local function CleanupInvalidESP()
    local killerFolder = workspace:FindFirstChild('GameAssets') 
        and workspace.GameAssets:FindFirstChild('Teams') 
        and workspace.GameAssets.Teams:FindFirstChild('Killer')
    
    local survivorFolder = workspace:FindFirstChild('GameAssets') 
        and workspace.GameAssets:FindFirstChild('Teams') 
        and workspace.GameAssets.Teams:FindFirstChild('Survivor')
    
    local ghostFolder = workspace:FindFirstChild('GameAssets') 
        and workspace.GameAssets:FindFirstChild('Teams') 
        and workspace.GameAssets.Teams:FindFirstChild('Ghost')
    
    for _, espFolder in pairs(game:GetService('CoreGui'):GetChildren()) do
        if espFolder.Name:match("_ESP$") then
            local playerName = espFolder.Name:gsub("_ESP$", "")
            local found = false
            
            if killerFolder and killerFolder:FindFirstChild(playerName) then
                found = true
            end
            
            if survivorFolder and survivorFolder:FindFirstChild(playerName) then
                found = true
            end
            
            if ghostFolder and ghostFolder:FindFirstChild(playerName) then
                found = true
            end
            
            if not found then
                espFolder:Destroy()
            end
        end
    end
end

Tabs.MainTab:CreateParagraph("Movement", {
    Title = "Мувемент",
    Content = ""
})

local StaminaMethodBypass = 'Модульный'

local StaminaBypassSelect = Tabs.MainTab:CreateDropdown("StaminaBypassMethod", {
    Title = "Метод обхода стамины",
    Values = {"Модульный", "Эвентный"},
    Multi = false,
    Default = 'Модульный',
})

StaminaBypassSelect:OnChanged(function(Value)
    StaminaMethodBypass = Value
end)

local InfiniteStamina = Tabs.MainTab:AddToggle("InfiniteStamina", {Title = "Бесконечная стамина", Default = false })

InfiniteStamina:OnChanged(function()

    InfiniteStamina = Options.InfiniteStamina.Value
    

    if InfiniteStamina == true then

		local ModuleBypass = require(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Client.Modules.Movement)
		


        while InfiniteStamina do

            if game.Players.LocalPlayer.Character ~= nil and (workspace.GameAssets.Teams.Survivor:FindFirstChild(game.Players.LocalPlayer.Name) or workspace.GameAssets.Teams.Killer:FindFirstChild(game.Players.LocalPlayer.Name)) then
 			
				if StaminaMethodBypass == 'Модульный' then
					ModuleBypass.Stamina = ModuleBypass.MaxStamina
				else
					local event = game:GetService("ReplicatedStorage").Events.RemoteEvents.StaminaModifier
					firesignal(event.OnClientEvent, ModuleBypass.MaxStamina-ModuleBypass.Stamina)
				end

			end

            task.wait()
        end

    end
end)

local EnableJump = Tabs.MainTab:AddToggle("EnableJump", {Title = "Включить прыжок", Default = false })

EnableJump:OnChanged(function()

    TEnableJump = Options.EnableJump.Value
    

    if TEnableJump == true then

        while TEnableJump do

            if game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character:FindFirstChild('Humanoid') and game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').JumpPower < 50 then
 			
				game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').UseJumpPower = true
				game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').JumpPower = 50

			end


            task.wait()
        end

		else
		if game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character:FindFirstChild('Humanoid') and game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').JumpPower >= 50 then
 			
				game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').UseJumpPower = true
				game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').JumpPower = 0

			end
    	end
end)

Tabs.MainTab:CreateParagraph("Other", {
    Title = "Остальное",
    Content = ""
})

local NoBarriers = Tabs.MainTab:AddToggle("NoBarriers", {Title = "Убрать барьеры", Default = false })

NoBarriers:OnChanged(function()

    TNoBarriers = Options.NoBarriers.Value
    

    if TNoBarriers == true then

        while TNoBarriers do

            if workspace.GameAssets:FindFirstChild('Map') and workspace.GameAssets.Map.Config:FindFirstChild('Barriers') and workspace.GameAssets.Map.Config.Barriers:FindFirstChild('Part', true).CanCollide == true then
 			
				task.spawn(function()
					for i,v in pairs(workspace.GameAssets.Map.Config.Barriers:GetDescendants()) do

						if v:IsA('Part') then
							v.CanCollide = false
						end

					end

					if workspace.GameAssets.Map.Config:FindFirstChild('KillerOnly') then

					for i,v in pairs(workspace.GameAssets.Map.Config.KillerOnly:GetDescendants()) do

						if v:IsA('Part') then
							v.CanCollide = false
						end

					end

					end


				end)

			end


            task.wait()
        end

		else
		if workspace.GameAssets:FindFirstChild('Map') and workspace.GameAssets.Map:FindFirstChild('Config') and workspace.GameAssets.Map.Config:FindFirstChild('Barriers') then
		task.spawn(function()
			for i,v in pairs(workspace.GameAssets.Map.Config.Barriers:GetDescendants()) do

				if v:IsA('Part') then
					v.CanCollide = true
				end

				

			end

			if workspace.GameAssets.Map.Config:FindFirstChild('KillerOnly') then

			for i,v in pairs(workspace.GameAssets.Map.Config.KillerOnly:GetDescendants()) do

				if v:IsA('Part') then
					v.CanCollide = true
				end

			end

			end

		end)
		end
    end
end)

local CheckForMapDelete = nil

local AntiKillerPlacements = Tabs.MainTab:AddToggle("AntiKillerPlacements", {Title = "Убирать штуки убийц", Default = false })

local AntiKillerPlacementsFolderStorage = nil

AntiKillerPlacements:OnChanged(function()

    TAntiKillerPlacements = Options.AntiKillerPlacements.Value
    

    if TAntiKillerPlacements == true then

		if not game:FindFirstChild('AntiKillerPlacements') then
			AntiKillerPlacementsFolderStorage = Instance.new('HopperBin', game)
			AntiKillerPlacementsFolderStorage.Name = 'AntiKillerPlacements'
		else
			AntiKillerPlacementsFolderStorage = game:FindFirstChild('AntiKillerPlacements')
		end	

		CheckForMapDelete = workspace.GameAssets.ChildRemoved:Connect(function(Child)
			if Child.Name == 'Map' then
				AntiKillerPlacementsFolderStorage:ClearAllChildren()
				CheckForMapDelete:Disconnect()
				CheckForMapDelete = nil
			end
		end)

        while TAntiKillerPlacements do

            if workspace.GameAssets:FindFirstChild('Teams') and workspace.GameAssets.Teams.Other:FindFirstChildOfClass('Model') then
 			
				task.spawn(function()

					for i,v in pairs(workspace.GameAssets.Teams.Other:GetChildren()) do

						v.Parent = AntiKillerPlacementsFolderStorage

					end

				end)

			end


            task.wait()
        end

	else

		if AntiKillerPlacementsFolderStorage ~= nil then

			for i,v in pairs(AntiKillerPlacementsFolderStorage:GetChildren()) do
				v.Parent = workspace.GameAssets.Teams.Other
				CheckForMapDelete:Disconnect()
				CheckForMapDelete = nil
			end

		end

    	end
end)



Tabs.AbilitiesTab:CreateButton{
    Title = "Ударить (На любом сурве)",
    Description = "",
    Callback = function()
		
		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end


       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer('Punch')
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Блокировать (На любом сурве)",
    Description = "",
    Callback = function()

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer('Block')
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Банан (На любом сурве)",
    Description = "",
    Callback = function()

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer('Banana')
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Хотдог (На любом сурве)",
    Description = "",
    Callback = function()

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer('Hotdog')
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Револьвер (На любом сурве)",
    Description = "",
    Callback = function()

		local AbilityNameTarget = 'Revolver'

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer(AbilityNameTarget)
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Инвизка (На любом сурве)",
    Description = "",
    Callback = function()

		local AbilityNameTarget = 'Cloak'

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer(AbilityNameTarget)
    end
}

Tabs.AbilitiesTab:CreateButton{
    Title = "Taunt (На любом сурве)",
    Description = "",
    Callback = function()

		local AbilityNameTarget = 'Taunt'

		if not workspace.GameAssets.Teams:FindFirstChild('Survivor'):FindFirstChild(game.Players.LocalPlayer.Name) then
			Library:Notify({Title = "Ошибка",Content = "Ты не сурв.",SubContent = "",Duration = 1})
			return
		end

       game:GetService("ReplicatedStorage").Events.RemoteFunctions.UseAbility:InvokeServer(AbilityNameTarget)
    end
}


local KillerESP = Tabs.VisualsTab:AddToggle("KillerESP", {Title = "Подсветка киллера", Default = false })

KillerESP:OnChanged(function()

    isKillerESPEnabled = Options.KillerESP.Value
    

    if isKillerESPEnabled == true then

        while isKillerESPEnabled do

            local killerFolder = workspace:FindFirstChild('GameAssets') 
                and workspace.GameAssets:FindFirstChild('Teams') 
                and workspace.GameAssets.Teams:FindFirstChild('Killer')
                
            if killerFolder then
                for _, killerPlayer in pairs(killerFolder:GetChildren()) do
                    if killerPlayer and killerPlayer.Parent and not killerPlayer:FindFirstChild(killerPlayer.Name.."_PESP") then
                        ESP(killerPlayer, Color3.fromRGB(255, 0, 0), "Killer")
                    end
                    
                    if killerPlayer and killerPlayer.Parent and killerPlayer:FindFirstChild("Humanoid") then
                        UpdateESPText(killerPlayer, "Killer")
                    end
                end
            end
            
            CleanupInvalidESP()

            task.wait()
        end

    else
        
        local killerFolder = workspace:FindFirstChild('GameAssets') 
            and workspace.GameAssets:FindFirstChild('Teams') 
            and workspace.GameAssets.Teams:FindFirstChild('Killer')
            
        if killerFolder then
            for _, killerPlayer in pairs(killerFolder:GetChildren()) do
                if killerPlayer then
                    UNESP(killerPlayer.Name, killerFolder)
                end
            end
        end
    end
end)

local SurvivorESP = Tabs.VisualsTab:AddToggle("SurvivorESP", {Title = "Подсветка игроков", Default = false })

SurvivorESP:OnChanged(function()

    isSurvivorESPEnabled = Options.SurvivorESP.Value
    

    if isSurvivorESPEnabled == true then

        while isSurvivorESPEnabled do

            local survivorFolder = workspace:FindFirstChild('GameAssets') 
                and workspace.GameAssets:FindFirstChild('Teams') 
                and workspace.GameAssets.Teams:FindFirstChild('Survivor')
                
            if survivorFolder then
                for _, survivorPlayer in pairs(survivorFolder:GetChildren()) do
                    if survivorPlayer and survivorPlayer.Parent and not survivorPlayer:FindFirstChild(survivorPlayer.Name.."_PESP") then
                        ESP(survivorPlayer, Color3.fromRGB(0, 255, 0), "Player")
                    end
                    
                    if survivorPlayer and survivorPlayer.Parent and survivorPlayer:FindFirstChild("Humanoid") then
                        UpdateESPText(survivorPlayer, "Player")
                    end
                end
            end
            
            CleanupInvalidESP()

            task.wait()
        end

    else
        
        local survivorFolder = workspace:FindFirstChild('GameAssets') 
            and workspace.GameAssets:FindFirstChild('Teams') 
            and workspace.GameAssets.Teams:FindFirstChild('Survivor')
            
        if survivorFolder then
            for _, survivorPlayer in pairs(survivorFolder:GetChildren()) do
                if survivorPlayer then
                    UNESP(survivorPlayer.Name, survivorFolder)
                end
            end
        end
    end
end)

local GhostESP = Tabs.VisualsTab:AddToggle("GhostESP", {Title = "Подсветка призраков", Default = false })

GhostESP:OnChanged(function()

    isGhostESPEnabled = Options.GhostESP.Value
    

    if isGhostESPEnabled == true then

        while isGhostESPEnabled do

            local ghostFolder = workspace:FindFirstChild('GameAssets') 
                and workspace.GameAssets:FindFirstChild('Teams') 
                and workspace.GameAssets.Teams:FindFirstChild('Ghost')
                
            if ghostFolder then
                for _, ghostPlayer in pairs(ghostFolder:GetChildren()) do
                    if ghostPlayer and ghostPlayer.Parent and not ghostPlayer:FindFirstChild(ghostPlayer.Name.."_PESP") then
                        ESP(ghostPlayer, Color3.fromRGB(200, 200, 200), "Ghost")
                    end
                    
                    if ghostPlayer and ghostPlayer.Parent and ghostPlayer:FindFirstChild("Humanoid") then
                        UpdateESPText(ghostPlayer, "Ghost")
                    end
                end
            end
            
            CleanupInvalidESP()

            task.wait()
        end

    else
        
        local ghostFolder = workspace:FindFirstChild('GameAssets') 
            and workspace.GameAssets:FindFirstChild('Teams') 
            and workspace.GameAssets.Teams:FindFirstChild('Ghost')
            
        if ghostFolder then
            for _, ghostPlayer in pairs(ghostFolder:GetChildren()) do
                if ghostPlayer then
                    UNESP(ghostPlayer.Name, ghostFolder)
                end
            end
        end
    end
end)
