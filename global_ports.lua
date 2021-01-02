local ports = {
    TURTLEPORT = 69 -- nice
    CPHONEPORT = 70

    if pocket then
        local modem = peripheral.wrap("left")
        modem.open(CPHONEPORT)
    else
        local modem = peripheral.wrap("back")
        modem.open(TURTLEPORT)
    end
}