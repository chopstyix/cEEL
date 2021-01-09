local ignore = { 
    disk = true,
    rom = true
}

-- shell.run("github","chopstyix","cEEL")
-- shell.run("clear")
shell.run("github","chopstyix/cEEL","-a chopstyix")
print("Detecting source...")
os.sleep(0.5)
if turtle then
    print("I'm a turtle!")
    for _,filename in ipairs(fs.list("cEEL/cTurtle/")) do
            fs.delete(filename)
            print("Copying..."..filename)
            fs.copy("cEEL/cTurtle/"..filename,filename) 
    end
elseif pocket then
    print("I'm a pocket pc!")
    for _,filename in ipairs(fs.list("cEEL/cPhone/")) do
        fs.delete(filename)
        fs.copy("cEEL/cPhone/"..filename,filename) 
end
else
    print("I'm a desktop!")
    print("I'm unable to do anything right now :)")
end
print("Complete!")
-- Press and key to continue
print("Press any key to continue")
local key = os.pullEvent("key")
term.clear()