os.loadAPI("UI")

doFile("settings/ports.lua")
local monX, monY = term.getSize()
-- 26 20

-- TURTLEPORT = 69 -- nice
-- CPHONEPORT = 70
-- local modem = peripheral.wrap("back")
-- modem.open(CPHONEPORT)

function removeSuffix(string, suffix)
    return string:gsub(suffix, "")
end

local function relay()
    local input
    input = read()
    local message = string.lower(input)
    modem.transmit(TURTLEPORT,CPHONEPORT,message)
    print("Sending...")
end

local function listen()
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    if senderChannel == CPHONEPORT then
        -- Send message from turtle to cPhone
        print(message)
        return message
    end
end

local function relayMessage(str)
    local message = string.lower(str)
    modem.transmit(TURTLEPORT,CPHONEPORT,message)
end

io.write("Booting cPhone")
for i=1,3 do
    io.write(".")
    os.sleep(1)
end
shell.run("clear")

-- while true do
--     parallel.waitForAny(listen,relay)
-- end

-- Function that requests a message from all active turtles in the network
-- local function turtleSignal()

headerText = UI.Widget:new()
headerText.label = "turtleNet"
headerText.x = math.ceil((monX / 2) - (headerText.label:len() / 2))
headerText.y = 1

connectButton = UI.Widget:new()
connectButton.label = "CONNECT"
connectButton.x = math.ceil((monX / 2) - (headerText.label:len() / 2))
connectButton.y = 4
connectButton.key = 30
connectButton.fontColor = 1
connectButton.backgroundColor = 64
connectButton.onClick = function (self) -- When the user clicks on this button it will do something
    modem.transmit(TURTLEPORT,CPHONEPORT,"rollCall")
end

fuelLevel = UI.Widget:new()
fuelLevel.label = "N/A"
fuelLevel.x = 1
fuelLevel.y = 10
fuelLevel.tick = function (self) -- Every tick this updates
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    local af = "automineFuel"
    if string.match(message,af) then
        local currFuelLevel = removeSuffix(message,af)
        self.label = currFuelLevel
    end
end
-- turtleInfo = UI.Widget:new()
-- turtleInfo.label = "test" -- Turtle Name
-- turtleInfo.x = 1
-- turtleInfo.y = 5

vp = UI.Viewport:new()
vp:addWidget(headerText)
vp:addWidget(connectButton)
vp:addWidget(fuelLevel)

app = UI.App:new()
app:setViewport(vp)
app:run()

-- farmButton = UI.Widget:new()
-- farmButton.x = 12
-- farmButton.y = 6
-- farmButton.farmWidth = 1
-- farmButton.farmDepth = 1
-- farmButton.label = "Launch farming"
-- farmButton.backgroundColor = 2048
-- farmButton.fontColor = 1
-- farmButton.onClick = function (self)
-- 	term.clear()
-- 	term.setCursorPos(1,1)
-- 	os.sleep(3)
-- end

-- refuelButton = UI.Widget:new()
-- refuelButton.x = 10
-- refuelButton.y = 8
-- refuelButton.label = "Refuel"
-- refuelButton.backgroundColor = 2048
-- refuelButton.fontColor = 1
-- refuelButton.onClick = function (self)
-- 	print("test")
-- end

-- fuelText = UI.Widget:new()
-- fuelText.x = 10
-- fuelText.y = 10
-- fuelText.label = "Fuel level : "

-- fuelLevel = UI.Widget:new()
-- fuelLevel.x = 22
-- fuelLevel.y = 10
-- fuelLevel.label = test
-- fuelLevel.tick = function(self)
-- 	self.label = "test"
-- end

-- vp = UI.Viewport:new()
-- vp:addWidget(farmButton)
-- vp:addWidget(refuelButton)
-- vp:addWidget(fuelText)
-- vp:addWidget(fuelLevel)

-- app = UI.App:new()
-- app:setViewport(vp)
-- app:run()

-- -- Initialize cPhone
-- TURTLEPORT = 69 -- nice
-- CPHONEPORT = 70
-- local modem = peripheral.wrap("back")
-- --modem.open(TURTLEPORT)
-- modem.open(CPHONEPORT)

-- print("Booting cPhone")
-- local function listen()
--     local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
--     if senderChannel == CPHONEPORT then
--         -- Send message from turtle to cPhone
--         print(message)  
--     end
-- end

-- local function relay()
--     local input
--     input = read()
--     local message = string.lower(input)
--     modem.transmit(TURTLEPORT,CPHONEPORT,message)
--     print("Sending...")
-- end

-- while true do
--     parallel.waitForAny(listen,relay)
-- end