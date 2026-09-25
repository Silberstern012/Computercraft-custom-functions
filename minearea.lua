-- Minearea - CC:Tweaked Turtle Mining Script
--
-- Provides minearea(pos1, pos2) to mine a rectangular volume.
--
-- Usage as program:
--   minearea <x1> <y1> <z1> <x2> <y2> <z2>
-- Usage as API:
--   local lib = require("minearea")
--   lib.minearea({x=10,y=64,z=-20}, {x=20,y=69,z=-10})
--
-- When GPS is available (modem equipped + GPS hosts in range):
--   Coordinates are ABSOLUTE WORLD coordinates.
--   The turtle gets its position via gps.locate() and detects its
--   facing by probing one block forward.
--
-- When GPS is NOT available:
--   Coordinates are RELATIVE to the turtle's starting position.
--   The turtle assumes it faces +x (forward) at startup.
--   x = forward(+) / backward(-)
--   y = up(+) / down(-)
--   z = right(+) / left(-)

--==================================================================
-- State
--==================================================================

local pos        = { x = 0, y = 0, z = 0 }
local facing     = 0  -- 0=+x, 1=+z, 2=-x, 3=-z
local gpsMode    = true
local startPos   = { x = 0, y = 0, z = 0 }
local startFace  = 0

--==================================================================
-- Direction helpers
--==================================================================

local dirVec = {
  [0] = { x =  1, z =  0, name = "+x (east)"  },
  [1] = { x =  0, z =  1, name = "+z (south)" },
  [2] = { x = -1, z =  0, name = "-x (west)"  },
  [3] = { x =  0, z = -1, name = "-z (north)" },
}

local function turnTo(target)
  if target == facing then return end
  local diff = (target - facing) % 4
  if diff == 1 then
    turtle.turnRight()
  elseif diff == 2 then
    turtle.turnRight()
    turtle.turnRight()
  elseif diff == 3 then
    turtle.turnLeft()
  end
  facing = target
end

--==================================================================
-- GPS
--==================================================================

local function initGPS()
  local x, y, z = gps.locate(2, false)
  if not x then return false end

  pos.x, pos.y, pos.z = x, y, z

  -- Detect facing: move forward, compare GPS, move back
  local x2, _, z2 = gps.locate(2, false)
  if turtle.forward() then
    x2, _, z2 = gps.locate(2, false)
    turtle.back()
    if x2 then
      local dx, dz = x2 - x, z2 - z
      if math.abs(dx) >= math.abs(dz) then
        facing = dx > 0 and 0 or 2
      else
        facing = dz > 0 and 1 or 3
      end
    end
  end

  return true
end

local function resyncGPS()
  if not gpsMode then return end
  local x, y, z = gps.locate(2, false)
  if x then
    pos.x, pos.y, pos.z = x, y, z
  end
end

--==================================================================
-- Fuel
--==================================================================

local function fuelLevel()
  local level = turtle.getFuelLevel()
  if type(level) ~= "number" then return nil end
  return level
end

local function needsFuel()
  local level = fuelLevel()
  return level ~= nil and level == 0
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
-- Navigation: go to a position
-- Axis order: Y -> X -> Z so the turtle approaches from outside
-- the volume whenever possible. Handles negative coordinates.
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
  -- Try GPS first
  gpsMode = initGPS()

  if gpsMode then
    print(("GPS: at %d,%d,%d facing %s")
          :format(pos.x, pos.y, pos.z, dirVec[facing].name))
  else
    print("No GPS — relative mode, assuming (0,0,0) facing +x.")
  end

  -- Normalise corners (any mix of positive/negative)
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

  -- Save origin for return
  startPos  = { x = pos.x, y = pos.y, z = pos.z }
  startFace = facing

  -- Fuel estimate
  refuel()
  local level = fuelLevel()
  if level then
    local outbound = math.abs(minX - pos.x) + math.abs(minY - pos.y) + math.abs(minZ - pos.z)
    local endX, endY, endZ = maxX, maxY, maxZ
    if dims.x % 2 == 0 then endZ = minZ end
    local returnDist = math.abs(endX - startPos.x) + math.abs(endY - startPos.y) + math.abs(endZ - startPos.z)
    local miningMoves = dims.x * (dims.z - 1) + (dims.x - 1) + (dims.y - 1)
    local estFuel = outbound + miningMoves + returnDist
    if level < estFuel then
      print(("WARNING: fuel %d may be low (est. %d needed)."):format(level, estFuel))
    end
  end

  print(("Mining %d blocks (%dx%dx%d from %d,%d,%d to %d,%d,%d)...")
        :format(blocks, dims.x, dims.y, dims.z,
                minX, minY, minZ, maxX, maxY, maxZ))

  -- Go to bottom-front-left corner
  gotoPos({ x = minX, y = minY, z = minZ })

  -- Sweep: layer by layer (y), row by row (x), zigzag along z
  for y = minY, maxY do
    for x = minX, maxX do
      local rowIdx = x - minX

      if rowIdx % 2 == 0 then
        turnTo(1)  -- face +z
        while pos.z < maxZ do moveForward() end
      else
        turnTo(3)  -- face -z
        while pos.z > minZ do moveForward() end
      end

      if inventoryFull() then
        print("WARNING: inventory full — mined blocks will be lost")
      end

      if x < maxX then
        turnTo(0)
        moveForward()
      end
    end

    if y < maxY then
      moveUp()
    end
  end

  -- Return to start
  print("Mining complete. Returning to start...")
  if gpsMode then resyncGPS() end
  gotoPos(startPos)
  turnTo(startFace)
  if gpsMode then resyncGPS() end

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
