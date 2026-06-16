if _G.beeESP_cleanup then
    _G.beeESP_cleanup()
end

local RunService = game:GetService("RunService")
local trackedBees = {}
local connection
local lastScan = 0

local function cleanup()
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end

    for _, beeInfo in pairs(trackedBees) do
        if beeInfo.box then
            pcall(function()
                beeInfo.box:Remove()
            end)
        end
    end

    trackedBees = {}
end

_G.beeESP_cleanup = cleanup

local function scanBees()
    local validBees = {}

    for _, model in pairs(workspace:GetChildren()) do
        local root = model:FindFirstChild("Root")
        local beeId = model:GetAttribute("BeeId")
        local centerPart = model.PrimaryPart

        if root and centerPart and beeId and beeId ~= -1 then
            local address = tostring(root.Address)
            validBees[address] = true

            if not trackedBees[address] then
                local box = Drawing.new("Square")
                box.Filled = false
                box.Thickness = 1
                box.Color = Color3.fromRGB(255, 220, 0)
                box.Visible = false

                trackedBees[address] = {
                    centerPart = centerPart,
                    box = box
                }
            else
                trackedBees[address].centerPart = centerPart
            end
        end
    end

    for address, beeInfo in pairs(trackedBees) do
        if not validBees[address] then
            if beeInfo.box then
                pcall(function()
                    beeInfo.box:Remove()
                end)
            end

            trackedBees[address] = nil
        end
    end
end

local function updateBoxes()
    for _, beeInfo in pairs(trackedBees) do
        local centerPart = beeInfo.centerPart
        local box = beeInfo.box

        if centerPart and box then
            local success, screenPosition, onScreen = pcall(WorldToScreen, centerPart.Position)

            if success and screenPosition and onScreen then
                box.Position = Vector2.new(screenPosition.X - 6, screenPosition.Y - 6)
                box.Size = Vector2.new(12, 12)
                box.Visible = true
            else
                box.Visible = false
            end
        end
    end
end

scanBees()

connection = RunService.RenderStepped:Connect(function()
    if tick() - lastScan >= 0.5 then
        lastScan = tick()
        scanBees()
    end

    updateBoxes()
end)
