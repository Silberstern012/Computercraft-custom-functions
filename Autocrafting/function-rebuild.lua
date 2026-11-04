--Crafter--

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


--Crafter-old--

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