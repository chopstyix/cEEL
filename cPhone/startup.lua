-- local function relay()
--     local input
--     input = read()
--     local message = string.lower(input)
--     modem.transmit(TURTLEPORT,CPHONEPORT,message)
--     print("Sending...")
-- end

-- local function listen()
--     local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
--     if senderChannel == CPHONEPORT then
--         -- Send message from turtle to cPhone
--         print(message)
--         return message
--     end
-- end

-- local function relayMessage(str)
--     local message = string.lower(str)
--     modem.transmit(TURTLEPORT,CPHONEPORT,message)
-- end

io.write("Booting cPhone")
for i=1,3 do
    io.write(".")
    os.sleep(1)
end
shell.run("clear")

-- -- Initialize cPhone
TURTLEPORT = 69 -- nice
CPHONEPORT = 70
rednet.open("back")
--modem.open(TURTLEPORT)

print("Booting cPhone")
local function listen()
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    if senderChannel == CPHONEPORT then
        -- Send message from turtle to cPhone
        print(message)  
    end
end

local function relay()
    local input
    input = read()
    local message = string.lower(input)
    modem.transmit(TURTLEPORT,CPHONEPORT,message)
    print("Sending...")
end

function init_automine()

while true do
    print("cTurtle Command UI")
    print("Select an input")
    print("[1] - Initiate Automine")
    print("[2] - Get Fuel Level")
    local choice = io.read()
    local func = c_tbl[choice]
    if (func) then
        func()
    else
        print("Invalid Choice!")
    end
end