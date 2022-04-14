require "Object"

RingBuffer = Object:new{}

function RingBuffer:init(capacity)
  self.buf = {}
  self.head = 1
  self.tail = 1

  self.capacity = capacity
end

-- Adds an item to the end of the buffer, replacing the current last item if the
-- buffer is full
function RingBuffer:Append(obj)
  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s):Append:\n",
  --   self:Size(), self.head, self.tail, self.capacity))
  -- console.print(obj)

  -- advance the tail if we're not yet full
  if (self:Size() > 0) and not (self:Size() == self.capacity) then
    self.tail = self:adv(self.tail)
  end

  local popped = self.buf[self.tail]
  self.buf[self.tail] = obj

  if popped then
    -- io.write(string.format("RingBuffer:Append -- Popped %s\n", self.tail))
    -- console.print(popped)
  end

  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s):Appended @ %s\n",
  --   self:Size(), self.head, self.tail, self.capacity, self.tail))

  return popped
end

-- Adds an item to the front of the buffer, replacing the current last item if 
-- the buffer is full
function RingBuffer:Prepend(obj)
  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s):Prepend\n",
  --   self:Size(), self.head, self.tail, self.capacity))
  -- console.print(obj)

  local popped = nil

  -- unless we don't have an element yet move the head back to the new position
  if self:Size() > 0 then
    self.head = self:prev(self.head)

    -- we need to pop the old tail element
    if self.head == self.tail then
      popped = self.buf[self.tail]
      -- io.write(string.format("RingBuffer:v -- Popped %s\n", self.tail))
      -- console.print(popped)

      self.tail = self:prev(self.tail)
    end
  end

  self.buf[self.head] = obj

  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s):Prepended @ %s\n",
  --   self:Size(), self.head, self.tail, self.capacity, self.head))
  return popped
end

function RingBuffer:Size()
  local s = 0
  -- If the head/tail point to the same object the buffer either has one or
  -- zero elements depending on the state of the first object

  local head_element = self.buf[self.head] and 1 or 0
  if self.tail < self.head then
    s = (self.capacity + self.tail) - self.head + head_element
  else
    s = self.tail - self.head + head_element
  end
  return s
end

function RingBuffer:prev(i)
  local ip = i - 1
  if ip == 0 then ip = self.capacity end
  return ip
end

function RingBuffer:adv(i)
  local ia = i + 1
  if i == self.capacity then ia = 1 end
  return ia
end

function RingBuffer:advn(i, n)
  n = n or 0
  local ia = i
  for i=1, n do
    ia = self:adv(ia)
  end
  return ia
end

function RingBuffer:Pop()
  if self:Size() > 0 then
    local popped = self.buf[self.tail]
    self.buf[self.tail] = nil
    if not (self.head == self.tail) then
      self.tail = self:prev(self.tail)
    end
    return popped
  end
  return nil
end

function RingBuffer:PopFront()
  if self:Size() > 0 then
    local popped = self.buf[self.head]
    self.buf[self.head] = nil
    if not (self.head == self.tail) then
      self.head = self:adv(self.head)
    end
    return popped
  end
  return nil
end

function RingBuffer:Peek()
  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s) Peek\n",
  --   self:Size(), self.head, self.tail, self.capacity, i, ip))
  return self.buf[self.tail]
end

function RingBuffer:PeekFront()
  -- io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s) PeekFront\n",
  --   self:Size(), self.head, self.tail, self.capacity, i, ip))
  return self.buf[self.head]
end

function RingBuffer:Print()
  io.write(string.format("RingBuffer(S=%s, h=%s, t=%s, c=%s)\n",
    self:Size(), self.head, self.tail, self.capacity, i, ip))

  for i = 1, self:Size() do
    local index = self:advn(self.head, i - 1)

    io.write(string.format("\tItem %s (index=%s) = %s\n", 
      i, index, self.buf[index]))
  end
end

function RingBuffer:Drain()
  self.buf = {}
  self.head = 1
  self.tail = 1
end