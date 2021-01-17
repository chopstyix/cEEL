--[[ 
--// TODO: Place torches every 10 blocks
--// TODO: Place block below if lava is detected
--// TODO: Return ores to a collection chest
--// TODO: Search and plug up liquids
--// TODO: Drop items into a chest when full, then pick up
--// TODO: Record distance travelled from origin point
TODO: Clean up mining code
TODO: Create a feature that checks inventory for correct items before launching
TODO: Create turtle network that listens to commands from master device
TODO: Incorporate something with GPS
]]--

-- Capture argument
local arg = { ... }
-- Settings
torchDistance = 7 -- Torch Spacing

-- Local Variables
-- horizontal = 0 -- 0 begins digging from left, 1 begins from the right
-- vertical = 0  -- 0 begins digging from bottom, 1 begins from top
currentTorchIteration = 1
currentDistance = 0
dist = 1

-- Core Item Slots
STORAGECHEST = 14
COBBLESTONE = 15
TORCH = 16
LASTITEM = 13

function initialize() -- Return true or false based pn item check
    -- Check for items
    local x = turtle.getItemDetail(STORAGECHEST)
    local y = turtle.getItemDetail(COBBLESTONE)
    local z = turtle.getItemDetail(TORCH)

    if x == nil then
        print("Ender Chest - Missing!")
        xCheck = false
    elseif x.name == "enderstorage:ender_storage" then
        print("Ender Chest - Check!")
        xCheck = true
    else
        print("Ender Chest - Missing!")
        xCheck = false
    end

    if y == nil then
        print("Cobblestone - Missing!")
        yCheck = false
    elseif y.name == "minecraft:cobblestone" then
        print("Cobblestone - Check!")
        yCheck = true
    else
        print("Cobblestone - Missing!")
        yCheck = false
    end

    if z == nil then
        print("Torch - Missing!")
        zCheck = false
    elseif z.name == "minecraft:torch" then
        print("Torch - Check!")
        zCheck = true
    else
        print("Torch - Missing!")
        zCheck = false
    end

    return (xCheck and yCheck and zCheck)
end

local dig_Table = {
    ["front"] = function() while turtle.detect() do turtle.dig() end end,
    ["up"] = function() while turtle.detectUp() do turtle.digUp() end end,
    ["down"] = function() while turtle.detectDown() do turtle.digDown() end end,
}

function dig(direction)
    local f = dig_Table[direction]
    if f then  
        f()
    else
        print("Case Default!")
    end
end

function diggySwipe()
        turtle.turnLeft()
        dig("front")
        turtle.turnRight()
        dig("front")
        turtle.turnRight()
        dig("front")
        turtle.turnLeft()
end

function inspectFloor()
    --print("Inspecting floor...")
    local success, data = turtle.inspectDown()
        if data.name == "minecraft:lava" or data.name =="minecraft:flowing_lava" or turtle.inspectDown() == false then
            print("Detected lava or air, placing block below...")
            turtle.select(COBBLESTONE)
            turtle.placeDown()
        end
end

function moveForward()
    turtle.forward()
    currentDistance = currentDistance + 1
end

function diggySlice()
    local data = turtle.getItemDetail(TORCH)
    dig("up")
    turtle.up()
    dig("up")
    turtle.up()
    diggySwipe()
    turtle.down()
    diggySwipe()
    turtle.down()
    diggySwipe()
    if data.name == "minecraft:torch" and currentTorchIteration > torchDistance then
        turtle.select(TORCH)
        turtle.turnRight()
        turtle.turnRight()
        turtle.place()
        turtle.turnRight()
        turtle.turnRight()
        currentTorchIteration = 0
    end
end

function checkInventoryFull()
    if turtle.getItemCount(LASTITEM) > 0 then
        return true
    end
    return false
end

function returnItemsChest()
    turtle.turnRight()
    turtle.turnRight()
    if turtle.detect() then
        turtle.dig()
        turtle.select(STORAGECHEST)
        turtle.place()
        local selectedItem = 1
        repeat
            turtle.select(selectedItem)
            turtle.drop()
            selectedItem = selectedItem + 1
        until (selectedItem > 13)
        turtle.select(STORAGECHEST)
        turtle.dig()
    else
        turtle.select(STORAGECHEST)
        turtle.place()
        local selectedItem = 1
        repeat
            turtle.select(selectedItem)
            turtle.drop()
            selectedItem = selectedItem + 1
        until (selectedItem > 13)
        turtle.select(STORAGECHEST)
        turtle.dig()
        turtle.select(TORCH)
        turtle.place()
    end

    turtle.select(1)
    turtle.turnRight()
    turtle.turnRight()
end

if initialize() then
    print("Initialization successful!")
    maxDistance_Fuel = math.floor(turtle.getFuelLevel() / 3)
    maxDistance_Torch = turtle.getItemCount(TORCH) * torchDistance
    if arg[1] == nil then -- If user doesn't specify a distance it will choose values based off _Fuel & _Torch
        maxDistance = math.min(maxDistance_Fuel, maxDistance_Torch)
    else
        maxDistance_User = math.floor(arg[1])
        maxDistance = math.min(maxDistance_Fuel, maxDistance_Torch, maxDistance_User)
    end

    print("Digging for a distance of:", maxDistance)

    -- MAIN MINING LOOP
    repeat
        -- local currentFuelLevel = turtle.getFuelLevel() -- Do be used to report back to cPhone in a later update
        
        if checkInventoryFull() then -- Check for full inventory
            returnItemsChest()
        end
    
        inspectFloor()
        diggySlice() -- 2 Fuel Cost
        moveForward() -- 1 Fuel Cost
        currentTorchIteration = currentTorchIteration + 1

    until (currentDistance > maxDistance)


    -- Return to middle position
    inspectFloor()
    turtle.up()
    turtle.turnRight()
    turtle.turnRight()

    -- Go back to origin position
    repeat
        dig("front")
        turtle.forward()
        dist = dist + 1
    until (dist > currentDistance)
else
    print("Initialization failed!")
end

