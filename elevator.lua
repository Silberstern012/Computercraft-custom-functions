f = require("functions")
elevator = peripheral.find("Create_ElevatorPulley")

coordx1 = -3026
coordx2 = -3023
coordz1 = -9694
coordz2 = -9691

t = os.startTimer(1)
tu = false
arrived = false
function wait() 
    while true do
        local event, id = os.pullEvent()
        if event == "timer" and id == t then
            tu = true  
            print("Timer up")      
        end
    end
end

function arrival() 
    while true do
        if elevator.isArrived() then
            if arrived == false then
                t = os.startTimer(3)
                arrived = true
            end
        end
        os.sleep(0.5)
    end
end

function main()
    while true do
        floors = elevator.getFloors()
        floory = {}
        for amt, floor in pairs(floors) do
            floory[amt] = floor.y
        end
        rpd = f.getPlayerData()
        if rpd then
            status, err = pcall(function()
            playerData = textutils.unserialiseJSON(rpd)
            for pamt, player in ipairs(playerData.players) do
                for famt, floorypos in pairs(floory) do
                    floorypos2 = floorypos + 5
                    if arrived and tu and not elevator.getCurrentY() == floorypos and f.isInArea(player.position.x, player.position.y, player.position.z,coordx1,floorypos,coordz1,coordx2,floorypos2,coordz2) then
                        elevator.setTargetFloor(floorypos)
                        arrived = false
                        print("Next Floor: "..floorypos)
                    end
                end
            end
            end)
        end
        if err then print(err) print(rpd) end
        os.sleep(1)
    end
end

parallel.waitForAll(main,arrival,wait)
