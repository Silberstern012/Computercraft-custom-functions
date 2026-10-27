-- by Silberstern012 (Silver)

modem = peripheral.find("modem", rednet.open)
output = peripheral.wrap("front")
input = peripheral.wrap("back")

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
  reciepe = msg.reciepe
  amt = msg.amt
  
  for slot,item in ipairs(reciepe)


end

run()