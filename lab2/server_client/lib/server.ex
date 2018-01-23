defmodule Server do

  def interact(client) do
    receive do
      { :circle, client, radius } ->
        send client, { :result, 3.14159 * radius * radius }
      { :square, client, side } ->
        send client, { :result, side * side }
    end
    interact(client)
  end

  def serve() do
    receive do
      { :bind, client } ->
        IO.puts ["Server > ", inspect client]

        interact(client)
    end

    serve()
  end

  def start do
    IO.puts "Server started"

    serve()
  end

end # module -----------------------
