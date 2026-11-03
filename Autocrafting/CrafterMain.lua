-- by Silberstern012 (Silver)

peripheral.find("modem", rednet.open)

computers = {}
updating = false

shell.run("delete", "crafting-recipes.json")
shell.run("wget", "https://raw.githubusercontent.com/Silberstern012/Computercraft-custom-functions/refs/heads/main/Autocrafting/crafting-recipes.json")


local jfile = fs.open("crafting-recipes.json", "r")
if not jfile then error("json file not found") end

local sjson = jfile.readAll()
jfile.close()

local data = textutils.unserialiseJSON(sjson)

--for item in pairs(data) do
--    print(item)
--end    
ended = false

function run()
    rednet.broadcast("preload","systemstart")
    while not ended do
        local event, sender, message, protocol = os.pullEvent("rednet_message")
        local message = tostring(message)
        if protocoll == "preload" then
            computers[message] = computer[message] or {}
            computers[message][#computers[message]+1]=sender
        end
    end    
end

function timr()
    sleep(3)
end
parallel.waitForAny(timr,run)

qiolocalData = data
qiousedData = {}
qiocollectors = computers.qioAmt
qiouCollectors = {}





function mainCrafter()
    while true do



    end
end

function mainCollector()
    while true do



    end
end

function mainQIOCollector()
    while true do
        for i,collector in ipairs(qiocollectors) do
            qioucollector[i] = collector
            rednet.send(collector, qiolocalData[#qiolocalData].name, "task")
            usedData[#qiousedData+1] = localData[#qiolocalData]
            table.remove(#qiolocalData)
            qiocollectors[i] = nil
        end
    end
end

function UPDATE()
    rednet.broadcast("update","update")
    if not fs.exists("update.lua") then
        updF = fs.open("update.lua","w")
        updF.writeLine('shell.run("delete","startup.lua")')
        updF.writeLine('shell.run("wget","https://raw.githubusercontent.com/Silberstern012/Computercraft-custom-functions/refs/heads/main/Autocrafting/CrafterMain.lua","startup.lua")')
        updF.close()
    end
    updating = true
    shell.run("update")
    sleep(1)
    os.reboot()
end

function upd() 
    while true do
        if redstone.getAnalogInput("right") >= 1 then
            print("Updating")
            UPDATE()
        end
        sleep(0.05)
    end
end

function vis()
  local ctr = 0
  while true do
    term.clear()
    term.setCursorPos(2,2)
    if not updating then term.write("CrafterMain  ---  by Silver")
    elseif updating and ctr<5 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<10 then term.write("Updating /") ctr = ctr +1
    elseif updating and ctr<15 then term.write("Updating -") ctr = ctr +1
    elseif updating and ctr<20 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<25 then term.write("Updating \\") ctr = ctr +1
    elseif ctr>=30 then ctr = 0
    end
    sleep(0.1)
  end
end

parallel.waitForAll(upd,vis)