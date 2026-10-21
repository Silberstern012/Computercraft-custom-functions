-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
container = peripheral.wrap("front")
input = peripheral.wrap("back")

function run()
  while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "systemstart" then
      rednet.send(sender,"crafter","preload")
    end
    if protocol == "craftTask" then
      rednet.send(sender,craft(message),"taskFinish")
    end
  end  
end

function craft(layout)
  
  
end

run()