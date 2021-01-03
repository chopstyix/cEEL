ignore = { 
    disk = true,
    rom = true
}

shell.run("github","chopstyix","cEEL")
print("Detecting source...")

if turtle then
    print("I'm a turtle!")
    for _,filename in fs.list("") do
        if not ignore[filename] then
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