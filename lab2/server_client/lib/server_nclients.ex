defmodule SC do

  def main do
    IO.puts "Hello World"

    server = spawn(Server, :start, [])

    Enum.map(0..5, fn(_) ->
      client = spawn(Client, :start, [])
      send client, { :bind, server }
    end)
  end

  def loop do
    loop
  end

  def start(_type, _args) do
    main()
    loop()
  end

end # module -----------------------
