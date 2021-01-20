local surface, diceMon, displayMon, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 49

SLOT_1 = {1,1}
SLOT_2 = {19,1}
SLOT_3 = {37,1}
SLOT_4 = {1,18}
SLOT_5 = {19,18}
SLOT_6 = {37,18}

HITBOX = {
    [1] = {SLOT_1[1],SLOT_1[2],SLOT_1[1]+14,SLOT_1[2]+17},
    [2] = {SLOT_2[1],SLOT_2[2],SLOT_2[1]+14,SLOT_2[2]+17},
    [3] = {SLOT_3[1],SLOT_3[2],SLOT_3[1]+14,SLOT_3[2]+17},
    [4] = {SLOT_4[1],SLOT_4[2],SLOT_4[1]+14,SLOT_4[2]+17},
    [5] = {SLOT_5[1],SLOT_5[2],SLOT_5[1]+14,SLOT_5[2]+17},
    [6] = {SLOT_6[1],SLOT_6[2],SLOT_6[1]+14,SLOT_6[2]+17},
}

Player = {
    flag_skip = false,
    flag_bust = false,
    input = nil,
    bet = 0,
    total_score = 0,
    turn_score = 0,
    hand = {    
      [1] = {value = nil, hold = false, lock = false, flag_count = false},
      [2] = {value = nil, hold = false, lock = false, flag_count = false},
      [3] = {value = nil, hold = false, lock = false, flag_count = false},
      [4] = {value = nil, hold = false, lock = false, flag_count = false},
      [5] = {value = nil, hold = false, lock = false, flag_count = false},
      [6] = {value = nil, hold = false, lock = false, flag_count = false},
    },
    hold = {},
  }

function setup()
    surface = dofile("cEEL/cAsino/farkle/surface")
    diceMon = peripheral.wrap("monitor_14")
    displayMon = peripheral.wrap("monitor_13")
    drive = peripheral.wrap("bottom")
    rednet.open("right")
    speaker = peripheral.find("speaker")
    diceMon.setTextScale(0.5)
    --oldTerm = term.redirect(diceMon)
    term.redirect(diceMon)
    term.setPaletteColor(colors.lightGray, 0xc5c5c5)
    term.setPaletteColor(colors.orange, 0xf15c5c)
    term.setPaletteColor(colors.gray, 0x363636)
    term.setPaletteColor(colors.green, 0x044906)
    width, height = term.getSize()
    screen = surface.create(width, height)
    diceBg = surface.load("cEEL/cAsino/farkle/diceBg.nfp")
end

function drawDice(value,selected)
    -- local value_buffer = value
    local dice = surface.create(16,14)
    local number = surface.load("cEEL/cAsino/farkle/"..value..".nfp")
    local highlight = surface.load("cEEL/cAsino/farkle/highlight.nfp")
    dice:drawSurface(diceBg, 0, 0)
    dice:drawSurface(number, 0, 0)
    if selected then
        dice:drawSurface(highlight, 0, 0)
    end
    return dice
end

function Player:rollDice()
    -- local x = 1
    local rolls = {math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6)}
    -- print("Showing rolls")
    -- print(rolls[1],rolls[2],rolls[3],rolls[4],rolls[5],rolls[6])
    -- os.sleep(2)
    for k,v in ipairs(self.hand) do
        -- print(k,v)
        if self.hand[k].lock == false then -- If dice is not locked then roll a new value.
        self.hand[k].value = rolls[k]
        -- x = x + 1
        end
    end
    -- x = 0
end

function Player:checkState(state)
    local valid = false
    local logtable = {}
    -- I don't understand how this works, but it count's the number of times each diceValue is repeated.
    if state == "hold" then
        -- print("Checking holds")
        -- sleep()
        for i,v in pairs(self.hand) do
            if self.hand[i].hold == true then
                print(self.hand[i].value)
                local index = v.value
                logtable[index] = (logtable[index] or 0) + 1
            end
        end
    elseif state == "roll" then
        --print("Checking rolls")
        --sleep()
        for i,v in pairs(self.hand) do
            if self.hand[i].lock == false then
                print(self.hand[i].value)
                local index = v.value
                logtable[index] = (logtable[index] or 0) + 1
            end
        end
    end

    local count = countTable(logtable)
    if (count == 6) then
        -- print("Detected a 6 dice straight")
        valid = true
    elseif (count == 5) then
        if (logtable[1] == 1) and (logtable[5] == 5) then
        -- print("Detected a 5 dice straight (1 to 5)")
        valid = true
        elseif (logtable[1] == 2) and (logtable[5] == 6) then
        -- print("Detected a 5 dice straight (2 to 6)")
        valid = true
        end
    else
        for diceValue,match in pairs(logtable) do -- Check for valid match, return a
        -- print("diceValue: "..diceValue.."  match: "..match)
        if (match >= 3) then
            -- print("Detected a minimum of 3 of a kind")
            valid = true
        elseif (diceValue == 1 or diceValue == 5) then
            -- print("Detected a 1 or a 5")
            valid = true
        end
        end
    end
    -- local key = os.pullEvent("key")
return valid
end

function countTable(table)
    local count = 0
    for i,v in pairs(table) do
      count = count + 1
    end
    return count
end

function Player:drawPlayerHand()
    screen:clear(colors.green)
    screen:drawSurface(drawDice(tostring(self.hand[1].value),self.hand[1].hold),SLOT_1[1],SLOT_1[2])
    screen:drawSurface(drawDice(tostring(self.hand[2].value),self.hand[2].hold),SLOT_2[1],SLOT_2[2])
    screen:drawSurface(drawDice(tostring(self.hand[3].value),self.hand[3].hold),SLOT_3[1],SLOT_3[2])
    screen:drawSurface(drawDice(tostring(self.hand[4].value),self.hand[4].hold),SLOT_4[1],SLOT_4[2])
    screen:drawSurface(drawDice(tostring(self.hand[5].value),self.hand[5].hold),SLOT_5[1],SLOT_5[2])
    screen:drawSurface(drawDice(tostring(self.hand[6].value),self.hand[6].hold),SLOT_6[1],SLOT_6[2])
    screen:output()
end

-- function Player:holdDice()
--     local loop = true
--     local count = 0
--     while loop do
--         -- refresh()
--         -- print("Select a dice to hold or use 'roll' or 'rollSkip'")
--         -- self:printDice()
--         -- local input = io.read()
--         local input_1 = tonumber(input)
--         if input == "roll" then
--         if count == 0 then
--             print("Unable to roll, please select dice to hold")
--         elseif (self:checkState("hold")) then
--             print("Score tallied, you can roll again")
--             local key = os.pullEvent("key")
--             loop = false
--         end
--         elseif input == "rollSkip" then
--         if count == 0 then
--             print("Unable to skip, please select a dice to hold")
--         elseif (self:checkState("hold")) then
--             loop = false
--             print("Score tallied, you end your turn")
--             self.flag_skip = true
--         end
--         elseif (type(input_1) == "number" and input_1 >= 1 and input_1 <=6) then
--         if self.hand[input_1].lock == true then
--             print("That dice is locked! Please try again.")
--         elseif (self.hand[input_1].hold == false) then
--             self.hand[input_1].hold = true
--             count = count + 1
--         elseif (self.hand[input_1].hold == true) then
--             self.hand[input_1].hold = false
--             count = count - 1
--         end
--         elseif input == nil then
--         print("Invalid input, please try again")
--         end
--     end

--     for i,v in pairs(self.hand) do
--         if self.hand[i].hold == true then
--         self.hand[i].hold = false
--         self.hand[i].lock = true
--         end
--     end
-- end

function setup()
    surface = dofile("cEEL/cAsino/farkle/surface")
    diceMon = peripheral.wrap("monitor_14")
    displayMon = peripheral.wrap("monitor_13")
    drive = peripheral.wrap("bottom")
    rednet.open("right")
    speaker = peripheral.find("speaker")
    diceMon.setTextScale(0.5)
    --oldTerm = term.redirect(diceMon)
    term.redirect(diceMon)
    term.setPaletteColor(colors.lightGray, 0xc5c5c5)
    term.setPaletteColor(colors.orange, 0xf15c5c)
    term.setPaletteColor(colors.gray, 0x363636)
    term.setPaletteColor(colors.green, 0x044906)
    width, height = term.getSize()
    screen = surface.create(width, height)
    diceBg = surface.load("cEEL/cAsino/farkle/diceBg.nfp")
end

function Player:holdDice_phase()
local loop = true
    while loop do
        screen:clear(colors.green)
        self:drawPlayerHand()
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        for i,v in pairs(HITBOX) do
            local x1 = HITBOX[i][1]
            local y1 = HITBOX[i][2]
            local x2 = HITBOX[i][3]
            local y2 = HITBOX[i][4]
            print("x1:"..x1)
            print("y1:"..y1)
            print("x2:"..x2)
            print("y2:"..y2)
            if (xPos >= x1 and x <= x2) and (yPos >= y1 and yPos <= y2) then
                if self.hand[i].hold == false then
                    self.hand[i].hold = true
                elseif self.hand[i].hold == true then
                    self.hand[i].hold = false
                end
            end
        end
        screen:output()
    end
    return xPos, yPos
end

-- function getButtonSurface(text, bg)
--     local textSize = surface.getTextSize(text, font)
--     local button = surface.create(textSize + 2, 7)
--     button:fillRect(0,0,textSize+2, 7, bg)
--     button:drawText(text, font, 1, 1, colors.black)
--     return button
-- end

-- function button(surface, text, bg, x, y, func, center)
--     local button = getButtonSurface(text, bg)
--     if center then
--         x = math.floor(x - button.width / 2)
--     end
--     surface:drawSurface(button, x, y)
--     buttons[text] = {x=x, y=y, width=button.width, height=button.height, cb=func}
--     return button
-- end
  
-- function waitForButtonPress(ox, oy)
--     local pressed = false
--     while not pressed do
--           local event, button, px, py = os.pullEvent("monitor_touch")
--       px = px - ox
--           py = py - oy
--       for text,button in pairs(buttons) do
--         if px >= button.x and px <= button.x + button.width and py >= button.y and py <= button.y + button.height then
--           button.cb()
--           buttons = {}
--           pressed = true
--         end
--       end
--     end
--   end

-- function button(surface, text, bg, x, y, func, center)
-- local button = getButtonSurface(text, bg)
-- if center then
--     x = math.floor(x - button.width / 2)
-- end
-- surface:drawSurface(button, x, y)
-- buttons[text] = {x=x, y=y, width=button.width, height=button.height, cb=func}
-- return button
-- end
-- Surface Stuff
-- function drawDice(selected)
--     -- local value_buffer = value
--     local dice = surface.create(17,17)
--     local number = surface.load("cEEL/cAsino/farkle/"..value..".nfp")
--     local highlight = surface.load("cEEL/cAsino/farkle/highlight.nfp")
--     dice:drawSurface(diceBg, 0, 0)
--     dice:drawSurface(number, 0, 0)
--     if selected then
--         dice:drawSurface(highlight, 0, 0)
--     end
--     return dice
-- end

  -- Main Line Code -- 
-- Dice img dimensions are 13 x 9
p1 = Player -- User
p2 = Player -- Computer Opponent
setup()

screen:clear(colors.green)
p1:rollDice()
-- p1:drawPlayerHand()
-- if p1:checkState("roll") then
    p1:drawPlayerHand()
    p1:holdDice_phase()
-- else
--     p1:drawPlayerHand()
-- end
-- p1:drawPlayerHand()
screen:output()
--term.redirect(oldTerm)
--print("test1")
