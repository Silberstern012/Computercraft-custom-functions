-- by Silberstern012 (Silver)
modem = peripheral.find("modem",rednet.open)
miner = peripheral.wrap("bottom")

while true do
    local mamt = miner.getToMine()
    if mamt > 0 then
        rednet.broadcast("stop","mnr")
    else
        rednet.broadcast("run","mnr")
    end
    sleep(0.1)
end
