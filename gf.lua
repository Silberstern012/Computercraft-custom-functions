--by Silberstern012 (Silver)
args = {...}

functions = peripheral.getMethods(peripherals.getName(peripheral.wrap(args[1])))
file = fs.open("functions.txt","w+")

for i,fun in ipairs(functions) do
    file.writeLine(fun)
end
file.close()
