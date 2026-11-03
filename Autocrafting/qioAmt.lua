-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
qior = peripheral.wrap("left")

updating = false

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"qioAmt","preload")
    end
    if protocol == "task" then
      rednet.send(sender,getAmt(message),"taskFinish")
    end
  end  
end

function getAmt(item)
  local currentVal = 0
  local cVal = false
  local lastcVal = false
  local active = false
  local state = false
  local vals = {500, 250, 125, 60, 30, 15, 6, 3, 1}
  qior.clearTargetItem()
  qior.setTriggerAmount(0)
  qior.setTargetItem(item)
  if not qio.isInverted then qio.invertSignal() inverted = qio.isInverted() end
  active = true
  
  tryVal(currentVal)
  if not tryVal(currentVal + 1) and lastVal<=1 then return 0 end
    
  while not tryVal(currentVal) do
    lastVal = currentVal
    currentVal = currentVal + 1000
  end  
  
  for _,val in ipairs(vals) do
    if redstone.getAnalogInput("bottom")==13 then
      currentVal=currentVal-val
      tryVal(currentVal)
    else  
      currentVal=currentVal+val
      tryVal(currentval)
    end  
  end  
  
  if redstone.getAnalogInput("bottom")==13 then state = true else state = false end
  while active do
    lastcVal = cVal
    if not state then
      currentVal = currentVal+1
      cval = tryVal(currentVal)
      if lastcVal == not cVal then active = false return currentVal end
    else
      currentVal = currentVal-1
      cval = tryVal(currentVal)
      if lastcVal == not cVal then active = false return currentVal+1 end
    end
  end  
end  
  
  

function tryVal(val)
  qio.setTriggerAmount(val)
  sleep(0.3)
  if redstone.getAnalogInput("bottom") == 13 then return true else return false end
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