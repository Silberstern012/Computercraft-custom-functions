--[[
by Silver :3
This is completely built by Silver (me)
(I hate it if someone uses AI for coding)
i just wanted to rebuild it, and tried 
to make it smaller and kinda fix it
]]

--functions in multiple parts used--

function numericSort(a,b)
  local nameA = type(a) == "string" and a or tostring(a or "")
  local nameB = type(b) == "string" and b or tostring(b or "")
  local nA = tonumber(nameA:match("_(%d+)$")) or 0
  local nB = tonumber(nameB:match("_(%d+)$")) or 0
  return nA < nB
end

--qioAmt--

function getAmt(item)
    local val = 0
    local out = 0
    local lastval = val
    local vals = {500, 250, 125, 50, 25, 15, 10, 5, 3, 2, 1}

    qio.clearTargetItem()
    qio.setTriggerAmount(0)
    qio.setTargetItem(item)

    if not qio.isInverted() then qio.invertSignal() end
    if checkR() then return 0 end
    
    if checkR(1) then return 0
    elseif checkR(2) then return 1
    elseif checkR(3) then return 2 
    elseif checkR(4) then return 3
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

    local laststate = checkR(val)
    while true do
        if not laststate == checkR(val) then 
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
    end

    ::exit_getAmt::
    return out
end

function checkR(value)
    if value then qio.setTriggerAmount(value) end
    sleep(0.3)
    if redstone.getAnalogInput("bottom") == 13 then return true else return false end
end


--qioAmt-old--

function getAmt(item)
  local lastVal = 0
  local currentVal = 0
  local cVal = false
  local lastcVal = false  
  local active = false
  local state = false
  local vals = {500, 250, 125, 60, 30, 15, 6, 3, 1}
  qior.clearTargetItem()
  qior.setTriggerAmount(0)
  qior.setTargetItem(item)
  if not qior.isInverted() then qior.invertSignal() inverted = qior.isInverted() end
  active = true
  
  tryVal(currentVal)
  if tryVal(1) then return 1 end

  while not tryVal(currentVal) do
    --lastVal = currentVal
    currentVal = currentVal + 1000
  end  
  
  for _,val in ipairs(vals) do
    if redstone.getAnalogInput("bottom")==13 then
      currentVal=currentVal-val
      tryVal(currentVal)
    else  
      currentVal=currentVal+val
      tryVal(currentVal)
    end  
  end  
  
  if redstone.getAnalogInput("bottom")==13 then state = true else state = false end
  cVal = state
  while active do
    lastcVal = cVal
    if not state then
      currentVal = currentVal+1
      cVal = tryVal(currentVal)
      if lastcVal == not cVal then active = false return currentVal end
    else
      currentVal = currentVal-1
      cVal = tryVal(currentVal)
      if lastcVal == not cVal then active = false return currentVal+1 end
    end
  end  
end  
  
  

function tryVal(val)
  qior.setTriggerAmount(val)
  sleep(0.3)
  if redstone.getAnalogInput("bottom") == 13 then return true else return false end
end

--itemCollector--

function cnp()
    outputs = {peripheral.find("minecraft:chest")}
    importer = {peripheral.find("mekanism:qio_importer")}
    exporter = {peripheral.find("mekanism:qio_exporter")}
  
    for i,output in ipairs(outputs) do outputs[i]=peripheral.getName(output) end 
    for i,import in ipairs(importer) do importer[i]=peripheral.getName(import) end
    for i,export in ipairs(exporter) do exporter[i]=peripheral.getName(export) end

    table.sort(outputs,numericSort)
    table.sort(importer,numericSort)
    table.sort(exporter,numericSort)

    imp = peripheral.find(importer[sysnum])
    qio = peripheral.find(exporter[sysnum])
end

function collectItem(details)
    local itemname = details.name
    local itemamt = details.amt
    local output = details.out
    
    local filter = {enabled = true, fuzzy = false, item = itemname,type = "QIO_ITEMSTACK_FILTER"}
    
    imp.setImportWithoutFilter(false)

    exp.addFilter(filter)

    local containeria = 0
    while containeria < itemamt do
        containeria = 0
        for _,itm in ipairs(container.list()) do
            containeria=containeria+itm.count
        end
    end

    for _,filt in ipairs(qio.getFilters()) do
        qio.removeFilter(filt)
    end

    for slot=1, container.size() do
        if container.getItemDetail(slot) == itemname then
            container.pushItems(outputs[output],slot,itemamt)
            itemamt=itemamt-64
        end
    end

    imp.setImportWithoutFilter(true)
end

--itemCollector-old--

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

--Crafter--

function craft(msg)
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
      iic.[item.name] = (iic[item.name] or 0) + item.count
    end
    
    itemsCollected = true
    for _,item in pairs(items) do
      if iic.[item.name] or 0 < item.amount then itemsCollected = false end
    end
  end

  for i,rslot in ipairs(recipe) do
    local itemamt = amount
    for c=1, input.size() do
      if input.getItemDetail(c).name == rslot then
        input.pushItems(currentName, c, itemamt, slots[i])
        itemamt = itemamt - input.getItemDetail(c).amount
      end
    end
  end

  turtle.craft(amt)

  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end
end

--Crafter--07.11.26--

function craft(msg)
  local recipe = msg.recipe
  local amount = msg.amt
  local slots = {1,2,3,5,6,7,9,10,11}

  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end

  for i,rslot in ipairs(reciepe) do
    local itemamt = amt
    for c=1, input.size() do
      if input.getItemDetail(c).name == rslot then
        input.pushItems(currentName, c, itemamt, slots[i])
        itemamt = itemamt - input.getItemDetail(c).amount
      end
    end
  end

  turtle.craft(amt)

  for i=1,16 do 
    output.pullItems(currentName,i,64)
  end
end


--Crafter-old--

function craft(msg)
  local rshape = nil
  recipe = msg.recipe
  
  for slot,item in ipairs(recipe) do
    for cslot=1,input.size() do
      item = input.getItemDetail(cslot)
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