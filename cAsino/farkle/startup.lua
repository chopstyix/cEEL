local surface, diceMon, displayMon, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 49

SLOT_1 = {1,1}
SLOT_2 = {18,1}
SLOT_3 = {35,1}
SLOT_4 = {52,1}
SLOT_5 = {69,1}
SLOT_6 = {86,1}

function setup()
    surface = dofile("cEEL/cAsino/farkle/surface")
    diceMon = peripheral.wrap("monitor_15")
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

function drawDice(value)
    -- local value_buffer = value
    local dice = surface.create(17,17)
    local number = surface.load("cEEL/cAsino/farkle/"..value..".nfp")
    dice:drawSurface(diceBg, 0, 0)
    dice:drawSurface(number, 0, 0)
    return dice
end

function drawPlayerHand(dice1,dice2,dice3,dice4,dice5,dice6)
    screen:clear(colors.green)
    screen:drawSurface(drawDice(dice1),SLOT_1[1],SLOT_1[2])
    screen:drawSurface(drawDice(dice2),SLOT_2[1],SLOT_2[2])
    screen:drawSurface(drawDice(dice3),SLOT_3[1],SLOT_3[2])
    screen:drawSurface(drawDice(dice4),SLOT_4[1],SLOT_4[2])
    screen:drawSurface(drawDice(dice5),SLOT_5[1],SLOT_5[2])
    screen:drawSurface(drawDice(dice6),SLOT_6[1],SLOT_6[2])
    screen:output()
end

function rollDiceButton(showRoll)
    screen:clear(colors.green)
    drawPlayerHand
end
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
setup()
screen:clear(colors.green)
drawPlayerHand("1","2","3","4","5","6")
screen:output()
--term.redirect(oldTerm)
--print("test1")
