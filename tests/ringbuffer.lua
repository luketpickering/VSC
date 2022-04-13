require "tests/Test"

require "utils/ringbuffer"

Test.RingBufferTests = function()

  local rb = RingBuffer:new{}
  local cap = 3
  rb:init(cap)

  io.write(string.format("adv(cap = %s) %s = %s\n",cap, 1, rb:adv(1)))
  io.write(string.format("adv(cap = %s) %s = %s\n",cap, 2, rb:adv(2)))
  io.write(string.format("adv(cap = %s) %s = %s\n",cap, 3, rb:adv(3)))

  io.write(string.format("advn(n = %s, cap = %s) %s = %s\n",0,cap, 1, rb:advn(1,0)))
  io.write(string.format("advn(n = %s, cap = %s) %s = %s\n",1,cap, 1, rb:advn(1,1)))
  io.write(string.format("advn(n = %s, cap = %s) %s = %s\n",2,cap, 1, rb:advn(1,2)))
  io.write(string.format("advn(n = %s, cap = %s) %s = %s\n",3,cap, 1, rb:advn(1,3)))

  io.write(string.format("prev(cap = %s) %s = %s\n",cap, 1, rb:prev(1)))
  io.write(string.format("prev(cap = %s) %s = %s\n",cap, 2, rb:prev(2)))
  io.write(string.format("prev(cap = %s) %s = %s\n",cap, 3, rb:prev(3)))

  io.write("\n\n---------------------------------------------\n\n")

  for i=1,6 do
    local popped = rb:Append(i)
    io.write(string.format("Append %s: Peek = %s\n",i,rb:Peek()))
    io.write(string.format("Append %s: PeekFront = %s\n",i,rb:PeekFront()))
    if popped then
      io.write(string.format("Appending popped = %s\n",popped))
    end
  end

  rb:Print()
  rb:Drain()

  io.write("\n\n---------------------------------------------\n\n")

  rb:Print()

  for i=1,5 do
    local popped = rb:Prepend(i)
    io.write(string.format("Prepend %s: Peek = %s\n",i,rb:Peek()))
    io.write(string.format("Prepend %s: PeekFront = %s\n",i,rb:PeekFront()))
    if popped then
      io.write(string.format("Appending popped = %s\n",popped))
    end
  end

  rb:Print()

  io.write("\n\n---------------------------------------------\n\n")

  rb:Print()
  io.write(string.format("Pop = %s\n",rb:Pop()))
  rb:Print()
  io.write(string.format("Pop = %s\n",rb:Pop()))
  rb:Print()
  io.write(string.format("Pop = %s\n",rb:Pop()))
  rb:Print()

  io.write("\n\n---------------------------------------------\n\n")
  rb:Drain()

  for i=1,5 do
    rb:Prepend(i)
  end

  rb:Print()
  io.write(string.format("PopFront = %s\n",rb:PopFront()))
  rb:Print()
  io.write(string.format("PopFront = %s\n",rb:PopFront()))
  rb:Print()
  io.write(string.format("PopFront = %s\n",rb:PopFront()))
  rb:Print()
end