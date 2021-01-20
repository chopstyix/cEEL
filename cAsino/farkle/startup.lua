local surface, diceMon, displayMon, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 49

SLOT_1 = {1,1}
SLOT_2 = {18,1}
SLOT_3 = {35,1}
SLOT_4 = {1,18}
SLOT_5 = {18,18}
SLOT_6 = {35,18}

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

function Player:drawDice(value)
    -- local value_buffer = value
    local dice = surface.create(17,17)
    local number = surface.load("cEEL/cAsino/farkle/"..value..".nfp")
    dice:drawSurface(diceBg, 0, 0)
    dice:drawSurface(number, 0, 0)
    return dice
end

function Player:drawPlayerHand()
    screen:clear(colors.green)
    screen:drawSurface(drawDice(self.hand[1]),SLOT_1[1],SLOT_1[2])
    screen:drawSurface(drawDice(self.hand[2]),SLOT_2[1],SLOT_2[2])
    screen:drawSurface(drawDice(self.hand[3]),SLOT_3[1],SLOT_3[2])
    screen:drawSurface(drawDice(self.hand[4]),SLOT_4[1],SLOT_4[2])
    screen:drawSurface(drawDice(self.hand[5]),SLOT_5[1],SLOT_5[2])
    screen:drawSurface(drawDice(self.hand[6]),SLOT_6[1],SLOT_6[2])
    screen:output()
end

-- function rollDiceButton(showRoll)
--     screen:clear(colors.green)
--     drawPlayerHand
-- end
-- function drawButton(text,function)
-- function drawCard(cardID)
-- 	local number = cardID:sub(1, 1)
-- 	if number == "T" then
-- 		number = "10"
-- 	end
-- 	local suit = cardID:sub(2, -1)
-- 	local card = surface.create(12, 15)
--   suit = surface.load("cEEL/cAsino/blackjack/"..suit..".nfp")
--   card:drawSurface(cardBg, 0, 0)
--   card:drawSurface(suit, 5, 2)
--   card:drawText(number, font, 2, 8, colors.black)
--   return card

-- Main Line Code -- 
-- Dice img dimensions are 13 x 9
p1 = Player -- User
p2 = Player -- Computer Opponent
setup()

screen:clear(colors.green)
p1:rollDice()
p1:drawPlayerHand()
screen:output()
--term.redirect(oldTerm)
--print("test1")
