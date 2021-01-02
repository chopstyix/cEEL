--[[ 
--// TODO: Place torches every 10 blocks
--// TODO: Place block below if lava is detected
--// TODO: Return ores to a collection chest
--// TODO: Search and plug up liquids
--// TODO: Drop items into a chest when full, then pick up
--// TODO: Record distance travelled from origin point
TODO: Create a feature that checks inventory for correct items before launching
TODO: Create turtle network that listens to commands from master device
TODO: Incorporate something with GPS
]]--

-- Capture argument
local arg = { ... }
-- Settings
torchDistance = 10 -- Torch Spacing

-- Local Variables
horizontal = 0 -- 0 begins digging from left, 1 begins from the right
vertical = 0  -- 0 begins digging from bottom, 1 begins from top
currentTorchIteration = 1
currentDistance = 0
dist = 1

-- Core Item Slots
STORAGECHEST = 14
COBBLESTONE = 15
TORCH = 16
LASTITEM = 13

-- Functions
function initialize()
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

function diggy()
    while turtle.detect()  do
        turtle.dig()
    end
end

function diggyUp()
    while turtle.detectUp() do
        turtle.digUp()
    end
end

function diggyDown()
    while turtle.detectDown() do
        turtle.digDown()
    end
end

function diggySwipe()
    if horizontal == 0 then
        diggy()
        turtle.turnRight()
        diggy()
        turtle.turnRight()
        diggy()
        horizontal = 1
    elseif horizontal == 1 then
        diggy()
        turtle.turnLeft()
        diggy()
        turtle.turnLeft()
        diggy()
        horizontal = 0
    end
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
    if horizontal == 0 then
        turtle.turnRight()
        turtle.forward()
    elseif horizontal == 1 then
        turtle.turnLeft()
        turtle.forward()
    end
    currentDistance = currentDistance + 1
end

function diggyToLeft()
    diggy()
    turtle.turnLeft()
    diggy()
    turtle.turnLeft()
    diggy()
end

function diggySlice()
    local data = turtle.getItemDetail(TORCH)
    if vertical == 0 then
        diggySwipe()
        diggyUp()
        turtle.up()
        if data.name == "minecraft:torch" and currentTorchIteration > torchDistance then
            turtle.select(TORCH)
            turtle.placeDown()
            currentTorchIteration = 0
        end
        diggySwipe()
        diggyUp()
        turtle.up()
        diggySwipe()
        vertical = 1
    elseif vertical == 1 then
        -- diggySwipe()
        diggyDown()
        turtle.down()
        -- diggySwipe()
        diggyDown()
        turtle.down()
        -- diggySwipe()
        vertical = 0
    end
end

function toStartingPosition()
    if horizontal == 1 then
        turtle.turnRight()
    elseif horizontal == 0 then
        turtle.turnLeft()
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

-- Initialize
if initialize() then
    print("Initialization successful!")
    maxDistanceFuel = math.floor(turtle.getFuelLevel() / 3)
    maxDistanceTorch = turtle.getItemCount(TORCH) * torchDistance
    if arg[1] == nil then
        maxDistance = math.min(maxDistanceFuel, maxDistanceTorch)
    else
        maxDistanceUser = math.floor(arg[1])
        maxDistance = math.min(maxDistanceFuel, maxDistanceTorch, maxDistanceUser)
    end

    print("Digging for a distance of:", maxDistance)

    -- Main Line Code
    repeat
        local currentFuelLevel = turtle.getFuelLevel()
        
        -- Check Inventory if full
        if checkInventoryFull() then
            returnItemsChest()
        end
    
        toStartingPosition()
        diggySlice() -- 2 Fuel Cost
        if vertical == 0 then
            inspectFloor()
        end
        moveForward() -- 1 Fuel Cost
        if vertical == 0 then
            inspectFloor()
        end
        currentTorchIteration = currentTorchIteration + 1

    until (currentDistance > maxDistance)


    -- Return to middle position
    if vertical == 1 then
        turtle.down()
    elseif vertical == 0 then
        turtle.up()
    end

    turtle.turnRight()
    turtle.turnRight()

    -- Go back to origin position
    repeat
        diggy()
        turtle.forward()
        dist = dist + 1
    until (dist > currentDistance)
else
    print("Initialization failed!")
end

