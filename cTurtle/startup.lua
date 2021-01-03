local turtleName = os.getComputerLabel()
local TURTLEPORT = 69
local CPHONEPORT = 70
local modem = peripheral.wrap("left")

modem.open(TURTLEPORT)

function toPhone(message)
    modem.transmit(CPHONEPORT, TURTLEPORT, message)
end

print("Searching for a modem")
os.sleep(1)
if modem == nil then
    print("Unable to find modem, switching to offline mode")
    print("Press ANY key to continue")
    os.pullEvent("key")
    shell.run("clear")
    print("Running offline!")
    print("My current fuel level is:",turtle.getFuelLevel())
else
    -- Wait for rollCall signal from cPhone
    print("Waiting for cPhone to connect")
end
repeat
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
until (message == "rollCall")
toPhone("ok")
shell.run("automine")
--     print("My current fuel level is: ",turtle.getFuelLevel())
--     print("Waiting for remote command...")
--     local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
--     if message == "automine" then
--         shell.run("automine")
--         modem.transmit(CPHONEPORT,CPHONEPORT,turtleName.." - Success")
--     else
--         modem.transmit(CPHONEPORT,CPHONEPORT,turtleName.." - Unknown command")
--         shell.run("startup")
--     end
-- end