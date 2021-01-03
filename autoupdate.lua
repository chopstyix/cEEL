local ignore = { 
    disk = true,
    rom = true
}

shell.run("github","chopstyix","cEEL")
print("Detecting source...")

if turtle then
    print("I'm a turtle!")
    for _,filename in fs.list("")
        if not ignore[filename] then
            fs.copy("downloads/cEEL/cTurtle/"..filename,filename) 
        end
    end
    shell.run("move","/download/cEEL","")
elseif pocket then
    print("I'm a pocket pc!")
else
    print("I'm a desktop!")
end
print("Complete!")