-- Minearea - CC:Tweaked Turtle Mining Script
--
-- Provides minearea(pos1, pos2) to mine a rectangular volume.
--
-- Usage as program:
--   minearea <x1> <y1> <z1> <x2> <y2> <z2>
-- Usage as API:
--   local lib = require("minearea")
--   lib.minearea({x=0,y=0,z=0}, {x=10,y=5,z=10})
--
-- Coordinates are relative to the turtle's starting position and facing:
--   x = forward(+) / backward(-)
--   y = up(+) / down(-)
--   z = right(+) / left(-)

--==================================================================
-- State
--==================================================================

local pos = { x = 0, y = 0, z = 0 }
local facing = 0  -- 0=+x, 1=+z, 2=-x, 3=-z

local startPos  = { x = 0, y = 0, z = 0 }
local startFace = 0

--==================================================================
-- Direction helpers
--==================================================================

local dirVec = {
  [0] = { x =  1, z =  0 }, -- forward  (+x)
  [1] = { x =  0, z =  1 }, -- right    (+z)
  [2] = { x = -1, z =  0 }, -- backward (-x)
  [3] = { x =  0, z = -1 }, -- left     (-z)
}

local function turnTo(target)
  local diff = (target - facing) % 4
  if diff == 0 then
    return
  elseif diff == 1 then
    turtle.turnRight()
  elseif diff == 2 then
    turtle.turnRight()
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  facing = target
end

--==================================================================
-- Fuel
--==================================================================

local function needsFuel()
  local level = turtle.getFuelLevel()
  return type(level) == "number" and level == 0
end

local function refuel()
  for i = 1, 16 do
    turtle.select(i)
    if turtle.refuel(0) then
      turtle.refuel()
    end
  end
  turtle.select(1)
end

--==================================================================
-- Movement (digs through obstacles, handles falling gravel)
--==================================================================

local function moveForward()
  local retries = 0
  while not turtle.forward() do
    if turtle.detect() then
      turtle.dig()
    elseif needsFuel() then
      refuel()
      if needsFuel() then error("Out of fuel!") end
    elseif retries < 20 then
      sleep(0.5)
      retries = retries + 1
    else
      error("Path blocked by entity — aborting after 20 retries")
    end
  end
  local d = dirVec[facing]
  pos.x = pos.x + d.x
  pos.z = pos.z + d.z
end

local function moveUp()
  local retries = 0
  while not turtle.up() do
    if turtle.detectUp() then
      turtle.digUp()
    elseif needsFuel() then
      refuel()
      if needsFuel() then error("Out of fuel!") end
    elseif retries < 20 then
      sleep(0.5)
      retries = retries + 1
    else
      error("Blocked above — aborting after 20 retries")
    end
  end
  pos.y = pos.y + 1
end

local function moveDown()
  local retries = 0
  while not turtle.down() do
    if turtle.detectDown() then
      turtle.digDown()
    elseif needsFuel() then
      refuel()
      if needsFuel() then error("Out of fuel!") end
    elseif retries < 20 then
      sleep(0.5)
      retries = retries + 1
    else
      error("Blocked below — aborting after 20 retries")
    end
  end
  pos.y = pos.y - 1
end

--==================================================================
-- Navigation: go to an arbitrary relative position
--==================================================================

local function gotoPos(target)
  while pos.y < target.y do moveUp()   end
  while pos.y > target.y do moveDown() end

  if pos.x < target.x then
    turnTo(0)
    while pos.x < target.x do moveForward() end
  elseif pos.x > target.x then
    turnTo(2)
    while pos.x > target.x do moveForward() end
  end

  if pos.z < target.z then
    turnTo(1)
    while pos.z < target.z do moveForward() end
  elseif pos.z > target.z then
    turnTo(3)
    while pos.z > target.z do moveForward() end
  end
end

--==================================================================
-- Inventory
--==================================================================

local function inventoryFull()
  for i = 1, 16 do
    if turtle.getItemCount(i) == 0 then return false end
  end
  return true
end

--==================================================================
-- Core: mine a rectangular volume
--==================================================================

local function minearea(pos1, pos2)
  local minX = math.min(pos1.x, pos2.x)
  local maxX = math.max(pos1.x, pos2.x)
  local minY = math.min(pos1.y, pos2.y)
  local maxY = math.max(pos1.y, pos2.y)
  local minZ = math.min(pos1.z, pos2.z)
  local maxZ = math.max(pos1.z, pos2.z)

  local dims = {
    x = maxX - minX + 1,
    y = maxY - minY + 1,
    z = maxZ - minZ + 1,
  }
  local blocks = dims.x * dims.y * dims.z

  -- Save origin for the return trip
  startPos  = { x = pos.x, y = pos.y, z = pos.z }
  startFace = facing

  -- Fuel check
  refuel()
  local level = turtle.getFuelLevel()
  if type(level) == "number" then
    local travel  = math.abs(minX) + math.abs(minY) + math.abs(minZ)
    local estFuel = travel + blocks + travel -- to corner + mine + return
    if level < estFuel then
      print(("WARNING: fuel %d may be low (est. %d needed)."):format(level, estFuel))
    end
  end

  print(("Mining %d blocks (%dx%dx%d)...")
        :format(blocks, dims.x, dims.y, dims.z))

  -- Navigate to the bottom-front-left corner
  gotoPos({ x = minX, y = minY, z = minZ })

  -- Sweep layer by layer (y), row by row (x), zigzag along z
  for y = minY, maxY do
    for x = minX, maxX do
      local rowIdx = x - minX

      if rowIdx % 2 == 0 then
        turnTo(1) -- face +z
        while pos.z < maxZ do moveForward() end
      else
        turnTo(3) -- face -z
        while pos.z > minZ do moveForward() end
      end

      if inventoryFull() then
        print("WARNING: inventory full — mined blocks will be lost")
      end

      -- Step to the next x row (if not the last)
      if x < maxX then
        turnTo(0)
        moveForward()
      end
    end

    -- Ascend to the next layer (if not the last)
    if y < maxY then
      moveUp()
    end
  end

  -- Return to the starting position and orientation
  print("Mining complete. Returning to start...")
  gotoPos(startPos)
  turnTo(startFace)
  print("Done.")
end

--==================================================================
-- Direct execution  (minearea x1 y1 z1 x2 y2 z2)
--==================================================================

local args = { ... }

if #args >= 6 and tonumber(args[1]) then
  minearea(
    { x = tonumber(args[1]), y = tonumber(args[2]), z = tonumber(args[3]) },
    { x = tonumber(args[4]), y = tonumber(args[5]), z = tonumber(args[6]) }
  )
end

return { minearea = minearea }
