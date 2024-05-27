---@diagnostic disable: unused-local
-- mine arguments : block, nil, true
-- the biggest project to ever exist.

local config = {
	["Debug Mode"] = true,
	["Enabled"] = true,
	["Ores"] = {
		["Target Ores"] = false,
		["Ores"] = { -- list all ores to collect
			"",
		},
	},
	["Rare Ores"] = {
		["Steal"] = true,
		["Rarity Threshold"] = 5000, --1/value
	},
	["Pickaxes"] = {
		["Auto-Crafting"] = true,
		["Pickaxe"] = "type here",
		["Auto-Progression"] = true, -- OVERRIDES THE FIRST TWO
	},
}

--script
local warn = function(...)
	if config["Debug Mode"] then
		warn("[OVERWARE DEBUG]", ...)
	end
end
local print = function(...)
	if config["Debug Mode"] then
		print("[OVERWARE DEBUG]", ...)
	end
end
local cfg = config
local rareOres = config["Rare Ores"]
local pickaxes = config["Pickaxes"]

local ws = game:GetService("Workspace")
local plrs = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")

local lp = plrs.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

warn("fecthing ore library")
local ores = loadstring(game:HttpGet("https://raw.githubusercontent.com/hyperclocked333/go-mining-ore-index/main/index.lua"))()
if ores then
	warn("fetch successful! (" .. tostring(ores) .. ")")
end

local blocksPath: Folder = ws.Blocks
local pickaxeList = {
	"Default Pickaxe",
	"Super-Steel Pickaxe",
	"Midas Mend",
	"Radiant Rapier",
	"Uranium Blastforge",
	"Luck Staff",
	"Excalibur",
}
local itemsIndex = rep.Items
local indexRecipies = itemsIndex.Crafting
local inventory = lp.Ores
local mor = rep.Events.ClientRemoteEvents.MineOre
local layerBlockList = { "Stone", "Dark Stone", "Granite", "Diorite", "Andesite", "Obsidian", "Augite" }

local oresToTarget = table.create(0)
local blocks = table.create(0)
-- handles the list of all current blocks in the mine
local function SetBlocks()
	local function set(block: Part)
		blocks[block] = 1
		block.Destroying:Once(function()
			blocks[block] = 0
		end)
	end
	for _, b: Part in ipairs(blocksPath:GetChildren()) do
		set(b)
	end
	blocksPath.ChildAdded:Connect(set)
end
task.spawn(SetBlocks)

-- return the amount of a ore owned in the users inventory
local function GetAmountOwned(oreName: string)
    local index: IntValue = inventory:FindFirstChild(oreName)
    if index then
        return index.Value
    end
    return 0
end

-- mines a ore
local function Mine(block: Part)
	local hl = Instance.new("Highlight")
	hl.Parent = block
	hl.FillColor = Color3.fromRGB(255, 0, 0)
	hl.OutlineColor = Color3.fromRGB(0, 0, 0)
	hrp.CFrame = block.CFrame
	repeat
		task.wait()
		mor:FireServer(block, nil, true)
	until block.Parent ~= blocksPath
	return
end

-- get a blocks stats (SCRAPPED BEACUSE THERES NO WAY TO SCRAP ORE DATA)
-- local function GetBlockStats()

-- end

--returns the next pickaxe, along with its recipe
local function GetNextPickaxe()
	local currentPickaxe = lp.SelectedPickaxe.value
	local nextPickaxe = pickaxeList[table.find(pickaxeList, currentPickaxe) + 1]
	local itemRecipe = indexRecipies[nextPickaxe]
	return { name = nextPickaxe, recipe = itemRecipe }
end
local nextPickaxe = GetNextPickaxe()
for _, o in pairs(nextPickaxe.recipe:GetChildren()) do
	local ore = o.Name
	local amt = o.Value
	oresToTarget[ore] = amt
end
for o: string, amt: number in oresToTarget do
    if GetAmountOwned(o) >= amt then continue end
	local ore: table = ores:GetInfo(o)
    -- print(ore.MaxDepth-ore.MinDepth)
    for block: Part, exists: number in pairs(blocks) do
        if exists == 1 and block.Name == o then
            hrp.CFrame = block.CFrame
            task.wait()
            Mine(block)
        end
    end
end

blocksPath.ChildAdded:Connect(function(f)
	if table.find(oresToTarget, f.Name) then
		hrp.CFrame = block.CFrame
		task.wait()
		Mine(block)
    end
end)
--print(ores:GetInfo("Geographite"))
-- LEGACY CODE BELOW

-- while task.wait() do
--     for _, o in oresToTarget do
--         local loopindex = {}
--         for _, b in GetBlocks() do
--             if b.Name == o then
--                 table.insert(loopindex,b)
--             end
--         end
--         local blockFound = (#loopindex > 0)
--         if blockFound then
--             for _, f in loopindex do
--                 local owned = inventory[o].Value
--                 local req = oresToTarget[o]
--                 if owned < req then
--                     Mine(f)
--                     continue
--                 end
--             end
--         end
--     end
--     Mine(blocks[layerBlockList[math.random(1,#layerBlockList)]])
-- end
-- blocks.ChildAdded:Connect(function(i: Instance)
--     if oresToTarget[i] then
--         Mine(i)
--     end
--     task.spawn(function()
--         task.wait(.05)
--         if i:FindFirstChild("Midas"..lp.Name) then
--             Mine(i)
--         end
--     end)
-- end)
-- print("finished")
