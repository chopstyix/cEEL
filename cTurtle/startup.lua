local turtleName = os.getComputerLabel()
local TURTLEPORT = 69
local CPHONEPORT = 70
local modem = peripheral.wrap("left")

modem.open(TURTLEPORT)

-- function toPhone(message)
--     modem.transmit(CPHONEPORT, TURTLEPORT, message)
-- end
functions = 
{
    ["automine"] = function() shell.run("automine") end,
    ["test"] = function() end
}
term.clear()
term.setCursorPos(1,1)
print(turtleName)
print("Fuel: "..turtle.getFuelLevel())
os.sleep(1)
if modem == nil then
    print("Unable to find modem, switching to offline mode")
    print("Press ANY key to continue")
    os.pullEvent("key")
    shell.run("clear")
    print("Running offline!")
else
    -- Wait for rollCall signal from cPhone
    print("Waiting for cPhone to connect")
end

local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
local func = f[message]
if (func) then
    func()
else
    print("Default case!")
end