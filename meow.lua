f = require("functions")
tank = peripheral.find("dynamicValve")
monitor = peripheral.find("monitor")


run=false
oldTankValue = 0
newTankValue = 0
diffValue = 0
fV = ""

function data()
    while true do
        tank = peripheral.find("dynamicValve")
		if tank.isFormed() then
        	storedNow = tank.getStored().amount
        else
			storedNow = 0
		end		
		if run then 
            oldTankValue = newTankValue 
        else 
            oldTankValue = storedNow 
        end
        
        newTankValue = storedNow
        diffValue = newTankValue - oldTankValue
		run = true
		sleep(0.05)
    end
end

function draw()
    while true do
        monitor.setCursorPos(1,1)
        monitor.clear()
        monitor.write("Currently Stored: "..f.numberSpacing(newTankValue))
        monitor.setCursorPos(1,2)
        monitor.write("Diff Val: "..diffValue)
		sleep(0.05)
    end
end

parallel.waitForAll(data,draw)