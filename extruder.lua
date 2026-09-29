local output1 = "sophisticatedstorage:chest_1"
local output2 = "sophisticatedstorage:chest_2"
local output3 = "sophisticatedstorage:chest_3"
local output4 = "sophisticatedstorage:chest_4"

local extruders = {}
for _, name in ipairs(peripheral.getNames()) do
  if peripheral.getType(name) == "create_mechanical_extruder:mechanical_extruder" then
    extruders[#extruders+1] = name
  end
end

print("Loaded "..#extruders)

local list1, list2, list3, list4 = {}, {}, {}, {}
for i, name in ipairs(extruders) do
  if i % 4 == 0 then list1[#list1+1] = name
  elseif i % 4 == 1 then list2[#list2+1] = name
  elseif i % 4 == 2 then list3[#list3+1] = name
  else list4[#list4+1] = name
  end
end

local function run(list, out)
  while true do
    for i=1, #list do
      peripheral.call(list[i], "pushItems", out, 1, 64)
    end
    os.queueEvent("a") os.pullEvent("a")
  end
end

parallel.waitForAll(
  function() run(list1,output1) end,
  function() run(list2,output2) end,
  function() run(list3,output3) end,
  function() run(list4,output4) end
)