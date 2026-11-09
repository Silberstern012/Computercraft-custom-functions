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


function run()
    rednet.broadcast("preload","systemstart")
    while true do
        local event, sender, message, protocol = os.pullEvent("rednet_message")
        local message = tostring(message)
        if protocol == "preload" then
            --print("connected: "..message)
            computers[message] = computers[message] or {}
            computers[message][#computers[message]+1]=sender
        end
    end    
end

function timr()
    sleep(3)
end
parallel.waitForAny(timr,run)

table.sort(computers["qioAmt"],numericSort)
table.sort(computers["collector"],numericSort)
table.sort(computers["crafter"],numericSort)


items = {}
runcomputers = {}
usecomputers = computers

runcomputers["qioAmt"] = {}
runcomputers["collector"] = {}
runcomputers["crafter"] = {}


for number,computer in ipairs(computers["collector"]) do
    rednet.send(computer, number, "number")
end

function rec()
    while true do
        local event, sender, message, protocol = os.pullEvent("rednet_message")
        if protocol == "taskFinish_amt" then
            print(message)
            --for i,k in pairs(message) do print(k) end
            items[message[1]] = message[2]
            for pos,id in ipairs(runcomputers["qioAmt"]) do
                if id == sender then table.remove(runcomputers["qioAmt"],pos) end
            end
            usecomputers["qioAmt"][#usecomputers["qioAmt"]+1] = message
        
        elseif protocol == "taskFinish_collect" then
            for pos,id in ipairs(runcomputers["collector"]) do
                if id == sender then table.remove(runcomputers["collector"],pos) end
            end
            usecomputers["collector"][#usecomputers["collector"]+1] = message
        elseif protocol == "taskFinish_crafter" then
            for pos,id in ipairs(runcomputers["crafter"]) do
                if id == sender then table.remove(runcomputers["crafter"],pos) end
            end
            usecomputers["crafter"][#usecomputers["crafter"]+1] = message    
        end
    end
end

function qioScan()
    for count, itemData in pairs(data) do
        print(itemData.name)
        local assigned = false
        while not assigned do
            for i,qioA in pairs(usecomputers["qioAmt"]) do
                table.insert(runcomputers["qioAmt"],1,qioA)
                table.remove(usecomputers["qioAmt"],i)
                rednet.send(qioA, itemData.name, "task")
                assigned = true
                goto end_qioScan
            end
            sleep(0.1)
            ::end_qioScan::
        end
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

function numericSort(a,b)
    local nameA = type(a) == "string" and a or tostring(a or "")
    local nameB = type(b) == "string" and b or tostring(b or "")
    local nA = tonumber(nameA:match("_(%d+)$")) or 0
    local nB = tonumber(nameB:match("_(%d+)$")) or 0
    return nA < nB
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
        sleep(0.1)
    end
end

function vis()
  local ctr = 0
  while true do
    term.clear()
    term.setCursorPos(2,2)
    if not updating then term.write("CrafterMain  ---  by Silver")
        term.setCursorPos(2,4)
        term.write("Connected Devices:")
        term.setCursorPos(3,5)
        --for device in pairs(computers) do print(device) print() end
        term.write("qioAmt:     "..#computers.qioAmt)
        term.setCursorPos(3,6)
        term.write("Crafter:    "..#computers.crafter)
        term.setCursorPos(3,7)
        term.write("Collectors: "..#computers.collector)
    elseif updating and ctr<1 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<2 then term.write("Updating /") ctr = ctr +1
    elseif updating and ctr<3 then term.write("Updating -") ctr = ctr +1
    elseif updating and ctr<4 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<5 then term.write("Updating \\") ctr = ctr +1
    elseif ctr>=6 then ctr = 0
    end
    sleep(0.5)
  end
end
s,e=pcall(function()
parallel.waitForAll(rec,qioScan,upd)
end)
term.clear()
term.setCursorPos(1,1)
print("Failed because:")
print(e)
sleep(3)
os.reboot()
