SCORE_TO_WIN = 4000
MAX_BET = 128

score = {
  single_one = 100,
  single_five = 50,
  three_of_kind = 100, -- times dice value
  three_of_kind_ones = 1000,
  four_or_more_of_kind = 0, -- double three of kind
  full_straight = 1600,
  partial_straight_1_5 = 500,
  partial_straight_2_6 = 750,
}

Player = {
  flag_skip = false,
  flag_bust = false,
  input = nil,
  bet = 0,
  total_score = 0,
  turn_score = 0,
  hand = {    
    [1] = {value = nil, hold = false, lock = false, flag_count = false},
    [2] = {value = nil, hold = false, lock = false, flag_count = false},
    [3] = {value = nil, hold = false, lock = false, flag_count = false},
    [4] = {value = nil, hold = false, lock = false, flag_count = false},
    [5] = {value = nil, hold = false, lock = false, flag_count = false},
    [6] = {value = nil, hold = false, lock = false, flag_count = false},
  },
  hold = {},
}
-- TODO: Make the function check if all 6 dice has been locked.
function Player:rollDice()
  -- local x = 1
  local rolls = {math.random(6),math.random(6),math.random(6),math.random(6),math.random(6),math.random(6)}
  -- print("Showing rolls")
  -- print(rolls[1],rolls[2],rolls[3],rolls[4],rolls[5],rolls[6])
  os.sleep(5)
  for k,v in ipairs(self.hand) do
    -- print(k,v)
    if self.hand[k].lock == false then -- If dice is not locked then roll a new value.
      self.hand[k].value = rolls[k]
      -- x = x + 1
    end
  end
  -- x = 0
end

function Player:printDice()
  for i,v in ipairs(self.hand) do
    if self.hand[i].lock == false then -- Print value of dice is not locked.
      print("Dice#"..i.." Value:"..self.hand[i].value.." Hold:"..tostring(self.hand[i].hold).." Lock:".. tostring(self.hand[i].lock))
    end
  end
  print("")
  print("On Hold")
  for i,v in ipairs(self.hand) do
    if self.hand[i].lock == true then -- Print value of dice is not locked.
      print("Dice#"..i.." Value:"..self.hand[i].value.." Hold:"..tostring(self.hand[i].hold).." Lock:".. tostring(self.hand[i].lock))
    end
  end
end

function sleep()
  os.sleep(.5)
end

function Player:checkState(state)
  local valid = false
  local logtable = {}
  -- I don't understand how this works, but it count's the number of times each diceValue is repeated.
  if state == "hold" then
    print("Checking holds")
    sleep()
    for i,v in pairs(self.hand) do
      if self.hand[i].hold == true then
        print(self.hand[i].value)
        local index = v.value
        logtable[index] = (logtable[index] or 0) + 1
      end
    end
  elseif state == "roll" then
    print("Checking rolls")
    sleep()
    for i,v in pairs(self.hand) do
      if self.hand[i].lock == false then
        print(self.hand[i].value)
        local index = v.value
        logtable[index] = (logtable[index] or 0) + 1
      end
    end
  end

  local count = countTable(logtable)
  if (count == 6) then
    print("Detected a 6 dice straight")
    valid = true
  elseif (count == 5) then
    if (logtable[1] == 1) and (logtable[5] == 5) then
      print("Detected a 5 dice straight (1 to 5)")
      valid = true
    elseif (logtable[1] == 2) and (logtable[5] == 6) then
      print("Detected a 5 dice straight (2 to 6)")
      valid = true
    end
  else
    for diceValue,match in pairs(logtable) do -- Check for valid match, return a
      print("diceValue: "..diceValue.."  match: "..match)
      if (match >= 3) then
        print("Detected a minimum of 3 of a kind")
        valid = true
      elseif (diceValue == 1 or diceValue == 5) then
        print("Detected a 1 or a 5")
        valid = true
      end
    end
  end
  local key = os.pullEvent("key")
  return valid
end

function Player:holdDice()
  local loop = true
  local count = 0
  while loop do
    refresh()
    print("Select a dice to hold or use 'roll' or 'rollSkip'")
    self:printDice()
    local input = io.read()
    local input_1 = tonumber(input)
    if input == "roll" then
      if count == 0 then
        print("Unable to roll, please select dice to hold")
      elseif (self:checkState("hold")) then
          print("Score tallied, you can roll again")
          local key = os.pullEvent("key")
          loop = false
      end
    elseif input == "rollSkip" then
      if count == 0 then
        print("Unable to skip, please select a dice to hold")
      elseif (self:checkState("hold")) then
        loop = false
        print("Score tallied, you end your turn")
        self.queue_skip = true
      end
    elseif (type(input_1) == "number" and input_1 >= 1 and input_1 <=6) then
      if self.hand[input_1].lock == true then
        print("That dice is locked! Please try again.")
      elseif (self.hand[input_1].hold == false) then
        self.hand[input_1].hold = true
        count = count + 1
      elseif (self.hand[input_1].hold == true) then
        self.hand[input_1].hold = false
        count = count - 1
      end
    elseif input == nil then
      print("Invalid input, please try again")
    end
  end

  for i,v in pairs(self.hand) do
    if self.hand[i].hold == true then
      self.hand[i].hold = false
      self.hand[i].lock = true
    end
  end
end

function countTable(table)
  local count = 0
  for i,v in pairs(table) do
    count = count + 1
  end
  return count
end

function refresh()
  term.clear()
  term.setCursorPos(1,1)
end

-- MAIN LINE --
print("Initializing")
p1 = Player
p2 = Player
repeat
  refresh()
  p1:rollDice()
  print("Done rolling")
  sleep()
  if p1:checkState("roll") then
    p1:printDice()
    p1:holdDice()
  else
    p1:printDice()
    print("Bust!")
    p1.flag_bust = true
  end
until (p1.flag_skip == true or p1.flag_bust == true)
print("Opponents Turn")