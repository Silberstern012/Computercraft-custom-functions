-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
output = peripheral.wrap("front")
input = peripheral.wrap("back")

currentName = modem.getNameLocal()

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

run()