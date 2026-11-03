-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
container = peripheral.wrap("left")

syscn = nil 
updating = false

outputs = {}
importer = {}
exporter = {}

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"collector","preload")
    elseif protocol == "collectTask" then
      rednet.send(sender,collect(message),"taskFinish")
    elseif protocol == "number" then
      syscn = message   
    end
  end  
end

function collectNeededPeripherals()
  outputs = {peripheral.find("minecraft:chest")}
  importer = {peripheral.find("mekanism:qio_importer")}
  exporter = {peripheral.find("mekanism:qio_exporter")}
  
  table.sort(outputs,numericSort)
  table.sort(importer,numericSort)
  table.sort(exporter,numericSort)
end

function collect(list)
  local id = list.id
  local itemName = list.name
  local itemAmount = list.amount
  local outputChest = list.output
  local targetAmount = 0
  
  qio.addFilter(itemName)
  
  while not targetAmount >= itemAmount do
    local currentAmount = 0
    for _,item in pairs(container.list()) do
      currentAmount = currentAmount + item.count
    end
    targetAmount = currentAmount
  end
  
  qio.removeFilter(itemName)
  
  for _,output in pairs(outputs) do
    if peripheral.getName(outputChest) == peripheral.getName(output) then
      for slot=1, container.size() do
        container.pushItems(peripheral.getName(output),slot)
      end
    end
  end
  return true
end  

function numericSort(a,b)
  local nameA = type(a) == "string" and a or tostring(a or "")
  local nameB = type(b) == "string" and b or tostring(b or "")
  local nA = tonumber(nameA:match("_(%d+)$")) or 0
  local nB = tonumber(nameB:match("_(%d+)$")) or 0
  return nA < nB
end  
  
function UPDATE()
  while true do 
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "update" then
      if not fs.exists("update.lua") then
        updF = fs.open("update.lua","w")
        updF.writeLine('shell.run("delete","startup.lua")')
        updF.writeLine('shell.run("wget","https://raw.githubusercontent.com/Silberstern012/Computercraft-custom-functions/refs/heads/main/Autocrafting/itemCollector.lua","startup.lua")')
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
    if not updating then term.write("itemCollector  ---  by Silver")
    elseif updating and ctr<5 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<10 then term.write("Updating /") ctr = ctr +1
    elseif updating and ctr<15 then term.write("Updating -") ctr = ctr +1
    elseif updating and ctr<20 then term.write("Updating |") ctr = ctr +1
    elseif updating and ctr<25 then term.write("Updating \\") ctr = ctr +1
    elseif ctr>=30 then ctr = 0
    end
    sleep(1)
  end
end

parallel.waitForAll(collectNeededPeripherals,run,UPDATE,vis)