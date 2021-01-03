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
    for _,filename in ipairs(fs.list("downloads/cEEL/cTurtle/")) do
            fs.delete(filename)
            fs.copy("downloads/cEEL/cTurtle/"..filename,filename) 
        end
    end
elseif pocket then
    print("I'm a pocket pc!")
else
    print("I'm a desktop!")
end
print("Complete!")