local surface, diceMon, displayMon, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 49

function setup()
    surface = dofile("cEEL/casino/farkle/surface")
    diceMon = peripheral.wrap("monitor_14")
    displayMon = peripheral.wrap("monitor_13")
    drive = peripheral.wrap("bottom")
    rednet.open("right")
    speaker = peripheral.find("speaker")
    diceMon.setTextScale(0.5)
    oldTerm = term.redirect(diceMon)
    --term.redirect(diceMon)
    --monitor.setTextScale(0.5)
    term.setPaletteColor(colors.lightGray, 0xc5c5c5)
    term.setPaletteColor(colors.orange, 0xf15c5c)
    term.setPaletteColor(colors.gray, 0x363636)
    term.setPaletteColor(colors.green, 0x044906)
    width, height = term.getSize()
    print(width, height)
    screen = surface.create(width, height)
    diceBg = surface.load("cEEL/cAsino/farkle/diceBg.nfp")
end

-- Main Line Code -- 
-- Dice img dimensions are 13 x 9
setup()
screen:clear(colors.green)
local dice = surface.create(13,9)
dice:drawSurface(diceBg, 0, 0)
term.redirect(oldTerm)
print("test1")