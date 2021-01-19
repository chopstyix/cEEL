local surface, diceMon, displayMon, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 49

SLOT_1 = {0,0}
SLOT_2 = {0,30}
SLOT_3 = {0,47}
SLOT_4 = {20,0}
SLOT_5 = {31,30}
SLOT_6 = {42,47}

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

function drawDice(value)
    local value_buffer = value
    local dice = surface.create(13,9)
    local number = surface.load("cEEL/cAsino/farkle/"..tostring(value)..".nfp")
    dice:drawSurface(diceBg, 0, 0)
    dice:drawSurface(number, 0, 0)
    return dice
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
screen:drawSurface(drawDice(1),SLOT_1[1],SLOT_1[2])
screen:output()
--term.redirect(oldTerm)
--print("test1")
