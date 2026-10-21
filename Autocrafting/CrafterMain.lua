

peripheral.find("modem", rednet.open)
preload = false

computers = {}


--os.run("delete", "cr.json")
--os.run("wget", "raw.git//Crafter/cr.json"


local jfile = fs.open("cr.json", "r")
if not jfile then error("json file not found") end

local sjson = jfile.readAll()
jfile.close()

local data = textutils.unserialiseJSON(sjson)

--for item in pairs(data) do
--    print(item)
--end    


function RX()
    while true do
        local event, sender, message, protocol = os.pullEvent("rednet_message")
        local message = tostring(message)
        if protocoll == "preload" then
            computers[message] = computer[message] or {}
            computers[message][#computers[message]+1]=sender
            goto endRX_ns
        end
        print(1)
        
        
        
        ::endRX::
        os.sleep(0.01)
        ::endRX_ns::
    end    
end

function TX()
    rednet.broadcast("preload","systemstart")
    while true do
        os.sleep(0.01)
    end    
end    

parallel.waitForAll(RX,TX)