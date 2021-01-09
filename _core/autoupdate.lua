local ignore = { 
    disk = true,
    rom = true
}

-- shell.run("github","chopstyix","cEEL")
-- shell.run("clear")

print("Detecting source...")
os.sleep(0.5)
if turtle then
    print("I'm a turtle!")
    shell.run("github","clone","chopstyix/cEEL/cTurtle","-a chopstyix")
    for _,filename in ipairs(fs.list("cEEL/cTurtle/")) do
            fs.delete(filename)
            print("Copying..."..filename)
            os.sleep(1)
            fs.copy("cEEL/cTurtle/"..filename,filename) 
    end
elseif pocket then
    print("I'm a pocket pc!")
    shell.run("github","clone","chopstyix/cEEL/cPhone","-a chopstyix")
    for _,filename in ipairs(fs.list("cEEL/cPhone/")) do
        fs.delete(filename)
        print("Copying..."..filename)
        os.sleep(1)
        fs.copy("cEEL/cPhone/"..filename,filename) 
end
else
    print("I'm a desktop!")
    shell.run("github","clone","chopstyix/cEEL/cOS","-a chopstyix")
    for _,filename in ipairs(fs.list("cEEL/cOS/")) do
        fs.delete(filename)
        print("Copying..."..filename)
        os.sleep(1)
        fs.copy("cEEL/cPhone/"..filename,filename) 
end
print("Grabbing autoupdater")
shell.run("github","clone","chopstyix/cEEL/_core/autoupdate.lua","-a chopstyix")
print("Complete!")
-- Press and key to continue
print("Press any key to continue")
local key = os.pullEvent("key")
term.clear()