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
    ["Roll"] = {x1,y1,x2,y2, enabled = true},
    ["Skip and Roll"] = {x1, y1,x2, y2, enabled = true},
    ["Skip and End Turn"] = {x1, y1, x2, y2, enabled = true},
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

function Player:holdDice_phase()
    local loop = true
        while loop do
            screen:clear(colors.green)
            self:drawPlayerHand()
            -- drawBottomButtons(buttons)
            local event, side, xPos, yPos = os.pullEvent("monitor_touch")
            -- xPos = xPos / 2
            -- yPos = yPos / 2
            for i,v in pairs(HITBOX) do
                local x1 = HITBOX[i][1]
                local y1 = HITBOX[i][2]
                local x2 = HITBOX[i][3]
                local y2 = HITBOX[i][4]
                print("xPos:"..xPos)
                print("yPos:"..yPos)
                print("x1:"..x1)
                print("y1:"..y1)
                print("x2:"..x2)
                print("y2:"..y2)
                if (xPos >= x1 and xPos <= x2) and (yPos >= y1 and yPos <= y2) then
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

  -- Main Line Code -- 
p1 = Player -- User
p2 = Player -- Computer Opponent
setup()
font = surface.loadFont(surface.load("cEEL/cAsino/blackjack/font"))
screen:clear(colors.green)
screen:drawText("test",debugFont,0,0,colors.white)
sleep()
p1:rollDice()
p1:drawPlayerHand()
if p1:checkState("roll") then
    p1:drawPlayerHand()
    p1:holdDice_phase()
else
    p1:drawPlayerHand()

end
-- p1:drawPlayerHand()
screen:output()
--term.redirect(oldTerm)
--print("test1")
