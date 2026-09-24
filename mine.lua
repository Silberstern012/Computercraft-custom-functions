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
--   The turtle auto-detects its position via gps.locate() and its
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
local facing     = 0  -- 0=+x(east), 1=+z(south), 2=-x(west), 3=-z(north)
local gpsMode    = false
local startPos   = { x = 0, y = 0, z = 0 }
local startFace  = 0

--==================================================================
-- Direction helpers
--
-- dirVec maps each facing to the world-space (or local-space) delta
-- produced by moving forward one block.
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
-- GPS initialisation
--==================================================================

-- Attempt to load the gps API
local function loadGPS()
  if package and package.loaded and package.loaded["gps"] then
    return package.loaded["gps"]
  end
  local ok, g = pcall(require, "gps")
  if ok then return g end
  return nil
end

-- Convert a GPS locate() result {x, y, z} to our pos table
local function gpsToPos(gpsResult)
  if not gpsResult then return nil end
  return { x = gpsResult[1], y = gpsResult[2], z = gpsResult[3] }
end

-- Determine which facing the turtle has by moving forward one block,
-- comparing GPS before/after, then moving back.
local function facingFromGPS(gps)
  local p1 = gps.locate(2, false)
  if not p1 then return nil, nil end

  -- Try moving forward; dig if needed (we'll fill the hole back on return)
  local dug = false
  if not turtle.forward() then
    if turtle.detect() then
      turtle.dig()
      dug = true
    end
    if not turtle.forward() then
      return nil, gpsToPos(p1)
    end
  end

  local p2 = gps.locate(2, false)
  turtle.back()

  if not p2 then return nil, gpsToPos(p1) end

  local dx, dz = p2[1] - p1[1], p2[3] - p1[3]
  local f
  if math.abs(dx) >= math.abs(dz) then
    f = dx > 0 and 0 or 2
  else
    f = dz > 0 and 1 or 3
  end

  return f, gpsToPos(p1)
end

-- Initialise position and facing from GPS. Returns true on success.
local function initGPS()
  local gps = loadGPS()
  if not gps then
    return false
  end

  local f, p = facingFromGPS(gps)
  if p then
    pos = p
  end

  if f then
    facing = f
    return true
  end

  -- We got a position but couldn't determine facing via movement.
  -- Still use the GPS position but default facing to 0.
  if p then
    return true
  end

  return false
end

-- Re-sync pos from GPS (call after the turtle has returned to a known spot)
local function resyncGPS()
  if not gpsMode then return end
  local gps = loadGPS()
  if not gps then return end
  local p = gps.locate(2, false)
  if p then
    pos = gpsToPos(p)
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
-- Navigation: go to an absolute (or relative) position
--
-- Axis order: Y → X → Z so the turtle approaches the mining corner
-- from outside the volume whenever possible.
-- Works for any mix of positive and negative coordinates.
--==================================================================

local function gotoPos(target)
  -- Y axis
  while pos.y < target.y do moveUp()   end
  while pos.y > target.y do moveDown() end

  -- X axis
  if pos.x < target.x then
    turnTo(0)
    while pos.x < target.x do moveForward() end
  elseif pos.x > target.x then
    turnTo(2)
    while pos.x > target.x do moveForward() end
  end

  -- Z axis
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
  -- Initialise position and facing from GPS if available
  gpsMode = initGPS()

  if gpsMode then
    print(("GPS mode: position %d,%d,%d facing %s")
          :format(pos.x, pos.y, pos.z, dirVec[facing].name))
  else
    print("No GPS available — using relative coordinates.")
    print("  Assuming start at (0,0,0) facing +x (forward).")
  end

  -- Normalise corners (works for any mix of positive/negative coords)
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

  -- Fuel estimate
  refuel()
  local level = fuelLevel()
  if level then
    local outbound = math.abs(minX - pos.x) + math.abs(minY - pos.y) + math.abs(minZ - pos.z)
    -- Conservative: turtle ends at farthest corner from start
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

  -- Navigate to the bottom-front-left corner
  gotoPos({ x = minX, y = minY, z = minZ })

  -- Sweep layer by layer (y), row by row (x), zigzag along z
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

      -- Step to the next x row
      if x < maxX then
        turnTo(0)
        moveForward()
      end
    end

    -- Ascend to next layer
    if y < maxY then
      moveUp()
    end
  end

  -- Return to start
  print("Mining complete. Returning to start...")
  if gpsMode then resyncGPS() end
  gotoPos(startPos)
  turnTo(startFace)

  -- Final GPS sync to confirm we're home
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
