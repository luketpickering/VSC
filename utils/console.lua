console = {
  print = function(t, i)
    i = i and i or ""

    if type(t) == "table" then
      io.write("table = {\n")

      local ti = i.."\t"

      for k,v in pairs(t) do
        io.write(string.format("%s%s: ", ti, k))
        console.print(v, ti)
      end

      io.write(string.format("%s}\n",i))
    else
      io.write(string.format("%s\n", t))
    end
  end
}