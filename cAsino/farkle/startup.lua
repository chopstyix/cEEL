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
    [7] = {59,3,79,9, enabled = true}, -- Roll
    [8] = {59,13,77,19, enabled = true}, -- Skip
    [9] = {59,32,79,39, enabled = true}, -- Quit
}

Player = {
    flag_quit = false,
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
    oldTerm = term.current()
    term.redirect(diceMon)
    term.setPaletteColor(colors.lightGray, 0xc5c5c5)
    term.setPaletteColor(colors.orange, 0xf15c5c)
    term.setPaletteColor(colors.gray, 0x363636)
    term.setPaletteColor(colors.green, 0x044906)
    width, height = term.getSize()
    screen = surface.create(width, height)
    font = surface.loadFont(surface.load("cEEL/cAsino/blackjack/font"))
    diceBg = surface.load("cEEL/cAsino/farkle/diceBg.nfp")
end

function drawDice(value,selected,locked)
    -- local value_buffer = value
    local dice = surface.create(16,14)
    local number = surface.load("cEEL/cAsino/farkle/"..value..".nfp")
    local highlight = surface.load("cEEL/cAsino/farkle/highlight.nfp")
    local lock = surface.load("cEEL/cAsino/farkle/lock.nfp")
    dice:drawSurface(diceBg, 0, 0)
    dice:drawSurface(number, 0, 0)
    if selected then
        dice:drawSurface(highlight, 0, 0)
    elseif locked then
        dice:drawSurface(lock, 0, 0)
    end
    return dice
end
    
function Player:rollDice()
    local rolls = {math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6)}
    debug(rolls[1],rolls[2],rolls[3],rolls[4],rolls[5],rolls[6])
    for k,v in ipairs(self.hand) do
        if self.hand[k].lock == false then -- If dice is not locked then roll a new value.
            self.hand[k].value = rolls[k+math.random(0,10)]
            sleep(.1)
        end
    end
end

function Player:checkState(state)
    local loop = true
    local valid = false
    local logtable = {}
    local count = 0
    local score = 0
    local hold_cards = 0
    -- I don't understand how this works, but it count's the number of times each diceValue is repeated.
    if state == "hold" then
        debug("Checking hold")
        for i,v in ipairs(self.hand) do
            if self.hand[i].hold == true then
                debug(self.hand[i].value)
                local index = v.value
                logtable[index] = (logtable[index] or 0) + 1
            end
        end
    elseif state == "roll" then
        debug("Checking rolls")
        for i,v in ipairs(self.hand) do
            if self.hand[i].lock == false then
                debug(self.hand[i].value)
                local index = v.value
                logtable[index] = (logtable[index] or 0) + 1    
            end
        end
    end

    count = countTable(logtable)
    -- for i,v in pairs (self.hand) do
        -- if self.hand[i].flag_count == false then
    while loop do
        if (count == 6) then
            debug("Detected a 6 dice straight")
            valid = true
            score = score + 1500
            self.hand[1].flag_count = true
            self.hand[2].flag_count = true
            self.hand[3].flag_count = true
            self.hand[4].flag_count = true
            self.hand[5].flag_count = true
            self.hand[6].flag_count = true
            count = 0
        elseif (count == 5) then
            if (logtable[1] == 1) and (logtable[5] == 5) then
                debug("Detected a 5 dice straight (1 to 5)")
                valid = true
                score = score + 500
                for i,v in ipairs(self.hand) do
                    if v.value == 1 then
                        self.hand[i].flag_count = true
                    elseif v.value == 2 then
                        self.hand[i].flag_count = true
                    elseif v.value == 3 then
                        self.hand[i].flag_count = true
                    elseif v.value == 4 then
                        self.hand[i].flag_count = true
                    elseif v.value == 5 then
                        self.hand[i].flag_count = true
                    end
                end
                count = 0
                flag_counter = 5
            elseif (logtable[1] == 2) and (logtable[5] == 6) then
                debug("Detected a 5 dice straight (2 to 6)")
                valid = true
                score = score + 750
                if v.value == 2 then
                    self.hand[i].flag_count = true
                elseif v.value == 3 then
                    self.hand[i].flag_count = true
                elseif v.value == 4 then
                    self.hand[i].flag_count = true
                elseif v.value == 5 then
                    self.hand[i].flag_count = true
                elseif v.value == 6 then
                    self.hand[i].flag_count = true
                end
                count = 0
                flag_counter = 5
            end
        else
            for diceValue,match in pairs(logtable) do 
                debug("diceValue: "..diceValue.."  match: "..match)
                if (match == 6) then
                    debug("Detected a 6 of a kind")
                    valid = true
                    if diceValue == 1 then
                        score = score + 8000
                    elseif diceValue == 2 then
                        score = score + 1600
                    elseif diceValue == 3 then
                        score = score + 2400
                    elseif diceValue == 4 then
                        score = score + 3200
                    elseif diceValue == 5 then
                        score = score + 4000
                    elseif diceValue == 6 then
                        score = score + 4800
                    end
                    self.hand[1].flag_count = true
                    self.hand[2].flag_count = true
                    self.hand[3].flag_count = true
                    self.hand[4].flag_count = true
                    self.hand[5].flag_count = true
                    self.hand[6].flag_count = true
                elseif (match == 5) then
                    debug("Detected a 5 of a kind")
                    valid = true
                    if diceValue == 1 then
                        score = score + 4000
                    elseif diceValue == 2 then
                        score = score + 800
                    elseif diceValue == 3 then
                        score = score + 1200
                    elseif diceValue == 4 then
                        score = score + 1600
                    elseif diceValue == 5 then
                        score = score + 2000
                    elseif diceValue == 6 then
                        score = score + 2400
                    end
                    for i,v in ipairs(self.hand) do
                        if self.hand[i].value == diceValue then
                            self.hand[i].flag_count = true
                        end
                    end
                elseif (match == 4) then
                    debug("Detected a 4 of a kind")
                    valid = true
                    if diceValue == 1 then
                        score = score + 2000
                    elseif diceValue == 2 then
                        score = score + 400
                    elseif diceValue == 3 then
                        score = score + 600
                    elseif diceValue == 4 then
                        score = score + 800
                    elseif diceValue == 5 then
                        score = score + 1000
                    elseif diceValue == 6 then
                        score = score + 1200
                    end
                    for i,v in ipairs(self.hand) do
                        if self.hand[i].value == diceValue then
                            self.hand[i].flag_count = true
                        end
                    end
                elseif (match == 3) then
                    debug("Detected a 3 of a kind")
                    valid = true
                    if diceValue == 1 then
                        score = score + 1000
                    elseif diceValue == 2 then
                        score = score + 200
                    elseif diceValue == 3 then
                        score = score + 300
                    elseif diceValue == 4 then
                        score = score + 400
                    elseif diceValue == 5 then
                        score = score + 500
                    elseif diceValue == 6 then
                        score = score + 600
                    end
                    for i,v in ipairs(self.hand) do
                        if self.hand[i].value == diceValue then
                            self.hand[i].flag_count = true
                        end
                    end
                end
            end
            for i,v in ipairs(self.hand) do
                if (v.value == 1) and self.hand[i].flag_count == false then
                        self.hand[i].flag_count = true
                        score = score + 100
                        debug("Detected a 1")
                        valid = true
                elseif (v.value == 5) and self.hand[i].flag_count == false then
                        self.hand[i].flag_count = true
                        score = score + 50
                        debug("Detected a 5")
                        valid = true
                end
            end
            debug("Loop is now false")
            loop = false
        end
    end
    turn_score = score
return valid
end


function countTable(table)
    local count = 0
    for i,v in pairs(table) do
      count = count + 1
    end
    return count
end

function Player:drawScreen()
    screen:clear(colors.green)
    screen:drawSurface(drawDice(tostring(self.hand[1].value),self.hand[1].hold,self.hand[1].lock),SLOT_1[1],SLOT_1[2])
    screen:drawSurface(drawDice(tostring(self.hand[2].value),self.hand[2].hold,self.hand[2].lock),SLOT_2[1],SLOT_2[2])
    screen:drawSurface(drawDice(tostring(self.hand[3].value),self.hand[3].hold,self.hand[3].lock),SLOT_3[1],SLOT_3[2])
    screen:drawSurface(drawDice(tostring(self.hand[4].value),self.hand[4].hold,self.hand[4].lock),SLOT_4[1],SLOT_4[2])
    screen:drawSurface(drawDice(tostring(self.hand[5].value),self.hand[5].hold,self.hand[5].lock),SLOT_5[1],SLOT_5[2])
    screen:drawSurface(drawDice(tostring(self.hand[6].value),self.hand[6].hold,self.hand[6].lock),SLOT_6[1],SLOT_6[2])
    screen:drawSurface(drawButton("ROLL",colors.white),58,2)
    screen:drawSurface(drawButton("SKIP",colors.white),58,12)
    screen:drawSurface(drawButton("QUIT",colors.red),58,30)
    screen:drawSurface(drawButton(tostring(self.turn_score),colors.white),0,31)
    screen:drawSurface(drawButton(tostring(self.total_score),colors.white),30,31)
    if self.flag_bust then
        screen:drawSurface(drawButton("BUST",colors.red),25,15)
    end
    screen:output()
end

function Player:card_counter()
    local value = 0
    for i,v in pairs(self.hand) do
        if self.hand[i].flag_count == true then
            value = value + 1
        end
    end
    return value
end

function Player:holdDice_phase()
    local loop = true
    while loop do
        screen:clear(colors.green)
        self:drawScreen()
        -- drawBottomButtons(buttons)
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        -- xPos = xPos / 2
        -- yPos = yPos / 2
        for i,v in pairs(HITBOX) do
            local x1 = HITBOX[i][1]
            local y1 = HITBOX[i][2]
            local x2 = HITBOX[i][3]
            local y2 = HITBOX[i][4]
            -- term.redirect(oldTerm)
            -- print("xPos:"..xPos)
            -- print("yPos:"..yPos)
            -- print("x1:"..x1)
            -- print("y1:"..y1)
            -- print("x2:"..x2)
            -- print("y2:"..y2)
            -- term.redirect(diceMon)
            if (xPos >= x1 and xPos <= x2) and (yPos >= y1 and yPos <= y2) then
                if i >= 1 and i <= 6 then
                    if self.hand[i].hold == false and self.hand[i].lock == false then
                        self.hand[i].hold = true
                    elseif self.hand[i].hold == true and self.hand[i].lock == false then
                        self.hand[i].hold = false
                    end
                    -- Calculate potential value everytime a dice is toggled with
                elseif i == 7 then -- Roll
                    if self:checkState("hold") then
                        for i,v in ipairs(self.hand) do
                            if self.hand[i].hold == true then
                                self.hand[i].hold = false
                                self.hand[i].lock = true
                            end
                        end
                        loop = false
                        -- Pass turn_score to total score
                        
                    end
                elseif i == 8 then -- 
                    loop = false
                    self.flag_skip = true
                elseif i == 9 then
                    loop = false
                    self.flag_quit = true
                end
            end
        end
        self.turn_score = 0
        screen:output()
    end
end

function drawButton(text, bg)
    local textSize = surface.getTextSize(text, font)
    local button = surface.create(textSize + 2, 7)
    button:fillRect(0,0,textSize+2, 7, bg)
    button:drawText(text, font, 1, 1, colors.black)
    return button
end

function debug(string)
    term.clear()
    term.redirect(oldTerm)
    print(string)
    term.redirect(diceMon)
end

  -- Main Line Code -- 
p1 = Player -- User
p2 = Player -- Computer Opponent
setup()

while p1.flag_bust == false and p1.flag_skip == false and p1.flag_quit == false do
    screen:clear(colors.green)
    p1:rollDice()
    if p1:checkState("roll") then
        p1:holdDice_phase()
        -- Update Score
    else
        p1.flag_bust = true
        p1:drawScreen()
        os.sleep(5)
    end
end
screen:clear()
print("Terminated")
-- p1:drawScreen()
--term.redirect(oldTerm)
--print("test1")
