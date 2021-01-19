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

function Player:rollDice()
  local count = 0
  for i,v in ipairs(self.hand) do
    if self.hand[i].lock == true then -- Print value of dice is not locked.
      count = count + 1
    end
  end
  if count == 6 then
    for i,v in ipairs(self.hand) do
      self.hand[i].lock = true
    end
    count = 0
  end
  for k,v in ipairs(self.hand) do
    if self.hand[k].lock == false then -- If dice is not locked then roll a new value.
      self.hand[k].value = math.random(6)
    end
  end
end

function Player:printDice()
  for i,v in ipairs(self.hand) do
    if self.hand[i].lock == false then -- Print value of dice is not locked.
      print("Dice#"..i.." Value:"..self.hand[i].value.." Hold:"..tostring(self.hand[i].hold).." Lock:".. tostring(self.hand[i].lock))
    end
  end
  print("On Hold")
  for i,v in ipairs(self.hand) do
    if self.hand[i].lock == true then -- Print value of dice is not locked.
      print("Dice#"..i.." Value:"..self.hand[i].value.." Hold:"..tostring(self.hand[i].hold).." Lock:".. tostring(self.hand[i].lock))
    end
  end
end

function sleep()
  os.sleep(2)
end

function Player:checkState(state)
  local valid = false
  local logtable = {}
  -- I don't understand how this works, but it count's the number of times each diceValue is repeated.
  if state == "hold" then
    for i,v in pairs(self.hand) do
      if self.hand[i].hold == true then
        -- print(self.hand[i].value)
        local index = v.value
        logtable[index] = (logtable[index] or 0) + 1
      end
    end
  elseif state == "roll" then
    for i,v in pairs(self.hand) do
      if self.hand[i].lock == false then
        -- print(self.hand[i].value)
        local index = v.value
        logtable[index] = (logtable[index] or 0) + 1
      end
    end
  end

  local count = countTable(logtable)
  if (count == 6) then
    --print("Detected a 6 dice straight")
    valid = true
  elseif (count == 5) then
    if (logtable[1] == 1) and (logtable[5] == 5) then
      --print("Detected a 5 dice straight (1 to 5)")
      valid = true
    elseif (logtable[1] == 2) and (logtable[5] == 6) then
      --print("Detected a 5 dice straight (2 to 6)")
      valid = true
    end
  else
    for diceValue,match in pairs(logtable) do -- Check for valid match, return a
      --print("diceValue: "..diceValue.."  match: "..match)
      if (match >= 3) then
        --print("Detected a minimum of 3 of a kind")
        valid = true
      elseif (diceValue == 1 or diceValue == 5) then
        --print("Detected a 1 or a 5")
        valid = true
      end
    end
  end
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
        print("unable to skip, please select a dice to hold")
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

while (p1.flag_skip == false or p1.flag_bust == false) do
  refresh()
  p1:rollDice()
  p1:printDice()
  if p1:checkState("roll") then
    p1:holdDice()
  else
    print("Bust!")
  end
  else
    p1.turn_score = 0
    p1.flag_bust = true
    print("Bust!")
  end
end

-- function printTable(player)
--   local logtable
--   for i,v in ipairs(player) do
--     print("Dice#"..i.." : "..player[i].value.." : "..tostring(player[i].hold))
--   end
--   -- for i,v in ipairs(player) do
--   --   if player[i].hold == false then
--   --     print("Dice#"..i.." : "..player[i].value.." : "..tostring(player[i].hold))
--   --   else 
--   --     local index = i
--   --     logtable[index] = (logtable[index] or 0) + 1
--   --   end
--   -- end
--   -- for i,v in ipairs
-- end  


-- function rollDice(player)
--   for k,v in ipairs(player) do
--     if player[k].hold == false then
--       player[k].value = math.random(6)
--     end
--   end
--   printTable(player)
-- end

-- function validDice(player, type)
--   local logtable = {}
--   local bool
--   for i,v in pairs(player) do
--     if type == "roll" then
--       bool = false
--     elseif type == "hold" then
--       bool = true
--     else
--       print("error")
--     end
--     if player[i].hold == bool then
--       local index = v.value
--       logtable[index] = (logtable[index] or 0) + 1
--     end
--   end
--   for diceValue,match in pairs(logtable) do
--     if diceValue == 1 or diceValue == 5 or match >= 3 then
--       return true
--     end
--   end
--   if (logtable[1] == 1 and logtable[1] == 2 and logtable[1] == 3 and logtable[1] == 4 and logtable[1] == 5) or ((logtable[1] == 2 and logtable[1] == 3 and logtable[1] == 4 and logtable[1] == 5 and logtable[1] == 6)) then
--     return true
--   end
--   return false
-- end

-- function holdDice(player)
--   local loop = true
--   while loop do
--     local i = 0
--     term.clear()
--     term.setCursorPos(1,1)
--     print("Select dice")
--     printTable(player)
--     local input = io.read()
--     i = tonumber(input)
--     if type(i) == "number" then
--       if i >= 1 and i <=6 then
--         if player[i].hold == false then
--           player[i].hold = true
--         elseif player[i].hold == true then
--           player[i].hold = false
--         else
--           error("idk how you got here")
--         end
--       end
--     elseif type(input) == "string" then
--       if input == "roll" then
--         if validDice(player,"hold") then
--           loop = false
--         else
--           print("Invalid Input")
--         end
--       else
--         print("Invalid Input")
--         local key = os.pullEvent("key")
--       end
--     else
--       error("idk how u got here")
--     end
--   end
-- end


-- -- MAIN CODE --
-- local turnloop = true
-- local turn = p1 -- User gets to roll first
-- function placeBet(player)
-- refresh()
-- print("You have a balance of: ".. p1_balance)
-- print("Enter bet: ")
-- while p1_bet == nil do
--   local input = io.read()
--   p1_bet = tonumber(input)
--   if type(p1_bet) == "number" then
--     p1_bet = input
--   else
--     print("Please enter a valid number")
--   end
-- end

-- while turnloop do
--   refresh()
--   for i,v in pairs(turn) do
--     if turn[i].hold == true then
--       turnloop = false -- End turn
--     end
--   end

--   rollDice(turn)
--   if validDice(turn,"roll") then
--     holdDice(turn)
--   else
--     turnloop = false -- End turn
--     print("Bust!")
--   end
-- end

-- -- calculateScore(p1)
-- print("Terminated")