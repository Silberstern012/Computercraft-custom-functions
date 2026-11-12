-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
output = peripheral.find("sophisticatedstorage:chest")
chests = {peripheral.find("minecraft:chest")}
for i,chest in ipairs(chests) do if peripheral.getName(chest) == "back" then table.remove(chests,i) end end
input = nil

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
    elseif protocol == "number" then
      chestNames = {}
      for i,chest in ipairs(chests) do
        chestNames[#chestNames+1]=peripheral.getName(chest)
      end
      table.sort(chestNames, numericSort)
      inputChest = chestNames[message]
      for c,chst in ipairs(chests) do
        if inputChest == peripheral.getName(chst) then input = chst end
      end
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

itemsNeeded = {}
itc = "none"
function craft(msg)
  itc = msg.itemtocraft
  local recipe = msg.recipe
  local amount = msg.amt
  local items = msg.items
  local slots = {1,2,3,5,6,7,9,10,11}
  
  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end

  local itemsCollected = false
  while not itemsCollected do
    local iic = {}
    for _,item in pairs(input.list()) do
      iic[item.name] = (iic[item.name] or 0) + item.count
    end
    itemsNeeded = {}
    itemsCollected = true
    for _,item in pairs(items) do
      local have = iic[item.name] or 0
      if have < item.count then
        itemsCollected = false
        itemsNeeded[item.name] = {name=item.name,cnt=item.count-have}
      end
    end
    sleep(0.1)
  end

  for i,rslot in ipairs(recipe) do
    local itemamt = amount
    for c=1, input.size() do
      itemDetail = input.getItemDetail(c)
      if itemDetail then
        if itemDetail.name == rslot then
          input.pushItems(currentName, c, itemamt, slots[i])
          itemamt = itemamt - itemDetail.count
        end
      end
    end
  end

  turtle.craft(amt)
  sleep(0.5)
  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end
  itemsNeeded = {}
  itc = "none"
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
      term.setCursorPos(2,5)
      inName = "none"
      if input then inName = peripheral.getName(input) end 
      term.write("Input: "..inName)
      term.setCursorPos(2,6)
      term.write("Current Item: "..tostring(itc))
      term.setCursorPos(2,8)
      term.write("Needed Items:")
      cnt=1
      for i, itm in pairs(itemsNeeded) do
        term.setCursorPos(2,8+cnt)
        term.write(itm.name.." "..itm.cnt)
        cnt=cnt+1
      end
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