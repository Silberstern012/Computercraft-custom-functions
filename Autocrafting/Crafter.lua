-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
output = peripheral.wrap("front")
input = peripheral.wrap("back")

currentName = modem.getNameLocal()
updating = false

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"crafter","preload")
    elseif protocol == "craftTask" then
      rednet.send(sender,craft(message),"taskFinish")
    end
  end  
end

function craft(msg)
  local rshape = nil
  recipe = msg.recipe
  
  for slot,item in ipairs(recipe) do
    for cslot, citem in ipairs(input.size()) do
      if item == citem then
        input.pushItems(currentName,64,slot)
      end
      goto nslot
    end
    ::nslot::
  end
  turtle.craft(64)
  for i=1,16 do
    output.pullItems(currentName,i)
  end
end

function UPDATE()
  while true do 
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "update" then
      if not fs.exists("update.lua") then
        updF = fs.open("update.lua","w")
        updF.writeLine('shell.run("delete","startup.lua")')
        updF.writeLine('shell.run("wget","https://raw.githubusercontent.com/Silberstern012/Computercraft-custom-functions/refs/heads/main/Autocrafting/Crafter.lua","startup.lua")')
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
    if not updating then term.write("Crafter  ---  by Silver")
    elseif updating and ctr<5 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<10 then term.write("Updating /") ctr = ctr +1
    elseif updating and ctr<15 then term.write("Updating -") ctr = ctr +1
    elseif updating and ctr<20 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<25 then term.write("Updating \\") ctr = ctr +1
    elseif ctr>=30 then ctr = 0
    end
  end
end

parallel.waitForAll(run,Update,vis)