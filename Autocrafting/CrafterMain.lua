-- by Silberstern012 (Silver)

peripheral.find("modem", rednet.open)

computers = {}


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

local timer_id = os.startTimer(3)
function tr()
    local event, id
    repeat
        event, id = os.pullEvent("timer")
    until id == timer_id
    ended = true
end
parallel.waitForAll(tr,run)

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

