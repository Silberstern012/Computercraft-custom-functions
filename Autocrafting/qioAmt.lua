-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
qio = peripheral.find("qioRedstoneAdapter")

updating = false
called = false

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"qioAmt","preload")
      called = true
    end
    if protocol == "task" then
      rednet.send(sender,{message,getAmt(message)},"taskFinish_amt")
    end
  end  
end


function getAmt(item)
    local val = 0
    local out = 0
    local lastval = val
    local vals = {500, 250, 125, 50, 25, 15, 10, 5, 3, 2, 1}

    qio.clearTargetItem()
    qio.setTriggerAmount(0)
    qio.setTargetItem(item)

    if not qio.isInverted() then qio.invertSignal() end
    if checkR(0) then out = 0 goto exit_getAmt end
    
    if checkR(1) then out = 0 goto exit_getAmt
    elseif checkR(2) then out = 1 goto exit_getAmt
    elseif checkR(3) then out = 2 goto exit_getAmt
    elseif checkR(4) then out = 3 goto exit_getAmt
    end

    while not checkR(val) do
        val = val+1000
    end

    for _,v in ipairs(vals) do
        if checkR(val) then
            val = val-v
        else
            val = val+v
        end
    end

    
    laststate = checkR(val)
    counter = 0
    while true do
        if not laststate == checkR(val) or counter>200 then 
            if laststate then
                out = val
                goto exit_getAmt
            else
                out = lastval
                goto exit_getAmt
            end
        end

        lastval = val
        if checkR(val) then
            val = val-1
            laststate=true
        else
            val = val+1
        end
        counter=counter+1
    end

    ::exit_getAmt::
    qio.clearTargetItem()
    qio.setTriggerAmount(0)
    if qio.isInverted() then qio.invertSignal() end
    return out
end

function checkR(value)
    if value then qio.setTriggerAmount(value) end
    sleep(0.3)
    if redstone.getAnalogInput("bottom") >= 13 then return true else return false end
end


function UPDATE()
  while true do 
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "update" then
      if not fs.exists("update.lua") then
        updF = fs.open("update.lua","w")
        updF.writeLine('shell.run("delete","startup.lua")')
        updF.writeLine('shell.run("wget","https://raw.githubusercontent.com/Silberstern012/Computercraft-custom-functions/refs/heads/main/Autocrafting/qioAmt.lua","startup.lua")')
        updF.close()
      end
      updating = true
      shell.run("update")
      sleep(1)
      os.reboot()
    end
  end
end

function vis()
  local ctr = 0
  while true do
    term.clear()
    term.setCursorPos(2,2)
    if not updating then term.write("qioAmt  ---  by Silver")
      term.setCursorPos(2,4)
      term.write("Called: "..tostring(called))
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

parallel.waitForAll(run,UPDATE,vis)