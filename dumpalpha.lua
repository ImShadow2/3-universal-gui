-- this is not mine it from ezhub
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Digging = false
local Running = true

-- Notification
game.StarterGui:SetCore("SendNotification", {
	Title = "rifton.top/discord",
	Text = "Use the tutorial shovel so that this works greatly",
	Duration = 10
})

-- Function to handle digging
task.spawn(function()
	while Running do
		if Digging then
			local Start = ReplicatedStorage.Network.RemoteFunctions.StartDigging
			Start:InvokeServer()

			task.wait()

			local EndDig = ReplicatedStorage.Network.RemoteEvents.EndDigging
			EndDig:FireServer("Succeeded")
		end
		task.wait(0.1)
	end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.F5 then
		Digging = not Digging
		game.StarterGui:SetCore("SendNotification", {
			Title = "Auto Digging",
			Text = Digging and "Enabled" or "Disabled",
			Duration = 3
		})
	end

	if input.KeyCode == Enum.KeyCode.F6 then
		local Sell = ReplicatedStorage.Network.RemoteEvents.PawnShopInteraction
		Sell:FireServer("SellInventory")
		game.StarterGui:SetCore("SendNotification", {
			Title = "Inventory",
			Text = "Sold successfully!",
			Duration = 2
		})
	end

	if input.KeyCode == Enum.KeyCode.F7 then
		game.StarterGui:SetCore("SendNotification", {
			Title = "Script",
			Text = "Refreshing script...",
			Duration = 3
		})

		-- Stop current loops
		Running = false
		Digging = false

		-- Wait a moment before reloading
		task.wait(1)

		-- Re-execute the same script again
		loadstring(game:HttpGet("https://your.script.url/here.lua"))()
	end
end)
