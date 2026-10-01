local monitor = peripheral.find("monitor")
if monitor then
  monitor.clear()
  monitor.setTextScale(0.5)
  monitor.setCursorPos(1,1)
end

local outputs = {}
local extruders = {}
for _, name in ipairs(peripheral.getNames()) do
  if peripheral.getType(name) == "create_mechanical_extruder:mechanical_extruder" then
    extruders[#extruders+1] = name
  elseif peripheral.getType(name) == "sophisticatedstorage:chest" then
    outputs[#outputs+1] = name
  end
end

print("Loaded "..#extruders)


local output1, output2, output3, output4 = "", "", "", ""
for amt, name in ipairs(outputs) do
  if amt % 4 == 0 then output1 = name
  elseif amt % 4 == 1 then output2 = name
  elseif amt % 4 == 2 then output3 = name
  else output4 = name
  end
end

local list1, list2, list3, list4 = {}, {}, {}, {}
for i, name in ipairs(extruders) do
  if i % 4 == 0 then list1[#list1+1] = name
  elseif i % 4 == 1 then list2[#list2+1] = name
  elseif i % 4 == 2 then list3[#list3+1] = name
  else list4[#list4+1] = name
  end
end

local ipm = 0

local function run(list, out)
  while true do
    for i=1, #list do
      inv = peripheral.call(list[i], "getItemDetail", 1)
      if inv then ipm = ipm + inv.count end
      peripheral.call(list[i], "pushItems", out, 1, 64)
    end
    os.queueEvent("a") os.pullEvent("a")
  end
end

print(#list1)
print(#list2)
print(#list3)
print(#list4)


local function tmr_ipm()
  while true do
    if os.date("%S") == "00" or os.date("%S") == "15" or os.date("%S") == "30" or os.date("%S") == "45" then
      fipm = ipm*4
      monitor.clear()
      monitor.setCursorPos(1,1)

      monitor.write("Items per")
      monitor.setCursorPos(1,2)
      monitor.write("Second: "..math.floor(fipm/60))
      monitor.setCursorPos(1,3)
      monitor.write("Minute: "..fipm)
      monitor.setCursorPos(1,4)
      monitor.write("Hour: "..math.floor(fipm*60))

      ipm = 0
    end
    os.sleep(1)
  end
end

parallel.waitForAll(
  function() run(list1,output1) end,
  function() run(list2,output2) end,
  function() run(list3,output3) end,
  function() run(list4,output4) end,
  tmr_ipm
)
