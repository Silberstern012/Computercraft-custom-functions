-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
container = peripheral.wrap("left")

syscn = nil 


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
      for slot=1 container.size() do
        container.pushItems(peripheral.getName(output),slot)
      end
    end
  end
  return true
end  

function numericSort(a,b)
  local nA = tonumber(a:match("_(%d+)$")) or 0
  local nB = tonumber(b:match("_(%d+)$")) or 0
  return nA < nB
end  
  
parralel.waitForAll(collectNeededPeripherals,run)