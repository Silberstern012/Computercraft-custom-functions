-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
output = peripheral.find("sophisticatedstorage:chest")
input = peripheral.wrap("back")

currentName = peripheral.wrap("bottom").getNameLocal()
updating = false
called = false

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"crafter","preload")
      called = true
    elseif protocol == "craftTask" then
      rednet.send(sender,craft(message),"taskFinish_crafter")
    end
  end  
end

function craft(msg)
  local recipe = msg.recipe
  local amount = msg.amt
  local items = msg.items
  local slots = {1,2,3,5,6,7,9,10,11}
  
  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end

    for i=1,16 do output.pullItems(currentName,i,64) end

  local itemsCollected = false
  while not itemsCollected do
    local iic = {}
    for _,item in pairs(input.list()) do
      iic[item.name] = (iic[item.name] or 0) + item.count
    end
    
    itemsCollected = true
    for _,item in pairs(items) do
      if iic[item.name] or 0 < item.count then itemsCollected = false end
    end
  end

  for i,rslot in ipairs(recipe) do
    local itemamt = amount
    for c=1, input.size() do
      itemDetail = input.getItemDetail(c)
      if itemDetail then
        if itemDetail.name == rslot then
          input.pushItems(currentName, c, itemamt, slots[i])
          itemamt = itemamt - itemDetail.amount
        end
      end
    end
  end

  turtle.craft(amt)
  sleep(0.5)
  for i=1,16 do 
    output.pullItems(currentName,i,64)
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