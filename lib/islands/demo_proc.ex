defmodule Islands.DemoProc do

"""
alias Islands.DemoProc
l = spawn(DemoProc, :loop, [])
Process.flag(:trap_exit, true)
Process.link(l)
send(l, "Hello")
Process.exit(l, :boom)
Process.alive?(l)

receive do
  m -> "Message: #{}"
  after 100 -> "nothing going on"
end

"""

  def loop() do
    receive do
      msg -> IO.puts "I have a message: #{msg}"
    end
    loop()
  end

end
