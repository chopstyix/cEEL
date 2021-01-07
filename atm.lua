localdebug = 0

exchange_rate = 2 
exchange_item = "minecraft:diamond"

side = "drive_1"
card_fileName = "disk/key"
database_fileName ="card_database"

card_present = false

monitor = peripheral.wrap("left")

-- Overwrite variables if debugging
if localdebug == 1 then
  card_name = "Bromanov_'s Card - 1000$nad" -- Debug
  card_id = 1
end

function findCharKeyIndex(charKey)
  local i = 0
  repeat
    i = i + 1
    local char = string.sub(card_name,i,i)
  until (char == charKey)
  return i
end

function getCardInfo(x)
  local v = string.len(card_name)
  local charKey = ""
  local y = 0
  local output = ""

  -- Set charKey
  if x == "user" then
    local i = findCharKeyIndex("'")
    i = i - 1
    output = string.sub(card_name,1,i)
    return output
  elseif x == "value" then
    local i = findCharKeyIndex("-")
    local i2 = findCharKeyIndex("$")
    i = i + 2
    i2 = i2 - 1
    output = string.sub(card_name,i,i2)
    return output
  elseif x == "key" then
    local file = fs.open(card_fileName,"r")
    output = tostring((file.readLine()))
    file.close()
    return output
  else
    error("Please specify getCardInfo argument")
  end
end

-- -- function createNewCard()
-- --   local file = fs.open(database_fileName,"w")

--   -- Check if user exists in database
--   -- If true exists, create new card and reassign disk ID
--   -- If false, create new card and add user to database and assign disk ID

function makeKey()
  local key = 0
  local v = string.len(card_name)
  local value = getCardInfo("value")
  for i=1,v do
    local test = string.byte(card_name,i)
    key = key + test
    key = math.floor((4.20 + value * key)  / (69 + card_id)) -- Super secret hash
  end
  return tostring(key)
end

function writeKey()
  local key = makeKey()
  local file
  if fs.exists(card_fileName) then
    file = fs.delete(card_fileName)
  end
  file = fs.open(card_fileName,"w")
  file.writeLine(key)
  file.close()
end

-- Security Check
function compareKey()
  expectedKey = makeKey()
  file = fs.open(card_fileName,"r")
  cardKey = tostring((file.readLine()))
  file.close()
  if expectedKey == cardKey then
    print("Card Match!")
    return true
  else
    print("Error!")
    return false
  end
end

function mathFunds(operator)
  local value_before = tonumber(getCardInfo("value"))
  local value_input = 0
  local value_after = 0
  if operator == "add" then
    print("Add number:")
  elseif operator == "subtract" then
    print("Subtract number:")
  else
    print("Invalid argument!")
  end
  value_input = tonumber(io.read())
  if operator == "add" then
    value_after = value_before + value_input
  elseif operator == "subtract" then
    value_after = value_before - value_input
  else
    print("Invalid argument!")
  end
  card_name = user.."'s Card - "..value_after.."$nad"
  writeKey()
  return card_name
end

local loop = true
local f = 
{
  ["1"] = function() print("Your balance is: "..value.."$nad") os.sleep(3) end, -- Check Balance
  ["2"] = function() mathFunds("add") end, -- Add Funds
  ["3"] = function() mathFunds("subtract") end, -- Withdraw Funds
  ["4"] = function() 
    print("Card ejected! Thank you for choosing $nad Inc!") 
    disk.eject(side) 
    loop = false 
  end -- Exit
}

-- Run Loop Display
print("Insert card")
while true do
  if localdebug == 1 then
    print("Card detected")
    break
  else
    local event, side = os.pullEvent("disk")
    if event == "disk" then
      print("Disk inserted")
      break
    end
  end
end

-- Parse through card data and fill out variables
card_name = disk.getLabel(side)
drive = disk.getMountPath(side)
card_id = disk.getID(side)
user = getCardInfo("user")
value = getCardInfo("value")
key = getCardInfo("key")

print("Verifying card...")
writeKey()
os.sleep(3)
-- Pass disk check
if compareKey() then
  print("Success!")
  os.sleep(1)
else
  print("Failed check, ending program.")
  os.sleep(1)
  return
end

while loop == true do
  user = getCardInfo("user")
  value = getCardInfo("value")
  key = getCardInfo("key")
  term.clear()
  term.setCursorPos(1,1)
  print("Hello "..user)
  print("Your balance is: "..value.."$nad")
  print("Key: "..key)
  print("Select an input")
  print("[1] = Check Balance")
  print("[2] = Add Funds")
  print("[3] = Withdraw Funds")
  print("[4] = Eject card")
  local user_input = io.read()
  local func = f[user_input]
  if (func) then
    func()
  else
    print("Default case!")
  end
end


