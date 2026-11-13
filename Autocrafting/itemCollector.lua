-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)


sysnum = nil 
updating = false
called = false

outputs = {}
importer = {}
exporter = {}

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"collector","preload")
      called = true
    elseif protocol == "collectTask" then
      rednet.send(sender,collect(message),"taskFinish_collect")
    elseif protocol == "number" then
      sysnum = message
      cnp()
    end
  end  
end

function cnp()
    container = {}
    outputs = {}
    exporter = {}
    importer = {}


    local names = peripheral.getNames()
    for _, p in ipairs(names) do
        if p:find("qioExporter") then
            table.insert(exporter,p)
        elseif p:find("qioImporter") then
            table.insert(importer,p)
        elseif p:find("minecraft:chest") then
            table.insert(outputs,p)
        elseif p:find("vault") then
            table.insert(container,p)
        end
    end
    table.sort(container,numericSort)
    table.sort(outputs,numericSort)
    table.sort(importer,numericSort)
    table.sort(exporter,numericSort)
    
    container = peripheral.wrap(container[sysnum])
    imp = peripheral.wrap(importer[sysnum])
    qio = peripheral.wrap(exporter[sysnum])
end
itemname = nil
function collect(details)
    local itemname = details.name
    local itemamt = details.amt
    local output = details.out
    
    local filter = {enabled = true, fuzzy = false, item = itemname,type = "QIO_ITEMSTACK_FILTER"}
    
    imp.setImportsWithoutFilter(false)

    qio.addFilter(filter)

    local containeria = 0
    while containeria < itemamt do
        containeria = 0
        for _,itm in pairs(container.list()) do
            containeria=containeria+itm.count
        end
        sleep(0.1)
    end

    for _,filt in ipairs(qio.getFilters()) do
        qio.removeFilter(filt)
    end

    for slot=1, container.size() do
        local item = container.getItemDetail(slot)
        if item and item.name == itemname then
            container.pushItems(outputs[output],slot,itemamt)
            itemamt=itemamt-64
        end
    end

    imp.setImportsWithoutFilter(true)
    itemname = nil
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
      term.setCursorPos(2,4)
      term.write("Called: "..tostring(called))
      term.setCursorPos(2,5)
      term.write("Item: "..tostring(itemname))
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

for _,p in ipairs({peripheral.find("minecraft:chest")}) do print(peripheral.getName(p)) end