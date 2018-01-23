defmodule SC do

  def main do
    IO.puts "Hello World"

    client = spawn(Client, :start, [])
    server = spawn(Server, :start, [])

    send client, { :bind, server }
    send server, { :bind, client }
  end

  def loop do
    loop
  end

  def start(_type, _args) do
    main()
    loop()
  end

end # module -----------------------
